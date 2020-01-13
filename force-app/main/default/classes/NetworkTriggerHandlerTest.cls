/* Class:       NetworkTriggerHandlerTest
 * Created On:  Oct 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */

@isTest
public class NetworkTriggerHandlerTest {
	
	@testSetup static void buildData(){
		Account a = DataFactory.buildAccount('Test Account');
		insert a;

		Network__c parent = DataFactory.buildNetwork('128.0.0.0','/20','IT Support','Netblock');
		insert parent;
	}

	//test methods

	static testMethod void octetIPv4Test() {
		Network__c net = DataFactory.buildNetwork('182.0.15.0','/20','IT Support','Netblock');
		insert net;

		net = [Select Id, Octet_1_Start__c, Octet_2_Start__c, Octet_3_Start__c, Octet_4_Start__c, Octet_5_Start__c, 
			Octet_6_Start__c, Octet_7_Start__c, Octet_8_Start__c, Octet_1_End__c, Octet_2_End__c, Octet_3_End__c, 
			Octet_4_End__c, Octet_5_End__c, Octet_6_End__c, Octet_7_End__c, Octet_8_End__c,Starting_Address__c
			from Network__c where Id =: net.Id];

		System.assertEquals('182', net.Octet_1_Start__c);
		System.assertEquals('0', net.Octet_2_Start__c);
		System.assertEquals('15', net.Octet_3_Start__c);
		System.assertEquals('0', net.Octet_4_Start__c);
		System.assertEquals(null, net.Octet_5_Start__c);
		System.assertEquals(null, net.Octet_6_Start__c);
		System.assertEquals(null, net.Octet_7_Start__c);
		System.assertEquals(null, net.Octet_8_Start__c);

		System.assertEquals('182', net.Octet_1_End__c);
		System.assertEquals('0', net.Octet_2_End__c);
		System.assertEquals('31', net.Octet_3_End__c);
		System.assertEquals('14', net.Octet_4_End__c);
		System.assertEquals(null, net.Octet_5_End__c);
		System.assertEquals(null, net.Octet_6_End__c);
		System.assertEquals(null, net.Octet_7_End__c);
		System.assertEquals(null, net.Octet_8_End__c);

		net.Starting_Address__c = '182.0.0.0';
		update net;

		net = [Select Id, Octet_1_Start__c, Octet_2_Start__c, Octet_3_Start__c, Octet_4_Start__c, Octet_5_Start__c, 
			Octet_6_Start__c, Octet_7_Start__c, Octet_8_Start__c, Octet_1_End__c, Octet_2_End__c, Octet_3_End__c, 
			Octet_4_End__c, Octet_5_End__c, Octet_6_End__c, Octet_7_End__c, Octet_8_End__c,Starting_Address__c
			from Network__c where Id =: net.Id];

		System.assertEquals('182', net.Octet_1_Start__c);
		System.assertEquals('0', net.Octet_2_Start__c);
		System.assertEquals('0', net.Octet_3_Start__c);
		System.assertEquals('0', net.Octet_4_Start__c);
		System.assertEquals(null, net.Octet_5_Start__c);
		System.assertEquals(null, net.Octet_6_Start__c);
		System.assertEquals(null, net.Octet_7_Start__c);
		System.assertEquals(null, net.Octet_8_Start__c);

		System.assertEquals('182', net.Octet_1_End__c);
		System.assertEquals('0', net.Octet_2_End__c);
		System.assertEquals('16', net.Octet_3_End__c);
		System.assertEquals('14', net.Octet_4_End__c);
		System.assertEquals(null, net.Octet_5_End__c);
		System.assertEquals(null, net.Octet_6_End__c);
		System.assertEquals(null, net.Octet_7_End__c);
		System.assertEquals(null, net.Octet_8_End__c);
	}
	
	static testMethod void octetIPv6Test() {
		Network__c net = DataFactory.buildNetwork('1726:3abc:0000:0000:0000:0000:0000:0000','/127','IT Support','Netblock');
		insert net;

		net = [Select Id, Octet_1_Start__c, Octet_2_Start__c, Octet_3_Start__c, Octet_4_Start__c, Octet_5_Start__c, 
			Octet_6_Start__c, Octet_7_Start__c, Octet_8_Start__c, Octet_1_End__c, Octet_2_End__c, Octet_3_End__c, 
			Octet_4_End__c, Octet_5_End__c, Octet_6_End__c, Octet_7_End__c, Octet_8_End__c
			from Network__c where Id =: net.Id];

		System.assertEquals('1726', net.Octet_1_Start__c);
		System.assertEquals('3abc', net.Octet_2_Start__c);
		System.assertEquals('0000', net.Octet_3_Start__c);
		System.assertEquals('0000', net.Octet_4_Start__c);
		System.assertEquals('0000', net.Octet_5_Start__c);
		System.assertEquals('0000', net.Octet_6_Start__c);
		System.assertEquals('0000', net.Octet_7_Start__c);
		System.assertEquals('0000', net.Octet_8_Start__c);

		System.assertEquals(null, net.Octet_1_End__c);
		System.assertEquals(null, net.Octet_2_End__c);
		System.assertEquals(null, net.Octet_3_End__c);
		System.assertEquals(null, net.Octet_4_End__c);
		System.assertEquals(null, net.Octet_5_End__c);
		System.assertEquals(null, net.Octet_6_End__c);
		System.assertEquals(null, net.Octet_7_End__c);
		System.assertEquals(null, net.Octet_8_End__c);
	}

	static testMethod void testName() {
		Network__c netv6 = DataFactory.buildNetwork('1726:3abc:0000:0000:0000:0000:0000:0000','/127','IT Support','Netblock');
		insert netv6;

		netv6 = [Select Id, Name
			from Network__c where Id =: netv6.Id];

		System.assertEquals('1726:3abc:0000:0000:0000:0000:0000:0000/127', netv6.Name);
		
		Network__c netv4 = DataFactory.buildNetwork('182.0.15.0','/20','IT Support','Netblock');
		insert netv4;

		netv4 = [Select Id, Name
			from Network__c where Id =: netv4.Id];

		System.assertEquals('182.0.15.0/20', netv4.Name);
	}

	static testMethod void historyTest() {
		Network__c net = DataFactory.buildNetwork('182.0.15.0','/20','IT Support','Netblock');
		insert net;

		net = [Select Id, Name, Network_History__c, Group__c, Starting_Address__c from Network__c where Id =: net.Id];

		System.assertNotEquals(null, net.Network_History__c);

		Network__c hist = [Select Id, Network_History__c, Group__c, Starting_Address__c, RecordTypeId from Network__c where Id =: net.Network_History__c];
		System.assertEquals(Schema.SObjectType.Network__c.getRecordTypeInfosByName().get('History').getRecordTypeId(), hist.RecordTypeId);
		System.assertEquals(net.Group__c, hist.Group__c);
		System.assertEquals(net.Starting_Address__c, hist.Starting_Address__c);

		net.Group__c = 'Sales';
		update net;

		hist = [Select Id, Network_History__c, Group__c, Starting_Address__c, RecordTypeId from Network__c where Id =: net.Network_History__c];
		System.assertEquals(Schema.SObjectType.Network__c.getRecordTypeInfosByName().get('History').getRecordTypeId(), hist.RecordTypeId);
		System.assertEquals(net.Group__c, hist.Group__c);
		System.assertEquals(net.Starting_Address__c, hist.Starting_Address__c);
		System.assertEquals(1,[Select count() from Network__c where Name =:net.Name and RecordType.Name = 'History']);

		delete net;

		System.assertEquals(1,[Select count() from Network__c where Name =:net.Name and RecordType.Name = 'History']);
	}
	
}