/*
** Class:  AccountHelper
** Created by OpFocus on Nov 23, 2015
** Description: Helper methods related to Account
**   + CreateDefaultEntitlement - When a Account is created we want to create an Entitlement for it.  
**         Returns a list of the newly created Entitlements
*/  
public without sharing class AccountHelper {
    
    public static final string DefaultSlaName = 'Default Support Entitlement Process';
    public static final string DefaultEntitlementRecordTypeName = 'Default Support';
    
    public static List<Entitlement> CreateDefaultEntitlement(List<Account> lstAccounts){
        List<Entitlement> lstEntitlmentsToCreate = new List<Entitlement>();
        Id defaultEntitlmentProcessId = getSlaIdByName(DefaultSlaName);
        Id recordTypeId = getRecordTypeIdByRecordTypeName(DefaultEntitlementRecordTypeName);

        List<Id> lstAccountIds = new List<Id>();
        if(defaultEntitlmentProcessId != null && recordTypeId != null){
            for(Account a : lstAccounts){
                Entitlement e = new Entitlement();
                e.AccountId = a.Id;
                e.Name = 'Default Support Entitlement - ' + a.Name;
                e.StartDate = Date.today();
                e.RecordTypeId = recordTypeId;
                e.SlaProcessId = defaultEntitlmentProcessId;
                lstEntitlmentsToCreate.add(e);
            }
        }
        return lstEntitlmentsToCreate;
    }


    public static Id getSlaIdByName(String recordTypeName){
        Id returnId; 
        try{
            SlaProcess sla = [Select Id from SlaProcess where Name = :DefaultSlaName and IsActive = true order by VersionNumber desc limit 1];
            returnId = sla.Id;
        }catch(Exception e){
            System.debug('============> No default SLA Process Found');
        }
        return returnId;
    }

    public static Id getRecordTypeIdByRecordTypeName(String recordTypeName){
        Id returnId; 
        Schema.DescribeSObjectResult R = Entitlement.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> lstRecordTypeInfos = R.getRecordTypeInfos();
        For(Schema.RecordTypeInfo rti : lstRecordTypeInfos){
            if(rti.getName() == recordTypeName){
                returnId = rti.getRecordTypeId();
            }
        }
        return returnId;
    }
}