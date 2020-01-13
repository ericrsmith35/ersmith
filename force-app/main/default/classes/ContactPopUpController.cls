// Project: Replace Standard Lookup with Custom Filtered Lookup         

// Created By: Eric Smith - GWI - 1/2016                                    
// Based on: 'Roll your own Salesforce "Lookup" Popup Window'               
//  By Jeff Douglas - http://blog.jeffdouglas.com/2011/08/12/roll-your-own-salesforce-lookup-popup-window/ 

// Calling Object:              Case            (Case)                                  
// Filtered Lookup Object:      Service_Address (Service_Address__c)
// Filtered Lookup Object:      Contact         (Contact)                                       
// Field with Filter Value:     Account         (Account)                                   

// This File:   ContactPopUpController                                           
//              Controller for popup page for Custom Filtered Lookup        

// VisualForce Pages:   Case_FL_Page,                                   
//                      Service_Address_FL_PopUp
//                      Contact_FL_PopUp                                    
// Classes Utilized:    CaseLookupController,                       
//                      Service_AddressPopUpController
//                      ContactPopUpController                          
// Test Classes:        CaseLookupControllerTester,                     
//                      Service_AddressPopUpControllerTester
//                      ContactPopUpControllerTester    

public with sharing class ContactPopUpController {
    
    //public Case co {get;set;}                             // new Case to create/update
    public Contact luobj {get;set;}                     // Contact placeholder
    public List<Contact> results{get;set;}              // search results
    public string searchString{get;set;}                // search keyword
    public string fid{get;set;}                         // filter value
    public string TabInFocus{get; set;}                 // Tab to display
    
    // ***** Optional parameters *****    
    // public string aid{get;set;}                          // AccountId parameter
    // public string cid{get;set;}                          // CaseId parameter
    // public string srvadr{get;set;}                       // Service Address parameter
    
    // ***** Optional record holder for new object record *****
    // public Asset cpe {get;set;}
    
    public ContactPopUpController() {
        
        TabInFocus = 'tab1';

        // placeholder for adding new record
        luobj = new Contact();
        
        // get the value of the passed AccountId parameter
        fid = System.currentPageReference().getParameters().get('fid');
        
        // get the current search string
        searchString = System.currentPageReference().getParameters().get('lksrch');
        runSearch(); 
        
        // ***** Optional: Get values of passed parameters *****        
        // get the value of the passed CaseId parameter
        // cid = System.currentPageReference().getParameters().get('cid'); 
        
        // get the value of the passed Service Address parameter
        // srvadr = System.currentPageReference().getParameters().get('srvadr'); 
        
        // ***** Optional: Create new object record *****
        // create Asset record placeholder
        // cpe = new Asset();
        
        // ***** Optional: Assign field values to new record *****
        // Assign standard default values
        // cpe.Name = 'New CPE';
        // cpe.Status = 'Installed';
        // cpe.Asset_Type__c = 'CPE';
        // cpe.Quantity = 1;
        
        // Assign standard values from the calling Case object
        // cpe.AccountId = aid.substring(1,19);
        // cpe.Service_Address__c = srvadr;
        
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
    private List<Contact> performSearch(string searchString) {
        
        // ***** Create the SOQL statement & include any optional fields *****
        String soql = 'SELECT id, name FROM Contact';
        
        // commented out next line to perform search on initial entry
        // if(searchString != '' && searchString != null)
        
        String escapedString = String.escapeSingleQuotes(searchString);
        
        soql = soql + ' WHERE (name LIKE \'%' + escapedString +'%\' AND AccountId='+ fid +')';
        
        // ***** Optional: Add additional sort fields *****
        soql = soql + ' ORDER BY name LIMIT 25';
        
        System.debug(soql);
        return database.query(soql); 
        
    }
    
    // Handle Save Button
    Public PageReference mySave(){
        //try {
            
            // ***** Optional: Create new object record *****
            // upsert(cpe);
            
            // ***** Optional: Create/update new Case record *****
            // co = new Case();
            // c0.Asset__c = cpe.Id;
            // ca.Case__c = cid;            
            // upsert(ca);
            
            // catch any errors when adding the new records    
        //} catch(System.DMLException e) {
        //    system.debug('New Case upsert failed');
        //    ApexPages.addMessages(e);
        //    return null;
        //}

        return null;
    } 
    
    // Save the new Contact record
    public PageReference saveContact() {
        insert luobj;       
        luobj.AccountId = fid.substring(1,19);
        upsert luobj;
        // reset the Contact
        luobj = new Contact();
        // return focus to Contact list
        TabInFocus = 'tab1';
        runSearch();
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
    
}