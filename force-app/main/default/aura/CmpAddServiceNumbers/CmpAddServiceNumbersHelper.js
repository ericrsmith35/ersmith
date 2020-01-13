({
	/**
	 * server call to get picklist values from fields
	 * @param  {[type]} component [description]
	 * @param  {[type]} t         [description]
	 * @return {[type]}           [description]
	 */
	getPLS : function(component, t) {
		var action = component.get('c.getPicklists');
		var params = {};
		var onsuccess = function(cmp,res){
			t.setPLS(cmp, res);
		}
		
		component.call(action, params, onsuccess);
	},

	/**
	 * onsuccess callback for getPLF
	 * @param {[type]} component [description]
	 * @param {[type]} result    [description]
	 */
	setPLS : function(component, result){
		component.set('v.picklistDef', result.pls);

		// dualListBox cannot have picklist values dynamic so we have to dynamically create the component
		$A.createComponent('lightning:dualListBox',
			{
				"name" : "features",
				"label" : "Calling Features",
				"options" : result.pls.Calling_Features__c,
				"sourceLabel" : "Available",
				"selectedLabel" : "Selected",
				"value" : component.getReference('v.num.Calling_Features__c')
			},
			function(cmp, status, err){
				if(status === 'SUCCESS'){
					component.find('features_div').set('v.body', cmp);
				}
				else{
					component.error(err);
				}
			}
		)
	},

	/**
	 * server call to get existing service numbers
	 * @param  {[type]} component [description]
	 * @param  {[type]} t         [description]
	 * @return {[type]}           [description]
	 */
	getData : function(component, t) {
		var action = component.get('c.getServiceNumbers');
		var params = {'oppId': component.get('v.recordId')};
		var onsuccess = function(cmp,res){
			t.setData(cmp, res);
		}

		component.call(action, params, onsuccess);
	},

	/**
	 * onsuccess callback for getData
	 * @param {[type]} component [description]
	 * @param {[type]} result    [description]
	 */
	setData : function(component, result){
		component.set('v.existingNumbers', result.lstSN);
	},

	/**
	 * server call to insert service number
	 * @param  {[type]} component [description]
	 * @param  {[type]} t         [description]
	 * @return {[type]}           [description]
	 */
	saveNewNumber : function(component, t) {
		var action = component.get('c.createNewSN');
		var num = component.get('v.num');
		var featureArray = num.Calling_Features__c;
		if(featureArray){
			var features = featureArray.join(';')
			num.Calling_Features__c = features;
		}
		console.log(JSON.stringify(num));
		var params = {'sn': num, 'blockCount' : component.get('v.block')};
		
		var onsuccess = function(cmp,res){
			t.setData(cmp, res);
			t.initNewNumber(cmp);
		}

		component.call(action, params, onsuccess);
	},

	/**
	 * build data table definitions
	 * @param {[type]} component [description]
	 */
	setDataTableColumns : function(component){
		var defaultActions = [
			{ label : "Edit", name : "edit"},
			{ label : "Delete", name : "del"}
		];
		var cols = [
			{label : "Number", fieldName : "Name", type : "text"},
			{label : "Type", fieldName : "Type__c", type : "text"},
			{label : "Product", fieldName : "Product__c", type : "text"},
			{label : "Hunt Group", fieldName : "Hunt_Group__c", type : "text"},
			{label : "Calling Features", fieldName : "Calling_Features__c", type : "text"},
			{label : "Caller ID", fieldName : "Caller_Id__c", type : "text"},
			{label : "Notes", fieldName : "Notes__c", type : "text"},
			{type : "action", typeAttributes : {rowActions : defaultActions}}
		];
		component.set('v.tableCols', cols);
	},

	/**
	 * init new service number record
	 * @param  {[type]} component [description]
	 * @return {[type]}           [description]
	 */
	initNewNumber : function(component){
		var nn = {'sobjectType':'Service_Number__c'};
		nn.Opportunity__c = component.get('v.recordId');
		component.set('v.num', nn);
		component.set('v.block',"1");
	},

	/**
	 * validates new service number form data
	 * @param  {[type]} component [description]
	 * @return {[type]}           [description]
	 */
	validate : function(component, single){
		var sn = component.get('v.num');
		var requiredFields = [];
		if(!sn.Name) requiredFields.push('Number is required.');
		if(!sn.Type__c) requiredFields.push('Type is required.');
		if(!sn.Product__c) requiredFields.push('Product is required.');
		if(!single && !component.get('v.block') > 0) requiredFields.push('Block Size must be greater than 0');
		
		if(requiredFields.length != 0){
			component.error(requiredFields.join(' '));
			return false;
		}
		return true;
	},

	/**
	 * opens dialog to edit selected service number record
	 * @param  {[type]} component [description]
	 * @param  {[type]} record    [description]
	 * @return {[type]}           [description]
	 */
	editRecord : function(component, record){
		$A.createComponent(
			'c:CmpRecordEditForm',
			{
				'sobject' : 'Service_Number__c',
				'recordId' : record.Id,
				'fields' : ['Name','Type__c','Product__c','Hunt_Group__c','Caller_Id__c','Calling_Features__c','Notes__c'],
				'whenDone' : component.getReference('c.closeDialog')
			},
			function(cmp, status, msg){
				if(status === 'SUCCESS'){
					var d = component.find('modallib').showCustomModal({
						header: 'Edit ' + record.Name,
						body : cmp,
						showCloseButton : true
					})
					component.set('v.dialog', d);
				}
				else{
					component.error(msg);
				}
			}
		)
	},

	/**
	 * server call to delete selected service record
	 * @param  {[type]} component [description]
	 * @param  {[type]} record    [description]
	 * @param  {[type]} t         [description]
	 * @return {[type]}           [description]
	 */
	deleteRecord : function(component, record, t){
		var action = component.get('c.deleteSN');
		var params = {'sn': record};
		var onsuccess = function(cmp,res){
			component.success('Deleted!', 'dimissible')
			t.getData(cmp, t);
		}

		component.call(action, params, onsuccess);
	}

})