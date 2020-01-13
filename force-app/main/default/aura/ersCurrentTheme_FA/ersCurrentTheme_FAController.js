({
    invoke : function(component, event) {
        var action = component.get("c.getUIThemeDescription");
        console.log('ersCurrentTheme_FAController');
        action.setCallback(this, function(a) {
            component.set("v.Theme", a.getReturnValue());
            console.log(a.getReturnValue());
            if(a.getReturnValue()=='Salesforce Classic'){
                component.set("v.isLEX",false);
            }else if(a.getReturnValue()=='Lightning Experience'){
                component.set("v.isLEX",true);
            }else if(a.getReturnValue()=='Salesforce1 Mobile'){
                component.set("v.isLEX",false);
            }
        });
        $A.enqueueAction(action);
    }
})