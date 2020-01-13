/** 
 Project: Assets Phase 2
 Created By: GWI, Eric Smith
 Class: OLI_UpdateA.apxc                    
 Description: Class to present and update Asset's Service Address(Deliver to Account)
    Classes: OLI_UpdateA.apxc, OLI_UpdateA_Test.apxc    
    VisualForce Page: OLI_UpdateA.vfp   

 Called from 'Assign Service Address' Button on Assets-Added Related List on Opportunity Page
 
**/

public with sharing class OLI_UpdateA {
    
    // SObject variables and Lists
    public Opportunity Opp {get; set;}
    public List<Asset> ASSlist1 {get; set;}

    // Variables
    private string TopId15, TopId;
    
    // Constructor
    public OLI_UpdateA() {
        
        // Get passed ID of Opportunity record
        getOIDQueryParameter();
        
        // Get ID of Top Parent of Opportunity's Account      
        TopId = [SELECT Top_Account__c FROM Opportunity WHERE ID=:Opp.Id LIMIT 1].Top_Account__c;
        TopId15 = TopId.left(15);

        // Select all Assets that can be updated
        // Don't include already Active items
        ASSlist1 = [SELECT  Purchase_Opportunity__c,
                            Name,
                            Asset_Type__c,
                            Status,
                            Service_Address__c,
                            Quantity,
                            ID
                    FROM    Asset 
                    WHERE   Purchase_Opportunity__c =:Opp.Id and
                            IsDeleted = false and       
                            Status = 'In Turn-Up'
                   ORDER BY Service_Address__c];    
    }

    // Parameter passed to the Visualforce page
    public Boolean getOIDQueryParameter(){
        Opp = new Opportunity(id=ApexPages.currentPage().getParameters().get('oid'));
        return null;
    }
   
    // Get complete Account Hierarchy list of the Opportunity's Account
    public List<selectOption> getAcctHierarchy() {
        List<selectOption> options = new List<selectOption>();                      // New list to contain all of the Account values
        for (Account a : [SELECT ID, Name, Hierarchy_Display__c FROM Account WHERE Top_ID_18__c =:TopId
                         ORDER BY Hierarchy_Sort__c]){                              // Find all Accounts with same Top ID
            options.add(new selectOption(a.Id, a.Hierarchy_Display__c));            // Add each Account found to the picklist
        }
        return options;
    }    

    // Get complete list of the Account Hierarchy's Service Addresses
    public List<selectOption> getDelvServAddr() {
        List<selectOption> options = new List<selectOption>();                      // New list to contain all of the Service Address values
        // John Casey Update 11/29/17 (replaced SOQL inside a loop with 'join' formatted request)        
        //for (Account a : [SELECT ID, Name, Hierarchy_Display__c FROM Account WHERE Top_ID_18__c =:TopId
        //                 ORDER BY Hierarchy_Sort__c]){                              // Find all Accounts with same Top ID        
        //    for (Service_Address__c sa : [SELECT ID, Name, vwf_AcctNameDesc__c FROM Service_Address__c WHERE Account__c =:a.Id
        //                     ORDER BY Name]){                                       // Find all Service Addresses from the Deliver to Account
        //        options.add(new selectOption(sa.Id, sa.vwf_AcctNameDesc__c));       // Add each Service Address found to the picklist
        //    }
        //}
        for (Service_Address__c sa: [SELECT Id, Name, vwf_AcctNameDesc__c FROM Service_Address__c
        WHERE Account__r.Top_ID_18__c =:TopId
        ORDER BY Account__r.Hierarchy_Sort__c])
        {
          options.add(new selectOption(sa.Id,sa.vwf_AcctNameDesc__c));
        }                             
        return options;
    }
        
    // Methods to process changes after Save button is selected
    public PageReference save() {
        PageReference returnPage;
               
        // Update the changed Assets
        update(ASSlist1);
                
        // Redirect back to the original Opportunity page
        returnPage = new ApexPages.StandardController(Opp).view();
        returnPage.setRedirect(true);
        return returnPage;                           
    }

    // Methods to process the Cancel button selection
    public PageReference cancel() {
        
        // Redirect back to the original Opportunity page
        PageReference returnPage = new ApexPages.StandardController(Opp).view();
        returnPage.setRedirect(true);
        return returnPage;        
    }
}