({
    getCounts: function(component, event, helper) {
        var spinnerd = component.find("spinnerd");
        $A.util.removeClass(spinnerd, "slds-hide");
        var spinnerv = component.find("spinnerv");
        $A.util.removeClass(spinnerv, "slds-hide");        
        var action = component.get("c.getDataCount");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var dcount = response.getReturnValue();
            component.set("v.dataCount", dcount);
            component.set("v.isActiveData", true);
            if (dcount === '0') component.set("v.isActiveData", false);            
        })
        $A.enqueueAction(action);
        
        var action = component.get("c.getVoiceCount");
        action.setParams({
            recordId: component.get("v.recordId")
        });        
        action.setCallback(this, function(response) {
            var vcount = response.getReturnValue();
            component.set("v.voiceCount", vcount);
            $A.util.addClass(spinnerd, "slds-hide");
            $A.util.addClass(spinnerv, "slds-hide");
        })
        $A.enqueueAction(action);        
    },
    
    getLists: function(component, event, helper) {
        var spinnerd = component.find("spinnerd");
        $A.util.removeClass(spinnerd, "slds-hide");
        var spinnerv = component.find("spinnerv");
        $A.util.removeClass(spinnerv, "slds-hide");
        
        var action = component.get("c.getDataList");
        action.setParams({
            recordId: component.get("v.recordId")
        });        
        action.setCallback(this, function(response) {
            var dlist = response.getReturnValue();
            component.set("v.dataList", dlist);
            var asset;
            component.set("v.isRequested", false);
            component.set("v.isTempDeactiveData", false);
            for(var i = 0; i < dlist.length; i++) {
                asset = dlist[i];
                // If (De)activation has been requested already
                if(asset.Deactivation_Requested__c === true) {
                    component.set("v.isRequested", true);
                }
                // Set values based on current status
                if(asset.Status === 'Temp Deactivated') {
                    component.set("v.isTempDeactiveData", true);
                }
            }
        })
        $A.enqueueAction(action);            
        
        var action = component.get("c.getVoiceList");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var vlist = response.getReturnValue();
            component.set("v.voiceList", vlist);
            $A.util.addClass(spinnerd, "slds-hide");
            $A.util.addClass(spinnerv, "slds-hide");
        })
        $A.enqueueAction(action); 
        
    },
    
})