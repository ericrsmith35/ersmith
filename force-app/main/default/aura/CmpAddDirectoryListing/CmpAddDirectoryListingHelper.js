({
	/**
	 * creates service number directory listing
	 * @param  {[type]} component [description]
	 * @return {[type]}           [description]
	 */
	saveData : function(component) {
		var $t = this;
		var action = component.get('c.createSNDL');
		var record = component.get('v.sndl');
		var dirs = component.get('v.selectedDirs');
		if(dirs.length == 0){
			component.error('Please select at least 1 directory');
			return;
		}
		// link record to opportunity
		record.Opportunity__c = component.get('v.recordId');
		var params = { sndl : record, directoryIds : dirs };
		var onsuccess = function(cmp, res){
			$t.initPage(component);
			$t.getDirectoriesAndOpp(component);
		}

		component.call(action, params, onsuccess);
	},

	handleSuccessSave : function(component, result){
		
	},

	/**
	 * inits data on page laod and after successful insert
	 * @param  {[type]} component [description]
	 * @return {[type]}           [description]
	 */
	initPage : function(component){
		component.set('v.sndl',{'sobjectType' : 'Service_Number_Directory_Listing__c'});
		component.set('v.selectedDirs',[])
		
		// clear lightningLookup fields. ignore errors
		try{
			component.find('n_lu').clearField();
			component.find('sa_lu').clearField();
			if(component.get('v.isBiz')){
				component.find('yp_lu').clearField();
			}
		}
		catch(e){
			console.warn(e.message);
		}
		component.find('ypcontainer').set('v.body',null);
		component.set('v.ypcmp', null);
		component.set('v.isBiz', false);
	},

	/**
	 * action for page load. gets diectories for duallist box and opportunity record
	 * @param  {[type]} component [description]
	 * @return {[type]}           [description]
	 */
	getDirectoriesAndOpp : function(component){
		var $t = this;
		var action = component.get('c.queryDirectories');
		var params = {oppId : component.get('v.recordId')}
		var onsuccess = function(cmp,res){
			$t.setDirectories(cmp,res);
		}

		component.call(action, params, onsuccess);
	},

	/**
	 * callback for getDirectoriesAndOpp
	 * @param {[type]} component [description]
	 * @param {[type]} result    [description]
	 */
	setDirectories : function(component, result){
		$A.createComponent(
			'lightning:dualListbox',
			{
				label : 'Directory(s)',
				sourceLabel : 'Available',
				selectedLabel : 'Selected',
				options : result.dirs,
				value : component.getReference('v.selectedDirs'),
				min : 1
			},
			function(cmp, status, msg){
				if(status === 'SUCCESS'){
					component.find('dircontainer').set('v.body', cmp);
				}
				else{
					component.error(msg);
				}
			}
		);
		component.set('v.opp', result.opp);

		// lightning:datatable can't do relationship data so, customize it for displaying lookup fields
		for(var i = 0; i < result.existingSNDL.length; i ++){
			if(result.existingSNDL[i].Service_Number__r){
				result.existingSNDL[i].Service_Number__r = result.existingSNDL[i].Service_Number__r.Name;
			}
			if(result.existingSNDL[i].Directory__r){
				result.existingSNDL[i].Directory__r = result.existingSNDL[i].Directory__r.Name;
			}
			if(result.existingSNDL[i].Yellow_Page_Listing__r){
				result.existingSNDL[i].Yellow_Page_Listing__r = result.existingSNDL[i].Yellow_Page_Listing__r.Name;
			}
		}
		component.set('v.existingSNDL', result.existingSNDL);
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
			{label : "Name", fieldName : "Name", type : "text"},
			{label : "Service Number", fieldName : "Service_Number__r", type : "text"},
			{label : "Directory", fieldName : "Directory__r", type : "text"},
			{label : "Business Name", fieldName : "Business_Name__c", type : "text"},
			{label : "First Name", fieldName : "First_Name__c", type : "text"},
			{label : "Last Name", fieldName : "Last_Name__c", type : "text"},
			{label : "Yellow Page Heading", fieldName : "Yellow_Page_Listing__r", type : "text"},
			{label : "Address Listing", fieldName : "Address_Listing__c", type : "text"},
			{type : "action", typeAttributes : {rowActions : defaultActions}}
		];
		component.set('v.tableCols', cols);
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
				'sobject' : 'Service_Number_Directory_Listing__c',
				'recordId' : record.Id,
				'fields' : ['Service_Number__c','Directory__c','Business_Name__c','First_Name__c','Last_Name__c','Address_Listing__c'],
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
	deleteRecord : function(component, record){
		var action = component.get('c.deleteSNDL');
		var params = {'sndlid': record.Id};
		var t = this;
		var onsuccess = function(cmp,res){
			t.getDirectoriesAndOpp(cmp);
		}

		component.call(action, params, onsuccess);
	}
})