({
    execute : function(component, event, helper) {

        if (''+component.get('v.sObjectInfo.Plat_Version__c')+'' == 6) 
        {
            var endurl = 'circuit_id=' + component.get('v.sObjectInfo.Name') + '&d_custid=' + component.get('v.sObjectInfo.Plat_ID__c');
        }
        if (''+component.get('v.sObjectInfo.Plat_Version__c')+'' == 5) 
        {
            var endurl = 'circuit_id=' + component.get('v.sObjectInfo.Name') + '&p5_id=' + component.get('v.sObjectInfo.Plat_ID__c');
        }
        helper.gotoURL(component, 'https://calltrak.gwi/broadband/line-view.pl?' + endurl);
        
        $A.get("e.force:closeQuickAction").fire();   
    }
})