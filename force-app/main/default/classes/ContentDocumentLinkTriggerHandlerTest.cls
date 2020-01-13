/* Class:       ContentDocumentLinkTriggerHandlerTest
 * Created On:  Aug 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: Test class for ContentDocumentLinkTriggerHandler
 */

@isTest
public class ContentDocumentLinkTriggerHandlerTest {
	
	@testSetup static void buildData(){
		Account a = DataFactory.buildAccount('Test Account');
		insert a;

		ContentVersion cv = DataFactory.buildContentVersion('Test Picture', 'Test.jpeg');
		insert cv;
	}

	//test methods

	static testMethod void shareWithAllUsersTest() {
		Account a = [Select Id from Account];
		ContentDocument cd = [Select Id from ContentDocument];

		ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.LinkedEntityId = a.Id;
		cdl.Visibility = 'InternalUsers';
		cdl.ContentDocumentId = cd.Id;
		cdl.ShareType = 'V';
		insert cdl;

		cdl = [Select Id, Visibility from ContentDocumentLink where Id =: cdl.Id];
		System.assertEquals('AllUsers', cdl.Visibility, 'Visibility was not set to AllUsers');
	}
	
}