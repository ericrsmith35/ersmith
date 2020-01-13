/** 
 Project: Assets Phase 1
 Created By: GWI, Eric Smith
 Class: OLI_SelectA_ap_Test.apxc					
 Description: Test for OLI_SelectA_ap class
 	Classes: OLI_SelectA_ap.apxc, OLI_SelectA_ap_Test.apxc, Asset_Wrapper	
 	VisualForce Page: OLI_SelectA_vf.vfp	

**/

@isTest // Using isTest annotation
private class OLI_SelectA_ap_Test {
    
    // Test Methods

    public static testMethod void testAll() {
        
        PageReference upPage;
        OLI_SelectA_ap OLISL;
        Account a1, ap;
        Service_Address__c sa1, sap;
        Opportunity o1;
        OpportunityLineItem oli1;
        Contract c;
        Asset as1;
        PageReference OP;
        List<Asset> assList;
        List<Asset_Wrapper> aList;
            
        try {       

			// Create and Insert Accounts
			//ap = new Account(Name='Parent');
            ap = DataFactory.buildAccount('Parent');
            insert ap;
            //a1 = new Account(Name='CTest', Parent=ap);
            a1 = DataFactory.buildAccount('CTest');
            a1.Parent = ap;
            insert a1;
            
            // Create and Insert Service Addresses
            //sap = new Service_Address__c(Name='Parent', Account__c=ap.id);
            sap = DataFactory.buildServiceAddress(ap.Id, 'Parent', null);
            insert sap;
            //sa1 = new Service_Address__c(Name='SATest1', Account__c=a1.id);
            sa1 = DataFactory.buildServiceAddress(a1.Id, 'SATest1', null);
            insert sa1;
            
            // Create and Insert Opportunity
            //o1 = new Opportunity(Name='CTestOpp', AccountId=a1.Id, Type='New Customer', Term_months__c='36', StageName='Closed Won', 
            //                     CloseDate=Date.today(), Billable_Date__c=Date.today(), CSD_Progress_Notes__c='This is a test'); 
            o1 = DataFactory.buildOpportunity('CTestOpp', 'New Customer', a1.Id, null);
            o1.CloseDate = System.today();
            o1.Billable_Date__c = Date.today();
            o1.CSD_Progress_Notes__c = 'This is a test';
            o1.StageName = 'Closed Won';
            o1.Term_months__c = '36';
            insert o1;           
            
            // Create and Insert Opportunity LineItem
			Id pricebookId = Test.getStandardPricebookId();
            
                    // Create product
                //Product2 prod = new Product2(
                //     Name = 'Product X',
                //     ProductCode = 'Pro-X',
                //     isActive = true, Asset_Type__c='Service'
                //);
                //insert prod;
                
                ////Create pricebook entry
                //PricebookEntry pbEntry = new PricebookEntry(
                //     Pricebook2Id = pricebookId,
                //     Product2Id = prod.Id,
                //     UnitPrice = 100.00,
                //     IsActive = true
                //);
                //insert pbEntry;
                Product2 prod = DataFactory.buildProduct('Product X', 'Service');
                prod.ProductCode = 'Pro-X';
                insert prod;

                PriceBookEntry pbEntry = DataFactory.buildPBE(prod.Id);
                insert pbEntry;
                
                // Create and Insert an Opportunity Line Item
                List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
                oli1 = DataFactory.buildOLI(o1.Id, pbEntry.Id, -1);
                oli1.IsConverted__c = true;
                oli1.Account__c = a1.Id;
                oli1.Deliver_to_Account__c = a1.Id;
                oli1.Service_Address__c = sa1.Id;
                olis.add(oli1);
                //olis.add(new OpportunityLineItem(OpportunityId=o1.id, Account__c=a1.id, IsConverted__c=True, Deliver_to_Account__c=a1.id,
                //                                 Service_Address__c=sa1.id, Quantity=-1, TotalPrice=-200, PriceBookEntryID=pbEntry.Id));           
                insert olis;
            
            // Create Contact
            //Contact con = new Contact(LastName='Contact', AccountId=a1.id);
            Contact con = DataFactory.buildContact('Contact', a1.Id);
            insert con;
            
            // Create Contract
            //c = new Contract(AccountID=a1.id, Status='Draft', Opportunity__c=o1.id, StartDate=Date.today(), ContractTerm=12, Auto_Renew__c='Included',
                            //CustomerSignedDate=Date.today(), CompanySignedDate=Date.today(), CustomerSignedId=con.id, CompanySignedId=UserInfo.getUserId());
            c = DataFactory.buildContract(o1.Id, a1.Id);
            c.StartDate = Date.today();
            c.Auto_Renew__c = 'Included';
            c.CustomerSignedDate = Date.today();
            c.CompanySignedDate = Date.today();
            c.CustomerSignedId = con.Id;
            c.CompanySignedId = UserInfo.getUserId();
            insert c;
            
            // Create Asset
            //as1 = new Asset(Name='Test Asset', AccountId=a1.id, Oli_Id__c=olis[0].id, Description = olis[0].Description, 
            //                Product2Id=Prod.Id, Quantity=1, In_Production__c=true, Contract__c=c.id, Asset_Type__c='Service');
            as1 = DataFactory.buildAsset(o1.Id, olis[0], prod, a1.Id, null);
            as1.Quantity = 1;
            as1.In_Production__c = true;
            as1.Contract__c = c.Id;
            as1.Purchase_Opportunity__c = null;
            insert as1;
            
            // Run with Valid OLIID
            upPage = new PageReference('/apex/OLI_SelectA_ap?oliid='+olis[0].Id+'&retPage=/apex/OLI_Select_vf?oid='+o1.id);
            Test.setCurrentPage(upPage);
            
            Test.startTest();
            
            OP = new ApexPages.StandardController(o1).view();
            OLISL = new OLI_SelectA_ap();
            
			// Testing getters			
            system.assertEquals(null,OLISL.getoAssetStatus().id);           
            assList = OLISL.getAsss();
            system.assert(assList.size()==1);
            aList = OLISL.getoAssetW();
            system.assert(aList.size()==1);
                
            // Testing SelectAll Button
            OLISL.chkSelection = true;            
            PageReference selPage = OLISL.selectAll();
                        
            // Testing SelectOne Button
            PageReference selPage2 = OLISL.selectOne();
            
            // Testing Assign Button       
            PageReference savePage = OLISL.assign();
            PageReference savePage2 = OLISL.assign();	// After Error Message

            // Testing None Selected Error Message
            OLISL = new OLI_SelectA_ap();
			olis[0].Quantity = -99;
            upsert olis;
            PageReference errorPage = OLISL.assign();            

            // Testing Cancel Button
            OLISL = new OLI_SelectA_ap();
            PageReference cancelPage = OLISL.cancel();            

            Test.stopTest();
            
        } catch (Exception e){
            System.debug('Unwanted Excpetion Caught: ' + e.getMessage());
            
        }
    }
}