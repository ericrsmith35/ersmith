/** 
 Project: Assets Phase 1
 Created By: GWI, Eric Smith
 Class: OLI_SplitQty2_Tester.apxc					
 Description: Test for OLI_SplitQty2 class
 	Classes: OLI_SplitQty2.apxc, OLI_SplitQty2_Tester.apxc	
 	VisualForce Page: OLI_SplitQty2.vfp	

**/

@isTest // Using isTest annotation
private class OLI_SplitQty2_Tester {
    
    // Test Methods
    
    public static testMethod void testInvalidOIDQueryParam() {
        PageReference osqPage;
        OLI_SplitQty2 CSQ2;
        Opportunity o1;        
        String invalidOID;            
        
        try {
            invalidOID = '006123456789123';
            
            // Run with Invalid OID
            osqPage = new PageReference('/apex/OLI_SplitQty2?oid='+ invalidOID);
            Test.setCurrentPage(osqPage);
            
            Test.startTest();
            
            CSQ2 = new OLI_SplitQty2();
            
            Test.stopTest();
            
        } catch (Exception e) {
            System.AssertEquals(e.getMessage(), 'Invalid id: 006123456789123');
        }
    }

    public static testMethod void testButtons() {
        // Testing Cancel & Split
        PageReference osqPage;
        OLI_SplitQty2 CSQ2;
        Account a1;
        Opportunity o1;
        OpportunityLineItem oli1;
        Asset ass1, ass2;
        PageReference OP;
        
        Double q = 2.00;
        Double sq = 1.00;

        try {       

			// Create and Insert Account
            //a1 = new Account(Name='CTest');
            a1 = DataFactory.buildAccount('CTest');
            insert a1;
            
            // Create and Insert Opportunity
            //o1 = new Opportunity(Name='CTestOpp', AccountId=a1.Id, Type='New Customer', Term_months__c='36', 
                                 //StageName='Closed Won', CloseDate=Date.today()); 
            o1 = DataFactory.buildOpportunity('CTestOppp', 'New Customer', a1.Id, null);
            o1.Term_months__c = '36';
            o1.StageName = 'Closed Won';
            insert o1;

            // Run with Valid OID
            osqPage = new PageReference('/apex/OLI_SplitQty2?oid='+ o1.Id);
            Test.setCurrentPage(osqPage);
            
            Test.startTest();
            
            OP = new ApexPages.StandardController(o1).view();
            
            CSQ2 = new OLI_SplitQty2();
            
            // Testing Cancel Button
            PageReference cancelPage = CSQ2.cancel();
            
            System.AssertEquals(cancelPage.getUrl(), OP.getUrl());

            // Testing Split Button without any Opportunity Line Items [including case for none selected]
            CSQ2 = new OLI_SplitQty2();
            PageReference SP = CSQ2.split();
            
            System.AssertEquals(SP.getUrl(), OP.getUrl());
            
            // Testing Split Button with Opportunity Line Items on Opportunity
			Id pricebookId = Test.getStandardPricebookId();
            
            // Create product
   //         Product2 prod = new Product2(
   //              Name = 'Product X',
   //              ProductCode = 'Pro-X',
   //              isActive = true, Asset_Type__c='Service'
   //         );
			//insert prod;
            Product2 prod = DataFactory.buildProduct('Product X', 'Service');
            prod.ProductCode = 'Pro-X';
            insert prod;
            
            //Create pricebook entry
            PricebookEntry pbEntry = DataFactory.buildPBE(prod.Id);
            insert pbEntry;
            
            // Create and Insert an Opportunity Line Item
            List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
            oli1 = DataFactory.buildOLI(o1.Id, pbEntry.Id, (Integer.valueOf(q)));
            oli1.Split_Qty__c = sq;
            oli1.IsConverted__c = true;
            olis.add(oli1);
            //olis.add(new OpportunityLineItem(OpportunityId=o1.id, Quantity=q, Split_Qty__c=sq, Account__c=a1.id, 
                                             //IsConverted__c=True, TotalPrice=200, PriceBookEntryID=pbEntry.Id));           
            insert olis;
            
            // Build Asset record 
                       
                // Create Contact
                Contact con = DataFactory.buildContact('Contact', a1.Id);
                upsert con;
                
                // Create Contract
                //Contract c = new Contract(AccountID=a1.id, Status='Draft', Opportunity__c=o1.id, StartDate=Date.today(), ContractTerm=12, Auto_Renew__c='Included', 
                //                          CustomerSignedDate=Date.today(), CompanySignedDate=Date.today(), CustomerSignedId=con.id, CompanySignedId=UserInfo.getUserId());
                Contract c = DataFactory.buildContract(null, a1.Id);
                c.Auto_Renew__c = 'Included';
                c.CustomerSignedDate=Date.today();
                c.CompanySignedDate=Date.today();
                c.CustomerSignedId=con.Id;
                c.CompanySignedId=UserInfo.getUserId();
                insert c;
                
            	// Create Service Address
            	Service_Address__c sa = DataFactory.buildServiceAddress(a1.Id, 'SATest1', null);
                upsert sa;
            
                // Create Asset
                //Asset as1 = new Asset(Name='Test Asset', AccountId=a1.id, Oli_Id__c=olis[0].id, Description = olis[0].Description, 
                                      //Product2Id=prod.Id, Quantity=1, In_Production__c=true, Contract__c=c.id, Service_Address__c=sa.id, Asset_Type__c='Service');
                Asset as1 = DataFactory.buildAsset(null, olis[0], prod, a1.Id, null);
                as1.In_Production__c = true;
                as1.Service_Address__c = sa.Id;
                upsert as1;
                
        
            // Run split method
			CSQ2 = new OLI_SplitQty2();
            PageReference SP2 = CSQ2.split();

            // See if split record was created
            system.assert(CSQ2.OLIlist1.size()==1);
            //system.assert(CSQ2.OLIlist2.size()==1);
            System.AssertEquals(SP2.getUrl(), OP.getUrl());            
            
  			// Test for error
  			q = 2;
            sq = 4;
            olis.clear();
            OpportunityLineItem oli2 = DataFactory.buildOLI(o1.Id, pbEntry.Id, (Integer.valueOf(q)));
            oli2.Split_Qty__c = sq;
            oli2.IsConverted__c = true;
            olis.add(oli2);
            //olis.add(new OpportunityLineItem(OpportunityId=o1.id, Quantity=q, Split_Qty__c=sq, TotalPrice=200, PriceBookEntryID=pbEntry.Id));           
            insert olis;          
			CSQ2 = new OLI_SplitQty2();
            PageReference SP3 = CSQ2.split();
            system.assert(CSQ2.OLIlist1.size()==1);
            system.assert(CSQ2.OLIlist2.size()==0);	// No split created
            
            Test.stopTest();
            
        } catch (Exception e){
            System.debug('Unwanted Excpetion Caught: ' + e.getMessage());
            
        }
    }

    
}