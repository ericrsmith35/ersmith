@isTest
private class testFlowAssetCollectionSize {
    static testmethod void validateCollectionSize() {
        List<Asset> testList = new List<Asset>();
        List<List<Asset>> testValueSet = new List<List<Asset>>();
        Asset testValue = new Asset();
        for (Integer i=1; i <=20; i++) {
            testValue.Name = 'Test ' + i;
            testList.add(testValue);
        }
        testValueSet.add(testList);
        List<azimuthflowlog.FlowCollectionSizing.FlowCollectionOutputs> testReturnSetSize = FlowAssetCollectionSize.FlowAssetCollectionSize(testValueSet);
        system.assertEquals(20, testReturnSetSize[0].CollectionSize);
    }

}