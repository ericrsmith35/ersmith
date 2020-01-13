/** 
 Project: Assets Phase 1
 Created By: GWI, Eric Smith
 Class: OLI_SplitQty2.apxc					
 Description: Class to present and update Products to be split on an Opportunity
 	Classes: OLI_SplitQty2.apxc, OLI_SplitQty2_Tester.apxc	
 	VisualForce Page: OLI_SplitQty2.vfp	

**/

public with sharing class OLI_SplitQty2 {
    
    // SObject variables and Lists
	public Opportunity Opp {get; set;}
	public List<OpportunityLineItem> OLIlist1 {get; set;}    
	public List<OpportunityLineItem> OLIlist2 {get; set;}
    public List<Asset> AssList {get; set;}
    
    // Variables
    private Decimal qty;
    private Decimal sQty;
	
    // Constructor
	public OLI_SplitQty2() {
        
        // Get passed ID of Opportunity record
		getOIDQueryParameter();
        
        // Select all OpportunityLineItems (Products) that can be split
        // Don't include single quantities, already Converted or Billed or Bulk items
        OLIlist1 = [SELECT 	ServiceDate,
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
                    FROM 	OpportunityLineItem 
                    WHERE	Billing_Enabled__c=false and  
							Bulk_Asset__c=false and
                  			Quantity<>1 and
                  			Quantity<>0 and
                  			Quantity<>-1 and 
                    		//IsConverted__c=false and		// Code is in place to split existing Assets
                    		OpportunityId =:Opp.Id 
                   ORDER BY	QT_Line__c];
       
        // Create list to hold the split records
        OLIlist2 = new List<OpportunityLineItem>();
	}

    // Parameter passed to the Visualforce page
    public Boolean getOIDQueryParameter(){
        Opp = new Opportunity(id=ApexPages.currentPage().getParameters().get('oid'));
        return null;
    }

   	// Methods to process changes after Split button is selected
	public PageReference split() {
        PageReference returnPage;
            
        // Iterate through the collection of OpportunityLineItems
        for(OpportunityLineItem oli: OLIlist1) {
            
            // Get the original quantity and the quantity to be split off
            sQty = oli.Split_Qty__c;
            qty = oli.Quantity;
            
            // Only process updates if a Split Quantity was entered
            if (sQty<>Null) {
                
                // Test that the split quantity is less than the original quantity
                if (math.abs(sQty) < math.abs(qty)) {
                    
                    // Create placeholders for the OpportunityLineItem records
                    OpportunityLineItem o2, o3;
                    o2 = new OpportunityLineItem();
                    o3 = new OpportunityLineItem();
                    
                    // Create a copy of the original record and update fields
                    o2 = oli.clone();
                    o2.TotalPrice = Null;			// Reset the TotalPrice so it can be recalculated by the system
                    o2.Quantity = o2.Split_Qty__c;	// Set the new split Quantity
                    o2.Split_Qty__c = Null;			// Clear the Split_Quantity field
                    if (o2.QT_Line__c<>Null) o2.QT_Line__c = o2.QT_Line__c + 1;	// If the Product list has been manually sorted assign the next sequence number                      
                    // OLIlist2.add(o2);				// Save the new record to be added to the Opportunity
					insert o2;
                    
					// If Assets exist, Update the OLI ID, Bill to Account and Service Address on sQty of them 
                    if (o2.IsConverted__c){							// Check to see if this OLI has converted Assets
                        AssList = [SELECT	ID,						// Get the Asset fields to update
                                  			AccountId,
                                  			Oli_Id__c,
                                  			Service_Address__c
                                  	FROM	Asset
                                  	WHERE	Oli_Id__c =:oli.Id		// Just Assets for this OLI                           
                                  	LIMIT	:sQty.intValue()];		// Select just the first Split Qty number of Assets
                        
                        for(Asset a1: AssList) {					// Loop through the selected Assets and update fields
                        	a1.AccountID = o2.Account__c;			// to point to the new Bill to Account, OLI record and Service Addr
                            a1.Oli_Id__c = o2.Id;                        
                            a1.Service_Address__c = o2.Service_Address__c;
                        }
                        update(AssList);							// Save the updated Asset records
                    }
                    
                    // Update the fields on the original OpportunityLineItem record
                    o3 = [SELECT 	Description, 
                          			ID,
                          			Account__c,
                          			Deliver_to_Account__c,
                          			Service_Address__c
                          	FROM 	OpportunityLineItem 
                          	WHERE 	ID =:oli.Id LIMIT 1];			// Get a copy of the original record prior to any changes
                    // Reset the Line Description, Accounts & SA to the original values (The new values go with the split record)
                    oli.Description = o3.Description;
                    oli.Account__c = o3.Account__c;
                    oli.Deliver_to_Account__c = o3.Deliver_to_Account__c;
                    oli.Service_Address__c = o3.Service_Address__c;
                    
                    oli.TotalPrice = Null;							// Reset the TotalPrice so it can be recalculated by the system
                    oli.Quantity = oli.Quantity - oli.Split_Qty__c;	// Reduce the Quantity of the OpportunityLineItem by the Split_Quantity
                    oli.Split_Qty__c = Null;						// Reset the Split_Quantity field
                    
                } else {	// The Split_Quantity was too large
                    
                    // Add error message to the page
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR: Quantity to split must be less than current quantity! ['+oli.Product_Name__c+' ('+oli.Quantity+')]');
                    ApexPages.addMessage(myMsg);
                    return null;                        
                }
            }
        }               
        
        // Update the changed OpportunityLineItems
        update(OLIlist1);
        // Add the newly split OpportunityLineItems
        // insert(OLIlist2);
        
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