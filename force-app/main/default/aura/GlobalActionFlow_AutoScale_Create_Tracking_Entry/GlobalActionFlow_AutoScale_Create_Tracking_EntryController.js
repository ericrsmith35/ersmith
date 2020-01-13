({
    init : function (component) {
        // Find the component whose aura:id is “flowData”
        var flow = component.find("flowData");
        
        // In that component, start your flow. Reference the flow’s Unique Name.
         
        // Change FlowName to your flow's name
        flow.startFlow("AutoScale_Create_Tracking_Entry");
        
    },
})