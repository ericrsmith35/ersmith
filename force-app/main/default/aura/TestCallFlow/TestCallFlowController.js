({
    doInit : function(component, event, helper) {
   
    },
    
    runFlow : function(component, event, helper) {
        // Get selected button
        var selectedButtonLabel = event.getSource().get("v.label");
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        var inputVariables = [
            { name : "vCaseId", type : "String", value: component.get("v.recordId") }, 
            { name : "vButton", type : "String", value: selectedButtonLabel }
        ];
        
        flow.startFlow("TEST_Case_TATA_buttons", inputVariables);
    },
    
})