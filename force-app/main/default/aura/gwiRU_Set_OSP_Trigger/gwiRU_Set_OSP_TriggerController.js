({

	handleSaveRecord : function(component, event, helper) {
         //     Field Updates go Here
         //     EXAMPLE:
         //         component.set("v.simpleRecord.fieldname__c", true);
		component.set("v.simpleRecord.Trigger_OSP__c", true);
        
         //Standard way to save a record template using Lightning Data Service
        component.find("recordEditor").saveRecord($A.getCallback(function(saveResult){
            if(saveResult.state === "SUCCESS" || saveResult.state === "DRAFT"){
                console.log("Save completed successfully.");
                $A.get("e.force:closeQuickAction").fire();
            }else if(saveResult.state === "INCOMPLETE"){
                console.log("User is offline, device doesn't support drafts.");
            }else if(saveResult.state === "ERROR"){
                console.log("Problem saving record, error: " + JSON.stringify(saveResult.error));
            }else{
                console.log("Unknown problem, state: " + saveResult.state + ", error: " + JSON.stringify(saveResult.error));
            }
        }));
	},
    
    cancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})