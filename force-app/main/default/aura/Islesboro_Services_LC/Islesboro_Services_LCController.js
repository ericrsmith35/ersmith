({
    doInit : function(component, event, helper) {
        
        helper.getCounts(component, event, helper);
        helper.getLists(component, event, helper);
        
    },
    
    vwfDeactivate : function (component) {
        var spinnerd = component.find("spinnerd");
        $A.util.removeClass(spinnerd, "slds-hide");        
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        
        // Set the account sObject variable to the value of the component's 
        // account attribute.
        var inputVariables = [
            {
                name : "vAccountId",
                type : "String",
                value: component.get("v.recordId")
            }
        ];
        
        // In the component whose aura:id is "flowData, start your flow
        // and initialize the account sObject variable. Reference the flow's
        // Unique Name.
        flow.startFlow("Islesboro_Activation_Request_LC", inputVariables);
    },
    
    handleStatusChange : function (component, event) {
        var spinnerd = component.find("spinnerd");
        if(event.getParam("status") === "FINISHED_SCREEN") {
            // Get the output variables and iterate over them
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                // Pass the values to the component's attributes
                if(outputVar.name === "vResult") {
                    component.set("v.vResult", outputVar.value);
                } else {
                    component.set("v.vResult", "ERROR");
                }
                if("v.vResult" === "SUCCESS") {
                    component.set("v.isRequested",true);
                }
            }
            $A.util.addClass(spinnerd, "slds-hide");
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "https://gwicommunity.force.com/Islesboro/s/account/"+component.get("v.recordId")
            });
            urlEvent.fire();
        }
    },
    
})