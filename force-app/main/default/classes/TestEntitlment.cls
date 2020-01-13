/*
** Class:  TestAccount
** Created by OpFocus on Nov 23, 2015
** Description: Unit tests for the AccountHelper Class and Account trigger
**              
*/  
@isTest
private class TestEntitlment {

    private static Boolean TestEntitlment         = true;

    static testMethod void TestEntitlment() {

        System.assert(TestEntitlment, 'Test disabled.');

        System.debug('=========> SLA processes found: ' + [Select Id, Name from SlaProcess]);

        Account a_NoSupport = DataFactory.buildAccount('Test No Support Account'); //new Account(Name='Test No Supoort Account');
        Account a_Support = DataFactory.buildAccount('Test Support Account'); //new Account(Name='Test Support Account', Support_Account_Type__c='Commercial Standard');
        a_Support.Support_Account_Type__c='Commercial Standard';
        List<Account> lstA = new List<Account>{a_Support, a_NoSupport};
        insert lstA;
        System.assertNotEquals(null, a_NoSupport.Id, 'Account not inserted');
        List<Entitlement> lstEntitlments = [Select Id, AccountId, Name, StartDate, RecordTypeId, SlaProcessId from Entitlement ];


        //We should only have 1 Entitlment, and it should be the a_Support
        System.assertEquals(1, lstEntitlments.size());

        //Make sure it got the right values
        Entitlement e = lstEntitlments[0];
        System.assertEquals(a_Support.Id, e.AccountId);
        System.assertEquals('Default Support Entitlement - ' + a_Support.Name, e.Name);
        System.assertEquals(Date.today(), e.StartDate);
        System.assertEquals(AccountHelper.getRecordTypeIdByRecordTypeName(AccountHelper.DefaultEntitlementRecordTypeName), e.RecordTypeId);
        System.assertEquals(AccountHelper.getSlaIdByName(AccountHelper.DefaultSlaName), e.SlaProcessId);

        //Now let's test to make sure new case's get that entitlment.
        //Case c_support = new Case(AccountId=a_Support.Id, Subject='Testing Entitlement with Support');
        //Case c_NoSupport = new Case(AccountId=a_NoSupport.Id, Subject='Testing Entitlement without Support');
        Case c_support = DataFactory.buildCase(a_Support.Id, null, null);
        Case c_NoSupport = DataFactory.buildCase(a_NoSupport.Id, null, null);
        List<Case> lstC = new List<Case>{c_support, c_NoSupport};
        insert lstC;
        c_support = [Select Id, EntitlementId, SlaStartDate from Case where Id = :c_support.Id];
        c_NoSupport = [Select Id, EntitlementId, SlaStartDate from Case where Id = :c_NoSupport.Id];

        System.assertNotEquals(null, c_support.EntitlementId, 'Case should have Entitlement set');
        System.assertEquals(null, c_NoSupport.EntitlementId, 'Case should have No Entitlement set');

        //Test updating an existing account that did not have support
        a_NoSupport.Support_Account_Type__c='Commercial Standard';
        update a_NoSupport;
        List<Entitlement> lstNewEntitlments = [Select Id, AccountId, Name, StartDate, RecordTypeId, SlaProcessId from Entitlement where AccountId = :a_NoSupport.Id];
        System.assertEquals(1, lstNewEntitlments.size(), 'There should be an Entitlement now for the Account');

    }
}