/** 
 Project: Assets Phase 2
 Created By: GWI, Eric Smith
 Class: OLI_SelectR_ap.apxc					
 Description: Class to select the Products from a Renewal Opportunity to be Turned-Down
 	Classes: OLI_SelectR_ap.apxc, OLI_SelectR_ap_Test.apxc, OLI_Wrapper	
 	VisualForce Page: OLI_SelectR_vf.vfp	
 
**/

public with sharing class OLI_SelectR_ap {
    
    // SObject variables and Lists
	public Opportunity Opp {get; set;}
	public List<OpportunityLineItem> olis {get; set;}
	public OpportunityLineItem oli, testOLI;
    public string testOLIid;
    public Opportunity beOpp {get; set;}
    public boolean chkSelection {get; set;}
    public List<Asset> alis {get; set;}
    
    // Stores final list of selected oProds
    public List<OpportunityLineItem> oProds;
    public List<String> oProdIds = new List<String>();

    // oProd object for setting mass status on all entries from VF page.
    private OpportunityLineItem oProdStatus = new OpportunityLineItem();
    
    // OLI_Wrapper lists - aid in defining the view that is displayed to the end-user
    public List<OLI_Wrapper> oProdW = new List<OLI_Wrapper>();    

    // Constructor
    public OLI_SelectR_ap() {
        
        // Get passed ID of Opportunity record
		getOIDQueryParameter();       

        // Get Opportunity record
        beOpp = [SELECT		Created_from_Contract__c,
                 			Type
                	FROM	Opportunity
                	WHERE	ID=:Opp.Id];
               
        // Check for correct Opportunity type
        if ( !beOpp.Created_from_Contract__c ) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR: Select for Turn-Down can only be used on Renewal Opportunities created from an existing Contract');
            ApexPages.addMessage(myMsg);
        }
                      
        // Select all OpportunityLineItems (Products) that can be selected for Turn-Down
        // Don't include already negative or newly added items
        olis = [SELECT 		ServiceDate,
                			IsDeleted,
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
                			Date_Sent_to_Billing__c,
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
                			//Additional_Phone_Numbers__c,
                    		ID,
                    		PricebookEntryId,
                    		OpportunityId
                    FROM 	OpportunityLineItem 
                    WHERE	Billing_Enabled__c=false and
                			IsConverted__c=true and
                			IsDeleted=false and
                			Quantity>0 and
                    		OpportunityId =:Opp.Id 
                   ORDER BY	QT_Line__c];    
        
        // Utilize the OLI list to set the oProd Wrapper List to be used by the VF Page          
        for(OpportunityLineItem o: olis) {
            oli = new OpportunityLineItem();
            oli = o.clone();
            //oli.Additional_Phone_Numbers__c = '';
            alis = [SELECT	Display_ID__c,
                   			Oli_Id__c
                   	FROM	Asset
                   	WHERE	Oli_Id__c = :o.Id and
                			IsDeleted=false];
            for (Asset a: alis) {
                if (a.Display_ID__c <> null) {
                	//oli.Additional_Phone_Numbers__c = oli.Additional_Phone_Numbers__c + a.Display_ID__c + ' | ';
                }
            }
            //oli.Additional_Phone_Numbers__c = oli.Additional_Phone_Numbers__c.removeEnd(' | ');
            oProdW.add(new OLI_Wrapper(oli, o.Id));
        } 
        
    }        
    
    // Parameter passed to the Visualforce page
    public Boolean getOIDQueryParameter(){
        Opp = new Opportunity(id=ApexPages.currentPage().getParameters().get('oid'));
        return null;
    }
           
    public String getOpportunityID() {
        return this.Opp.ID;
    } 
          
    public Opportunity getOpp() {       
        return this.Opp;
    }
    
    public OpportunityLineItem getoProdStatus() {
        return oProdStatus;
    }
    
    public List<OpportunityLineItem> getOlis() {
        return this.olis;
    }

    public List<Asset> getAlis() {
    return this.alis;
    }

    public List<OLI_Wrapper> getoProdW(){
        return this.oProdW;
    }

    // selectAll: checks/selects all checkboxes
    public PageReference selectAll() {
        for(OLI_Wrapper oW: oProdW){
            oW.setIsoProdSelected(chkSelection);
        }        
        return null;
    }

   	// Methods to process updates after Select for Turn-Down button is selected
    public PageReference remove() {
        
        // Create list of selected OpportunityLineItem IDs & Update Line Description
        oProdIds = new List<String>();
        oProds = new List<OpportunityLineItem>();
            for(OLI_Wrapper oW: oProdW){
                testOLI = oW.getOLI();
                testOLIid = oW.getOliID();
                if(oW.getIsoProdSelected()) {
                	oProdIds.add(testOLIid);
                    oli = [SELECT ID, Description FROM OpportunityLineItem WHERE ID =:testOLIid];
                    oli.Description = testOLI.Description;
                    oProds.add(oli);
                }        
            }        
               
        // Check for no Products selected
        if (oProds.size() == 0) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR: Please select at least one Product to Turn-Down');
            ApexPages.addMessage(myMsg);
            return null;  
        }
                
        // Update the changed Opportunity fields
        // update(beOpp);
        update(oProds);
               
		// Call the Visual Workflow that will Update OLI fields
        Map<String, Object> params = new Map<String, Object>();
        params.put('colIDs', oProdIds);
        Flow.Interview.OLI_Update_Selected_Products_Assets_for_Turn_Down myFlow = new Flow.Interview.OLI_Update_Selected_Products_Assets_for_Turn_Down(params);
        myFlow.start();
        
        // Redirect back to the original Opportunity page
        PageReference returnPage = new ApexPages.StandardController(Opp).view();
        returnPage.setRedirect(true);
        return returnPage;               
    }

   	// Methods to process changes after Cancel button is selected
    public PageReference cancel() {
        
        // Redirect back to the original Opportunity page
        PageReference returnPage = new ApexPages.StandardController(Opp).view();
        returnPage.setRedirect(true);
		return returnPage;    
    }

}