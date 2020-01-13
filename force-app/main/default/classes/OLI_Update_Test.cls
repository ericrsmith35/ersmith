/** 
 Project: Assets Phase 1
 Created By: GWI, Eric Smith
 Class: OLI_Update_Test.apxc					
 Description: Test for OLI_Update class
 	Classes: OLI_Update.apxc, OLI_Update_Test.apxc	
 	VisualForce Page: OLI_Update.vfp	

 Called from 'Update Products' Button on Products Related List on Opportunity Page

**/

@isTest // Using isTest annotation
private class OLI_Update_Test {
    
    // Test Methods

    public static testMethod void testAll() {
        
        PageReference upPage;
        OLI_Update OLIU;
        Account a1, ap;
        Service_Address__c sa1, sap;
        Opportunity o1;
        OpportunityLineItem oli1;
        PageReference OP;
        
        try {       

			// Create and Insert Accounts
            ap = DataFactory.buildAccount('Parent');
            insert ap;
            a1 = DataFactory.buildAccount('CTest');
            a1.Parent = ap;
            insert a1;

            sap = DataFactory.buildServiceAddress(ap.Id, 'Parent', null);
            insert sap;
            //sa1 = new Service_Address__c(Name='SATest1', Account__c=a1.id);
            sa1 = DataFactory.buildServiceAddress(a1.Id, 'SATest1', null);
            upsert sa1;
            
            // Create and Insert Opportunity
            o1 = DataFactory.buildOpportunity('CTestOpp', 'New Customer', a1.Id, null);
            o1.Term_months__c = '36';
            
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
                oli1.Deliver_to_Account__c = a1.Id;
                oli1.Service_Address__c = sa1.Id;
                olis.add(oli1);
                
                      
                insert olis;
            
            // Run with Valid OID
            upPage = new PageReference('/apex/OLI_Update?oid='+ o1.Id);
            Test.setCurrentPage(upPage);
            
            Test.startTest();
            
            OP = new ApexPages.StandardController(o1).view();
            
            // Test Picklist Builds for VFP
            OLIU = new OLI_Update();
            List<selectOption> hierList = OLIU.getAcctHierarchy();
            OLIU = new OLI_Update();
            List<selectOption> delvList = OLIU.getDelvServAddr();
            System.debug('d - '+delvList);            


            // Testing Save Button
            OLIU = new OLI_Update();
            PageReference savePage = OLIU.save();
			System.AssertEquals(savePage.getUrl(), OP.getUrl()); 
            
            // Testing Cancel Button
            OLIU = new OLI_Update();
            PageReference cancelPage = OLIU.cancel();            
            System.AssertEquals(cancelPage.getUrl(), OP.getUrl());

            Test.stopTest();
            
        } catch (Exception e){
            System.debug('Unwanted Excpetion Caught: ' + e.getMessage());
            
        }
    }
}