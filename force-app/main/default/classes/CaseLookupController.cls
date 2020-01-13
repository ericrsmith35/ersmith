// Project: Replace Standard Lookup with Custom Filtered Lookup   		

// Created By: Eric Smith - GWI - 1/2016									
// Based on: 'Roll your own Salesforce "Lookup" Popup Window'				
// 	By Jeff Douglas - http://blog.jeffdouglas.com/2011/08/12/roll-your-own-salesforce-lookup-popup-window/ 

// Calling Object: 				Case 			(Case) 									
// Filtered Lookup Object: 		Service_Address	(Service_Address__c)
// Filtered Lookup Object: 		Contact			(Contact) 									
// Field with Filter Value: 	Account 		(Account) 									

// This File:	CaseLookupController 											 
//				Controller for start page for Custom Filtered Lookup		

// VisualForce Pages: 	Case_FL_Page,        		        			
//						Service_Address_FL_PopUp
//						Contact_FL_PopUp			
// Classes Utilized: 	CaseLookupController, 						
//                   	Service_AddressPopUpController
//                   	ContactPopUpController			   				
// Test Classes: 		CaseLookupControllerTester, 					
//                   	Service_AddressPopUpControllerTester
//                   	ContactPopUpControllerTester	

public with sharing class CaseLookupController {
    
    // Record holder for new Case
    Public Case co {get; set;}
    
    // Handle Record Type
    // Public RecordType rt {get; set;}
    Public RecordType[] rtlist = [SELECT Id FROM RecordType WHERE (Name='Support Trouble' and SobjectType='Case') LIMIT 1];
    
    // Capture Id of the Account record this routine is activated from
    Public String recId = System.currentPagereference().getParameters().get('rid');
    Public String recName = System.currentPagereference().getParameters().get('rnm');
    Public String ServiceConsoleView = System.currentPagereference().getParameters().get('sconsole');
    Public String acctName {get; set;}
    Public String userName {get; set;}
    Public String CaseNumber {get; set;}
    
    // Return to Calling record on Cancel and New record on Save
    Public String returnId {get; set;}
    
    // Optional: Get contents from the Case Record
    // Public Case[] c = [SELECT Id,AccountId FROM Case WHERE (Id=:CaseId) LIMIT 1];
    
    // Boolean flag to fire the Assignment Rules
    Public Boolean isAssignmentChecked {get; set;}
    
    // Boolean flags to identify if in Service Console or Standard view
    Public Boolean isServiceConsole {get; set;}
    Public Boolean isStandardView {get; set;}
    
    Public CaseLookupController() {         
        
        // Make Account Name & User Name available to page
        acctName = recName;
        userName = UserInfo.getName();
        
        // We want to always process Case Assignment rules
        isAssignmentChecked = true;        
        
        // Create a new Case record
        co = new Case();   
      
        // Set the filter field
        co.AccountId = recId;
        
        // Optional: Set values in the new record
        co.RecordTypeId = rtlist[0].Id;
        co.OwnerId = UserInfo.getUserId();
        
        // Reset the view type flags
        if (ServiceConsoleView == 'true') {
            isServiceConsole = true;
            isStandardView = false;
        } else {
            isServiceConsole = false;
            isStandardView = true;
        }
        
    }
    
    // Handle Save Button
    Public PageReference mySave(){
        try {
            
            // Get the Active Case Assignment Rule and set it on the Case
            if (isAssignmentChecked) {
                AssignmentRule AR = new AssignmentRule();
                AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                co.setOptions(dmlOpts);
            }
            
            // Save updated Case record
            // DeleteFlag will be left as true if user Cancels from the 
            // Case Edit screen before Saving this new Case
            // co.DeleteFlag__c = true;
            upsert(co);
            // *** URL Hack - Hard coded field ID for DeleteFlag field ***
            // *** Field has to be on the Edit Page Layout for this to work ***
            // returnId = co.Id+'/e?00N11000001blF1=false';		//Sandbox
            // returnId = co.Id+'/e?00N3200000308iN=false';		//Production
            returnId = co.Id;
            
            // Read back record to get system created CaseNumber
            co = [select Id, CaseNumber from Case where id = :co.id];
            CaseNumber = co.CaseNumber;
            
            // catch any errors when adding the new records    
        } catch(System.DMLException e) {
            system.debug('New Case upsert failed:'+e);
            ApexPages.addMessages(e);
            return null;
        }
        
        // Return to the designated page
        return myReturn();
    } 
    
    // Handle Save & Close Button
    Public PageReference mySaveClose(){
        try {
            
            // Get the Active Case Assignment Rule and set it on the Case
            if (isAssignmentChecked) {
                AssignmentRule AR = new AssignmentRule();
                AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                co.setOptions(dmlOpts);
            }
            
            // Save updated Case record & continue to Close Case page
            upsert(co);
            returnId = co.Id+'/s?retUrl='+co.Id;
            
            // Read back record to get system created CaseNumber
            co = [select Id, CaseNumber from Case where id = :co.id];            
            CaseNumber = co.CaseNumber;
               
            // catch any errors when adding the new records    
        } catch(System.DMLException e) {
            system.debug('New Case upsert failed:'+e);
            ApexPages.addMessages(e);
            return null;
        }
        
        // Return to the designated page
        return myReturn();
    }
    
    // Handle More Options Button
    // This would save the new case and send the user to the case edit page
    // so they could select Check Spelling if desired
    //Public PageReference myMore(){
    //    try {
    
    //        // Save updated Case record
    //        upsert(co);
    //        returnId = co.Id+'/e';
    
    //    // catch any errors when adding the new records    
    //    } catch(System.DMLException e) {
    //        system.debug('New Case upsert failed:'+e);
    //        ApexPages.addMessages(e);
    //        return null;
    //    }
    
    //    // Return to the designated page
    //    return myReturn();
    //}
    
    // Handle Cancel Button
    Public PageReference myCancel(){
        // Return to the designated page
        returnId = recId;
        return myReturn();
    } 
    
    // Set return page
    Private pageReference myReturn() {
        if (isServiceConsole){
            if (returnId.contains('?')){
                returnId = returnId+'&isdtp=vw';
            } else {
            	returnId = returnId+'?isdtp=vw';                
            }
        }
        PageReference page = new PageReference('/' + returnId);
        page.setRedirect(true);
        return page;
    }    
    
}