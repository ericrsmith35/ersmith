/* Class:       CmpLinkAssetToNumberCtrlTest
 * Created On:  Sept 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: Test class for CmpLinkAssetToNumberCtrl
 */

@isTest
public class CmpLinkAssetToNumberCtrlTest {
	
	@testSetup static void buildData(){
		Account a = DataFactory.buildAccount('Test Account');
		insert a;

		Opportunity opp = DataFactory.buildOpportunity('Test Opp', 'New Customer', a.Id, 'Residential Customer');
		insert opp;

		Product2 p1 = DataFactory.buildProduct('Product 1', 'CPE');
		Product2 p2 = DataFactory.buildProduct('Product 2', 'CPE');
		Product2 p3 = DataFactory.buildProduct('Product 3', 'Service');
		Product2 p4 = DataFactory.buildProduct('Product 4', 'Service');
		p1.Requires_Service_Number__c = 1;
		p2.Requires_Service_Number__c = 1;
		p3.Requires_Service_Number__c = 1;
		p4.Requires_Service_Number__c = 1;
		insert new Product2[]{p1,p2,p3,p4};

		PricebookEntry pb1 = DataFactory.buildPBE(p1.Id);
		PricebookEntry pb2 = DataFactory.buildPBE(p2.Id);
		PricebookEntry pb3 = DataFactory.buildPBE(p3.Id);
		PricebookEntry pb4 = DataFactory.buildPBE(p4.Id);
		insert new PricebookEntry[]{pb1,pb2,pb3,pb4};

		OpportunityLineItem oli1 = DataFactory.buildOLI(opp.Id, pb1.Id, 2);
		OpportunityLineItem oli2 = DataFactory.buildOLI(opp.Id, pb2.Id, 1);
		OpportunityLineItem oli3 = DataFactory.buildOLI(opp.Id, pb3.Id, 2);
		OpportunityLineItem oli4 = DataFactory.buildOLI(opp.Id, pb4.Id, 1);
		insert new OpportunityLineItem[] {oli1,oli2,oli3,oli4};

		Asset s1 = DataFactory.buildAsset(opp.Id, oli1, p1, a.Id, 'Active');
		Asset s2 = DataFactory.buildAsset(opp.Id, oli1, p1, a.Id, 'Active');
		Asset s3 = DataFactory.buildAsset(opp.Id, oli2, p2, a.Id, 'Active');
		Asset s4 = DataFactory.buildAsset(opp.Id, oli3, p3, a.Id, 'Active');
		Asset s5 = DataFactory.buildAsset(opp.Id, oli3, p3, a.Id, 'Active');
		Asset s6 = DataFactory.buildAsset(opp.Id, oli4, p4, a.Id, 'Active');
		insert new Asset[] {s1,s2,s3,s4,s5,s6};

		Service_Number__c sn1 = DataFactory.buildServiceNumber(opp.Id, '1111111111', 'P', 'CL');
		Service_Number__c sn2 = DataFactory.buildServiceNumber(opp.Id, '1111111112', 'P', 'CL');
		Service_Number__c sn3 = DataFactory.buildServiceNumber(opp.Id, '1111111113', 'P', 'CL');
		Service_Number__c sn4 = DataFactory.buildServiceNumber(opp.Id, '1111111114', 'P', 'CL');
		Service_Number__c sn5 = DataFactory.buildServiceNumber(opp.Id, '1111111115', 'P', 'CL');
		Service_Number__c sn6 = DataFactory.buildServiceNumber(opp.Id, '1111111116', 'P', 'CL');
		insert new Service_Number__c[] {sn1,sn2,sn3,sn4,sn5,sn6};

		Assigned_Service_Number__c asn1 = DataFactory.buildAssignedNumber(sn3.Id, s3.Id);
		insert asn1;
		//s3.Service_Number__c = sn3.Id;
		//update s3;
	}

	//test methods

	static testMethod void getRecordsTest() {
		Opportunity o = [Select Id from Opportunity];

		CmpLinkAssetToNumberCtrl.Input inp = new CmpLinkAssetToNumberCtrl.Input();
		inp.recordId = o.Id;
		inp.deviceInfoStr = '{}';

		CmpLinkAssetToNumberCtrl.Output out = CmpLinkAssetToNumberCtrl.getRecords(JSON.serialize(inp));
		System.assertEquals(out.auraerror, 'UnitTest', out.auraerror);
		System.assertEquals(6, out.assets2.size(), 'Incorrect number of assets returned');
		System.assertEquals(6 + 1, out.numbers.size(), 'Incorrect number of numbers returned');
	}
	
	static testMethod void getRecords2Test() {
		Opportunity o = [Select Id from Opportunity];

		CmpLinkAssetToNumberCtrl.Input inp = new CmpLinkAssetToNumberCtrl.Input();
		inp.recordId = o.Id;
		inp.deviceInfoStr = '{}';

		CmpLinkAssetToNumberCtrl.Output out = CmpLinkAssetToNumberCtrl.getRecords2(JSON.serialize(inp));
		System.assertEquals(out.auraerror, 'UnitTest', out.auraerror);
		System.assertEquals(5, out.assets2.size(), 'Incorrect number of assets returned');
		System.assertEquals(5, out.numbers.size(), 'Incorrect number of numbers returned');
	}

	static testMethod void saveAssetsTest() {
		Opportunity o = [Select Id from Opportunity];

		CmpLinkAssetToNumberCtrl.Input inp = new CmpLinkAssetToNumberCtrl.Input();
		inp.recordId = o.Id;
		inp.deviceInfoStr = '{}';

		CmpLinkAssetToNumberCtrl.Output out = CmpLinkAssetToNumberCtrl.getRecords(JSON.serialize(inp));
		System.assertEquals(out.auraerror, 'UnitTest', out.auraerror);
		System.assertEquals(6, out.assets2.size(), 'Incorrect number of assets returned');
		System.assertEquals(6 + 1, out.numbers.size(), 'Incorrect number of numbers returned');

		for(Integer ind = 0; ind < out.assets2.size(); ind ++){
			out.assets2[ind].sn = out.numbers[ind + 1].value;
		}

		inp.selectedAssets = out.assets2;

		out = CmpLinkAssetToNumberCtrl.saveAssets(JSON.serialize(inp));
		System.assertEquals(out.auraerror, 'UnitTest', out.auraerror);
		System.assertEquals(6,[Select count() from Assigned_Service_Number__c ]);
	}

	static testMethod void assignAssetsTest() {
		Opportunity o = [Select Id from Opportunity];

		CmpLinkAssetToNumberCtrl.Input inp = new CmpLinkAssetToNumberCtrl.Input();
		inp.recordId = o.Id;
		inp.deviceInfoStr = '{}';

		CmpLinkAssetToNumberCtrl.Output out = CmpLinkAssetToNumberCtrl.getRecords2(JSON.serialize(inp));
		System.assertEquals(out.auraerror, 'UnitTest', out.auraerror);
		System.assertEquals(5, out.assets2.size(), 'Incorrect number of assets returned');
		System.assertEquals(5, out.numbers.size(), 'Incorrect number of numbers returned');

		List<CmpLinkAssetToNumberCtrl.WrapperAsset> selected = new CmpLinkAssetToNumberCtrl.WrapperAsset[]{out.assets2[0],out.assets2[1],out.assets2[2]};
		List<CmpLinkAssetToNumberCtrl.SelOpt> nums = new CmpLinkAssetToNumberCtrl.SelOpt[]{out.numbers[0],out.numbers[1],out.numbers[2]};

		inp.selectedAssets = selected;
		inp.selectedServiceNumbers = nums;

		out = CmpLinkAssetToNumberCtrl.assignAssets(JSON.serialize(inp));
		System.assertEquals(out.auraerror, 'UnitTest', out.auraerror);
		//System.assertEquals(2,[Select count() from Assigned_Service_Number__c]);
	}
	
}