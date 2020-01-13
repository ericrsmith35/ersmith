({
	init : function(component, event, helper) {
		console.log('init');

		var action = component.get('c.getAE');
		var p = {str : component.get('v.recordId')};
		var onsuccess = function(component, result){
			console.log(result);
		}

		component.call(action, p, onsuccess);
	}
})