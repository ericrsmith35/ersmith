/*
** Class:  CaseHelper
** Created by OpFocus on Nov 23, 2015
** Description: Helper methods for the Case object
**   setDefaultEntitlmentFromAccount - When a case is created, get the Account's Default Entitlement and assign it

**   +caseOpenCloseEmailTask = When a case is opened or closed, capture email alert body and store in task
*/  
public without sharing class CaseHelper {
    
    public static List<Case> setDefaultEntitlmentFromAccount(List<Case> lstCasesToUpdate){
        // Set up collections and data
        List<Id> lstAccountIds = new List<Id>();
        Map<Id, Entitlement> mapEntitlementByAccountId = new Map<Id, Entitlement>();
        Id defaultRecordTypeId = AccountHelper.getRecordTypeIdByRecordTypeName(AccountHelper.DefaultEntitlementRecordTypeName);
        
        for(Case c : lstCasesToUpdate){
            lstAccountIds.add(c.AccountId);
        }
        
        // Get related entitlements for Account 
        List<Entitlement> lstEntitlments = new List<Entitlement>();
        try{
            lstEntitlments = [Select Id, Name, AccountId, StartDate from Entitlement where AccountId in :lstAccountIds and RecordTypeId = :defaultRecordTypeId];
        }catch(Exception e){}
        for(Entitlement e : lstEntitlments){
            mapEntitlementByAccountId.put(e.AccountId, e);
        }
        
        //Now set the Entitlment on all the new cases
        for(Case c : lstCasesToUpdate){
            Entitlement currentEntitlement = mapEntitlementByAccountId.get(c.AccountId);
            if(currentEntitlement != null){
                c.EntitlementId = currentEntitlement.Id;
                c.SlaStartDate = currentEntitlement.StartDate;
            }
        }
        
        return lstCasesToUpdate;
    }
    
    private static Id closedCaseEmail = [Select Id from EmailTemplate where DeveloperName = 'Case_Closed_Template'].Id;
    private static Id openCaseEmail = [Select Id from EmailTemplate where DeveloperName = 'New_Case_Template'].Id;
    
    // ERS 2/6/18 - only process Support Trouble Cases
    //private static Id supportTroubleTypeId = [Select Id from RecordType where Name = 'Support Trouble'].Id;
    private static Id supportTroubleTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support Trouble').getRecordTypeId();
    
    public static void caseOpenCloseEmailTask(){
        Set<Id> setContactIds = new Set<Id>();
        Set<Id> setOwnerIds = new Set<Id>();
        for(Case currentCase :(Case[])Trigger.new){
            
            // ERS 2/6/18 - only process Support Trouble Cases
            if (currentCase.RecordTypeId == supportTroubleTypeId){
                
                if(Trigger.isUpdate){
                    Case oldCase = (Case)Trigger.oldMap.get(currentCase.Id);
                    if(currentCase.IsClosed && !oldCase.IsClosed){
                        setContactIds.add(currentCase.ContactId);
                    }
                }
                if(Trigger.isInsert){
                    if(currentCase.Origin != 'Email'){
                        setContactIds.add(currentCase.ContactId);
                        setOwnerIds.add(currentCase.OwnerId);
                    }
                }
            }
        }
        
        Map<Id,Contact> mapContacts = new Map<Id,Contact>();
        if(!setContactIds.isEmpty()){
            mapContacts.putAll([Select Id, Email, IsEmailBounced from Contact where Id in :setContactIds]);
        }
        
        Map<Id,User> mapOwners = new Map<Id,User>();
        if(!setOwnerIds.isEmpty()){
            mapOwners.putAll([Select Id, UserType from User where Id in :setOwnerIds]);
        }
        
        List<Contact> lstTempEmailUpdates = new List<Contact>();
        List<Messaging.SingleEmailMessage> lstMail = new List<Messaging.SingleEmailMessage>();
        for(Case currentCase :(Case[])Trigger.new){
            
            // ERS 2/6/18 - only process Support Trouble Cases
            if (currentCase.RecordTypeId == supportTroubleTypeId){
                
                if(Trigger.isUpdate){
                    Case oldCase = (Case)Trigger.oldMap.get(currentCase.Id);
                    Contact c = mapContacts.get(currentCase.ContactId);
                    if(currentCase.IsClosed && !oldCase.IsClosed && c != null){
                        String toEmail;

                        // OpFocus 9.5.2018 - ignore if email is bounced
                        if(c.IsEmailBounced){
                            continue;
                        }
                        if(c.Email == null || c.Email == ''){
                            toEmail = 'no_email_provided@opfocus.com';
                            lstTempEmailUpdates.add(new Contact(Id=c.Id,Email=toEmail));
                        }
                        else{
                            toEmail = c.Email;
                        }
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new String[] {toEmail});
                        mail.setWhatId(currentCase.Id);
                        mail.setTemplateId(closedCaseEmail);
                        mail.setTargetObjectId(currentCase.ContactId);
                        lstMail.add(mail);
                    }
                }
                if(Trigger.isInsert){
                    User owner = mapOwners.get(currentCase.OwnerId);
                    Contact c = mapContacts.get(currentCase.ContactId);
                    //
                    if(currentCase.Origin != 'Email' && c != null){
                        if(currentCase.OwnerId.getSObjectType() != Group.SObjectType){
                            if(owner.UserType == 'PowerPartner'){
                                continue;
                            }
                        }
                        String toEmail;
                        if(c.Email == null || c.Email == ''){
                            toEmail = 'no_email_provided@opfocus.com';
                            lstTempEmailUpdates.add(new Contact(Id=c.Id,Email=toEmail));
                        }
                        else{
                            toEmail = c.Email;
                        }
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new String[] {toEmail});
                        mail.setWhatId(currentCase.Id);
                        mail.setTemplateId(openCaseEmail);
                        mail.setTargetObjectId(currentCase.ContactId);
                        lstMail.add(mail);
                    }
                }
            }
        }
        
        if(!lstMail.isEmpty()){
            SavePoint sp = Database.setSavePoint();
            if(!lstTempEmailUpdates.isEmpty()){
                update lstTempEmailUpdates;
            }
            try{
                Messaging.sendEmail(lstMail);
            }
            catch(Exception e){
                Database.rollback(sp); 
                return;
            }
            Database.rollback(sp);
            
            List<Task> lstNewTasks = new List<Task>();
            for(Messaging.SingleEmailMessage m :lstMail){
                Task t = new Task();
                t.WhatId = m.getWhatId();
                t.Status = 'Completed';
                t.Type = 'Email';
                t.Subject = m.getSubject();
                Boolean doNotSendEmail = ((Case)Trigger.newMap.get(m.getWhatId())).Do_not_send_Close_Case_Email__c;
                if(doNotSendEmail){
                    t.Subject += ' (Do not send email)';
                }
                t.Description = 'Sent to: ' + m.getToAddresses() + 
                    (doNotSendEmail?'\n\n***THIS EMAIL WAS NOT SENT OUT':'') +
                    '\n\n' +m.getPlainTextBody();
                t.ActivityDate = System.today();
                lstNewTasks.add(t);
            }
            
            insert lstNewTasks;
        }
    }


    public class E2CException extends Exception{}

    private static List<Case> casesToDelete = new List<Case>();
    private static Savepoint sp;

    public static void preventE2CLoop(){
        sp = Database.setSavePoint();
        try{
            Set<String> emails = new Set<String>();
            Auto_Reply_Matcher__mdt[] lstMatchers = [Select MasterLabel from Auto_Reply_Matcher__mdt];

            for(Case c : (Case[]) Trigger.new){
                ltngfw.Log.log(JSON.serializePretty(c));
                System.debug(JSON.serializePretty(c));
                if(c.SuppliedEmail != null && c.Origin == 'Email' && c.Subject != null){
                    for(Auto_Reply_Matcher__mdt m : lstMatchers){
                        if(c.Subject.containsIgnoreCase(m.MasterLabel)){
                            emails.add(c.SuppliedEmail);
                        }
                    }
                }
            }


            Map<String,E2C_Rejected_Email__c> emailToReject = new Map<String,E2C_Rejected_Email__c>();
            E2C_Rejected_Email__c[] lstR = [Select Id, From__c from E2C_Rejected_Email__c where From__c in :emails and CreatedDate = TODAY];
            for(E2C_Rejected_Email__c re : lstR){
                emailToReject.put(re.From__c, re);
            }
            ltngfw.Log.log('emailToReject:\n' + JSON.serializePretty(emailToReject));
            System.debug('emailToReject:\n' + JSON.serializePretty(emailToReject));


            List<E2C_Rejected_Email__c> lstRejected = new List<E2C_Rejected_Email__c>();
            try{
                Boolean throwError = false;
                for(Case c : (Case[]) Trigger.new){
                    if(c.SuppliedEmail != null && c.Origin == 'Email' && c.Subject != null){
                        for(Auto_Reply_Matcher__mdt m : lstMatchers){
                            ltngfw.Log.log(m.MasterLabel);
                            ltngfw.Log.log('matches? ' + c.Subject.containsIgnoreCase(m.MasterLabel));
                            System.debug(m.MasterLabel);
                            System.debug('matches? ' + c.Subject.containsIgnoreCase(m.MasterLabel));
                            if(c.Subject.containsIgnoreCase(m.MasterLabel)){
                                if(!emailToReject.containsKey(c.SuppliedEmail)){
                                    E2C_Rejected_Email__c re = new E2C_Rejected_Email__c();
                                    re.Body__c = c.Description;
                                    re.From__c = c.SuppliedEmail;
                                    re.Subject__c = c.Subject;
                                    ltngfw.Log.log(JSON.serializePretty(re));
                                    lstRejected.add(re);
                                }
                                c.E2C_Loop__c = true;
                                throwError = true;
                            }
                        }
                    }
                }
                ltngfw.Log.log('throeError: ' + throwError);
                System.debug('throeError: ' + throwError);
                
                if(throwError){
                    ltngfw.Log.log('lstRejected\n' + JSON.serializePretty(lstRejected));
                    //System.debug('lstRejected\n' + JSON.serializePretty(lstRejected));
                    insert lstRejected;
                    System.debug('lstRejected\n' + JSON.serializePretty(lstRejected));
                }
            }

            catch(Exception ex){
                System.debug(ex.getMessage() + ' :: ' + ex.getStackTraceString());
                ltngfw.Log.notify('Testing','E2C');
            }
        }
        catch(Exception e){
            System.debug(e.getMessage() + ' :: ' + e.getStackTraceString());
            ltngfw.Log.notify(e,'CaseHelper');
        }
        
    }

    public static void deleteE2CCase(){
        List<Case> delCaseIds = new List<Case>();
        for(Case c :(Case[]) Trigger.new){
            if(c.E2C_Loop__c){
                delCaseIds.add(c);
            }
        }
        deleteFuture(JSON.serialize(delCaseIds));
    }

    @future 
    private static void deleteFuture(string casejson){
        delete (Case[])JSON.deserialize(casejson, List<Case>.class);
    }
    
}