({
	init : function(component, event, helper) {
		try{
			helper.getData(component);
		}
		catch(e){
			component.notify(e, 'CmpLinkAssetToNumberController.init');
		}
	},

	picklistChange : function(component, event, helper) {
		var newvalue = event.getSource().get('v.value');
		var assets = component.get('v.lstAssets');
		var dupeCnt = 0;

		if(newvalue != '--Select--'){
			for(var i in assets){
				console.log(assets[i].sn + ' == ' + newvalue)
				if(assets[i].sn == newvalue){
					dupeCnt++;
					helper.toggleHighlight(i, true);
				}
				else{
					helper.toggleHighlight(i, false);
				}
			}
		}
			
		if(dupeCnt > 1){
			var newlabel;
			var options = component.get('v.availableNumbers')
			for(var l in options){
				if(options[l].value == newvalue){
					newlabel = options[l].label
				}
			}
			component.warn(newlabel + ' is a duplicate','dimissible');
		}
		else{

			for(var i in assets){
				helper.toggleHighlight(i, false);
			}
		}
	},

	saveAll : function(component, event, helper) {
		try{
			helper.saveData(component);
		}
		catch(e){
			component.notify(e, 'CmpLinkAssetToNumberController.saveAll');
		}
	},

})