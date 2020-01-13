@isTest
private class testFlowAccountCollectionSize {
    static testmethod void validateCollectionSize() {
        List<Account> testList = new List<Account>();
        List<List<Account>> testValueSet = new List<List<Account>>();
        Account testValue = new Account();
        for (Integer i=1; i <=20; i++) {
            testValue.Name = 'Test ' + i;
            testList.add(testValue);
        }
        testValueSet.add(testList);
        List<azimuthflowlog.FlowCollectionSizing.FlowCollectionOutputs> testReturnSetSize = FlowAccountCollectionSize.FlowAccountCollectionSize(testValueSet);
        system.assertEquals(20, testReturnSetSize[0].CollectionSize);
    }

}