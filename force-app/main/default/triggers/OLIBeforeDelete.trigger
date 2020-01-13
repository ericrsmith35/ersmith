trigger OLIBeforeDelete on OpportunityLineItem (before delete) {
    for (OpportunityLineItem oli : trigger.old)
        if (oli.IsConverted__c == true) {
            oli.adderror('Cannot Delete Opportunity Product because its has been converted to an Asset');
        }
}