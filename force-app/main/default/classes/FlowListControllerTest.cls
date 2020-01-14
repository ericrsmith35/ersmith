@IsTest
class FlowListControllerTest {
static testMethod void testFlowListController() {

    Test.startTest();
        String filters = '{"ProcessType":["Flow","AutolaunchedFlow"]}';
        FlowListController.getFlowNamesApex(filters);
    Test.stopTest();
    
}
}
/*
    FlowListController.FlowListController flc = new FlowListController.FlowListController('');
List<FlowDefinitionView> values = FlowListController.FlowListController('');
    @isTest 
    public static void testFlowListController() {
        try {

            Test.startTest();
            
            FlowListController.getFlowNamesApex flowList = new FlowListController.getFlowNamesApex('');
            
            Test.stopTest();
            
            //System.assertEquals( Account.Type.getDescribe().getLabel(), fieldLabel );

        } catch (Exception e) {
            System.debug('Unwanted Excpetion Caught: ' + e.getMessage());
        }
    } */