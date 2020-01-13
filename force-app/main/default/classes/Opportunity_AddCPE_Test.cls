@isTest
public class Opportunity_AddCPE_Test{

    @isTest
    static void PricebookTest() {
        Opportunity opp = DataFactory.buildOpportunity('Test Opportunity', null);
        insert opp;
        Pricebook2 pricebook = new Pricebook2();
        pricebook.Name = 'Test';
        pricebook.IsActive = true;
        insert pricebook;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(opp);
        Opportunity_AddCPE extController = new Opportunity_AddCPE(stdController);
        system.assert(extController.PricebookEntries != null);
        List<SelectOption> options = extController.getPricebookOptions();
        system.assert(options != null); 
        system.assertEquals(1, options.size());
        SelectOption option = options[0];
        system.assertEquals(pricebook.Name, option.getLabel());
        system.assertEquals(pricebook.Id, option.getValue());
    }
}