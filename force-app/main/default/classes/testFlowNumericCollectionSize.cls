@isTest
public class testFlowNumericCollectionSize {
    static testmethod void validateCollectionSize() {
        List<Integer> testListValue = new List<Integer>();
        List<List<Integer>> testValueSet = new List<List<Integer>>();
        Integer testValue;
        for (Integer i=1; i <=20; i++) {
            testValue = i;
            testListValue.add(testValue);
        }
        testValueSet.add(testListValue);
        List<azimuthflowlog.FlowCollectionSizing.FlowCollectionOutputs> testReturnSetSize = FlowNumericCollectionSize.FlowNumericCollectionSize(testValueSet);
        system.assertEquals(20, testReturnSetSize[0].CollectionSize);
    }

}