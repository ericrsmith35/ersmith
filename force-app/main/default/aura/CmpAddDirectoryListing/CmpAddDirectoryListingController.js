({
	/**
	 * init data for page
	 * @param  {[type]} component [description]
	 * @param  {[type]} event     [description]
	 * @param  {[type]} helper    [description]
	 * @return {[type]}           [description]
	 */
	init : function(component, event, helper) {
		try{
			helper.initPage(component);
			helper.getDirectoriesAndOpp(component);
			helper.setDataTableColumns(component);
		}
		catch(e){
			component.log(e.message);
			component.notify(e, 'CmpAddDirectoryListing.controller.init');
		}
	},

	/**
	 * onchange function for "Business Listing?" checkbox
	 * @param  {[type]} component [description]
	 * @param  {[type]} event     [description]
	 * @param  {[type]} helper    [description]
	 * @return {[type]}           [description]
	 */
	handleBusinessCheck : function(component, event, helper) {
		try{
			var isBusiness = event.getSource().get('v.value');
			var ypdiv = component.find('ypcontainer');
			// if checkbox is checkd
			if(isBusiness){
				// first clear first and last name just in case fields are filled out
				component.set('v.sndl.First_Name__c', null);
				component.set('v.sndl.Last_Name__c', null);

				//default values
				component.set('v.sndl.Business_Name__c', component.get('v.opp.Account.Name'));

				// create yellow page lookup field
				$A.createComponent(
					'c:LightningLookup',
					{
						label : "Yellow Page Heading",
						required: "true",
						svg: "standard:apps",
						selectedValue: component.getReference("{!v.sndl.Yellow_Page_Listing__c}"),
						sObjectField: "Service_Number_Directory_Listing__c.Yellow_Page_Listing__c",
						displayedFieldName: "Listing__c",
						valueFieldName: "Id",
						cmpId: "sndl_yp",
						"aura:id" : "yp_lu"
					},
					function(cmp, status, msg){
						if(status === 'SUCCESS'){
							ypdiv.set('v.body', cmp);
						}
						else{
							component.error(msg);
						}
					}
				);
			}
			else{

				// clear business fields
				component.set('v.sndl.Yellow_Page_Listing__c', null);
				component.set('v.sndl.Business_Name__c', null);
				ypdiv.set('v.body', null);
			}
		}
		catch(e){
			component.log(e.message);
			component.notify(e, 'CmpAddDirectoryListing.controller.handleBusinessCheck');
		}

	},

	addNew : function(component, event, helper){
		try{
			helper.saveData(component);
		}
		catch(e){
			component.log(e.message);
			component.notify(e, 'CmpAddDirectoryListing.controller.addNew');
		}
	},

	/**
	 * dataTable actions controller
	 * @param  {[type]} component [description]
	 * @param  {[type]} event     [description]
	 * @param  {[type]} helper    [description]
	 * @return {[type]}           [description]
	 */
	handleTableAction : function(component, event, helper){
		try{
			var action = event.getParam('action');
			var record = event.getParam('row');
			// console.log(JSON.stringify(record));
			// return;
			
			switch(action.name) {
				case 'edit':
					helper.editRecord(component, record);
					break;
				case 'del':
					helper.deleteRecord(component, record);
					break;
			}
		}
		catch(e){
			component.log(e.message);
			component.notify(e, 'CmpAddDirectoryListing.controller.handleTableAction');
		}
	},

	/**
	 * function runs when the edit service number component has successfully saved the service number record
	 * @param  {[type]} component [description]
	 * @param  {[type]} event     [description]
	 * @param  {[type]} helper    [description]
	 * @return {[type]}           [description]
	 */
	closeDialog : function(component, event, helper){
		try{
			// close dialog
			component.get('v.dialog').then(function(d){
				d.close();
			});
			// refresh data in data table
			helper.getDirectoriesAndOpp(component);
		}
		catch(e){
			component.log(e.message);
			component.notify(e, 'CmpAddDirectoryListing.controller.closeDialog');
		}
	},

	handleLookupChange : function(component, event, helper){
		try{
			if(event.getParam('name') == 'sndl_sa'){
				component.set('v.sndl.Address_Listing__c', event.getParam('recordName'));
			}
		}
		catch(e){
			component.log(e.message);
			component.notify(e, 'CmpAddDirectoryListing.controller.init');
		}
	}
})