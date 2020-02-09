({
    invoke : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            console.log("TEST RESPONSE:", response);
       })
        .catch(function(error) {
            console.log(error);
        });
    }
})