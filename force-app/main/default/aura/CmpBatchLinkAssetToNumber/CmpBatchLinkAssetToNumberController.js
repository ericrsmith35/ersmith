({
	init : function(component, event, helper) {
		try{
			helper.getData(component);

		}
		catch(e){
			component.notify(e, 'CmpLinkAssetToNumberController.init');
		}
	},

	updateTable : function(component, event, helper) {
		helper.populateTable(component);
		helper.selectAll(component, 'v.lstDisplayAssets', false);
		helper.selectAll(component, 'v.availableNumbers', false);
		component.find('asset_all').set('v.checked',false);
		component.find('sn_all').set('v.checked',false);
		component.set('v.countAsset',0);
		component.set('v.countSN',0);
		component.set('v.totalSN',0);
	},

	saveAll : function(component, event, helper) {
		helper.saveData(component);
	},

	assetSelect : function(component, event, helper) {
		try{
			helper.getCheckedCount(component,'v.countAsset',event.getSource().get('v.checked'))
			helper.setTotalSN(component);
		}
		catch(e){
			console.log(e)
		}
	},

	snSelect : function(component, event, helper) {
		try{
			helper.getCheckedCount(component,'v.countSN',event.getSource().get('v.checked'))
		}
		catch(e){
			console.log(e)
		}
	},

	assetSelectAll : function(component, event, helper){
		try{
			var isChecked = event.getSource().get('v.checked');
			helper.selectAll(component, 'v.lstDisplayAssets', isChecked);
			helper.setTotalSN(component);
			if(isChecked){
				component.set('v.countAsset',component.get('v.lstDisplayAssets').length);
			}
			else{
				component.set('v.countAsset',0);
			}
		}
		catch(e){
			console.log(e);
		}
	},

	snSelectAll : function(component, event, helper){
		try{
			var isChecked = event.getSource().get('v.checked');
			helper.selectAll(component, 'v.availableNumbers', isChecked);
			if(isChecked){
				component.set('v.countSN',component.get('v.availableNumbers').length);
			}
			else{
				component.set('v.countSN',0);
			}
		}
		catch(e){
			console.log(e);
		}
	}
})