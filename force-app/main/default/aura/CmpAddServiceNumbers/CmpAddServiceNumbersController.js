({
	/**
	 * init function. called by ltngfw:BaseCmp
	 * @param  {[type]} component [description]
	 * @param  {[type]} event     [description]
	 * @param  {[type]} helper    [description]
	 * @return {[type]}           [description]
	 */
	init : function(component, event, helper) {
		try{
			// init empty service number
			helper.initNewNumber(component);

			// if picklist definitions is empty, get them
			if(!component.get('v.picklistDef')){
				helper.getPLS(component, helper);
			}

			// if data table columns are empty, get them as well as the data
			if(!component.get('v.tableCols')){
				helper.setDataTableColumns(component);
				helper.getData(component, helper);
			}
		}
		catch(e){
			component.error(e.message);
		}
	},

	/**
	 * insert new service number
	 * @param {[type]} component [description]
	 * @param {[type]} event     [description]
	 * @param {[type]} helper    [description]
	 */
	addNew : function(component, event, helper){
		try{
			// validate required fields
			if(!helper.validate(component, event.getSource().get('v.label').toLowerCase() == 'create single')){
				return;
			}
			
			helper.saveNewNumber(component, helper);
		}
		catch(e){
			component.error(e.message);
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
			
			switch(action.name) {
				case 'edit':
					helper.editRecord(component, record);
					break;
				case 'del':
					helper.deleteRecord(component, record, helper);
					break;
			}
		}
		catch(e){
			component.error(e.message);
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
			helper.getData(component, helper);
		}
		catch(e){
			component.error(e.message);
		}
	}
})