({
	invoke: function(component, event, helper) {
		component.set("v.isOpen", true);
        var flow = component.find("flow");
        var flowName = componet.get("v.flowAPIName");
		flow.startFlow(flowName);
	},

	closeFlowModal: function(component, event, helper) {
		component.set("v.isOpen", false);
	},

	closeModalOnFinish: function(component, event, helper) {
		if (event.getParam("status") === "FINISHED") {
			component.set("v.isOpen", false);
		}
	}
});