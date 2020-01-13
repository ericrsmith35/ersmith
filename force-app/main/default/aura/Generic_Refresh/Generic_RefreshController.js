({
    
    init : function(cmp, event, helper) {
        var urlEvt = $A.get("e.force:navigateToSObject");
        if (urlEvt)
        {
            urlEvt.setParams({
                "recordId": cmp.get("v.SOID"),
                "isredirect": "true"
            });
            urlEvt.fire();
        }
        if (typeof sforce != 'undefined')
        {
            sforce.one.navigateToSObject(cmp.get("v.SOID"));
        }
    }
})