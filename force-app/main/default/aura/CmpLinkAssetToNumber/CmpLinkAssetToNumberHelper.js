({
	getData : function(component) {
		var action = component.get('c.getRecords');
		var params = {
			recordId : component.get('v.recordId')
		}
		var onsuccess = function(cmp, res){
			console.log(res);
			component.set('v.lstAssets', res.assets2);
			component.set('v.availableNumbers', res.numbers);
		}

		component.call(action, params, onsuccess);
	},

	saveData : function(component) {
		var action = component.get('c.saveAssets');
		var la = component.get('v.lstAssets');

		for(var i in la){
			if(la[i].sn == '--Select--'){
				la[i].sn = null;
			}
			// cannot send left outer joins to server
			delete la[i].asset['Assigned_Service_Numbers__r']
		}
		var params = {
			selectedAssets : la
		}

		var help = this;
		var onsuccess = function(cmp, res){
			help.getData(cmp);
			component.success('Saved!','dismissible')
		}

		component.call(action, params, onsuccess);
	},

	toggleHighlight : function(i, highlight){
		document.getElementById('trsingle_' + i).setAttribute('style',(highlight ? 'color:red;' : null));
		if(i == '0'){
			console.log('doing ' + highlight);
		}
	}
})