/** 
* Project: Assets Phase 1
* Project: Assets Phase 2 - Updated to select CPE Assets for (De)Activation
* Created By: GWI, Eric Smith
* Class: OLI_SelectB_ap.apxc					
* Description: Class to select the Products from an Opportunity to be Billing Enabled
* Classes: OLI_SelectB_ap.apxc, OLI_SelectB_ap_Test.apxc, OLI_Wrapper	
* VisualForce Page: OLI_SelectB_vf.vfp	
* 
**/

public with sharing class OLI_SelectB_ap {
    
    // SObject variables and Lists
    public Opportunity Opp {get; set;}
    public List<OpportunityLineItem> olis {get; set;}
    public OpportunityLineItem oli, testOLI;
    public string testOLIid;
    public Opportunity beOpp {get; set;}
    public boolean chkSelection {get; set;}
    public boolean chkSelectionA {get; set;}     
    public boolean partialBill {get; set;}
    public boolean isRenewal = false;
    public List<Asset> alis {get; set;} 
    public Asset ass, testASS;
    public string testASSid;
    
    // Stores final list of selected oProds
    public List<OpportunityLineItem> oProds;
    public List<String> oProdIds = new List<String>();
    
    // oProd object for setting mass status on all entries from VF page.
    private OpportunityLineItem oProdStatus = new OpportunityLineItem();
    
    // OLI_Wrapper lists - aid in defining the view that is displayed to the end-user
    public List<OLI_Wrapper> oProdW = new List<OLI_Wrapper>();    
    
    // Stores final list of selected oAsss
    public List<Asset> oAsss;
    public List<String> oAssIds = new List<String>();
    
    // oAss object for setting mass status on all entries from VF page.
    private Asset oAssStatus = new Asset();
    
    // OLI_Wrapper lists - aid in defining the view that is displayed to the end-user
    public List<Asset_Wrapper> oAssW = new List<Asset_Wrapper>();    
    
    // Constructor
    public OLI_SelectB_ap() {
        
        // Get passed ID of Opportunity record
        getOIDQueryParameter();       
        
        // Get Opportunity record
        beOpp = [SELECT		CSD_Progress_Notes__c,
                 Inst_Date__c,
                 Billable_Date__c,
                 Today__c,
                 ContractId,
                 IsFlow__c,
                 Account_Plat_ID__c,
                 Type
                 FROM	Opportunity
                 WHERE	ID=:Opp.Id];
        
        //Reset the Previous Billing Enabled Date
        beOpp.Billable_Date__c = beOpp.Today__c; 

        // set if opp type is renewal
        isRenewal = beOpp.Type.substring(0,3).equalsIgnoreCase('ren');       
     
        // Select all OpportunityLineItems (Products) that can be selected for Billing
        // Don't include already billed items
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
                ID,
                PricebookEntryId,
                Equipment_Price_Ext__c,
                Installation_Ext__c,
                OpportunityId 
                FROM 	OpportunityLineItem 
                WHERE	Billing_Enabled__c=false and
                IsConverted__c=true and
                IsDeleted=false and
                OpportunityId =:Opp.Id 
                ORDER BY	QT_Line__c];    
        
        //Utilize the OLI list to set the oProd Wrapper List to be used by the VF Page          
        for(OpportunityLineItem o: olis) {
            oProdW.add(new OLI_Wrapper(o, o.Id));
        } 
        
        // Select all CPE Assets that can be selected for (De)Activation
        // Don't include already activated or non-CPE items
        // ID, Status, InstallDate, Contract__c, In_Production__c, Removal_Date__c, UsageEndDate
        alis = [SELECT 		Purchase_Opportunity__c,
                Disconnect_Opportunity__c,
                Name,
                Asset_Type__c,
                Status,
                Service_Address__c,
                Display_ID__c,
                Quantity,
                InstallDate,
                Contract__c,
                In_Production__c,
                Removal_Date__c,
                UsageEndDate,
                ID
                FROM 	Asset 
                WHERE	IsDeleted = false and
                ((Purchase_Opportunity__c =:Opp.Id and Status = 'In Turn-Up') or
                 (Disconnect_Opportunity__c =:Opp.Id and Status = 'Selected for Turn-Down'))
                ORDER BY	Status, Name];      
        
        //Utilize the Asset list to set the oAss Wrapper List to be used by the VF Page          
        for(Asset a: alis) {
            if(a.Asset_Type__c == 'CPE'){
                ass = new Asset();
                ass = a.clone();
                oAssW.add(new Asset_Wrapper(ass, a.Id));
            }
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
    
    public List<OLI_Wrapper> getoProdW(){
        return this.oProdW;
    }
    
    public Asset getoAssStatus() {
        return oAssStatus;
    }
    
    public List<Asset> getAlis() {
        return this.alis;
    }
    
    public List<Asset_Wrapper> getoAssW(){
        return this.oAssW;
    }
    
    // selectAll: checks/selects all checkboxes
    public PageReference selectAll() {
        for(OLI_Wrapper oW: oProdW){
            oW.setIsoProdSelected(chkSelection);
        }        
        return null;
    }
    
    // selectAll: checks/selects all checkboxes
    public PageReference selectAllA() {
        for(Asset_Wrapper aW: oAssW){
            aW.setIsoAssetSelected(chkSelectionA);
        }        
        return null;
    }
    
    // Methods to process conversions after Billing Enable button is selected
    public PageReference enable() {
    
        // Check for a blank Plat ID
        if (beOpp.Account_Plat_ID__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR: Account must have a Plat ID before you can Billing Enable');
            ApexPages.addMessage(myMsg);
            return null;  
        }
        
        // Create list of selected OpportunityLineItem IDs & Update Line Description
        oProdIds = new List<String>();
        oProds = new List<OpportunityLineItem>();
        partialBill = false;
        for(OLI_Wrapper oW: oProdW){
            testOLI = oW.getOLI();
            testOLIid = oW.getOliID();
            if(oW.getIsoProdSelected()) {
                oProdIds.add(testOLIid);
                testOLI.Billing_Enabled__c = true;
                testOLI.Date_Sent_to_Billing__c = beOpp.Billable_Date__c;
                oProds.add(testOLI);
            }else{
                partialBill = true;		//Set this flag if an OLI is not selected for Billing
            }        
        }        
        
        // Create list of selected CPE Asset IDs & Update Status
        oAssIds = new List<String>();
        oAsss = new List<Asset>();
        for(Asset_Wrapper aW: oAssW){
            testAss = aW.getASS();
            testASSid = aW.getAssID();
            if(aW.getIsoAssetSelected()) {
                oAssIds.add(testASSid);
                oAsss.add(testAss);
            }        
        } 
        
        // Check for Products not yet Converted to Assets
        if (!partialBill) {				//Don't need to check if we already know this is a partial bill
            if ([SELECT 	ID 
                 FROM 	OpportunityLineItem 
                 WHERE 	IsConverted__c=false and
                 IsDeleted=false and
                 OpportunityId =:Opp.Id]
                .size() > 0) {		//Found unconverted Assets
                    partialBill = True; 
                }    
        }
        
        // Check for no Products selected
        if (oProds.size() == 0 && oAsss.size() == 0) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR: Please select at least one Product to Bill or Asset to Activate');
            ApexPages.addMessage(myMsg);
            return null;  
        }
        
        // Check for a blank Billing Enable Date
        if (beOpp.Billable_Date__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR: Please select a Billing Date');
            ApexPages.addMessage(myMsg);
            return null;  
        }
        
        // Set Turn-Up date if it's blank
        if (beOpp.Inst_Date__c == null) beOpp.Inst_Date__c = beOpp.Billable_Date__c;
        
        // Require future Turn-Up date if this is a partial Billing Enable
        if (partialBill && beOpp.Inst_Date__c <= beOpp.Today__c) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR: Please select a future Turn-Up Date for the unbilled balance on this Opportunity!');
            ApexPages.addMessage(myMsg);
            return null;              
        }
        
        // Do not allow for a partial Billing Enable on a Service Reduction     
        if (partialBill && beOpp.Type == 'Service Reduction') {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR: Please wait and Billing Enable a Service Reduction Opportunity all at once!');
            ApexPages.addMessage(myMsg);
            return null;              
        }
        
        // Save the Product and Asset collections
        update(oProds);
        //update(oAsss);

        billingEnableOLIs();
        
        /* OPFOCUS (7/25/18): Commenting out call to flow to avoid governor limits*/

        // Convert date to text to avoid SF bug of passing the prior day
        //Date d = beOpp.Billable_Date__c;
        //Datetime myDT = datetime.newInstance(d.year(), d.month(),d.day());
        //String myDate = myDT.format('yyyy-MM-dd');
        
        //// Call the Visual Workflow that will Update OLI fields
        //Map<String, Object> params = new Map<String, Object>();
        //params.put('colIDs', oProdIds);
        //params.put('vTextDate', myDate);
        //Flow.Interview.Billing_Enable_OLIs myFlow = new Flow.Interview.Billing_Enable_OLIs(params);
        //myFlow.start();
        
        // Update the changed Opportunity fields
        // 		This holds off changing the Billing Enabled date until after the OLIs have been selected for billing
        // 		which allows the Billing Enabled notice to include the date of billing for each lineitem.
        beOpp.IsFlow__c = True;	// Bypass Validation Rule for Opportunity Locked if Billable Date is Set
        update(beOpp);
        
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

    /**
     * originally a autolaunch flow "Billing Enable OLIs". Updates asset records to enable billing
     */
    private void billingEnableOLIs(){
        //alis
        Map<Id,Asset> assetUpdates = new Map<Id,Asset>();
        for(Asset a : alis){
            if(a.Status == 'Active' && isRenewal){
                // do nothing
            }
            else if(a.Status == 'In Turn-Up'){
                a.In_Production__c = true;
                a.InstallDate = beOpp.Billable_Date__c;
                a.Status = 'Active';
                a.Contract__c = beOpp.ContractId;
                assetUpdates.put(a.Id, a);
            }
            else{
                a.In_Production__c = false;
                a.Removal_Date__c = beOpp.Billable_Date__c;
                a.UsageEndDate = beOpp.Billable_Date__c;
                assetUpdates.put(a.Id, a);
            }
        }
        update assetUpdates.values();
    }
    
}