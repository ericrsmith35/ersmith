// Project: Create new record to add to a Case as an Asset       
// Created By: Eric Smith - GWI - 12/2015
// Thanks to Jeff Douglass (http://about.me/jeffdonthemic) for the Lookup Override                      
// VisualForce Page: CaseAssetLookup                                
// Description: Test Code for CaseAssetLookupController                  
// Classes Utilized: CaseAssetLookupController, CustomAssetLookupController                     
// Test Classes: CaseAssetLookupControllerTester, CustomAssetLookupControllerTester                                             

@isTest
private class CaseAssetLookupControllerTester {

    @isTest public static void testCaseAssetLookup() {
/* Removed in Assets Phase 2 - 11/17        
        try {
            // Assign variables & Create Records
            Id aid;
            Id cnid;
            Id cid;
            
            Account a;
            a = new Account(Name='TestAccount');
            insert a;
            aid = a.Id;
            
            Contact cn;
            cn = new Contact(LastName='TestContact', Account=a);
            insert cn;
            cnid = cn.Id;
            
            Asset ass;
            ass = new Asset(Name='TestAsset', AccountId=aid);
            insert ass;
            
            Service_Address__c sa;
            sa = new Service_Address__c(Name='TestServiceAddress', Account__c=aid );
            insert sa;
            
            Case cRecord;
            cRecord = new Case(AccountId=aid, Service_Address__c=sa.Id);
            insert cRecord;
            Case[] c = [SELECT Id,AccountId,Service_Address__c FROM Case];
            cid = c[0].Id;
            
            CaseAsset__c ca;
            ca = new CaseAsset__c(AccountLookup__c=aid, Asset__c=ass.Id, Case__c=cid, SrvAdr__c=sa.Id);
            insert ca;
            
            // Test Standard Operation
            PageReference caPage;
            caPage = new PageReference('/apex/CaseAssetLookup?cid='+cid);
            Test.setCurrentPage(caPage);
            
            Test.startTest(); 
            
            CaseAssetLookupController caController = new CaseAssetLookupController();
            
            caController.ca.Asset__c=ass.Id;
            caController.mySave();
            system.assertEquals(c[0].Id, ca.Case__c);
            system.assertEquals(caController.ca.Case__c, cid);
            system.assertEquals(caController.ca.SrvAdr__c, sa.Id);
            caController.myCancel();
              
            // Test Error with invalid CaseAsset Record
            PageReference errPage;
            errPage = new PageReference('/apex/CaseAssetLookup?cid='+cid);
            Test.setCurrentPage(errPage);
            
            CaseAssetLookupController errController = new CaseAssetLookupController();
            errController.ca.Asset__c=null;
            errController.ca.Case__c=null;
            errController.mySave();
            
            //Check Error Messages
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            boolean err = false;
            //Loop through any messages to see if the expected error was caught
            for(ApexPages.Message msg:msgs){
                if(msg.getDetail().contains('Required fields are missing')) err = true;
            }
            system.assert(err);                 

            Test.stopTest();
            
        } catch (Exception e) {
            System.debug('Unwanted Excpetion Caught: ' + e.getMessage());
        }
*/        
    }
    
}