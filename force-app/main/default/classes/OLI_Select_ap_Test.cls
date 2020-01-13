/** 
* Project: Assets Phase 1
* Created By: GWI, Eric Smith
* Class: OLI_Select_ap_Test.apxc					
* Description: Test for OLI_Select_ap class
* 	Classes: OLI_Select_ap.apxc, OLI_Select_ap_Test.apxc, OLI_Wrapper	
* 	VisualForce Page: OLI_Select_vf.vfp	
*
**/

@isTest // Using isTest annotation
private class OLI_Select_ap_Test {
    
    // Test Methods

    public static testMethod void testAll() {
        
        PageReference upPage;
        OLI_Select_ap OLISL;
        Account a1, ap;
        Service_Address__c sa1, sap;
        Opportunity o1;
        OpportunityLineItem oli1;
        Asset as1;
        PageReference OP;
        List<OpportunityLineItem> oliList;
        List<OLI_Wrapper> aList, wList;
            
    

			// Create and Insert Accounts
			//ap = new Account(Name='Parent');
            ap = DataFactory.buildAccount('Parent');
            insert ap;
            //a1 = new Account(Name='CTest', Parent=ap);
            a1 = DataFactory.buildAccount('CTest');
            a1.Parent=ap;
            insert a1;
            
            // Create and Insert Service Addresses
            sap = DataFactory.buildServiceAddress(ap.Id, 'Parent', null);//new Service_Address__c(Name='Parent', Account__c=ap.id);
            upsert sap;
            sa1 = DataFactory.buildServiceAddress(a1.Id, 'SATest1', null);//new Service_Address__c(Name='SATest1', Account__c=a1.id);
            upsert sa1;
            
            // Create and Insert Opportunity
            o1 = DataFactory.buildOpportunity('CTestOpp', 'New Customer', a1.Id, null);
            o1.Term_months__c = '36';
            o1.StageName = 'Closed Won';
            o1.CloseDate = SYstem.today();
            //o1 = new Opportunity(Name='CTestOpp', AccountId=a1.Id, Type='New Customer', Term_months__c='36', StageName='Closed Won', CloseDate=Date.today());
            //o1.Default_Delivery_Method__c = 'Copper';
            insert o1;
            
            // Create and Insert Opportunity LineItem
			Id pricebookId = Test.getStandardPricebookId();
            
                // Create product
                //Product2 prod = new Product2(
                //     Name = 'Product X',
                //     ProductCode = 'Pro-X',
                //     isActive = true, Asset_Type__c='Service', Requires_Service_Number__c = 1
                //);
                Product2 prod = DataFactory.buildProduct('Product X', 'Service');
                prod.ProductCode = 'Pro-X';
                prod.Requires_Service_Number__c = 1;
                insert prod;
                
                //Create pricebook entry
                //PricebookEntry pbEntry = new PricebookEntry(
                //     Pricebook2Id = pricebookId,
                //     Product2Id = prod.Id,
                //     UnitPrice = 100.00,
                //     IsActive = true
                //);
                PriceBookEntry pbEntry = DataFactory.buildPBE(prod.Id);
                insert pbEntry;
                
                // Create and Insert an Opportunity Line Item
                List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
                oli1 = DataFactory.buildOLI(o1.Id, pbEntry.Id, 2);
                oli1.UnitPrice = null;
                oli1.Account__c = a1.Id;
                oli1.Deliver_to_Account__c = a1.Id;
                oli1.Description = 'xxx';
                oli1.TotalPrice = 200;
                oli1.Service_Address__c = sa1.Id;
                olis.add(oli1);

                OpportunityLineItem oli2 = DataFactory.buildOLI(o1.Id, pbEntry.Id, -1);
                oli2.UnitPrice = null;
                oli2.Account__c = a1.Id;
                oli2.Deliver_to_Account__c = a1.Id;
                oli2.Description = 'xxx';
                oli2.TotalPrice = -200;
                oli2.Service_Address__c = sa1.Id;
                olis.add(oli2);
                //olis.add(new OpportunityLineItem(OpportunityId=o1.id, Account__c=a1.id, Deliver_to_Account__c=a1.id, IsConverted__c=false, Description='xxx',
                //                                 Service_Address__c=sa1.id, Quantity=2, TotalPrice=200, PriceBookEntryID=pbEntry.Id));
                //olis.add(new OpportunityLineItem(OpportunityId=o1.id, Account__c=a1.id, Deliver_to_Account__c=a1.id, IsConverted__c=false, Description='xxx',
                //                                 Service_Address__c=sa1.id, Quantity=-1, TotalPrice=-200, PriceBookEntryID=pbEntry.Id));
                insert olis;

            // Create Asset
            //as1 = new Asset(Name='Test Asset', AccountId=a1.id, Description = olis[1].Description, Product2Id=Prod.Id, Quantity=1, Asset_Type__c='Service');
            as1 = DataFactory.buildAsset(o1.Id, olis[1], prod, a1.Id, null);
            as1.Quantity = 1;
            as1.Purchase_Opportunity__c = null;
            as1.Oli_Id__c = null;
            as1.Name = 'Test Asset';
            insert as1;
            
            // Run with Valid OID
            upPage = new PageReference('/apex/OLI_Select_ap?oid='+ o1.Id);
            Test.setCurrentPage(upPage);
            
            Test.startTest();
            
            OP = new ApexPages.StandardController(o1).view();
            OLISL = new OLI_Select_ap();
            
			// Testing getters
			system.assertEquals(o1.id,OLISL.getOpp().id);
            system.assertEquals(o1.id,OLISL.getOpportunityID());
            system.assertEquals(null,OLISL.getoProdStatus().id);
            oliList = OLISL.getOlis();              
            system.assert(oliList.size()==2);
            wList = OLISL.getoProdW();
            system.assert(wList.size()==1);
            aList = OLISL.getoProdAW();
            system.assert(aList.size()==1);         
            
            // Testing SelectAll Button
            OLISL.chkSelection = true;            
            PageReference selPage = OLISL.selectAll();

            // Testing Create Assets Button
            PageReference savePage = OLISL.create();
            Asset[] la = [Select AccountId, Asset_Type__c, Converted_Asset__c, Description, Name, Oli_Id__c, Price, Product2Id,
                Purchase_Opportunity__c, Quantity, Service_Address__c, Status, Total_Asset_Price__c, Contract__c, Phone_Number__c,
                RGID__c, Svc_id_s__c
                from Asset];
            System.debug('****** testjson\n\n' + JSON.serializePretty(la));

            for(Asset a : la){
                if(a.Oli_Id__c == null){
                    System.assertEquals(false, a.Converted_Asset__c);
                }
                else{
                    System.assertEquals(true, a.Converted_Asset__c);
                    System.assertEquals(100, a.Price);
                    System.assertEquals(o1.Id, a.Purchase_Opportunity__c);
                    System.assertEquals(sa1.Id, a.Service_Address__c);
                    System.assertEquals(olis[0].Id, a.Oli_Id__c);
                    System.assertEquals('In Turn-Up', a.Status);
                    System.assertEquals('xxx', a.Description);
                }
            }

			System.AssertEquals(savePage.getUrl(), OP.getUrl()); 

            // Testing none selected
            OLISL.chkSelection = false;            
            PageReference selPage2 = OLISL.selectAll();
			PageReference savePage2 = OLISL.create(); 
            
            // Testing selectUnass Button
            OLISL.assSelection = true;
            PageReference deselPage = OLISL.selectUnass();

            // Testing Assign Button
            PageReference assignPage = OLISL.assign();
          
            // Testing Error Message
            PageReference errorPage = OLISL.create();
           
            // Testing Cancel Button
            OLISL = new OLI_Select_ap();
            PageReference cancelPage = OLISL.cancel();            
            System.AssertEquals(cancelPage.getUrl(), OP.getUrl());

            Test.stopTest();
            
        
    }

    public static testMethod void batchTest() {
        
        PageReference upPage;
        OLI_Select_ap OLISL;
        Account a1, ap;
        Service_Address__c sa1, sap;
        Opportunity o1;
        OpportunityLineItem oli1;
        Asset as1;
        PageReference OP;
        List<OpportunityLineItem> oliList;
        List<OLI_Wrapper> aList, wList;
            
            // Create and Insert Accounts
            //ap = new Account(Name='Parent');
            ap = DataFactory.buildAccount('Parent');
            insert ap;
            //a1 = new Account(Name='CTest', Parent=ap);
            a1 = DataFactory.buildAccount('CTest');
            a1.Parent=ap;
            insert a1;
            
            // Create and Insert Service Addresses
            sap = DataFactory.buildServiceAddress(ap.Id, 'Parent', null);//new Service_Address__c(Name='Parent', Account__c=ap.id);
            upsert sap;
            sa1 = DataFactory.buildServiceAddress(a1.Id, 'SATest1', null);//new Service_Address__c(Name='SATest1', Account__c=a1.id);
            upsert sa1;
            
            // Create and Insert Opportunity
            o1 = DataFactory.buildOpportunity('CTestOpp', 'New Customer', a1.Id, null);
            o1.Term_months__c = '36';
            o1.StageName = 'Closed Won';
            o1.CloseDate = SYstem.today();
            insert o1;


            Service_Number__c sn1 = DataFactory.buildServiceNumber(o1.Id, '123456789', 'P', 'CL');//new Service_Number__c();
            Service_Number__c sn2 = DataFactory.buildServiceNumber(o1.Id, '987654321', 'P', 'CL');//new Service_Number__c();
            insert new Service_Number__c[]{sn1,sn2}; 
            
            // Create and Insert Opportunity LineItem
            Id pricebookId = Test.getStandardPricebookId();
            
                // Create product
                Product2 prod = DataFactory.buildProduct('Product X', 'Service');
                prod.ProductCode = 'Pro-X';
                prod.Requires_Service_Number__c = 1;
                insert prod;
                
                PriceBookEntry pbEntry = DataFactory.buildPBE(prod.Id);
                insert pbEntry;
                
                // Create and Insert an Opportunity Line Item
                List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
                oli1 = DataFactory.buildOLI(o1.Id, pbEntry.Id, 150);
                oli1.UnitPrice = null;
                oli1.Account__c = a1.Id;
                oli1.Deliver_to_Account__c = a1.Id;
                oli1.Description = 'xxx';
                oli1.TotalPrice = 200;
                oli1.Service_Address__c = sa1.Id;
                olis.add(oli1);

                OpportunityLineItem oli2 = DataFactory.buildOLI(o1.Id, pbEntry.Id, 1);
                oli2.UnitPrice = null;
                oli2.Account__c = a1.Id;
                oli2.Deliver_to_Account__c = a1.Id;
                oli2.Description = 'xxx';
                oli2.TotalPrice = 200;
                oli2.Service_Address__c = sa1.Id;
                olis.add(oli2);
                
                // Create and Insert an Opportunity Line Item
                //List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
                //olis.add(new OpportunityLineItem(OpportunityId=o1.id, Account__c=a1.id, Deliver_to_Account__c=a1.id, IsConverted__c=false, Description='xxx',
                //                                 Service_Address__c=sa1.id, Quantity=150, TotalPrice=200, PriceBookEntryID=pbEntry.Id));  
                //olis.add(new OpportunityLineItem(OpportunityId=o1.id, Account__c=a1.id, Deliver_to_Account__c=a1.id, IsConverted__c=false, Description='xxx',
                //                                 Service_Address__c=sa1.id, Quantity=1, TotalPrice=200, PriceBookEntryID=pbEntry.Id));             
                insert olis;

        
            
            // Run with Valid OID
            upPage = new PageReference('/apex/OLI_Select_ap?oid='+ o1.Id);
            Test.setCurrentPage(upPage);
            
            Test.startTest();
            
            OP = new ApexPages.StandardController(o1).view();
            OLISL = new OLI_Select_ap();
            
            // Testing getters
            system.assertEquals(o1.id,OLISL.getOpp().id);
            system.assertEquals(o1.id,OLISL.getOpportunityID());
            system.assertEquals(null,OLISL.getoProdStatus().id);
            oliList = OLISL.getOlis();              
            system.assert(oliList.size()==2);
            wList = OLISL.getoProdW();
            system.assert(wList.size()==2);
            aList = OLISL.getoProdAW();
            system.assert(aList.size()==0);         
            
            // Testing SelectAll Button
            OLISL.chkSelection = true;            
            PageReference selPage = OLISL.selectAll();

            // Testing Create Assets Button
            PageReference savePage = OLISL.create();

            Test.stopTest();
            
            System.assertEquals(151, [Select count() from Asset]);
        
    }
}