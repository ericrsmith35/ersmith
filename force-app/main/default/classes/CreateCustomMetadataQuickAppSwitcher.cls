public class CreateCustomMetadataQuickAppSwitcher implements Metadata.DeployCallback{

    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug(' success : '+ result);
        } else {
            System.debug(' fail : '+ result);
        }
    }
 
    @InvocableMethod(label='Create/Update QuickAppSwitcher Custom Metadata Record')
    public static void createCustomMetadata(List<String> flowParameters) {
        List<String> parameterCollection = new List<String>();
        parameterCollection = flowParameters[0].split('~');
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = parameterCollection[0];
        customMetadata.label = parameterCollection[1];
        
            Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue();
            customField1.field = 'AppAPINames__c';
            customField1.value = parameterCollection[2]; 
            customMetadata.values.add(customField1);

            Metadata.CustomMetadataValue customField2 = new Metadata.CustomMetadataValue();
            customField2.field = 'AppImageNames__c';
            customField2.value = parameterCollection[3]; 
            customMetadata.values.add(customField2);

            Metadata.CustomMetadataValue customField3 = new Metadata.CustomMetadataValue();
            customField3.field = 'AppAlternateTexts__c';
            customField3.value = parameterCollection[4]; 
            customMetadata.values.add(customField3);
        
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
        CreateCustomMetadataQuickAppSwitcher callback = new CreateCustomMetadataQuickAppSwitcher();
        Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
    }
}
