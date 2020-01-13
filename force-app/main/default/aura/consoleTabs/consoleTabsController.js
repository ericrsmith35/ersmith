({
    openTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '#/sObject/0010e00001JUkEpAAL/view',
            focus: true
        });
    },
    
    refreshFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.refreshTab({
                tabId: focusedTabId,
                includeAllSubtabs: true
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    isConsole : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {            
            console.log("IsConsole: ", response);
        })
        .catch(function(error) {
            console.log(error);
        });        
    },
    
    closeTabs : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getAllTabInfo().then(function(response) {            
            console.log("All Info: ", response);
            for (var t = 0, len = response.length; t < len; t++) {
                if (response[t].closeable && !response[t].pinned) {
                    var closeTabId = response[t].tabId;
                    var closeTitle = response[t].title;
                    workspaceAPI.closeTab({
                        tabId: closeTabId
                    }).then(function(closeResponse) {
                        console.log("Closed: ", closeTitle);                      
                    })
                    .catch(function(error) {
                        console.log(error);
                    });                            
                } else {
                    console.log("Left Open: ", response[t].title);
                }
            } 
        })
        .catch(function(error) {
            console.log(error);
        });        
    },
    
})