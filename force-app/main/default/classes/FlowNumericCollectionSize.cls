public class FlowNumericCollectionSize {
@InvocableMethod
    public static List<azimuthflowlog.FlowCollectionSizing.FlowCollectionOutputs> FlowNumericCollectionSize(List<List<Double>> FlowCollectionSet){
        List<azimuthflowlog.FlowCollectionSizing.FlowCollectionOutputs> returnList = azimuthflowlog.FlowCollectionSizing.FlowCollectionSize(FlowCollectionSet);
        return returnList;
    }

}