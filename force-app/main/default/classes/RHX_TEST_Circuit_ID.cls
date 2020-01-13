@isTest(SeeAllData=true)
public class RHX_TEST_Circuit_ID {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Circuit_ID__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Circuit_ID__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}