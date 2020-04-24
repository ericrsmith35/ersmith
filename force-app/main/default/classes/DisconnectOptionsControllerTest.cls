@isTest(SeeAllData=true)
public class DisconnectOptionsControllerTest {
    @isTest public static void testSysadminPerm()
    {
        Integer perm;
        User SA = [SELECT id FROM USER WHERE alias = 'johncase' LIMIT 1];
        System.runas(SA){
            perm = DisconnectOptionsController.getDeactivatePerm();
        }
    }
    @isTest public static void getInfo()
    {
        User SA = [SELECT id FROM USER WHERE alias = 'johncase' LIMIT 1];
        System.runas(SA)
        {
         	string name =  DisconnectOptionsController.getUsername();
            string profilename = DisconnectOptionsController.getProfileName();
        }
    }
    @isTest public static void makeAndTestAccount()
    {
       //Account testaccount = new Account(Name = 'Test Account');
        Account testaccount = DataFactory.buildAccount('Test Account');
       insert testaccount;
       string disco = DisconnectOptionsController.getDiscoReason(testaccount.Id);
       User SA = [SELECT id FROM USER WHERE alias = 'johncase' LIMIT 1];
       System.runas(SA)
       {
          DisconnectOptionsController.setDeactivateReason(testaccount.Id, 'Non Payment');
          DisconnectOptionsController.setDeactivateReason(testaccount.Id, 'Seasonal Suspend');
          DisconnectOptionsController.setDeactivateReason(testaccount.Id, 'Security Suspend');
          DisconnectOptionsController.setDeactivateReason(testaccount.Id, 'COVID-19 Suspend');
          DisconnectOptionsController.setDeactivateReason(testaccount.Id, 'Reactivate Non Payment');
          DisconnectOptionsController.setDeactivateReason(testaccount.Id, 'Reactivate Seasonal');
          DisconnectOptionsController.setDeactivateReason(testaccount.Id, 'Reactivate Security'); 
          DisconnectOptionsController.setDeactivateReason(testaccount.Id, 'Reactivate COVID-19'); 
       }
    }
}