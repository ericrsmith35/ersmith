({
	getData : function(component) {
		var action = component.get('c.getRecords2');
		var params = {
			recordId : component.get('v.recordId')
		}
		var $this = this;
		var onsuccess = function(cmp, res){
			console.log(res);
			component.set('v.lstAssets', res.assets2);
			component.set('v.availableNumbers', res.numbers);
			$this.populatePicklists(cmp);
			$this.populateTable(cmp);
		}

		component.call(action, params, onsuccess);
	},

	saveData : function(component) {
		var action = component.get('c.assignAssets');
		var selectedAssets = this.getSelected(component.get('v.lstDisplayAssets'));
		var selectedSN = this.getSelected(component.get('v.availableNumbers'));
		var params = {
			selectedAssets : selectedAssets,
			selectedServiceNumbers : selectedSN
		}
		var $this = this;

		var onsuccess = function(cmp, res){
			component.success('Saved!','dismissible')
			$this.getData(component);
		}

		component.call(action, params, onsuccess);
	},

	getSelected : function(lst){
		var rlst = [];
		for(var i in lst){
			if(lst[i].isSelected){
				rlst.push(lst[i]);
			}
		}
		return rlst;
	},

	toggleHighlight : function(i, highlight){
		document.getElementById('tr_' + i).setAttribute('style',(highlight ? 'color:red;' : null))
	},

	populatePicklists : function(component){
		var assets = component.get('v.lstAssets');
		var selectedAsset = component.get('v.selectedProduct');
		var selectedSA = component.get('v.selectedSA');
		var emptySO = {
			label : '--Select--',
			value : ''
		}
		var assetSO = [emptySO];
		var saSO = [emptySO];
		var processedProducts = []
		var processedSA = []
		for(var asset in assets){
			var a = assets[asset];
			var meetsAsset = false, meetsSA = false;
			if(a.asset.Product2Id && !processedProducts.includes(a.asset.Product2Id)){
				processedProducts.push(a.asset.Product2Id);
				assetSO.push({label:a.asset.Name,value:a.asset.Product2Id,selected:a.asset.Product2Id == selectedAsset});
			}

			if(a.asset.Service_Address__c && !processedSA.includes(a.asset.Service_Address__c)){
				processedSA.push(a.asset.Service_Address__c);
				saSO.push({label:a.asset.Service_Address_Name__c,value:a.asset.Service_Address__c,selected:a.asset.Service_Address__c == selectedSA});
			}
			
		}

		component.set('v.assetOptions', assetSO);
		component.set('v.saOptions', saSO);
		
	},


	populateTable : function(component){

		var assets = component.get('v.lstAssets');
		var selectedAsset = component.get('v.selectedProduct');
		var selectedSA = component.get('v.selectedSA');
		var lstDisplayAssets = new Array();

		for(var asset in assets){
			var a = assets[asset];
			var meetsAsset = false, meetsSA = false;
			if(selectedAsset == a.asset.Product2Id){
				meetsAsset = true;
			}
			if(selectedSA == '' || selectedSA == null || selectedSA == a.asset.Service_Address__c){
				meetsSA = true;
			}	
			
			if(meetsAsset === true && meetsSA === true){
				lstDisplayAssets.push(a);
			}
		}

		component.set('v.lstDisplayAssets',lstDisplayAssets);
	},

	selectAll : function(component, table, isSelected){
		var lst = component.get(table);
		console.log(isSelected);
		for(var l in lst){
			lst[l].isSelected = isSelected;
		}
		console.log(lst);
		component.set(table,lst);
	},

	getCheckedCount : function(component, prop, isSelected){
		var attr = component.get(prop);
		if(isSelected) attr ++;
		else attr--;
		component.set(prop,attr);
	},

	setTotalSN : function(component){
		var selectedAssets = this.getSelected(component.get('v.lstDisplayAssets'));
		var cnt = 0;
		for(var i in selectedAssets){
			cnt += selectedAssets[i].numOfSN;
		}
		component.set('v.totalSN', cnt);
	}
})