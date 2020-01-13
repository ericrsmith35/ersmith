public with sharing class DisconnectOptionsController {
    //Use @AuraEnabled to enable client- and server-side access to the method
    //Case 48003
    @AuraEnabled
    public static String getUserName() {
        return userinfo.getName();
    }
    @AuraEnabled
    public static String getProfileName() {
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        return PROFILE[0].Name;
    }
    @AuraEnabled
    public static integer setDeactivateReason(Id accountId,String reason)
    {
        integer result = -1;
        List<Deactivate_Permissions__c> Perm = [Select Deactivate_for_Non_Payment__c,Deactivate_for_Seasonal_Suspend__c,Deactivate_for_Security__c,Reactivate_from_Non_Payment__c,Reactivate_from_Seasonal_Suspend__c,Reactivate_from_Security__c from Deactivate_Permissions__c where SetupOwnerId =: userinfo.getProfileId() LIMIT 1];
        Account accountToUpdate;
        //six reasons, Non Payment, Seasonal Suspend, Security Suspend to deactivate
        //Reactivate Non Payment,Reactivate Seasonal,Reactivate Security to reactivate
        //we also check permissions here to keep people from being cute
        //return 1 if something is changed, -1 otherwise
        accountToUpdate = [SELECT DiscoFlag__c,DiscoType__c FROM Account where Id =: accountId];
        if ((reason == 'Non Payment')  && (Perm[0].Deactivate_for_Non_Payment__c == true))
        {
            accountToUpdate.DiscoFlag__c = True;
            accountToUpdate.DiscoType__c = 'Non-Payment';
            result = 1;
        }
        if ((reason == 'Seasonal Suspend') && (Perm[0].Deactivate_for_Seasonal_Suspend__c == true))
        {
            accountToUpdate.DiscoFlag__c = True;
            accountToUpdate.DiscoType__c = 'Seasonal Suspend';
            result = 1;
        }
        if ((reason == 'Security Suspend') && (Perm[0].Deactivate_for_Security__c == true))
        {
            accountToUpdate.DiscoFlag__c = True;
            accountToUpdate.DiscoType__c = 'Security';
            result = 1;
        }
        if ((reason == 'Reactivate Non Payment') && (Perm[0].Reactivate_from_Non_Payment__c == true))
        {
            accountToUpdate.DiscoFlag__c = False;
            accountToUpdate.DiscoType__c = null;
            result = 1;
        }
        if ((reason == 'Reactivate Seasonal') && (Perm[0].Reactivate_from_Seasonal_Suspend__c == true))
        {
            accountToUpdate.DiscoFlag__c = False;
            accountToUpdate.DiscoType__c = null;
            result = 1;
        }
        if ((reason == 'Reactivate Security') && (Perm[0].Reactivate_from_Security__c == true))
        {
            accountToUpdate.DiscoFlag__c = False;
            accountToUpdate.DiscoType__c = null;
            result = 1;
        }
        if (result == 1)
        {
            update accountToUpdate;
        }
        return result;
        
    }
    @AuraEnabled
    public static Integer getDeactivatePerm() {
        integer answer = 0;
        Id profid = userinfo.getProfileId();
        // Permissions retrieved as an integer, each permission represented as a bit
        List<Deactivate_Permissions__c> Perm = [Select Deactivate_for_Non_Payment__c,Deactivate_for_Seasonal_Suspend__c,Deactivate_for_Security__c,Reactivate_from_Non_Payment__c,Reactivate_from_Seasonal_Suspend__c,Reactivate_from_Security__c from Deactivate_Permissions__c where SetupOwnerId =: profid LIMIT 1];
        if (Perm[0].Deactivate_for_Non_Payment__c)
        {
            answer += 1;
        }
        if (Perm[0].Deactivate_for_Seasonal_Suspend__c)
        {
            answer += 2;
        }
        if (Perm[0].Deactivate_for_Security__c)
        {
            answer += 4;
        }
        if (Perm[0].Reactivate_from_Non_Payment__c)
        {
            answer += 8;
        }
        if (Perm[0].Reactivate_from_Seasonal_Suspend__c)
        {
            answer += 16;
        }
        if (Perm[0].Reactivate_from_Security__c)
        {
            answer += 32;
        }
        return answer;     
    }
    @AuraEnabled
    public static String getDiscoReason(Id accountId){
        List<Account> discod = [SELECT DiscoType__c from Account where Id =: accountId];
        return discod[0].DiscoType__c;   
    }
    
}