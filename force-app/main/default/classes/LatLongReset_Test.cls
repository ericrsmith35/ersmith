@isTest
global class LatLongReset_Test {
  @isTest global static void TestReset()
  {
      //Account TestAccount = NEW Account();
      //TestAccount.Name = 'TestAccount';
      //insert TestAccount;
      //Service_Address__c SA = NEW Service_Address__c();
      //SA.SANO__c = '24';
      //SA.SASN__c = 'Central';
      //SA.SATH__c = 'St';
      //SA.City__c = 'SACO';
      //SA.Account__c = TestAccount.Id;
      //insert SA;
      
      Account testAccount = DataFactory.buildAccount('TestAccount');
      insert testAccount;

      Service_Address__c sa = DataFactory.buildServiceAddress(testAccount.Id, 'TestSA', '01234');
      sa.SANO__c = '24';
      sa.SASN__c = 'Central';
      sa.SATH__c = 'St';
      sa.City__c = 'SACO';
      insert sa;
  }
}