({
	goToCmpSendEmail : function(component, event, helper) {
		var c = component.get('v.caseobject');
		
		var navService = component.find("nav");
		var pageReference = {
		    "type": "standard__component",
		    "attributes": {
		        "componentName": "c__CmpSendEmail",
		    },
		    "state": {
		        relatedTo: "Case",
		        relatedToRecord: component.get('v.recordId'),
		        templateId: 'Case_Comment_Template',
		        to : c.ContactId,
		        fromEmail : 'help@gwisupport.net'
		    }
		};
		navService.navigate(pageReference);
	}
})