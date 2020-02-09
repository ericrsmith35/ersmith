({
    invoke : function(component, event, helper) {
        
        var workspaceAPI = component.find("workspace");
        var action = component.get("v.action").toLowerCase();
        var tabId = component.get("v.tabId");
        var subtabId = component.get("v.subtabId");
        var tabLabel = component.get("v.tabLabel");
        var tabIcon = component.get("v.tabIcon");
        var tabUrl = component.get('v.tabUrl');
        var isConsole = false;
        var currentTabId = tabId;
        var currentSubtabId = subtabId;
        var subtabs = [];

        return new Promise(function(result, error) {


            // check to see if running in a Console
            workspaceAPI.isConsoleNavigation().then(response => {  
                isConsole = response;          
                component.set('v.tabLabel', isConsole);
                if (!isConsole) {
                    component.set('v.errorMessage', 'ERROR: Not running in a Console!');
                    result();
                }
            }).then(allTabs => {
                if (isConsole) {
                    // get current focused tabId
                    workspaceAPI.getAllTabInfo().then(tabInfo => {
                        var tabs = JSON.parse(JSON.stringify(tabInfo));
                        for (var t = 0; t < tabs.length; t++) {
                            if (tabs[t].focused) {
                                currentTabId = tabs[t].tabId;
                                subtabs = JSON.parse(JSON.stringify(tabs[t].subtabs));
                                // get current focused subtabId
                                for (var s = 0; s < subtabs.length; s++) {
                                    if (subtabs[s].focused) {
                                        currentSubtabId = subtabs[s].tabId;
                                    }
                                }                               
                            }                          
                        }
                    }).then(actions => {
                        component.set('v.tabId', currentTabId);
                        component.set('v.subtabId', currentSubtabId);
                        var defaultTabId = (tabId != "") ? tabId : (currentSubtabId != "") ? currentSubtabId : currentTabId;

                        // return active tabId and subtabId
                        if (action == "getid") {
                            result();
                        }

                        // open url in new parent Tab
                        if (action == "open" && tabId == "") {
                            workspaceAPI.openTab({
                                url: tabUrl,
                                focus: true
                            }).then(openedId => {
                                component.set('v.saveTabId', openedId);
                            }).then(newTab => {
                                component.set('v.tabId', component.get('v.saveTabId'));
                                result(); 
                            });
                        }

                        // open url in new subTab
                        if (action == "open" && tabId != "") {
                            var parentId = (tabId.toLowerCase() == "child") ? currentTabId : tabId;
                            workspaceAPI.openSubtab({
                                parentTabId: parentId,
                                url: tabUrl,
                                focus: true
                            }).then(openedId => {
                                component.set('v.saveTabId', openedId);
                            }).then(newTab => {
                                component.set('v.tabId', component.get('v.saveTabId'));
                                result(); 
                            });
                        }

                        // set tab icon
                        if (action == "label") {
                            workspaceAPI.setTabIcon({
                                tabId: defaultTabId,
                                icon: tabIcon
                            }).then(updatedTab => {
                                result();
                            });
                        }
                        
                        // set tab label
                        if (action == "label") {
                            workspaceAPI.setTabLabel({
                                tabId: defaultTabId,
                                label: tabLabel
                            }).then(updatedTab => {
                                result();
                            });
                        }

                        // focus then refresh tab (default is current focused tab)
                        if (action == "focus") {
                            workspaceAPI.focusTab({
                                tabId: defaultTabId
                            }).then(isFocused => {
                                workspaceAPI.refreshTab({
                                    tabId: defaultTabId,
                                    includeAllSubtabs: false
                                }).then(isRefreshed => {
                                    result();
                                });
                            });
                        }

                        // close tab
                        if (action == "close") {
                            workspaceAPI.closeTab({
                                tabId: defaultTabId
                            }).then(isClosed => {
                                result();
                            });
                        }
                    });
                    
                }
            })
            .catch(function(error) {
                console.log("Error: ", error);
                component.set('v.errorMessage', 'Unhandled ERROR: ' + error);
                error(error);
            });  

        });
    },

})