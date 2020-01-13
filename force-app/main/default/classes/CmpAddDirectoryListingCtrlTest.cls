/* Class:       CmpAddDirectoryListingCtrlTest
 * Created On:  Aug 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */

@isTest
public class CmpAddDirectoryListingCtrlTest {
	
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

		Yellow_Page_Listing__c yp1 = DataFactory.buildYPListing('Services');
		Yellow_Page_Listing__c yp2 = DataFactory.buildYPListing('Auto');
		Yellow_Page_Listing__c yp3 = DataFactory.buildYPListing('Lawn');
		insert new Yellow_Page_Listing__c[]{yp1,yp2,yp3};

		Directory__c d1 = DataFactory.buildDirectory('City1');
		Directory__c d2 = DataFactory.buildDirectory('City2');
		Directory__c d3 = DataFactory.buildDirectory('City3');
		Directory__c d4 = DataFactory.buildDirectory('City4');
		insert new Directory__c[]{d1,d2,d3,d4};

	}

	//test methods

	static testMethod void initDataTest() {
		Opportunity opp = [Select Id from Opportunity];
		
		//CmpAddDirectoryListingCtrl.AddDirectoryListingReturn adl = CmpAddDirectoryListingCtrl.queryDirectories('{}', opp.Id);
		//System.assertNotEquals(null, adl.opp, 'Controller did not find opp');
		//System.assertEquals(opp.Id, adl.opp.Id, 'Controller found the wrong opp');
		//System.assertEquals(4, adl.dirs.size(), 'Controller did not return all of the directory records');
	}
	
	static testMethod void insertAndDeleteSNDLTest() {
		Opportunity opp = [Select Id from Opportunity];
		Service_Number__c sn = [Select Id from Service_Number__c where Name = '4564564564'];
		Service_Address__c sa = [Select Id from Service_Address__c where Zip__c = '12345'];
		Yellow_Page_Listing__c yp = [Select Id,Name from Yellow_Page_Listing__c where Listing__c = 'Auto'];
		Directory__c[] dirs = [Select Id, Name from Directory__c];

		Service_Number_Directory_Listing__c sndl = new Service_Number_Directory_Listing__c();
		sndl.Business_Name__c = 'Test';
		sndl.Opportunity__c = opp.Id;
		sndl.Service_Address__c = sa.Id;
		sndl.Yellow_Page_Listing__c = yp.Id;
		sndl.Address_Listing__c = yp.Name;
		sndl.Service_Number__c = sn.Id;
		sndl.First_Name__c = 'test';
		sndl.Last_Name__c = 'mctesterson';
		
		//CmpAddDirectoryListingCtrl.AddDirectoryListingReturn adl = CmpAddDirectoryListingCtrl.createSNDL('{}', sndl, new String[]{dirs[0].Id, dirs[2].Id});
		//Service_Number_Directory_Listing__c[] lstSNDL = [Select Id, Directory__c from Service_Number_Directory_Listing__c];
		//System.assertEquals(2, lstSNDL.size(),'Controller did not create all of the SNDL');

		//for(Service_Number_Directory_Listing__c newsndl : lstSNDL){
		//	System.assert(newsndl.Directory__c == dirs[0].Id || newsndl.Directory__c == dirs[2].Id, 'Directory is incorrect');
		//}

		//CmpAddDirectoryListingCtrl.deleteSNDL('{}', lstSNDL[0].Id);
		//lstSNDL = [Select Id, Directory__c from Service_Number_Directory_Listing__c];
		//System.assertEquals(1, lstSNDL.size(),'Controller did not delete the SNDL');
	}
	
}