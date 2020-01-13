({
    disco : function(cmp,event,helper){
        var action = cmp.get("c.setDeactivateReason");
        if (cmp.get("v.recordId") == null)
        {           
            action.setParams({accountId:cmp.get("v.AccId"),reason:event.getSource().get("v.label")})
        }
        else
        {
            action.setParams({accountId:cmp.get("v.recordId"),reason:event.getSource().get("v.label")})};
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() == '1')
                {
                    if (cmp.get("v.AccId") !== null)
                    {
                        var urlEvt = $A.get("e.force:navigateToSObject");
                        urlEvt.setParams({
                            "recordId": cmp.get("v.AccId")
                            
                        });
                        urlEvt.fire();
                        if (typeof sforce != 'undefined')
                        {
                            sforce.one.navigateToSObject(cmp.get("v.AccId"));
                        }
                        //window.location.href = "/one/one.app#/sObject/" + cmp.get("v.AccId") + "/view";
                    }
                    $A.get('e.force:refreshView').fire();
                }
            }
        })
        $A.enqueueAction(action);
    },
    doInit: function(cmp,event,helper){
        
        var action = cmp.get("c.getProfileName");       
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.Name",response.getReturnValue());  
            }
        });        
        $A.enqueueAction(action);
        var action2 = cmp.get("c.getDiscoReason");
        
        if (cmp.get("v.recordId") == null)
        {
            action2.setParams({accountId:cmp.get("v.AccId")});   
        }
        else
        {
            action2.setParams({accountId:cmp.get("v.recordId")});
        }
        action2.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS")
            {
                cmp.set("v.DiscoReason",response.getReturnValue());
            }
        });
        $A.enqueueAction(action2);
        var action3 = cmp.get("c.getDeactivatePerm");
        action3.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.Perm",response.getReturnValue());  
            }
        });
        $A.enqueueAction(action3);
    }
})