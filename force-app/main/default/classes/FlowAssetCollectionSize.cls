public class FlowAssetCollectionSize {
@InvocableMethod
    public static List<azimuthflowlog.FlowCollectionSizing.FlowCollectionOutputs> FlowAssetCollectionSize(List<List<Asset>> FlowCollectionSet){
        List<azimuthflowlog.FlowCollectionSizing.FlowCollectionOutputs> returnList = azimuthflowlog.FlowCollectionSizing.FlowCollectionSize(FlowCollectionSet);
        return returnList;
    }
}