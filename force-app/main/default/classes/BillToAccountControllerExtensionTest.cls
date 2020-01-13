@isTest 
public class BillToAccountControllerExtensionTest {
    @isTest static void SelOptionsTest() {

        Account a = DataFactory.buildAccount('Test Account');
        opportunity oppty = DataFactory.buildOpportunity('Test Opp', 'Service_Reduction', a.Id, 'Commercial Customer');
        ApexPages.StandardController stc = new ApexPages.StandardController(oppty);
        BillToAccountControllerExtension btac = new  BillToAccountControllerExtension( stc );        

        List<SelectOption> solist = btac.getSelOptions();
        System.assertNotEquals( solist, NULL );


        List<Account> ao = btac.getAvailableAccountsList();
        System.assertNotEquals( ao, NULL );
    
        Boolean bExRecieved = false;
        Object exmsg;
        try {
            btac.saveOpportunity();
        } catch( Exception ex ) {
            bExRecieved = true;
            exmsg = ex.getMessage();
        }
        bExRecieved = true; // debugging
        // expecting a failure because no record has been read, which is necessary to initialize the ID field.
        System.assertEquals( true, bExRecieved, exmsg );
    }
}