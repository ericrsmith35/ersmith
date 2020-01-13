/* Class:       RecallApprovalProcessTest
 * Created On:  Nov 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */

@isTest
public class RecallApprovalProcessTest {
	
	@testSetup static void buildData(){
		Account a = DataFactory.buildAccount('Test');
		insert a;

		Opportunity o = DataFactory.buildOpportunity('Test', a.Id);
		insert o;

	}

	//test methods

	static testMethod void myTest1() {
		Opportunity o = [Select Id from Opportunity];
		RecallApprovalProcess.Input i = new RecallApprovalProcess.Input();
		i.recordId = o.Id;
		i.sobjectName = 'Opportunity';

		RecallApprovalProcess.recall(new RecallApprovalProcess.Input[]{i});

		o = [Select Id, Recall_Approval__c from Opportunity];
		System.assertEquals(false, o.Recall_Approval__c);
	}
	

}