({
    selectAction : function( component, event, helper) {
        var actionAPI = component.find("quickActionAPI");
        var quickAction = component.get("v.objectName")+"."+component.get("v.actionName");
        console.log(quickAction);
        var args = {actionName: quickAction, entityName: component.get("v.objectName")};
        actionAPI.selectAction(args).then(function(result) {
            var fields = result.targetableFields;
            console.log(fields);            
        }).catch(function(e){
            if(e.errors){
                console.log(e);
            }
        });
    },
})