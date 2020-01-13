({
    handleCancelRecord: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    update: function(component, event, helper) {
        component.find('clone').set('v.value', '1');


    },
    handleSaveRecord: function(component, event, helper) {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Saved",
                "message": "The record was updated."
            });
            resultsToast.fire();
            $A.get("e.force:closeQuickAction").fire();
    }
})