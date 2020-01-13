({
	/**
	 * init function
	 * @param  {[type]} component [description]
	 * @param  {[type]} event     [description]
	 * @param  {[type]} helper    [description]
	 * @return {[type]}           [description]
	 */
	init : function(component, event, helper) {
		try{
			helper.disableDownload(component);
			helper.getData(component);
		}
		catch(e){
			component.notify(e, 'CmpMetaSwitchCSV');
		}
	},

	/**
	 * starts building the csv file
	 * @param  {[type]} component [description]
	 * @param  {[type]} event     [description]
	 * @param  {[type]} helper    [description]
	 * @return {[type]}           [description]
	 */
	startBuild : function(component, event, helper) {
		try{
			helper.buildCSV(component);
		}
		catch(e){
			component.notify(e, 'CmpMetaSwitchCSV');
		}
	},

	selectTemplate : function(component, event, helper){
		try{
			helper.getTemplate(component);
			helper.createTable(component);
		}
		catch(e){
			component.notify(e, 'CmpMetaSwitchCSV');	
		}
	},

	saveTable : function(component, event, helper){
		try{
			helper.enableDownload(component);
			helper.updateWrappers(component, event, true);

			// cancel and save buttons won't go away so we have to destroy and re-create the table
			helper.destroyTable(component);
			helper.createTable(component);
		}
		catch(e){
			component.notify(e, 'CmpMetaSwitchCSV');	
		}
	},

	cellChange : function(component, event, helper){
		try{
			helper.disableDownload(component);
			helper.updateWrappers(component, event, false);
		}
		catch(e){
			component.notify(e, 'CmpMetaSwitchCSV');	
		}
	},

	cancel : function(component, event, helper){
		try{
			helper.enableDownload(component);
		}
		catch(e){
			component.notify(e, 'CmpMetaSwitchCSV');	
		}
	},

	applyCOS : function(component, event, helper){
		try{
			var assets = component.get('v.assets');
			var sassets = component.get('v.table').getSelectedRows();
			var selected = component.get('v.eas')
			for(var a in sassets){
				for(var i in assets){
					if(assets[i].asset.Id == sassets[a].asset.Id){
						assets[i].easCOS = selected;
					}
				}
			}
			component.set('v.assets', assets);
		}
		catch(e){
			component.notify(e, 'CmpMetaSwitchCSV');	
		}
	},

})