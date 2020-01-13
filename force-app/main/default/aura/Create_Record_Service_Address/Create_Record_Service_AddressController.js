({
    handleSubmit : function(component, event, helper) {
        event.preventDefault(); 							// Prevent default submit
        var fields = event.getParam("fields");
        fields["Account__c"] = component.get("v.AccountId");        
        component.find('recordEditForm').submit(fields); 	// Submit form
        console.log("Account ID: "+fields["AccountId"]);       								   
    },
    handleSaved: function(component, event, helper) {
        console.log("Saved");
        var payload = event.getParams().response;			// Get created record Id
        component.set("v.ServiceAddressId",payload.id);
        console.log("Serv Addr ID: "+payload.id);
        var navigate = component.get("v.navigateFlow");		// Control flow navigation
        navigate("NEXT");        
    },
    handleError: function(component, event, helper) {
        console.log("Error"); 
    }
})