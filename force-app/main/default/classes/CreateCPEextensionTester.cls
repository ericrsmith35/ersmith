// Project: Create new CPE to add to a Case as an Asset       
// Created By: Eric Smith - GWI - 12/2015						
// VisualForce Page: CreateCPE         		                
// Description: Standard Asset Controller Extension                       
// Classes Utilized: CreateCPEextension					   	
// Test Classes: CreateCPEextensionTester												

@isTest
private class CreateCPEextensionTester {
    @isTest public static void testCreateCPEextension() {
/* Removed in Assets Phase 2 - 11/17        
        try {
            // Assign variables & Create Records
            Id aid;
            Id cnid;
            Id cid;
            Id pid;
            
            Account a;
            a = new Account(Name='TestAccount');
            insert a;
            aid = a.Id;
            
            Contact cn;
            cn = new Contact(LastName='TestContact', Account=a);
            insert cn;
            cnid = cn.Id;
            
			Product2 p;
            p = new Product2(Name='TestProduct', Asset_Type__c='CPE');
			insert p;
            pid = p.Id;
            
            Asset ass;
            ass = new Asset(Name='TestAsset', AccountId=aid, Product2Id=pid);
            insert ass;
            
            Service_Address__c sa;
            sa = new Service_Address__c(Name='TestServiceAddress', Account__c=aid );
            insert sa;
            
            Case cRecord;
            cRecord = new Case(AccountId=aid, Service_Address__c=sa.Id);
            insert cRecord;
            Case[] c = [SELECT Id,AccountId,Service_Address__c FROM Case];
            cid = c[0].Id;
            
            CaseAsset__c ca;
            ca = new CaseAsset__c(AccountLookup__c=aid, Asset__c=ass.Id, Case__c=cid, SrvAdr__c=sa.Id);
            insert ca;
            
            // Test Standard Operation
            PageReference caPage;
            caPage = new PageReference('/apex/CreateCPE?cid='+cid);
            Test.setCurrentPage(caPage);
            
            Test.startTest(); 
            
            CreateCPEextension cpeExt = new CreateCPEextension(new ApexPages.StandardController(new asset()));
            
            cpeExt.mySave();
            system.assertEquals(c[0].Id, ca.Case__c);
            //system.assertEquals(cpeExt.ca.Case__c, cid);

            cpeExt.myCancel();
            
            // Test Error with invalid CaseAsset Record
            PageReference errPage;
            errPage = new PageReference('/apex/CreateCPE?cid='+cid);
            Test.setCurrentPage(errPage);
            
            CreateCPEextension errExt = new CreateCPEextension(new ApexPages.StandardController(new asset()));
            errExt.cpe.AccountId=null;
            errExt.mySave();
            
            //Check Error Messages
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            boolean err = false;
            //Loop through any messages to see if the expected error was caught
            for(ApexPages.Message msg:msgs){
//              if(msg.getDetail().contains('asset must have account')) err = true;
                if(msg.getDetail().contains('asset needs an account')) err = true;   // Winter '18             
            }
            system.assert(err);                 
            
            Test.stopTest();
            
        } catch (Exception e) {
            System.debug('Unwanted Excpetion Caught: ' + e.getMessage());
        }
*/        
    }
    
}