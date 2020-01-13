@isTest
private class WebSvcCalloutTest {
    @isTest static void testEchoString() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        
        // Call the method that invokes a callout
        Account a1;
        Opportunity o1;
        OpportunityLineItem oli1;
        OpportunityLineItem oli2;
        Double q1 = 1.00;
        Double q2 = 2.00;
        
        try {
            //Account
            a1 = DataFactory.buildAccount('STestAct');
            insert a1;
            System.debug('Test: Insert Account');
            
            //Pricebook&Products
            Id PB_Id = Test.getStandardPricebookId();
            Product2 p1 = DataFactory.buildProduct('Test Product 1', null);
            insert p1;
            Product2 p2 = DataFactory.buildProduct('Test Product 2', null);
            insert p2;
            System.debug('Test: Insert Products');
            PricebookEntry pe1 = DataFactory.buildPBE(p1.Id);
            insert pe1;
            PricebookEntry pe2 = DataFactory.buildPBE(p2.Id);
            insert pe2;
            System.debug('Test: Insert Pricebook Entries');
            
            //Opportunity
            o1 = DataFactory.buildOpportunity('STestOpp', a1.Id);
            o1.StageName='ClosedWon';
            o1.CloseDate=Date.today();
            insert o1;
            System.debug('Test: Insert Opportunity');
            
            //Opportunity Products
            oli1 = DataFactory.buildOLI(o1.Id, pe1.Id, Integer.valueOf(q1));
            oli1.QT_Line__c=20;
            insert oli1;
            System.debug('Test: Insert 1st Line Item - '+ oli1.id);
            oli2 = DataFactory.buildOLI(o1.Id, pe1.Id, Integer.valueOf(q1));
            oli1.QT_Line__c=10;
            insert oli2;
            System.debug('Test: Insert 2nd Line Item - '+ oli2.id);
            
            string o115 = string.valueof(oli1.id).substring(0,15);
            string o215 = string.valueof(oli2.id).substring(0,15);
            
            //Test
            Test.startTest();
            String output = QuoteTool_Sort.MRsort(o1.Id);
            
            // Verify that a fake result is returned
            // System.assertEquals('Mock response', output);
            
            System.assertEquals(o215+','+o115, output); 
            Test.stopTest();
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug('Test: Exception');
        }
    }
}