/* Class:       CmpAddServiceNumbersCtrlTest
 * Created On:  Aug 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: Test class for CmpAddServiceNumbersCtrl
 */

@isTest
public class CmpAddServiceNumbersCtrlTest {
	
	@testSetup static void buildData(){
		Account a = DataFactory.buildAccount('Test Account');
		insert a;

		Opportunity o = DataFactory.buildOpportunity('Test Opp', 'New Customer', a.Id, 'Residential Customer');
		insert o;

		Service_Address__c sa1 = DataFactory.buildServiceAddress(a.Id, '123 Main St', '12345');
		Service_Address__c sa2 = DataFactory.buildServiceAddress(a.Id, '789 Main St', '45678');
		insert new Service_Address__c[]{sa1,sa2};

		Service_Number__c sn1 = DataFactory.buildServiceNumber(o.Id, '4564564564','N','CL');
		Service_Number__c sn2 = DataFactory.buildServiceNumber(o.Id, '1231231231','P','CL');
		insert new Service_Number__c[]{sn1,sn2};

	}

	//test methods

	static testMethod void getPicklistTest() {
		Opportunity o = [Select Id from Opportunity];
		CmpAddServiceNumbersCtrl.InputData input = new CmpAddServiceNumbersCtrl.InputData();
		input.deviceInfoStr = '{}';
		CmpAddServiceNumbersCtrl.PicklistValues pls = CmpAddServiceNumbersCtrl.getPicklists(JSON.serialize(input));
		System.assertNotEquals(0, pls.pls.size(), 'Did not capture any picklist fields on Service Number object');
	}
	
	static testMethod void getExistingNumbersTest() {
		Opportunity o = [Select Id from Opportunity];
		CmpAddServiceNumbersCtrl.InputData input = new CmpAddServiceNumbersCtrl.InputData();
		input.deviceInfoStr = '{}';
		input.oppId = o.Id;

		CmpAddServiceNumbersCtrl.NumberData nd = CmpAddServiceNumbersCtrl.getServiceNumbers(JSON.serialize(input));
		System.assertEquals(2, nd.lstSN.size(), 'Did not find correct number of existing Service Numbers');
	}

	static testMethod void singleSNInsertTest() {
		Opportunity o = [Select Id from Opportunity];
		Service_Number__c sn = DataFactory.buildServiceNumber(o.Id, '7777777777','N','CL');
		CmpAddServiceNumbersCtrl.InputData input = new CmpAddServiceNumbersCtrl.InputData();
		input.deviceInfoStr = '{}';
		input.sn = sn;
		input.blockCount = 1;

		CmpAddServiceNumbersCtrl.NumberData nd = CmpAddServiceNumbersCtrl.createNewSN(JSON.serialize(input));
		System.assertEquals(3, nd.lstSN.size(), 'Did not find correct number of Service Numbers');
		System.assertEquals(1, [Select count() from Service_Number__c where Name = '7777777777'], 'Controller did not insert record');
	}

	static testMethod void blockSNInsertTest() {
		Opportunity o = [Select Id from Opportunity];
		Service_Number__c sn = DataFactory.buildServiceNumber(o.Id, '7777777777','N','CL');
		CmpAddServiceNumbersCtrl.InputData input = new CmpAddServiceNumbersCtrl.InputData();
		input.deviceInfoStr = '{}';
		input.sn = sn;
		input.blockCount = 10;

		CmpAddServiceNumbersCtrl.NumberData nd = CmpAddServiceNumbersCtrl.createNewSN(JSON.serialize(input));
		System.assertEquals(12, nd.lstSN.size(), 'Did not find correct number of Service Numbers');
		Set<String> newNumbers = new Set<String>();
		for(Service_Number__c snu : [Select Id, Name from Service_Number__c where Name like '777%']){
			newNumbers.add(snu.Name);
		}

		Long num = Long.valueOf('7777777777');
		for(Integer i = 0 ; i < 10 ; i++){
			String searchname = String.valueOf(num + i);
			System.assert(newNumbers.contains(searchname), 'Number ' + searchname + ' was not found in new number list');
		}
	}

	static testMethod void deleteSNTest() {
		Opportunity o = [Select Id from Opportunity];
		Service_Number__c sn = [Select Id, Opportunity__c from Service_Number__c LIMIT 1];
		CmpAddServiceNumbersCtrl.InputData input = new CmpAddServiceNumbersCtrl.InputData();
		input.deviceInfoStr = '{}';
		input.sn = sn;

		CmpAddServiceNumbersCtrl.NumberData nd = CmpAddServiceNumbersCtrl.deleteSN(JSON.serialize(input));
		System.assertEquals(1, nd.lstSN.size(), 'Did not delete Service Numbers');
	}
	
}