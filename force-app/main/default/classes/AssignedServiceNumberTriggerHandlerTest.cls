/* Class:       AssignedServiceNumberTriggerHandlerTest
 * Created On:  
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */

@isTest
public class AssignedServiceNumberTriggerHandlerTest {
	
	@testSetup static void buildData(){
		Account acc = DataFactory.buildAccount('Test');
		insert acc;

		Opportunity o = DataFactory.buildOpportunity('TEst', acc.Id);
		insert o;

		Product2 p1 = DataFactory.buildProduct('Product 1', 'CPE');
		p1.Requires_Service_Number__c = 1;
		insert p1;

		PricebookEntry pb1 = DataFactory.buildPBE(p1.Id);
		insert pb1;

		OpportunityLineItem oli1 = DataFactory.buildOLI(o.Id, pb1.Id, 2);
		insert oli1;

		Asset a = DataFactory.buildAsset(o.Id, oli1, p1, acc.Id, 'Active');
		insert a;

		Service_Number__c sn = DataFactory.buildServiceNumber(o.Id, '123456789', null, null);
		insert sn;
	}

	//test methods

	static testMethod void keyTest_Filled() {
		Asset a = [Select Id from Asset];
		Service_Number__c sn = [Select Id from Service_Number__c];
		Assigned_Service_Number__c asn = DataFactory.buildAssignedNumber(sn.Id, a.Id);
		insert asn;

		asn = [Select Id, Key__c from Assigned_Service_Number__c];
		System.assertEquals(a.Id + '||' + sn.Id,asn.Key__c);
	}
}