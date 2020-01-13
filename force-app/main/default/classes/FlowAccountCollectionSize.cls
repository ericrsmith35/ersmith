public class FlowAccountCollectionSize {
@InvocableMethod
    public static List<azimuthflowlog.FlowCollectionSizing.FlowCollectionOutputs> FlowAccountCollectionSize(List<List<Account>> FlowCollectionSet){
        List<azimuthflowlog.FlowCollectionSizing.FlowCollectionOutputs> returnList = azimuthflowlog.FlowCollectionSizing.FlowCollectionSize(FlowCollectionSet);
        return returnList;
    }
}