/** 
 Project: Assets Phase 2
 Created By: GWI, Eric Smith
 Class: OLI_SelectR_ap_Test.apxc					
 Description: Test for OLI_SelectR_ap class
 	Classes: OLI_SelectR_ap.apxc, OLI_SelectR_ap_Test.apxc, OLI_Wrapper	
 	VisualForce Page: OLI_SelectR_vf.vfp	

**/

@isTest // Using isTest annotation
private class OLI_SelectR_ap_Test {
    
    // Test Methods

    public static testMethod void testAll() {
        
        PageReference upPage;
        OLI_SelectR_ap OLISL;
        Account a1, ap;
        Service_Address__c sa1, sap;
        Opportunity o1;
        OpportunityLineItem oli1;
        PageReference OP;
        List<OpportunityLineItem> oliList;
        List<OLI_Wrapper> wList;
            
        try {       

			// Create and Insert Accounts
			//ap = new Account(Name='Parent', Active__c=true);
            ap = DataFactory.buildAccount('Parent');
            ap.Active__c = true;
            insert ap;
            a1 = DataFactory.buildAccount('CTest');
            a1.Plat_ID__c = '123456';
            a1.Plat_Version__c = '6';
            a1.Active__c = true;
            a1.Parent = ap;
            //a1 = new Account(Name='CTest', Plat_ID__c='123456', Plat_Version__c='6', Active__c=true, Parent=ap);
            insert a1;
            
            // Create and Insert Service Addresses
            sap = DataFactory.buildServiceAddress(ap.Id, 'Parent', null);
            insert sap;
            //sa1 = new Service_Address__c(Name='SATest1', Account__c=a1.id);
            sa1 = DataFactory.buildServiceAddress(a1.Id, 'SATest1', null);
            insert sa1;
            
            // Create and Insert Opportunity
            o1 = new Opportunity(Name='CTestOpp', AccountId=a1.Id, Type='Service Reduction', Term_months__c='36', StageName='Closed Won', 
                                 CloseDate=Date.today(), Billable_Date__c=Date.today(), Inst_Date__c=null, CSD_Progress_Notes__c='This is a test'); 
            o1 = DataFactory.buildOpportunity('CTestOpp', 'Service Reduction', a1.Id, null);
            o1.Term_Months__c = '36';
            o1.Billable_Date__c = Date.today();
            o1.CSD_Progress_Notes__c = 'Test is a test';
            insert o1;           
            
            // Create and Insert Opportunity LineItem
			Id pricebookId = Test.getStandardPricebookId();
            
                    // Create product
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
            
            // Run with Valid OID
            upPage = new PageReference('/apex/OLI_SelectR_ap?oid='+ o1.Id);
            Test.setCurrentPage(upPage);
            
            Test.startTest();
            
            OP = new ApexPages.StandardController(o1).view();
            OLISL = new OLI_SelectR_ap();
            
			// Testing getters
			system.assertEquals(o1.id,OLISL.getOpp().id);
            system.assertEquals(o1.id,OLISL.getOpportunityID());
            system.assertEquals(null,OLISL.getoProdStatus().id);           
            oliList = OLISL.getOlis();
            system.assert(oliList.size()==1);
            wList = OLISL.getoProdW();
            system.assert(wList.size()==1);
                
            // Testing SelectAll Button
            OLISL.chkSelection = true;            
            PageReference selPage = OLISL.selectAll();
            
            // Testing Billing Enable Button
            o1.Billable_Date__c = date.today();
            update o1;           
            PageReference savePage = OLISL.remove();
			System.AssertEquals(savePage.getUrl(), OP.getUrl()); 
			
            // Testing None Selected Error Message
            OLISL.chkSelection = false;            
            PageReference selPage2 = OLISL.selectAll();
            PageReference errorPage = OLISL.remove();            
            
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
            OLISL = new OLI_SelectR_ap();
            PageReference cancelPage = OLISL.cancel();            
            System.AssertEquals(cancelPage.getUrl(), OP.getUrl());
            
            // Test OLIBeforeDelete Trigger
            delete olis[0];
            
            Test.stopTest();
            
        } catch (Exception e){
            System.debug('Unwanted Excpetion Caught: ' + e.getMessage());
            
        }
    }
}