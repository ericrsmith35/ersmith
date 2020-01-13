/** 
 Project: Assets Phase 1
 Created By: GWI, Eric Smith
 Class: OLI_Update.apxc                 
 Description: Class to present and update Products for Bill to Account, 
              Service Address(Deliver to Account), Line Description & Sort Order
    Classes: OLI_Update.apxc, OLI_Update_Test.apxc  
    VisualForce Page: OLI_Update.vfp    

 Called from 'Update Products' Button on Products Related List on Opportunity Page

**/

public with sharing class OLI_Update {
    
    // SObject variables and Lists
    public Opportunity Opp {get; set;}
    public List<OpportunityLineItem> OLIlist1 {get; set;}
    
    // Variables
    private string TopId15, TopId;
    
    // Constructor
    public OLI_Update() {
        
        // Get passed ID of Opportunity record
        getOIDQueryParameter();
        
        // Get ID of Top Parent of Opportunity's Account      
        TopId = [SELECT Top_Account__c FROM Opportunity WHERE ID=:Opp.Id LIMIT 1].Top_Account__c;
        TopId15 = TopId.left(15);

        // Select all OpportunityLineItems (Products) that can be updated
        // Don't include already Billed items
        OLIlist1 = [SELECT  ServiceDate,
                            Discount,
                            Description,
                            ListPrice,
                            Product2Id,
                            ProductCode,
                            Quantity,
                            UnitPrice,
                            Subtotal,
                            TotalPrice,
                            Billing_Enabled__c,
                            Account__c,
                            Deliver_to_Account__c,
                            Equipment_Price__c,
                            Installation__c,
                            IsConverted__c,
                            Product_Name__c,
                            QT_Line__c,
                            Service_Address__c,
                            Service_Address_Size__c,
                            Split_Qty__c,
                            ID,
                            PricebookEntryId,
                            OpportunityId 
                    FROM    OpportunityLineItem 
                    WHERE   Billing_Enabled__c=false and
                            IsConverted__c=false and        // Don't allow Account/Address change if Assets have been created for the Product
                            OpportunityId =:Opp.Id 
                   ORDER BY QT_Line__c];    
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
        for (Service_Address__c sa : [SELECT sa.ID,sa.Name,sa.vwf_AcctNameDesc__c from Service_Address__c sa  
        where Account__r.Top_ID_18__c =:Topid
        ORDER BY Account__r.Hierarchy_Sort__c])
          {
            options.add(new selectOption(sa.Id,sa.vwf_AcctNameDesc__c));
          }
        //}                             
        return options;
    }
        
    // Methods to process changes after Save button is selected
    public PageReference save() {
        PageReference returnPage;
         
        // Reset the Deliver to Accounts to match the Account for the selected Service Addresses
        for (OpportunityLineItem oli : OLIlist1){
            for (Service_Address__c sa : [SELECT Account__c FROM Service_Address__c WHERE ID =:oli.Service_Address__c LIMIT 1]){
                oli.Deliver_to_Account__c = sa.Account__c;
            }       
        }
        
        // Update the changed OpportunityLineItems
        update(OLIlist1);
        
        // Opportunity Audit Chatter Posts
        Opportunity o = [SELECT Name FROM Opportunity WHERE ID =:Opp.Id LIMIT 1];
        FeedItem post = new FeedItem();
        post.ParentId = opp.Id;
        post.Body = '[ OpportunityAudit ]\n' + 
                    'Opportunity - ' + o.Name + '\n' + 
                    'Button - Update Products\n' + 
                    'User - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        //insert post;  //Record Feed

        FeedItem postg = new FeedItem();        
        postg.ParentId = Label.Chatter_Group_Opportunity_Audit;
        postg.Body = post.Body;       
        //commented out for asset2 sandbox //insert postg;  //Group Feed
        
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