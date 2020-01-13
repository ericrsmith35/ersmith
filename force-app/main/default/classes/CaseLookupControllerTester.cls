// Project: Replace Standard Lookup with Custom Filtered Lookup   		

// Created By: Eric Smith - GWI - 1/2016									
// Based on: 'Roll your own Salesforce "Lookup" Popup Window'				
// 	By Jeff Douglas - http://blog.jeffdouglas.com/2011/08/12/roll-your-own-salesforce-lookup-popup-window/ 

// Calling Object: 				Case 			(Case) 									
// Filtered Lookup Object: 		Service_Address	(Service_Address__c)
// Filtered Lookup Object: 		Contact			(Contact) 									
// Field with Filter Value: 	Account 		(Account) 									

// This File:	CaseLookupControllerTester											 
//				Test for controller for start page for Custom Filtered Lookup		

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
private class CaseLookupControllerTester {
    @isTest public static void testCaseLookup() {
        try {
            
            // Assign variables & Create Records
            Id aid;
            Id cnid;
            Id cid;
         
            Account a = DataFactory.buildAccount('TestAccount');
            insert a;
            aid = a.Id;
            
            Contact cn = DataFactory.buildContact('TestContact', a.Id);
            insert cn;
            cnid = cn.Id;
            
            Asset ass = DataFactory.buildAsset(a.Id, 'TestAsset');
            insert ass;
            
            Service_Address__c sa = DataFactory.buildServiceAddress(a.Id, 'TestServiceAddress', '12345');
            insert sa;
            
            Case cRecord = DataFactory.buildCase(a.Id, sa.Id, 'Support Trouble');
            insert cRecord;
            //Case[] c = [SELECT Id,AccountId,Service_Address__c,RecordTypeId FROM Case];
            //cid = c[0].Id;
            cid = cRecord.Id;
            
            // Test Standard Operation
            PageReference caPage = Page.Case_FL_Page;
            Test.setCurrentPage(caPage);
            ApexPages.currentPage().getParameters().put('rid', a.Id);
            ApexPages.currentPage().getParameters().put('rnm', a.Name);
            ApexPages.currentPage().getParameters().put('sconsole', 'true');
            
            Test.startTest(); 
            
            CaseLookupController caController = new CaseLookupController();
            
            caController.co.AccountId=aid;
            caController.mySave();
            caController.mySaveClose();
            //caController.myMore();
            //system.assertEquals(c[0].Id, caController.co.Id);
            //system.assertEquals(caController.co.Contact.Id, cnid);
            caController.myCancel();
            
            // Test Error with invalid Record
            //PageReference caPage = Page.Case_FL_Page;
            //Test.setCurrentPage(caPage);
            ApexPages.currentPage().getParameters().put('rid', a.Id);
            ApexPages.currentPage().getParameters().put('rnm', a.Name);
            ApexPages.currentPage().getParameters().put('sconsole', 'false');
            
            CaseLookupController errController = new CaseLookupController();
            errController.co.Service_Address__c=null;
            errController.co.AccountId=cnid;	// insert invalid id type to force error
            errController.co.Contact=null;
            errController.mySave();
            errController.mySaveClose();            
            
            //Check Error Messages
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            boolean err = false;
            //Loop through any messages to see if the expected error was caught
            for(ApexPages.Message msg:msgs){
                if(msg.getDetail().contains('id value of incorrect type')) err = true;
            }
            system.assert(err);                 
            
            Test.stopTest();
            
        } catch (Exception e) {
            System.debug('Unwanted Excpetion Caught: ' + e.getMessage());
        }
        
    }
    
}