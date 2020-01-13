@isTest
global Class UpsertUserContact_Test
{
  @isTest global static void testUserVoid()
  {
    User A = NEW User();
    A.Username = 'Void@staff.gwi.net.edouglass';
    A.FirstName = 'Test';
    A.LastName = 'User';
    A.Email = 'Void@devnull.com';
    A.Alias = 'V';
    A.CommunityNickname = 'V';
    A.TimeZoneSidKey = 'America/New_York';
    A.LocaleSidKey = 'en_US';
    A.EmailEncodingKey = 'ISO-8859-1';
    A.ProfileId = [SELECT Id FROM Profile WHERE name =: 'Standard User'].Id;
    A.LanguageLocaleKey = 'en_US';
    
    insert A;
    A = [SELECT FirstName
                 FROM User
                 WHERE Id = :A.Id];
  }
}