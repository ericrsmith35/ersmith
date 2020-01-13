/** 
 Project: Assets Phase 2
 Created By: GWI, Eric Smith
 Class: OLI_SelectT_ap_Test.apxc                    
 Description: Test for OLI_SelectT_ap class
    Classes: OLI_SelectT_ap.apxc, OLI_SelectT_ap_Test.apxc, Asset_Wrapper   
    VisualForce Page: OLI_SelectT_vf.vfp    

**/

@isTest // Using isTest annotation
private class OLI_SelectT_ap_Test {
    
    // Test Methods

    public static testMethod void testAll() {
        
        PageReference upPage, upPage2;
        OLI_SelectT_ap OLISL, OLISL2;
        Account a1, ap;
        Service_Address__c sa1, sap;
        Opportunity o_nc, o_sr;
        OpportunityLineItem oli1;
        Contract c;
        Asset as1;
        PageReference OP;
        List<Asset> assList;
        List<Asset_Wrapper> aList;
            
        try {       

            // Create and Insert Accounts
            ap = DataFactory.buildAccount('Parent');
            insert ap;
            a1 = DataFactory.buildAccount('CTest');
            a1.Parent = ap;
            insert a1;
            
            // Create and Insert Service Addresses
            sap = DataFactory.buildServiceAddress(ap.Id, 'Parent', null);
            insert sap;
            //sa1 = new Service_Address__c(Name='SATest1', Account__c=a1.id);
            sa1 = DataFactory.buildServiceAddress(a1.Id, 'SATest1', null);
            insert sa1;
            
            // Create Contact
            //Contact con = new Contact(LastName='Contact', AccountId=a1.id);
            Contact con = DataFactory.buildContact('Contact', a1.Id);
            upsert con;
            
            // Create Contract
            //c = new Contract(AccountID=a1.id, Status='Draft', StartDate=Date.today(), ContractTerm=12, Auto_Renew__c='Included',
                            //CustomerSignedDate=Date.today(), CompanySignedDate=Date.today(), CustomerSignedId=con.id, CompanySignedId=UserInfo.getUserId());
            c = DataFactory.buildContract(null, a1.Id);
            c.Auto_Renew__c = 'Included';
            c.CustomerSignedDate=Date.today();
            c.CompanySignedDate=Date.today();
            c.CustomerSignedId=con.Id;
            c.CompanySignedId=UserInfo.getUserId();
            insert c;
            c.Status = 'Activated';
            update c;
                        
            // Set Pricebook
            Id pricebookId = Test.getStandardPricebookId();
            
            // Create and Insert Opportunity's

            o_nc = DataFactory.buildOpportunity('CTestOpp_nc','New Customer', a1.Id, null);
            o_nc.Term_Months__c = '36';
            o_nc.CSD_Progress_Notes__c = 'This is a test';
            o_nc.StageName = 'Closed Won';
            o_nc.Pricebook2Id = null;

            o_sr = DataFactory.buildOpportunity('CTestOpp_sr','Service Reduction', a1.Id, null);
            o_sr.Term_Months__c = '36';
            o_sr.CSD_Progress_Notes__c = 'This is a test';
            o_sr.StageName = 'Closed Won';

            insert new Opportunity[]{o_nc, o_sr};          

            
            Product2 prod = DataFactory.buildProduct('Product X', 'CPE');
            insert prod;
            
          
            PricebookEntry pbEntry = DataFactory.buildPBE(prod.Id);
            insert pbEntry;
            
            // Create and Insert an Opportunity Line Item
            List<OpportunityLineItem> olis = new List<OpportunityLineItem>();                 
            oli1 = DataFactory.buildOLI(o_nc.Id, pbEntry.Id, -1);
            oli1.Account__c = a1.Id;
            oli1.Deliver_to_Account__c = a1.Id;
            oli1.Service_Address__c = sa1.Id;
            olis.add(oli1);
            insert olis;
            
    
           
            
            as1 = DataFactory.buildAsset(null, oli1, prod, a1.Id, 'Active');
            as1.In_Production__c = true;
            as1.Quantity = 1;
            as1.Contract__c = c.Id;
            as1.Oli_Id__c = null;
            upsert as1;

            // Run with New Customer, No Contract
            upPage = new PageReference('/apex/OLI_SelectT_ap?oppid='+o_nc.Id+'&contractID=NoContractLinked');
            Test.setCurrentPage(upPage);
            
            Test.startTest();
            
            OP = new ApexPages.StandardController(o_nc).view();
            OLISL = new OLI_SelectT_ap();
            
            // Testing getters
            system.assertEquals('New Customer', OLISL.getOpportunityType());            
                
            // Testing Cancel Button
            OLISL = new OLI_SelectT_ap();
            PageReference cancelPage = OLISL.cancel();            

            // Run with Service Reduction, Contract
            upPage2 = new PageReference('/apex/OLI_SelectT_ap?oppid='+o_sr.Id+'&contractID='+c.Id);
            Test.setCurrentPage(upPage2);

            OP = new ApexPages.StandardController(o_sr).view();
            OLISL2 = new OLI_SelectT_ap();
            
            // Testing getters
            
            system.assertEquals('Service Reduction', OLISL2.getOpportunityType());          
            
            // Different Opportunity Type
            //o_nc.Type = 'Service Reduction';
            //contractID = c.Id;
            //update o_nc;
            
            // Testing getters          
            system.assertEquals(null,OLISL2.getoAssetStatus().id);           
            assList = OLISL2.getAsss();                   
            system.assert(assList.size()==1);
            aList = OLISL2.getoAssetW();
            system.assert(aList.size()==1);
                        
            // Testing SelectOne Button
            PageReference selPage2 = OLISL2.selectOne();   
            
            // Testing SelectAll Button
            OLISL2.chkSelection = true;            
            PageReference selPage = OLISL2.selectAll();
        
            // Testing Assign Button       
            PageReference savePage = OLISL2.selecta();
            PageReference savePage2 = OLISL2.selecta(); // After Error Message  
            
            // Test OLIBeforeDelete Trigger
            //olis[0].IsConverted__c = true;
            //update olis;   
            //try{
            //  delete olis[0];
            //    system.assert(1==0);  // This should not execute due to OLIBeforeDelete trigger
            //} catch (Exception e){
            //    //system.assert(e.getMessage()=='FIELD_CUSTOM_VALIDATION_EXCEPTION, Cannot Delete Opportunity Product because its has been converted to an Asset: []');
            //}
            //system.assert(olis.size()==1);
            
            Test.stopTest();
            
        } catch (Exception e){
            System.debug('Unwanted Excpetion Caught: ' + e.getMessage());
            
        }
    }
}