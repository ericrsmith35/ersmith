public class FlowContactCollectionSize {
@InvocableMethod
    public static List<azimuthflowlog.FlowCollectionSizing.FlowCollectionOutputs> FlowContactCollectionSize(List<List<Contact>> FlowCollectionSet){
        List<azimuthflowlog.FlowCollectionSizing.FlowCollectionOutputs> returnList = azimuthflowlog.FlowCollectionSizing.FlowCollectionSize(FlowCollectionSet);
        return returnList;
    }
}