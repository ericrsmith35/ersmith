// Project: Create new record to add to a Case as an Asset       
// Created By: Eric Smith - GWI - 12/2015
// Thanks to Jeff Douglass (http://about.me/jeffdonthemic) for the Lookup Override                      
// VisualForce Page: CaseAssetLookup                                
// Description: Creates a new CaseAsset so I can lookup the related Asset field                      
// Classes Utilized: CaseAssetLookupController, CustomAssetLookupController                     
// Test Classes: CaseAssetLookupControllerTester, CustomAssetLookupControllerTester                                             

public class CaseAssetLookupController {
/* Removed in Assets Phase 2 - 11/17    
    // Record holder for new CaseAsset
    Public CaseAsset__c ca {get; set;}
    
    // Capture Id of the Case record this routine is activated from
    //      This value is passed as a parameter in the URL called by the 'Create New CPE'
    //      button on the CaseAsset Related List on the Case Page Layout(s)
    Public String CaseId = System.currentPagereference().getParameters().get('cid');
    
    // Get the needed contents of the Case Record
    Public Case[] c = [SELECT Id,AccountId,Service_Address__c FROM Case WHERE (Id=:CaseId) LIMIT 1];
    
    Public CaseAssetLookupController() {

        // Create a new Case Asset record
        ca = new CaseAsset__c();
        // Set the CaseId to be the current Case
        ca.Case__c = CaseId;
        // Set the Account Id to be passed to the custom lookup filter
        ca.AccountLookup__c = c[0].AccountId;
        // Set the Service Address Id to be passed to the new CPE create page
        ca.SrvAdr__c = c[0].Service_Address__c;
        
    }
    
    // Handle Save Button
    Public PageReference mySave(){
        try {
            
            // Save new CaseAsset record
            upsert(ca);
            
            // catch any errors when adding the new records    
        } catch(System.DMLException e) {
            system.debug('New CaseAsset upsert failed:'+e);
            ApexPages.addMessages(e);
            return null;
        }
        
        // Return to the original Case page
        return myReturn();
    } 
    
    // Handle Cancel Button
    Public PageReference myCancel(){
        // Return to the original Case page
        return myReturn();
    } 
    
    // Always return to the Case page where the 'Create New CPE' button was pressed
    Private pageReference myReturn() {
        PageReference page = new PageReference('/' + CaseId);
        page.setRedirect(true);
        return page;
    }    
*/    
}