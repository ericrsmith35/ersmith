public with sharing class Opportunity_AddCPE {

    private final Opportunity opp;
    public string selectedPricebook {get;set;}
    public List<PricebookEntry> pricebookEntries {get; private set;}
    
    public Opportunity_AddCPE(ApexPages.StandardController stdController) {
        this.opp = (Opportunity)stdController.getRecord();
        List<Pricebook2> pricebooks = [SELECT Id, Name from Pricebook2 where IsActive = true];
        //if (pricebooks.size() > 0) {
        //    selectedPricebook = pricebooks[0].Id;
        //}
        selectedPricebook = opp.Pricebook2Id;
        loadPricebookEntries();
    }
    
    public List<SelectOption> getPricebookOptions() {
        List<SelectOption> options = new List<SelectOption>();
        List<Pricebook2> pricebooks = [SELECT Id, Name from Pricebook2 where IsActive = true];
        for(Pricebook2 pricebook : pricebooks) {
          options.add(new SelectOption(pricebook.Id,pricebook.Name));
        }
        return options;
    }
    
    public void loadPricebookEntries() {
        pricebookEntries = [SELECT Id, Name, Product2.Name, Product2.ProductCode,
                            UnitPrice  
                           FROM PricebookEntry
//                         WHERE Pricebook2Id =: selectedPricebook and IsActive = true and Product2.Asset_Type__c = 'CPE'
                           WHERE Pricebook2Id =: selectedPricebook and IsActive = true and Product2.Asset_Type__c <> 'CPE'
                           ORDER BY Name];
    }
}