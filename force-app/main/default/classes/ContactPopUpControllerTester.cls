// Project: Replace Standard Lookup with Custom Filtered Lookup   		

// Created By: Eric Smith - GWI - 1/2016									
// Based on: 'Roll your own Salesforce "Lookup" Popup Window'				
// 	By Jeff Douglas - http://blog.jeffdouglas.com/2011/08/12/roll-your-own-salesforce-lookup-popup-window/ 

// Calling Object: 				Case 			(Case) 									
// Filtered Lookup Object: 		Service_Address	(Service_Address__c)
// Filtered Lookup Object: 		Contact			(Contact) 	 									
// Field with Filter Value: 	Account 		(Account) 									

// This File:	ContactPopUpControllerTester 											 
//				Test for controller for popup page for Custom Filtered Lookup		

// VisualForce Pages: 	Case_FL_Page,        		        			
//						Service_Address_FL_PopUp
//						Contact_FL_PopUp									
// Classes Utilized: 	CaseLookupController, 						
//                   	Service_AddressPopUpController
//                   	ContactPopUpController			   				
// Test Classes: 		CaseLookupControllerTester, 					
//                   	Service_AddressPopUpControllerTester
//                   	ContactPopUpControllerTester	

@isTest
private class ContactPopUpControllerTester {
    @isTest public static void testCustomLookup() {
        try {
            // Assign variables & Create Records
            Id aid;
            Id cnid;
            String cnln;
            Id cid;
            Id said;
			String searchstring;
            searchstring = '';
         
            Account a;
            a = DataFactory.buildAccount('Test Account');
            insert a;
            aid = a.Id;
            
            Contact cn = DataFactory.buildContact('TestContact', a.Id);
            //Contact cn = new Contact(LastName='TestContact', Account=a);
            insert cn;
            cnid = cn.Id;
            cnln = cn.LastName;
            
            Service_Address__c sa;
            sa = DataFactory.buildServiceAddress(aid, 'TestServiceAddress', '98989');
            //sa = new Service_Address__c(Name='TestServiceAddress', Account__c=aid );
            insert sa;
            said = sa.Id;
            
            Case cRecord;
            //String recType = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Support Trouble'].Id;
            //cRecord = new Case(AccountId=aid, Service_Address__c=sa.Id, RecordTypeId=recType);
            cRecord = DataFactory.buildCase(aid, sa.Id, 'Supper Trouble');
            insert cRecord;
            cid = cRecord.Id;
            
            // Test Standard Operation
            PageReference puPage;
            puPage = new PageReference('/apex/Contact_FL_PopUp?fid=\''+aid+'\'&lksrch='+searchstring);
            Test.setCurrentPage(puPage);
            
            Test.startTest(); 
            
            ContactPopUpController puController = new ContactPopUpController();
            
            //puController.co.AccountId = aid;
            puController.luobj.LastName = cnln;
            puController.mySave();

            //system.assertEquals(puController.luobj.Account__c, aid);
            puController.search();
            puController.saveContact();
            puController.getFormTag();
            puController.getTextBox();
            
            // Test Error with invalid CaseAsset Record         
            //PageReference errPage;
            //errPage = new PageReference('/apex/CustomAssetLookup?aid=\''+aid+'\'&lksrch='+searchstring+'&cid='+cid+'&srvadr='+said);
            //Test.setCurrentPage(errPage);
            
            //CustomAssetLookupController errController = new CustomAssetLookupController();
            //errController.ca.Asset__c=null;
            //errController.ca.Case__c=null;
            //errController.mySave();
            
            //Check Error Messages
            //List<ApexPages.Message> msgs = ApexPages.getMessages();
            //boolean err = false;
            //Loop through any messages to see if the expected error was caught
            //for(ApexPages.Message msg:msgs){
            //    if(msg.getDetail().contains('Required fields are missing')) err = true;
            //}
            //system.assert(err);                 

            Test.stopTest();
            
        } catch (Exception e) {
            System.debug('Unwanted Excpetion Caught: ' + e.getMessage());
        }
}
}