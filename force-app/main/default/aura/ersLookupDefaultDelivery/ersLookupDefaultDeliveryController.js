({
	fieldChanged : function(component, event, helper) {
		var v = event.getSource().get('v.value');
        component.set('v.whereValue', v);
		var f = component.get('v.whereFormat');
		f = f.replace(/\{0\}/g,v);
		component.set('v.whereClause',f);
        component.find('mylookup').clearField();
	}
})