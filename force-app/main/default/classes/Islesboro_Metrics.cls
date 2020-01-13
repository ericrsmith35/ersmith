public class Islesboro_Metrics {
    @InvocableMethod
    public static List<String> Get_Counts() {
        
        List<String> countList = new List<String>();
        String results;
        
        results = 			(string.valueOf(([		
            				SELECT 	ID, Description 
                            FROM 	Account
							WHERE 	IsDeleted = False and
									System_ID_Name__c LIKE 'Islesboro%' and
                            		Hierarchy_Tier__c <> 'I' 
                            		].size()))) + ';';

        results = results +	(string.valueOf(([		
            				SELECT 	ID, Description 
                            FROM 	Account
							WHERE 	IsDeleted = False and
									System_ID_Name__c LIKE 'Islesboro%' and
                            		Hierarchy_Tier__c <> 'I' and
            						Plat_ID__c <> '' 
                            		].size()))) + ';';

        results = results +	(string.valueOf(([		
            				SELECT 	ID, Name
                            FROM 	Asset
							WHERE 	IsDeleted = False and
									Account_s_System_ID__c LIKE 'Islesboro%' and
                            		Status = 'Active' and
            						Name LIKE 'Residential Internet' 
                            		].size()))) + ';';        

        results = results +	(string.valueOf(([		
            				SELECT 	ID, Name 
                            FROM 	Asset
							WHERE 	IsDeleted = False and
									Account_s_System_ID__c LIKE 'Islesboro%' and
                            		Status = 'Active' and
            						Name LIKE 'Residential Unlimited' 
                            		].size()))) + ';';        

        countList.add(results);          
        return countList;
    }
}