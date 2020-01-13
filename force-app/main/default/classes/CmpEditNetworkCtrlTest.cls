/* Class:       CmpEditNetworkCtrlTest
 * Created On:  Oct 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */

@isTest
public class CmpEditNetworkCtrlTest {
	
	@testSetup static void buildData(){
		Account a = DataFactory.buildAccount('Test Account');
		insert a;

		Network__c parent = DataFactory.buildNetwork('128.0.0.0','/20','IT Support','Netblock');
		insert parent;
	}

	//test methods

	static testMethod void getPicklistsTest() {
		CmpEditNetworkCtrl.Input inp = new CmpEditNetworkCtrl.Input();
		inp.deviceInfoStr = '{}';

		CmpEditNetworkCtrl.Output o = CmpEditNetworkCtrl.getPicklists(JSON.serialize(inp));
		System.assert(o.picklists != null, 'picklists is null');
		System.assert(!o.picklists.isEmpty(), 'picklists is empty');
		System.assertNotEquals(0, o.picklists.get('Type__c').size(),'Type__c returned no picklist values');

	}
	
	static testMethod void saveNetworkTest() {
		Network__c p = [Select Id from Network__c where RecordType.Name = 'Netblock'];
		Account a = [Select Id from Account];

		Network__c n = DataFactory.buildNetwork('128.0.255.0','/26','Sales','Netblock');
		n.Customer__c = a.Id;
		n.Parent_Network__c = p.Id;

		CmpEditNetworkCtrl.Input inp = new CmpEditNetworkCtrl.Input();
		inp.deviceInfoStr = '{}';
		inp.network = n;
		inp.groups = new String[]{'IT Support','Sales'};

		CmpEditNetworkCtrl.Output o = CmpEditNetworkCtrl.saveData(JSON.serialize(inp));
		n = [Select Id, Group__c, Parent_Network__c from Network__c where Name = '128.0.255.0/26' and RecordType.Name = 'Netblock'];
		System.assertEquals('IT Support;Sales', n.Group__c,'Group was not set correctly');
		System.assertEquals(p.Id, n.Parent_Network__c, 'Parent Network was not set');

		inp.network.id = n.Id;
		inp.groups = new String[]{'IT Support'};
		o = CmpEditNetworkCtrl.saveData(JSON.serialize(inp));
		n = [Select Id, Group__c, Parent_Network__c from Network__c where Name = '128.0.255.0/26' and RecordType.Name = 'Netblock'];
		System.assertEquals('IT Support', n.Group__c,'Group was not set correctly');

	}
	
}