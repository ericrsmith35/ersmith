public with sharing class Islesboro_Services {
    
   	public Account acct {get; set;}      
    public string DataCount {get; set;}
    public string VoiceCount {get; set;}
    public List<Asset> DataList {get; set;}
    public List<Asset> VoiceList {get; set;}
    
    public Islesboro_Services() {

        getRecordid();
     
        DataCount = string.valueOf(([		
            				SELECT 	ID, Name 
                            FROM 	Asset
							WHERE 	IsDeleted = False and
									Service_Address_Account_Lookup__c = :acct.Id and
                            		Status = 'Active' and
            						Name LIKE 'Residential Internet%' 
                            		].size()));
        
        VoiceCount = string.valueOf(([		
            				SELECT 	ID, Name 
                            FROM 	Asset
							WHERE 	IsDeleted = False and
									AccountID = :acct.Id and
                            		Status = 'Active' and
            						Name LIKE 'Residential Unlimited%' 
                            		].size()));
    
    	DataList = 		[SELECT ID, Name, Status, InstallDate, Removal_Date__c, GWI_Asset_Tag_Number__c 
                    		FROM	Asset 
                         	WHERE 	IsDeleted = False and
                         			Service_Address_Account_Lookup__c = :acct.Id and
                         			Name LIKE 'Residential Internet%'
                         	ORDER BY InstallDate Desc];
   
    	VoiceList = 	[SELECT ID, Name, Status, InstallDate, Removal_Date__c, Phone_Number__c 
                    		FROM	Asset 
                         	WHERE 	IsDeleted = False and 
                         			AccountID = :acct.Id and
                         			Name LIKE 'Residential Unlimited%'
                         	ORDER BY InstallDate Desc];
       }
        
    public Boolean getRecordid(){
        acct = new Account(id=ApexPages.currentPage().getParameters().get('id'));       
        return null;
    }
    
    public Account getAcct() {
        return this.Acct;
    }
    
}