/* Class:       TestCaseTrigger
 * Created On:  
 * Created by:  OpFocus Team
 * Description: 
 */

@isTest
public class TestCaseTrigger {
	
	@testSetup static void buildData(){
		Account a = new Account(Name='Test Account');
		insert a;

		Contact con = new Contact();
		con.LastName = 'Test';
		con.Email = 'test@noemail.com';
		con.AccountId = a.Id;
		insert con;

		Service_Address__c sa = new Service_Address__c();
		sa.Name = 'Test SA';
		sa.Account__c = a.Id;
		insert sa;


	}

	//test methods

	static testMethod void myTest1() {
		Account a = [Select Id from Account];
		Service_Address__c sa = [Select Id from Service_Address__c];
		Contact con = [Select Id from Contact];

		Case c = new Case();
		c.RecordTypeId = SobjectType.Case.getRecordTypeInfosByName().get('Support Trouble').getRecordTypeId();
		c.AccountId = a.Id;
		c.Service_Address__c = sa.Id;
		c.ContactId = con.Id;
		c.Service_Catagory__c = 'Fiber';
		c.Impact__c = 'Down';
		c.Origin = 'Agent';
		c.Status = 'New';
		c.Subject = 'Test Case';

		Test.startTest();
			insert c;
		Test.stopTest();

		Task t = [Select Id, Status, WhatId from Task];
		System.assertEquals('Completed',t.Status);
		System.assertEquals(c.Id,t.WhatId);
	}
	
	static testMethod void myTest2() {
		Account a = [Select Id from Account];
		Service_Address__c sa = [Select Id from Service_Address__c];
		Contact con = [Select Id from Contact];

		Case c = new Case();
		c.RecordTypeId = SobjectType.Case.getRecordTypeInfosByName().get('Support Trouble').getRecordTypeId();
		c.AccountId = a.Id;
		c.Service_Address__c = sa.Id;
		c.ContactId = con.Id;
		c.Service_Catagory__c = 'Fiber';
		c.Impact__c = 'Down';
		c.Origin = 'Agent';
		c.Status = 'New';
		c.Subject = 'Test Case';
		insert c;

		Test.startTest();
			c.Closed_Reason__c = 'Internal Wiring';
			c.Case_Closed_Comments__c = 'Test close';
			c.Status = 'Closed: Answered';
			update c;
		Test.stopTest();

		Task[] t = [Select Id, Status, Subject, WhatId from Task where WhatId =:c.Id];
		System.debug(JSON.serializePretty(t));
		//System.assertEquals(2,t.size());
	}

	static testMethod void e2cReject1(){
		Account a = [Select Id from Account];
		Service_Address__c sa = [Select Id from Service_Address__c];
		Contact con = [Select Id from Contact];

		Case c1 = new Case();
		c1.RecordTypeId = SobjectType.Case.getRecordTypeInfosByName().get('Support Trouble').getRecordTypeId();
		c1.Service_Catagory__c = 'Fiber';
		c1.Impact__c = 'Down';
		c1.Origin = 'Email';
		c1.Status = 'New';
		c1.Subject = 'Test Case';
		c1.SuppliedEmail = 'test1@noemail.com';

		Case c2 = new Case();
		c2.RecordTypeId = SobjectType.Case.getRecordTypeInfosByName().get('Support Trouble').getRecordTypeId();
		c2.Service_Catagory__c = 'Fiber';
		c2.Impact__c = 'Down';
		c2.Origin = 'Email';
		c2.Status = 'New';
		c2.Subject = 'Out of Office RE: Test Case';
		c2.SuppliedEmail = 'test2@noemail.com';

		Case c3 = new Case();
		c3.RecordTypeId = SobjectType.Case.getRecordTypeInfosByName().get('Support Trouble').getRecordTypeId();
		c3.Service_Catagory__c = 'Fiber';
		c3.Impact__c = 'Down';
		c3.Origin = 'Email';
		c3.Status = 'New';
		c3.Subject = 'Vacation Response';
		c3.SuppliedEmail = 'test3@noemail.com';

		Case c4 = new Case();
		c4.RecordTypeId = SobjectType.Case.getRecordTypeInfosByName().get('Support Trouble').getRecordTypeId();
		c4.Service_Catagory__c = 'Fiber';
		c4.Impact__c = 'Down';
		c4.Origin = 'Email';
		c4.Status = 'New';
		c4.Subject = 'OOO';
		c4.SuppliedEmail = 'test4@noemail.com';

		Test.startTest();
		Database.insert(c1,false);
		Database.insert(c2,false);
		Database.insert(c3,false);
		Database.insert(c4,false);
		Test.stopTest();

		System.assertEquals(1, [Select count() from Case]);
		System.assertEquals(3, [Select count() from E2C_Rejected_Email__c]);

		Case c = [Select Id, SuppliedEmail from Case];
		System.assertEquals(c.SuppliedEmail, c1.SuppliedEmail);
	}

	static testMethod void e2cReject2(){
		Account a = [Select Id from Account];
		Service_Address__c sa = [Select Id from Service_Address__c];
		Contact con = [Select Id from Contact];

		insert new E2C_Rejected_Email__c(From__c='test4@noemail.com'); 

		Case c1 = new Case();
		c1.RecordTypeId = SobjectType.Case.getRecordTypeInfosByName().get('Support Trouble').getRecordTypeId();
		c1.Service_Catagory__c = 'Fiber';
		c1.Impact__c = 'Down';
		c1.Origin = 'Email';
		c1.Status = 'New';
		c1.Subject = 'Test Case';
		c1.SuppliedEmail = 'test1@noemail.com';

		Case c2 = new Case();
		c2.RecordTypeId = SobjectType.Case.getRecordTypeInfosByName().get('Support Trouble').getRecordTypeId();
		c2.Service_Catagory__c = 'Fiber';
		c2.Impact__c = 'Down';
		c2.Origin = 'Email';
		c2.Status = 'New';
		c2.Subject = 'Out of Office RE: Test Case';
		c2.SuppliedEmail = 'test2@noemail.com';

		Case c3 = new Case();
		c3.RecordTypeId = SobjectType.Case.getRecordTypeInfosByName().get('Support Trouble').getRecordTypeId();
		c3.Service_Catagory__c = 'Fiber';
		c3.Impact__c = 'Down';
		c3.Origin = 'Email';
		c3.Status = 'New';
		c3.Subject = 'Vacation Response';
		c3.SuppliedEmail = 'test3@noemail.com';

		Case c4 = new Case();
		c4.RecordTypeId = SobjectType.Case.getRecordTypeInfosByName().get('Support Trouble').getRecordTypeId();
		c4.Service_Catagory__c = 'Fiber';
		c4.Impact__c = 'Down';
		c4.Origin = 'Email';
		c4.Status = 'New';
		c4.Subject = 'OOO';
		c4.SuppliedEmail = 'test4@noemail.com';

		Test.startTest();
		Database.insert(c1,false);
		Database.insert(c2,false);
		Database.insert(c3,false);
		Database.insert(c4,false);
		Test.stopTest();

		System.assertEquals(1, [Select count() from Case]);
		System.assertEquals(3, [Select count() from E2C_Rejected_Email__c]);

		Case c = [Select Id, SuppliedEmail from Case];
		System.assertEquals(c.SuppliedEmail, c1.SuppliedEmail);
	}
	
}