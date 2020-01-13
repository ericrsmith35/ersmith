@isTest
public class SetFlowReturnExtensionTest{
    static testmethod void testFinishPage() {
        Account testAccount = DataFactory.buildAccount('Testing123');
        insert testAccount;
        ApexPages.standardController std = new ApexPages.standardController(testAccount);
        SetFlowReturnExtension controllerExt = new SetFlowReturnExtension(std);
        PageReference pageRef = Page.Opportunity_Button_Won_vf;
        Test.setCurrentPage(pageRef);
        System.assertEquals(controllerExt.getFinishPageRef().getUrl(), '/home/home.jsp');
    }
}