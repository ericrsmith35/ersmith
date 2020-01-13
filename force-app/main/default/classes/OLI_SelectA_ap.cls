/** 
 Project: Assets Phase 1
 Created By: GWI, Eric Smith
 Class: OLI_SelectA_ap.apxc                 
 Description: Class for selecting existing Assets to assign to OLIs
    Classes: OLI_SelectA_ap.apxc, OLI_SelectA_ap_Test.apxc, Asset_Wrapper   
    VisualForce Page: OLI_SelectA_vf.vfp    
 
**/

public with sharing class OLI_SelectA_ap {
    
    // SObject variables and Lists
    public OpportunityLineItem paramOLI {get; set;}
    public Contract paramContract {get; set;}
    public List<OpportunityLineItem> olis {get; set;}
    public List<Asset> asss {get; set;}
    public Asset ass, testASS;
    public string testASSid {get; set;}
    public boolean chkSelection {get; set;}
    public string oliid {get; set;}
    public string contractid {get; set;}    
    public double selQty {get; set;}
    public string selColor {get; set;}
    public string oliServAddr {get; set;}
    public boolean addrMatch {get; set;}
    public boolean warningMsg {get; set;}
    
    // Stores final list of selected oAssets
    public List<Asset> oAssets;
    public List<String> oAssetIds = new List<String>();

    // oAsset object for setting mass status on all entries from VF page.
    private Asset oAssetStatus = new Asset();
    
    // Asset_Wrapper lists - aid in defining the view that is displayed to the end-user
    public List<Asset_Wrapper> oAssetW = new List<Asset_Wrapper>();    

    // Constructor
    public OLI_SelectA_ap() {
        
        // First time in - no warnings
        warningMsg = false;
        
        // Get passed ID of OpportunityLineItem record
        getOIDQueryParameter();       

        // Get passed ID of Contract record
        getContractQueryParameter();      
        
        // Get OpportunityLineItem record
        olis = [SELECT      Product_Name__c,
                            Quantity,
                            Account__c,
                            Deliver_to_Account__c,
                            Service_Address__c,
                            Description,
                            IsConverted__c,
                            OpportunityId,
                            Product2Id
                    FROM    OpportunityLineItem
                    WHERE   ID=:oliid];   
        
        oliServAddr = olis[0].Service_Address__c;
          
        // Select all Assets that can be assigned to this Product
        asss = [SELECT      ID,
                            AccountId,
                            Name,
                            Asset_Type__c,
                            Status,
                            InstallDate,
                            Quantity,
                            Converted_Asset__c,
                            Service_Address__c,
                            Contract__c,
                            Contract_End_Date__c,
                            Purchase_Opportunity__c,
                            Disconnect_Opportunity__c,
                            Renewal_Opportunity__c,
                            In_Production__c,
                            Latest_Opportunity__c,
                            Product2Id,
                			Display_ID__c,
                            IsDeleted
                    FROM    Asset 
                    WHERE   IsDeleted=false and
                            AccountId =:olis[0].Account__c and
                            Product2Id =:olis[0].Product2Id and
                			Asset_Type__c <> 'CPE' and
                            In_Production__c = true
                   ORDER BY Contract_End_Date__c, Contract__c DESC NULLS LAST];    
       
        //Utilize the Asset list to set the oAsset Wrapper List to be used by the VF Page          
        for(Asset a: asss) {
            if (String.isBlank(contractid) || contractid == a.Contract__c) {
                ass = new Asset();
                ass = a.clone();
                oAssetW.add(new Asset_Wrapper(ass, a.Id));
            }
        } 

        getSelQty();      
        getSelColor();    
    }        
   
    // Parameters passed to the Visualforce page
    public Boolean getOIDQueryParameter(){
        paramOLI = new OpportunityLineItem(id=ApexPages.currentPage().getParameters().get('oliid'));
        oliid = paramOLI.id;
        return null;
    }

    public Boolean getContractQueryParameter(){
        system.debug(ApexPages.currentPage().getParameters().get('contractid'));
        system.debug(String.isBlank(ApexPages.currentPage().getParameters().get('contractid')));
        if (ApexPages.currentPage().getParameters().get('contractid') <> 'NoContractSelected') {
            paramContract = new Contract(id=ApexPages.currentPage().getParameters().get('contractid'));
            contractid = paramContract.id;  
        }
        return null;
    }
    
    public double getSelQty() {
        selQty = 0;
        for(Asset_Wrapper oW: oAssetW) {
            if(oW.getIsoAssetSelected()) {
                ass = [SELECT ID, Quantity FROM Asset WHERE ID =:oW.getAssID()]; 
                selQty = selQty + ass.Quantity;                
            }
        }
        return selQty;
    }   

    public string getSelColor() {
        if (math.abs(olis[0].Quantity) != selQty) {
            selColor='red';
        }else{
            selColor='green';
        }
        return selColor;
    }   
    
    public Asset getoAssetStatus() {
        return oAssetStatus;
    }

    public List<Asset_Wrapper> getoAssetW(){
        return this.oAssetW;
    }
    
    public List<Asset> getAsss() {
        return this.asss;
    }

    // selectAll: checks/selects all checkboxes
    public PageReference selectAll() {
        for(Asset_Wrapper oW: oAssetW){
            oW.setIsoAssetSelected(chkSelection);
        }
        getSelQty();
        getSelColor();        
        return null;
    }

    public PageReference selectOne() {
        getSelQty();
        getSelColor();        
        return null;                
    }
    
    // Methods to process conversions after Assign button is selected
    public PageReference assign() {
        
        // Create list of selected Asset IDs & update Asset fields
        oAssetIds = new List<String>();
        oAssets = new List<Asset>();
        selQty = 0;
        addrMatch = true;
        for(Asset_Wrapper oW: oAssetW){
            testASS = oW.getASS();
            testASSid = oW.getAssID();
            if(oW.getIsoAssetSelected()) {
                oAssetIds.add(testASSid);
                ass = [SELECT ID, Status, Service_Address__c, Quantity, Disconnect_Opportunity__c, Oli_Id__c
                       FROM Asset WHERE ID =:testASSid];
                ass.Status = 'In Turn Down';
                ass.Disconnect_Opportunity__c = olis[0].OpportunityId;
                ass.Oli_Id__c = olis[0].id;
                oAssets.add(ass);
                selQty = selQty + ass.Quantity;
                addrMatch = (addrMatch) && (ass.Service_Address__c == olis[0].Service_Address__c);
            }        
        }        
      
        // If not currently with Warning, Check for no Assets selected & Address mismatch
        if (!warningMsg) {
            if ((oAssets.size() == 0) ||(math.abs(olis[0].Quantity) != selQty)) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'WARNING: Quantity of Assets selected does not match the quantity of Product to be turned down!');
                ApexPages.addMessage(myMsg);
                warningMsg = true;
            }
    
            if (!AddrMatch) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'WARNING: Not all of the Asset Service Addresses match the Service Address of the Product to be turned down!');
                ApexPages.addMessage(myMsg);
                warningMsg = true;
            }
         
            if (warningMsg) return null;
        }
       
        // Update any field changes made to the OLI record & Assets records
        olis[0].IsConverted__c = true;
        update(olis);
        update(oAssets);        
        
        // Redirect back to the calling OLI selection page
        PageReference returnPage = new PageReference(ApexPages.currentPage().getParameters().get('retPage'));      
        returnPage.setRedirect(true);
        return returnPage;               
    }

    // Methods to process changes after Cancel button is selected
    public PageReference cancel() {
        
        // Redirect back to the calling OLI selection page
        PageReference returnPage = new PageReference(ApexPages.currentPage().getParameters().get('retPage'));      
        returnPage.setRedirect(true);
        return returnPage;    
    }

}