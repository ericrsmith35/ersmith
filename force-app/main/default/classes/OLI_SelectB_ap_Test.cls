/** 
* Project: Assets Phase 1
*  Project: Assets Phase 2
*  Created By: GWI, Eric Smith
*  Class: OLI_SelectB_ap_Test.apxc					
*  Description: Test for OLI_SelectB_ap class
*  	Classes: OLI_SelectB_ap.apxc, OLI_SelectB_ap_Test.apxc, OLI_Wrapper, Asset_Wrapper
*  	VisualForce Page: OLI_SelectB_vf.vfp	
* 
**/

@isTest // Using isTest annotation
private class OLI_SelectB_ap_Test {
    
    // Test Methods

    public static testMethod void testAll() {
        
        PageReference upPage;
        OLI_SelectB_ap OLISL;
        Account a1, ap;
        Service_Address__c sa1, sap;
        Opportunity o1;
        OpportunityLineItem oli1;
        PageReference OP;
        List<OpportunityLineItem> oliList;
        List<OLI_Wrapper> wList;
        Asset ass;
        List<Asset> assList;
        List<Asset_Wrapper> waList;
            
        //try {       

			// Create and Insert Accounts
			//ap = new Account(Name='Parent', Active__c=true);
            ap = DataFactory.buildAccount('Parent');
            ap.Active__c = true;
            insert ap;
            //a1 = new Account(Name='CTest', Plat_ID__c='123456', Plat_Version__c='6', Active__c=true, Parent=ap);
            a1 = DataFactory.buildAccount('CTest');
            a1.Plat_ID__c = '123456';
            a1.Plat_Version__c = '6';
            a1.Active__c = true;
            a1.Parent = ap;
            insert a1;
            
            // Create and Insert Service Addresses
            //sap = new Service_Address__c(Name='Parent', Account__c=ap.id);
            sap = DataFactory.buildServiceAddress(ap.Id, 'Parent', null);
            insert sap;
            //sa1 = new Service_Address__c(Name='SATest1', Account__c=a1.id);
            sa1 = DataFactory.buildServiceAddress(a1.Id, 'SATest1', null);
            upsert sa1;
            
            // Create and Insert Opportunity
            o1 = DataFactory.buildOpportunity('CTestOpp', 'Service Reduction', a1.Id, null);
            o1.Term_months__c = '36';
            o1.StageName = 'Closed Won';
            o1.Billable_Date__c = Date.today();
            o1.CSD_Progress_Notes__c = 'This is a test';
            //o1 = new Opportunity(Name='CTestOpp', AccountId=a1.Id, Type='Service Reduction', Term_months__c='36', StageName='Closed Won', 
                                 //CloseDate=Date.today(), Billable_Date__c=Date.today(), Inst_Date__c=null, CSD_Progress_Notes__c='This is a test'); 
            
            insert o1;           
            
            // Create and Insert Opportunity LineItem
			Id pricebookId = Test.getStandardPricebookId();
            
                // Create product
                //Product2 prod = new Product2(
                //     Name = 'Product X',
                //     ProductCode = 'Pro-X',
                //     Asset_Type__c = 'CPE',
                //     isActive = true
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
                
                Product2 prod = DataFactory.buildProduct('Product X', 'CPE');
                prod.ProductCode = 'Pro-X';
                insert prod;

                PricebookEntry pbEntry = DataFactory.buildPBE(prod.Id);
                insert pbEntry;
                // Create and Insert an Opportunity Line Item
                List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
                oli1 = DataFactory.buildOLI(o1.Id, pbEntry.Id, 1);
                oli1.IsConverted__c = true;
                oli1.Deliver_to_Account__c = a1.Id;
                oli1.Service_Address__c = sa1.Id;
                olis.add(oli1);
                //olis.add(new OpportunityLineItem(OpportunityId=o1.id, Account__c=a1.id, IsConverted__c=True, Deliver_to_Account__c=a1.id,
                                                 //Service_Address__c=sa1.id, Quantity=1, TotalPrice=200, PriceBookEntryID=pbEntry.Id));           
                insert olis;

            	//Create Assets
            	List<Asset> alis;// = new List<Asset>();
            	//alis.add(new Asset(
             //   	Product2Id = prod.Id,
             //       AccountId = a1.id,
             //       Purchase_Opportunity__c = o1.id,
             //       Name = 'Product X',
             //       Asset_Type__c = 'CPE',
             //       Status = 'In Turn-Up',
             //       Quantity = 1
             //   ));
            	//alis.add(new Asset(
             //   	Product2Id = prod.Id,
             //       AccountId = a1.id,
             //       Disconnect_Opportunity__c = o1.id,
             //       Name = 'Product X',
             //       Asset_Type__c = 'CPE',
             //       Status = 'Selected for Turn-Down',
             //       Quantity = 1
             //   ));
                
                Asset as1 = DataFactory.buildAsset(o1.Id, olis[0], prod, a1.Id, 'In Turn-Up');
                Asset as2 = DataFactory.buildAsset(null, olis[0], prod, a1.Id, 'Selected for Turn-Down');
                as2.Disconnect_Opportunity__c = o1.Id;
                alis = new Asset[]{as1,as2};
            	insert alis;
          
            // Run with Valid OID
            upPage = new PageReference('/apex/OLI_SelectB_ap?oid='+ o1.Id);
            Test.setCurrentPage(upPage);
            
            //Test.startTest();
            
            OP = new ApexPages.StandardController(o1).view();
            OLISL = new OLI_SelectB_ap();
            
			// Testing getters
			system.assertEquals(o1.id,OLISL.getOpp().id);
            system.assertEquals(o1.id,OLISL.getOpportunityID());
            system.assertEquals(null,OLISL.getoProdStatus().id);           
            oliList = OLISL.getOlis();          
            system.assert(oliList.size()==1);
            assList = OLISL.getAlis();
            system.assert(assList.size()==2);
            wList = OLISL.getoProdW();
            system.assert(wList.size()==1);
            waList = OLISL.getoAssW();
            system.assert(waList.size()==2);
            
            // Testing SelectAll Button
            OLISL.chkSelection = true;            
            PageReference selPage = OLISL.selectAll();
            OLISL.chkSelectionA = true;            
            PageReference selPage3 = OLISL.selectAllA();
            
            // Testing Billing Enable Button
            o1.Billable_Date__c = date.today();
            update o1;           
            Test.startTest();
            PageReference savePage = OLISL.enable();
            Test.stopTest();

            Asset[] la = [Select Id, Oli_Id__c, In_Production__c, Status, InstallDate, Removal_Date__c, Asset_Type__c, Quantity, UsageEndDate, Name from Asset];
            System.debug('%%%%%%%%%% testjson assets line134\n\n' + JSON.serializePretty(la));
            for(Asset updass : la){
                if(updass.Id == alis[0].Id){
                    System.assertEquals(true, updass.In_Production__c);
                    System.assertEquals('Active', updass.Status);
                    System.assertEquals(o1.Billable_Date__c, updass.InstallDate);
                }
                else{
                    System.assertEquals(false, updass.In_Production__c);
                    System.assertEquals('Selected for Turn-Down', updass.Status);
                    System.assertEquals(o1.Billable_Date__c, updass.Removal_Date__c);
                }
            }
            OpportunityLineItem[] lo = [Select Id, Billing_Enabled__c, Date_Sent_To_Billing__c, Product2Id from OpportunityLineItem];
            System.debug('%%%%%%%%%% testjson oli line135\n\n' + JSON.serializePretty(lo));
            for(OpportunityLineItem opli : lo){
                System.assertEquals(true, opli.Billing_Enabled__c);
                System.assertEquals(System.today(), opli.Date_Sent_to_Billing__c);
            }
            
			System.AssertEquals(savePage.getUrl(), OP.getUrl()); 

			// Testing Account w/o Plat ID
			a1.Plat_ID__c = null;
			update a1;

            PageReference savePage0 = OLISL.enable();
			a1.Plat_ID__c = '123456';
			update a1;
            
            // Testing None Selected Error Message
            OLISL.chkSelection = false; 
            PageReference selPage2 = OLISL.selectAll();
            OLISL.chkSelectionA = false;
            PageReference selPage4 = OLISL.selectAllA();
            PageReference errorPage = OLISL.enable();            
            
            // Testing Blank Date Error Message
            //OLISL.beOpp.Billable_Date__c = null;          
            //PageReference savePage2 = OLISL.enable();            
			
            // Testing Need Turn-Up Date Error Message
            //OLISL.chkSelection = true;            
            //PageReference selPage3 = OLISL.selectAll();
            //olis.add(new OpportunityLineItem(OpportunityId=o1.id, Account__c=a1.id, IsConverted__c=True, Deliver_to_Account__c=a1.id,
            //                                     Service_Address__c=sa1.id, Quantity=1, TotalPrice=200, PriceBookEntryID=pbEntry.Id));
            //upsert olis;
            //PageReference errorPage2 = OLISL.enable();            
			
            // Testing Service Reduction Error Message
            //PageReference errorPage3 = OLISL.enable();            
            
            // Testing Cancel Button
            OLISL = new OLI_SelectB_ap();
            PageReference cancelPage = OLISL.cancel();            
            System.AssertEquals(cancelPage.getUrl(), OP.getUrl());

            //Test.stopTest();
            
        //} catch (Exception e){
        //    System.debug('Unwanted Excpetion Caught: ' + e.getMessage());
            
        //}
    }
}