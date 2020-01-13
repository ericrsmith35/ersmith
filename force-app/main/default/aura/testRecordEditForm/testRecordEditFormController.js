({
    handleSubmit : function(component, event, helper) {
        event.preventDefault(); 							// Prevent default submit
        var fields = event.getParam("fields");
        fields["ContactId"] = component.get("v.selectedContact"); 
        component.find('recordEditForm').submit(fields); 	// Submit form
        var navigate = component.get("v.navigateFlow");
        navigate("NEXT");     								// Control flow navigation   
    }
})