/* Class:       CmpMetaSwitchCSVCtrlTest
 * Created On:  Sept 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: Test class for CmpMetaSwitchCSVCtrl
 */

@isTest
public class CmpMetaSwitchCSVCtrlTest {
	
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
		p1.Build_In_Metaswitch__c = true;
		p2.Build_In_Metaswitch__c = true;
		p3.Build_In_Metaswitch__c = true;
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
		Service_Number__c sn4 = DataFactory.buildServiceNumber(opp.Id, '111111', 'P', 'CL');
		Service_Number__c sn5 = DataFactory.buildServiceNumber(opp.Id, '1112221115', 'P', 'CL');
		Service_Number__c sn6 = DataFactory.buildServiceNumber(opp.Id, '1112221116', 'P', 'CL');
		insert new Service_Number__c[] {sn1,sn2,sn3,sn4,sn5,sn6};

		Assigned_Service_Number__c asn1 = DataFactory.buildAssignedNumber(sn1.Id, s1.Id);
		Assigned_Service_Number__c asn2 = DataFactory.buildAssignedNumber(sn2.Id, s2.Id);
		Assigned_Service_Number__c asn3 = DataFactory.buildAssignedNumber(sn3.Id, s3.Id);
		Assigned_Service_Number__c asn4 = DataFactory.buildAssignedNumber(sn4.Id, s4.Id);
		Assigned_Service_Number__c asn5 = DataFactory.buildAssignedNumber(sn5.Id, s5.Id);
		insert new Assigned_Service_Number__c[]{asn1, asn2, asn3, asn4, asn5};


		BBI_metaswitch_rate_centers__c bbi1 = DataFactory.buildBBI(111,111,'Test1',100);
		BBI_metaswitch_rate_centers__c bbi2 = DataFactory.buildBBI(111,222,'Test2',200);
		BBI_metaswitch_rate_centers__c bbi3 = DataFactory.buildBBI(222,222,'Test2',200);
		insert new BBI_metaswitch_rate_centers__c[]{bbi1,bbi2,bbi3};

		Metaswitch_Template__c t1 = DataFactory.buildMetaswitchTemplate('Resi', 'Residential');
		Metaswitch_Template__c t2 = DataFactory.buildMetaswitchTemplate('Comm', 'Commercial');
		insert new Metaswitch_Template__c[]{t1,t2};

	}

	//test methods

	static testMethod void initDataTest() {
		Opportunity opp = [Select Id from Opportunity];
		CmpMetaSwitchCSVCtrl.Input inp = new CmpMetaSwitchCSVCtrl.Input();
		inp.recordId = opp.Id;
		inp.deviceInfoStr = '{}';

		CmpMetaSwitchCSVCtrl.Output out = CmpMetaSwitchCSVCtrl.getAssets(JSON.serialize(inp));
		System.assertEquals('UnitTest',out.auraerror, out.auraerror);
		System.assertEquals(5, out.assets.size(), 'Incorrect number of assets returned');
		System.assertEquals(2, out.bbiMap.size(), 'Incorrect number of bbi returned');
		System.assertNotEquals(0, out.templates.size(), 'No templated returned');
	}
	
	static testMethod void updateAssetTest() {
		Opportunity opp = [Select Id from Opportunity];
		CmpMetaSwitchCSVCtrl.Input inp = new CmpMetaSwitchCSVCtrl.Input();
		inp.recordId = opp.Id;
		inp.deviceInfoStr = '{}';

		CmpMetaSwitchCSVCtrl.Output out = CmpMetaSwitchCSVCtrl.getAssets(JSON.serialize(inp));
		System.assertEquals('UnitTest',out.auraerror, out.auraerror);
		System.assertEquals(5, out.assets.size(), 'Incorrect number of assets returned');
		System.assertEquals(2, out.bbiMap.size(), 'Incorrect number of bbi returned');
		System.assertNotEquals(0, out.templates.size(), 'No templated returned');

		List<Id> assetIds = new List<Id>();
		Metaswitch_Template__c[] mt = [Select Id, Name from Metaswitch_Template__c];
		String easCOS = out.easPLs[0].value;
		for(CmpMetaSwitchCSVCtrl.AssetWrapper a : out.assets){
			assetIds.add(a.asset.Id);
			a.metaswitch_Subscriber_Template = mt[0].Id;
			a.bizGroup = 'Test';
			a.easCOS = easCOS;
			a.department = 'Test';
			a.cpNumber = 'Test';
		}
		List<CmpMetaSwitchCSVCtrl.AssetWrapper> la = new List<CmpMetaSwitchCSVCtrl.AssetWrapper>(out.assets);
		inp.assetIds = assetIds;
		out = CmpMetaSwitchCSVCtrl.markAssets(JSON.serialize(inp));
		System.assertEquals('UnitTest',out.auraerror, out.auraerror);
		System.assertEquals(5, [Select count() from Asset where Built_In_Switch__c = true],'Assets were not updated');

		inp.assets = la;
		out = CmpMetaSwitchCSVCtrl.saveAssets(JSON.serialize(inp));
		System.assertEquals('UnitTest',out.auraerror, out.auraerror);

		for(Asset a : [Select Metaswitch_Template__c, Business_Group__c, EAS_Class_of_Service__c, Department__c, Calling_Party_Number__c from Asset where Built_In_Switch__c = true]){
			System.assertEquals(mt[0].Id, a.Metaswitch_Template__c);
			System.assertEquals('Test', a.Business_Group__c);
			System.assertEquals(easCOS, a.EAS_Class_of_Service__c);
			System.assertEquals('Test', a.Department__c);
			System.assertEquals('Test', a.Calling_Party_Number__c);
		}
	}

	static testMethod void createFile() {
		Opportunity opp = [Select Id from Opportunity];
		CmpMetaSwitchCSVCtrl.Input inp = new CmpMetaSwitchCSVCtrl.Input();
		inp.recordId = opp.Id;
		inp.filename = 'Test filename';
		inp.csv = 'Test1,Test2\n1,2';
		inp.deviceInfoStr = '{}';

		CmpMetaSwitchCSVCtrl.Output out = CmpMetaSwitchCSVCtrl.createFile(JSON.serialize(inp));
		System.assertEquals('UnitTest',out.auraerror, out.auraerror);
		System.assertEquals(1, [Select count() from ContentDocumentLink where LinkedEntityId =:opp.Id], 'File was not created');
	}


	
}