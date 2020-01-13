public class FlowLoggingExample {
    public static string FlowLoggingExample(){
	// Set up the Flow Log Inputs -- FlowName (String), FlowLogUpdateString (String), FlowLogRecordID (String)
	// Leave FlowLogRecordID as null to create a new Flow Log Record.
    azimuthflowlog.FlowLogInputs testFlowLog = new azimuthflowlog.FlowLogInputs();
    List<azimuthflowlog.FlowLogInputs> testFlowLogList = new List<azimuthflowlog.FlowLogInputs>();
    //Initialize the values to create a new record
	testFlowLog.FlowName = 'Apex.FlowLoggingExample';
    testFlowLog.FlowLogUpdateString = 'This is an example debug';
    testFlowLogList.add(testFlowLog);
        List<azimuthflowlog.FlowLogInputs> returnFlowLog = azimuthflowlog.FlowLoggingWrapper.FlowLogWrapper(testFlowLogList);
    // and then update it
    testFlowLogList.clear();
    	testFlowLog.FlowLogRecordID = returnFlowLog[0].FlowLogRecordID;
        testFlowLog.FlowName = returnFlowLog[0].FlowName;
        testFlowLog.FlowLogUpdateString = '++ UPDATED ++';
        testFlowLogList.add(testFlowLog);
        returnFlowLog = azimuthflowlog.FlowLoggingWrapper.FlowLogWrapper(testFlowLogList);
        //Or you can debug the code by calling FlowDebugger from Apex
        returnFlowLog = azimuthflowlog.FlowDebugger.FlowDebugger('Example Flow', 'This is the string through the Debugger', 'NEW');
        return 'Completed';
    }   
}