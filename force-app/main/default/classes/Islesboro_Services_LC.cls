public with sharing class Islesboro_Services_LC {

    @AuraEnabled
    public static string getDataCount(Id recordId) {      
    	return string.valueOf(([		
			SELECT 	ID, Name 
			FROM 	Asset
			WHERE 	IsDeleted = False and
					Service_Address_Account_Lookup__c = :recordId and
					Status = 'Active' and
					Name LIKE 'Residential Internet%' 
		].size()));
    }

	@AuraEnabled    
    public static string getVoiceCount(Id recordId) {
    	return string.valueOf(([		
			SELECT 	ID, Name 
			FROM 	Asset
			WHERE 	IsDeleted = False and
					AccountID = :recordId and
					Status = 'Active' and
					Name LIKE 'Residential Unlimited%' 
		].size()));
    }

    @AuraEnabled
    public static List<Asset> getDataList(Id recordId) {
        return [
            SELECT 	ID, Name, Status, InstallDate, Removal_Date__c, Registration_ID__c, Deactivation_Requested__c
            FROM	Asset 
            WHERE 	IsDeleted = False and
					Service_Address_Account_Lookup__c = :recordId and
					Name LIKE 'Residential Internet%'
			ORDER BY InstallDate Desc
        ];
    }

	@AuraEnabled    
    public static List<Asset> getVoiceList(Id recordId) {
        return [
            SELECT 	ID, Name, Status, InstallDate, Removal_Date__c, Phone_Number__c 
            FROM	Asset 
            WHERE 	IsDeleted = False and
					AccountID = :recordId and
					Name LIKE 'Residential Unlimited%'
			ORDER BY InstallDate Desc
        ];
    }
       
}