// Project: Create new CPE to add to a Case as an Asset       
// Created By: Eric Smith - GWI - 12/2015                       
// VisualForce Page: CreateCPE                              
// Description: Standard Asset Controller Extension                       
// Classes Utilized: CreateCPEextension                     
// Test Classes: CreateCPEextensionTester                                               

public class CreateCPEextension {
/* Removed in Assets Phase 2 - 11/17    
    // Record holder for new CPE Asset
    Asset cpe;
    
    // Record holder for new CaseAsset
    Public CaseAsset__c ca {get; set;}
    
    // Capture Id of the Case record this routine is activated from
    //      This value is passed as a parameter in the URL called by the 'Create New CPE'
    //      button on the CaseAsset Related List on the Case Page Layout(s)
    Public String CaseId = System.currentPagereference().getParameters().get('cid');
    
    // Get the needed contents of the Case Record
    Case[] c = [SELECT Id,AccountId,Service_Address__c FROM Case WHERE (Id=:CaseId) LIMIT 1];
    
    // Extend the Standard Asset Controller
    public CreateCPEextension(ApexPages.StandardController std) {
        
        // Create new Asset record
        cpe = (Asset)std.getRecord();
        
        // Assign standard default values
        cpe.Name = 'New CPE';
        cpe.Status = 'Installed';
        cpe.Asset_Type__c = 'CPE';
        cpe.Quantity = 1;
        
        // Assign standard values from the calling Case object
        cpe.Service_Address__c = c[0].Service_Address__c;
        cpe.AccountId = c[0].AccountId;
        
    }       
    
    // Handle Save Button
    Public PageReference mySave(){
        try {
            
            // Create new Asset record
            upsert(cpe);
            
            // Create new CaseAsset record
            ca = new CaseAsset__c();
            ca.Asset__c = cpe.Id;
            ca.Case__c = CaseId;            
            upsert(ca);
        
        // catch any errors when adding the new records    
        } catch(System.DMLException e) {
            system.debug('New CPE CaseAsset upsert failed');
            ApexPages.addMessages(e);
            return myReturn();
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