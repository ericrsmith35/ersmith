@isTest
private class testFlowContactCollectionSize {
    static testmethod void validateCollectionSize() {
        List<Contact> testList = new List<Contact>();
        List<List<Contact>> testValueSet = new List<List<Contact>>();
        Contact testValue = new Contact();
        for (Integer i=1; i <=20; i++) {
            testValue.LastName = 'Test ' + i;
            testList.add(testValue);
        }
        testValueSet.add(testList);
        List<azimuthflowlog.FlowCollectionSizing.FlowCollectionOutputs> testReturnSetSize = FlowContactCollectionSize.FlowContactCollectionSize(testValueSet);
        system.assertEquals(20, testReturnSetSize[0].CollectionSize);
    }

}