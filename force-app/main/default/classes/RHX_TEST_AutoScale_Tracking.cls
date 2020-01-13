@isTest(SeeAllData=true)
public class RHX_TEST_AutoScale_Tracking {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM AutoScale_Tracking__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new AutoScale_Tracking__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}