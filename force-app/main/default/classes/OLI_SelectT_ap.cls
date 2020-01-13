/** 
 Project: Assets Phase 2
 Created By: GWI, Eric Smith
 Class: OLI_SelectT_ap.apxc                 
 Description: Class for selecting existing CPE Assets from a Contract for Turn-Down on an Opportunity
    Classes: OLI_SelectT_ap.apxc, OLI_SelectT_ap_Test.apxc, Asset_Wrapper   
    VisualForce Page: OLI_SelectT_vf.vfp    
 
**/

public with sharing class OLI_SelectT_ap {
    
    // SObject variables and Lists
    public Opportunity paramOpp {get; set;}
    public Contract paramContract {get; set;}
    public List<Asset> asss {get; set;}
    public Asset ass, testASS;
    public string testASSid {get; set;}
    public boolean chkSelection {get; set;}
    public string oppid {get; set;}
    public string contractid {get; set;}    
    public boolean warningMsg {get; set;}    
    public string ContractNumber {get; set;}
    public List<Contract> conrec {get; set;}
    public string OpportunityType {get; set;}
    public List<Opportunity> opprec {get; set;}
    
    // Stores final list of selected oAssets
    public List<Asset> oAssets;
    public List<String> oAssetIds = new List<String>();

    // oAsset object for setting mass status on all entries from VF page.
    private Asset oAssetStatus = new Asset();
    
    // Asset_Wrapper lists - aid in defining the view that is displayed to the end-user
    public List<Asset_Wrapper> oAssetW = new List<Asset_Wrapper>();    

    // Constructor
    public OLI_SelectT_ap() {
        
        // First time in - no warnings
        warningMsg = false;
        
        // Get passed ID of Opportunity record
        getOppQueryParameter();       

        // Get passed ID of Contract record
        getContractQueryParameter();      
        
        // Get Opportunity Type
        getOpportunityType();
                       
        // Check for correct Opportunity Type for selecting Assets
        if (OpportunityType != 'Add/Move/Change' && OpportunityType != 'Service Reduction' && !OpportunityType.startsWith('Ren')){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Selecting Assets for Turn-Down is only valid for Opportunity Types: Add/Move/Change, Service Reduction or Renewal/With Changes!');
            ApexPages.addMessage(myMsg);
            warningMsg = true;
        }
        
        // Get Contract Number
        getContractNumber();
        
        // Check for no Contract linked to Opportunity
        if (ContractNumber == 'NoContractLinked'){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'You must first Select a Contract to link to this Opportunity before you can select Assets for Turn-Down!');
            ApexPages.addMessage(myMsg);
            warningMsg = true;
        }            

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
                ORDER BY Contract_End_Date__c, Contract__c DESC NULLS LAST];         
      
        // Select all Assets that can be assigned to this Opportunity
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
                            IsDeleted
                    FROM    Asset 
                    WHERE   IsDeleted = false and
                            Contract__c =:contractid and
                			Asset_Type__c = 'CPE' and
                            Status = 'Active' 
                   ORDER BY Contract_End_Date__c, Contract__c DESC NULLS LAST];    
      
        //Utilize the Asset list to set the oAsset Wrapper List to be used by the VF Page          
        for(Asset a: asss) {
            if (String.isBlank(contractid) || contractid == a.Contract__c) {
                ass = new Asset();
                ass = a.clone();
                oAssetW.add(new Asset_Wrapper(ass, a.Id));
            }
        } 
        
    }        
   
    // Parameters passed to the Visualforce page
    public Boolean getOppQueryParameter(){
        paramOpp = new Opportunity(id=ApexPages.currentPage().getParameters().get('oppid'));
        oppid = paramOpp.id;
        return null;
    }

    public Boolean getContractQueryParameter(){
        contractid = ApexPages.currentPage().getParameters().get('contractid');        
        if (contractid != 'NoContractLinked'){               
            paramContract = new Contract(id=ApexPages.currentPage().getParameters().get('contractid'));
            contractid = paramContract.id;
        }    
        return null;
    }

    // Other Code
    public string getContractNumber(){
        if (contractid != 'NoContractLinked'){
            conrec = [SELECT    ID,
                                ContractNumber
                        FROM    Contract
                        WHERE   ID =:contractid LIMIT 1];
            if (conrec.isEmpty()) return null;
            ContractNumber = conrec[0].ContractNumber;
        } else {
            ContractNumber = 'NoContractLinked';
        }
        return ContractNumber;
    }   
    
    public string getOpportunityType(){
        opprec = [SELECT    ID,
                            Type
                    FROM    Opportunity
                    WHERE   ID =:oppid LIMIT 1]; 
        OpportunityType = opprec[0].Type;    
        return OpportunityType;
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
        return null;
    }

    public PageReference selectOne() {  
        return null;                
    }
    
    // Methods to process conversions after Select button is selected
    public PageReference selecta() {
        
        if (!warningMsg){
            
            // Create list of selected Asset IDs & update Asset fields
            oAssetIds = new List<String>();
            oAssets = new List<Asset>();
            for(Asset_Wrapper oW: oAssetW){
                testASS = oW.getASS();
                testASSid = oW.getAssID();
                if(oW.getIsoAssetSelected()) {
                    oAssetIds.add(testASSid);
                    ass = [SELECT ID, Status, Service_Address__c, Quantity, Disconnect_Opportunity__c, Oli_Id__c
                           FROM Asset WHERE ID =:testASSid];
                    ass.Status = 'Selected for Turn-Down';
                    ass.Disconnect_Opportunity__c = oppid;
                    oAssets.add(ass);
                }        
            }        
           
            // Update any field changes made to the OAssets records
            update(oAssets);        
            
            // Call the Visual Workflow that will Update OLI fields
            //Map<String, Object> params = new Map<String, Object>();
            //params.put('colIDs', oAssetIds);
            //params.put('vOppID', oppid);
            //Flow.Interview.Create_OLI_from_Assets myFlow = new Flow.Interview.Create_OLI_from_Assets(params);
            //myFlow.start();
        }
        
        // Redirect back to the calling Opportunity page
        PageReference returnPage = new ApexPages.StandardController(paramOpp).view();      
        returnPage.setRedirect(true);
        return returnPage;               
    }

    // Methods to process changes after Cancel button is selected
    public PageReference cancel() {
        
        // Redirect back to the calling Opportunity page
        PageReference returnPage = new ApexPages.StandardController(paramOpp).view();      
        returnPage.setRedirect(true);
        return returnPage;    
    }

}