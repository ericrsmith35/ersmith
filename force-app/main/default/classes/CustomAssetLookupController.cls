// Project: Create new record to add to a Case as an Asset       
// Created By: Eric Smith - GWI - 12/2015
// Thanks to Jeff Douglass (http://about.me/jeffdonthemic) for the Lookup Override						
// VisualForce Page: CustomAssetLookup         		                
// Description: Select an existing Asset from the Cases's Account                 
// Classes Utilized: CustomAssetLookupController, CaseAssetLookupController					   	
// Test Classes: CaseAssetLookupControllerTester, CustomAssetLookupControllerTester												

public with sharing class CustomAssetLookupController {
/* Removed in Assets Phase 2 - 11/17    
    public CaseAsset__c ca {get;set;} 		// new CaseAsset to create
    public Asset asset {get;set;}			// Asset placeholder
    public List<Asset> results{get;set;} 	// search results
    public string searchString{get;set;} 	// search keyword
    public string aid{get;set;}				// AccountId parameter
    public string cid{get;set;}				// CaseId parameter
    public string srvadr{get;set;}			// Service Address parameter
    
    // Record holder for new CPE Asset
    public Asset cpe {get;set;}
    
    public CustomAssetLookupController() {
        
        // get the value of the passed AccountId parameter
        aid = System.currentPageReference().getParameters().get('aid');
        
        // get the current search string
        searchString = System.currentPageReference().getParameters().get('lksrch');
        runSearch(); 
        
        // get the value of the passed CaseId parameter
        cid = System.currentPageReference().getParameters().get('cid'); 
        
        // get the value of the passed Service Address parameter
        srvadr = System.currentPageReference().getParameters().get('srvadr'); 
        
        // create Asset record placeholder
        cpe = new Asset();
        
        // Assign standard default values
        cpe.Name = 'New CPE';
        cpe.Status = 'Installed';
        cpe.Asset_Type__c = 'CPE';
        cpe.Quantity = 1;
        
        // Assign standard values from the calling Case object
        cpe.AccountId = aid.substring(1,19);
        cpe.Service_Address__c = srvadr;
        
    }
    
    // perform the keyword search
    public PageReference search() {
        runSearch();
        return null;
    }
    
    // prepare the query and issue the search command
    private void runSearch() {
        // TODO prepare query string for complex serarches & prevent injections
        results = performSearch(searchString);               
    } 
    
    // run the search and return the records found. 
    private List<Asset> performSearch(string searchString) {
        
        // create the SOQL statement
        String soql = 'SELECT id, name, Service_Address__c, GWI_Asset_Tag_Number__c, SerialNumber FROM asset';
        
        // commented out next line to perform search on initial entry
        // if(searchString != '' && searchString != null)
        
        soql = soql + ' WHERE (name LIKE \'%' + searchString +'%\' AND accountId='+ aid +')';
        soql = soql + ' ORDER BY name, Service_Address__c LIMIT 25';
        
        System.debug(soql);
        return database.query(soql); 
        
    }
    
    // Handle Save Button
    Public PageReference mySave(){
        try {
            
            // Create new Asset record
            upsert(cpe);
            
            // Create new CaseAsset record
            ca = new CaseAsset__c();
            ca.Asset__c = cpe.Id;
            ca.Case__c = cid;            
            upsert(ca);
            
            // catch any errors when adding the new records    
        } catch(System.DMLException e) {
            system.debug('New CPE CaseAsset upsert failed');
            ApexPages.addMessages(e);
            return null;
        }
        
        return null;
    } 
    
    // used by the VisualForce page to send the link to the right dom element
    public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }
    
    // used by the VisualForce page to send the link to the right dom element for the text box
    public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }
*/    
}