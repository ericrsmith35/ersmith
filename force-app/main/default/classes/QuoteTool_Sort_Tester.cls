@isTest

private class QuoteTool_Sort_Tester {

    public static testMethod void testMySort() {
            
        PageReference SortPage;
        QuoteTool_Sort SortController;
        Account a1;
        Opportunity o1;
        OpportunityLineItem oli1;
        OpportunityLineItem oli2;
        PageReference OppPage;
        PageReference ActPage;
        Double q1 = 1.00;
        Double q2 = 2.00;
        
        try {
            //Account
            //a1 = new Account(Name='STestAct');
            a1 = DataFactory.buildAccount('STestAct');
            insert a1;
            System.debug('Test: Insert Account');
            
            //Pricebook&Products
            //Id PB_Id = Test.getStandardPricebookId();
            //Product2 p1 = new Product2 (Name='Test Product 1', Description='Test Product 1', isActive=true);
            //insert p1;
            //Product2 p2 = new Product2 (Name='Test Product 2', Description='Test Product 2', isActive=true);
            //insert p2;
            Product2 p1 = DataFactory.buildProduct('Test Product 1', null);
            Product2 p2 = DataFactory.buildProduct('Test Product 2', null);
            insert new Product2[]{p1,p2};

            //PricebookEntry pe1 = new PricebookEntry(UnitPrice=1, Product2Id=p1.id, Pricebook2Id=PB_Id, isActive=true);
            //insert pe1;
            //PricebookEntry pe2 = new PricebookEntry(UnitPrice=2, Product2Id=p2.id, Pricebook2Id=PB_Id, isActive=true);
            //insert pe2;
            PricebookEntry pe1 = DataFactory.buildPBE(p1.Id);
            PricebookEntry pe2 = DataFactory.buildPBE(p2.Id);
            pe1.UnitPrice = 1;
            pe2.UnitPrice = 2;
            insert new PricebookEntry[] {pe1,pe2};
            
            
            //Opportunity
            //o1 = new Opportunity(Name='STestOpp', AccountId=a1.Id, StageName='ClosedWon', CloseDate=Date.today());
            o1 = DataFactory.buildOpportunity('STestOpp', a1.Id);
            insert o1;
            System.debug('Test: Insert Opportunity');
            
            //Opportunity Products
            //oli1 = new OpportunityLineItem(OpportunityId=o1.id, Quantity=q1, TotalPrice=100, PriceBookEntryID=pe1.id, QT_Line__c=20);
            //insert oli1;
            //System.debug('Test: Insert 1st Line Item - '+ oli1.id);
            //oli2 = new OpportunityLineItem(OpportunityId=o1.id, Quantity=q2, TotalPrice=200, PriceBookEntryID=pe2.id, QT_Line__c=10);
            //insert oli2;
            //System.debug('Test: Insert 2nd Line Item - '+ oli2.id);
            oli1 = DataFactory.buildOLI(o1.Id, pe1.Id, Integer.valueOf(q1));
            oli2 = DataFactory.buildOLI(o1.Id, pe2.Id, Integer.valueOf(q2));
            oli1.QT_Line__c = 20;
            oli2.QT_Line__c = 10;
            insert new OpportunityLineItem[] {oli1, oli2};
                
            Test.startTest();
            
            OppPage = new ApexPages.StandardController(o1).view();
            System.assertEquals(OppPage.getRedirect(), true);
            System.debug('Test: Opportunity Page');
            
            SortPage = new PageReference('apex/QuoteTool_Sort?oid='+ o1.Id);
            System.debug('Test: Call Sort');
 
            Test.stopTest();
            
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug('Test: Exception');
        }
        
    }    
}