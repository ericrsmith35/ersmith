@isTest
private class testFlowStringCollectionSize{
    static testmethod void validateCollectionSize() {
        List<String> testListString = new List<String>();
        List<List<String>> testValueSet = new List<List<String>>();
        String testValue;
        for (Integer i=1; i <=20; i++) {
            testValue = 'Test ' + i;
            testListString.add(testValue);
        }
        testValueSet.add(testListString);
        List<azimuthflowlog.FlowCollectionSizing.FlowCollectionOutputs> testReturnSetSize = FlowStringCollectionSize.FlowStringCollectionSize(testValueSet);
        system.assertEquals(20, testReturnSetSize[0].CollectionSize);
    }
}