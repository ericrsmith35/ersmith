({
    toggleSection : function(component, event, helper) {
        component.set('v.isSidebarCollapsed', !component.get('v.isSidebarCollapsed'));
    },
    
    doneRendering : function(component, event, helper) {
        try {
            var stickySectionAura = component.find("stickySection");
            if(window && stickySectionAura){
                window.onscroll = function() {
                    //Purely informational
                    var html = document.documentElement;
                    var scrollHeight = parseInt(html.scrollHeight);
                    var clientHeight = parseInt(html.clientHeight);
                    
                    //This is where it happens, so adjust this per your requirement
                    if(parseInt(window.pageYOffset) > 75) 
                        $A.util.addClass(stickySectionAura, 'stickySection');
                    else
                        $A.util.removeClass(stickySectionAura, 'stickySection');
                }
            }
        } catch(err){
            console.log('-------> doneRendering ERROR: ' + err + ' ** MESSAGE: ' + err.message + ' ** STACK: ' + err.stack);
        }
    }
})