/** 
* Project: Assets Phase 1
* Created By: GWI, Eric Smith
* Class: OLI_Select_ap.apxc                  
* Description:   Class to select the Products from an Opportunity to be converted to Assets 
*                or Assets to be assigned to Products
*    Classes: OLI_Select_ap.apxc, OLI_Select_ap_Test.apxc, OLI_Wrapper   
*    VisualForce Page: OLI_Select_vf.vfp 
* 
**/

public with sharing class OLI_Select_ap {
    
    // SObject variables and Lists
    public Opportunity Opp {get; set;}
    public List<OpportunityLineItem> olis {get; set;}
    public OpportunityLineItem oli, testOLI;
    public string testOLIid; 
    public string pcontract;
    public boolean chkSelection {get; set;}
    public boolean assSelection {get; set;}
    public boolean oSelect {get; set;}
    public boolean aSelect {get; set;}
    public string assignID {get; set;}
    
    // Stores final list of selected oProds
    public List<OpportunityLineItem> oProds;
    public List<String> oProdIds = new List<String>();

    // oProd object for setting mass status on all entries from VF page.
    private OpportunityLineItem oProdStatus = new OpportunityLineItem();
    
    // OLI_Wrapper lists - aid in defining the view that is displayed to the end-user
    public List<OLI_Wrapper> oProdW = new List<OLI_Wrapper>();
    public List<OLI_Wrapper> oProdAW = new List<OLI_Wrapper>();    

    // Constructor
    public OLI_Select_ap() {    

        // Get passed ID of Opportunity record
        getOIDQueryParameter();       

        // Select all OpportunityLineItems (Products) that can be converted to Assets
        // Don't include already converted items
        oSelect = false;
        aSelect = false;
        olis = [Select      ServiceDate,
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
                            Product2.RGID__c,
                            Product2.Svc_id_s__c,
                            Product2.Requires_Service_Number__c,
                            Phone_Number__c,
                            Asset_Type__c, 
                            Bulk_Asset__c,
                            OpportunityId 
                    FROM    OpportunityLineItem 
                    WHERE   IsConverted__c=false and
                            IsDeleted=false and
                            Account__c<>null and
                            Deliver_to_Account__c<>null and
                            OpportunityId =:Opp.Id 
                   ORDER BY QT_Line__c];    

        // Utilize the OLI list to set the oProd Wrapper Lists to be used by the VF Page          
        for(OpportunityLineItem o: olis) {
            if (o.Quantity > 0) {
                oProdW.add(new OLI_Wrapper(o, o.Id));     // Needs to be converted to Assets
                oSelect = true;
            }else{
                oProdAW.add(new OLI_Wrapper(o, o.Id));    // Needs to be assigned to existing Assets
                aSelect = true;
            }                
        } 
            
    }        
    
    // Parameter passed to the Visualforce page
    public Boolean getOIDQueryParameter(){
        Opp = new Opportunity(id=ApexPages.currentPage().getParameters().get('oid'));    
        opp.ContractId = [SELECT ID, ContractID FROM Opportunity WHERE ID =:Opp.id LIMIT 1].ContractID;    
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

    public List<OLI_Wrapper> getoProdAW(){
        return this.oProdAW;
    }

    // selectAll: checks/selects all checkboxes
    public PageReference selectAll() {
        for(OLI_Wrapper oW: oProdW){
            oW.setIsoProdSelected(chkSelection);
        }        
        return null;
    }

    // selectAll: checks/selects all checkboxes
    public PageReference selectUnass() {
        for(OLI_Wrapper oW: oProdAW){
            oW.setIsoProdSelected(assSelection);
        }        
        return null;
    }

    // Methods to process conversions after Create button is selected
    public PageReference create() {

        // Create list of selected OpportunityLineItem IDs
        oProdIds = new List<String>();     
        oProds = new List<OpportunityLineItem>();      
            for(OLI_Wrapper oW: oProdW){               
                testOLI = oW.getOLI();                
                testOLIid = oW.getOliID();             
                if(oW.getIsoProdSelected()) {                   
                    oProdIds.add(oW.getOliID());                    
                    oProds.add(testOLI);                   
                }               
            }
       
            for(OLI_Wrapper oW: oProdAW){
                testOLI = oW.getOLI();
                testOLIid = oW.getOliID();                
                if(oW.getIsoProdSelected()) {
                    oProdIds.add(oW.getOliID());
                    oProds.add(testOLI);
                }                 
            }        
            
        // Check for no Products selected
        if (oProds.size() == 0) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR: Please select at least one '+
                                        'Product to Convert to an Asset and/or at least one Product to assign Assets to!');
            ApexPages.addMessage(myMsg);
            return null;  
        }

        createAssets();

        /* OPFOCUS 7/25/18: Removing reference to visual flow*/
        // Update the changed Opportunity LineItem Fields
        //update(oProds);
     
        // Call the Visual Workflow that will create the Assets
        //Map<String, Object> params = new Map<String, Object>();
        //params.put('colIDs', oProdIds);     
        //Flow.Interview.Convert_to_Asset myFlow = new Flow.Interview.Convert_to_Asset(params);
        //myFlow.start();
      
        // Redirect back to the original Opportunity page
        PageReference returnPage = new ApexPages.StandardController(Opp).view();
        returnPage.setRedirect(true);
        return returnPage;               
    }

    // Methods to process changes after Assign Assets button is selected
    public PageReference assign() {

        // Get the OLI id from the row then button was pressed on
        testOLIid = this.assignID;

        // Get the ID of the Contract assigned to the Opportunity
        pcontract = opp.ContractId;
        if (String.isBlank(pcontract)) {
            pcontract = 'NoContractSelected';
        }

        // Call new VF page to select Assets
        PageReference assetPage = new PageReference('/apex/OLI_SelectA_vf?oliid='+testOLIid+
                                                    '&contractid='+pcontract+
                                                    '&retPage=/apex/OLI_Select_vf?oid='+Opp.id);
        assetPage.setRedirect(true);
        return assetPage;
        
    }
    
    // Methods to process changes after Cancel button is selected
    public PageReference cancel() {
        
        // Redirect back to the original Opportunity page
        PageReference returnPage = new ApexPages.StandardController(Opp).view();
        returnPage.setRedirect(true);
        return returnPage;    
    }

    /**
     * Originally a autolaunch flow "Create Assets". Creates asset records
     */
    private void createAssets(){
        List<Asset> assets = new List<Asset>();
        List<Asset> batchassets = new List<Asset>();
        // keep track of asset list count to avoid governor limits
        Integer assetCount = 0;
        Map<String,Service_Number__c> numberMap = new Map<String,Service_Number__c>();
        
        List<Service_Number__c> lstSN = [Select Id, Name from Service_Number__c where Opportunity__c =: opp.Id];
        for(Service_Number__c sn : lstSN){
            numberMap.put(sn.Name, sn);
        }
        SYstem.debug('number map:\n' + JSON.serializePretty(numberMap));

        Set<Id> olisNeedNumber = new Set<Id>();

        for(OpportunityLineItem oli : oProds){
            assetCount = assets.size();

            //// set phone number
            //String phoneNumber;
            //if(oli.Quantity == 1){
            //    if(oli.Phone_Number__c != null) phoneNumber = oli.Phone_Number__c;
            //    else if(oli.Description != null && oli.Description.trim().length() == 10) phoneNumber = oli.Description.trim();
            //}

            // check for 0 or negative quantities
            if(oli.Quantity <= 0){
                oli.IsConverted__c = true;
                continue;
            }

            Id snid;
            if(oli.Product2.Requires_Service_Number__c > 0){
                olisNeedNumber.add(oli.Id);
            }
            

            // init new asset record based on OLI data
            Asset a = new Asset();
            a.AccountId = oli.Account__c;
            a.Asset_Type__c = oli.Asset_Type__c;
            a.Converted_Asset__c = true;
            a.Description = oli.Description;
            a.Name = oli.Product_name__c;
            a.Oli_Id__c = oli.Id;
            a.Price = oli.UnitPrice;
            a.Product2Id = oli.Product2Id;
            a.Purchase_Opportunity__c = oli.OpportunityId;
            a.Quantity = oli.Quantity;
            a.Service_Address__c = oli.Service_Address__c;
            a.Status = 'In Turn-Up';
            a.Total_Asset_Price__c = oli.TotalPrice;
            a.Contract__c = Opp.ContractId;
            //a.Phone_Number__c = phoneNumber;
            a.RGID__c = oli.Product2.RGID__c;
            a.Svc_id_s__c = oli.Product2.Svc_id_s__c;
            // #1008
            //a.Service_Number__c = snid;

            // if bulk
            if(oli.Bulk_Asset__c){
                if(assetCount < 100) assets.add(a);
                else batchAssets.add(a);
            }
            // otherwise create asset for each quantity
            else{
                a.Quantity = 1;
                a.Total_Asset_Price__c = oli.UnitPrice;
                for(Integer i = 0; i < oli.Quantity; i++){
                    // offload asset records to batch mode when too many records need to be processed
                    if(assetCount > 99 || i > 99){
                        batchassets.add(a.clone());
                    }
                    else{
                        assets.add(a.clone());
                    }
                }
            }
            // mark oli as converted
            oli.IsConverted__c = true;
        }

        for(Asset[] lstAsset : new List<List<Asset>>{assets, batchAssets}){
            for(Asset a : lstAsset){
                // #1008
                //if(olisNeedNumber.contains(a.Oli_Id__c) && a.Service_Number__c == null && !numberMap.isEmpty()){
                //    System.debug('assiging asset manually');
                //    String randomNum = (new List<String>(numberMap.keySet()))[0];
                //    a.Service_Number__c = numberMap.get(randomNum).Id;
                //    numberMap.remove(randomNum);
                //}
            }
        }

        // if there is batching record, fire off batchable class
        if(!batchassets.isEmpty()){
            InsertAssetsFromOLI.batchAssets(batchassets);
        }

        // dml operations
        insert assets;
        update oProds;
    }

    
    
}