({
	getPLValues : function(component) {
		var action = component.get('c.getPicklists');

		var onsuccess = function(component, result){
			component.set('v.picklists',result.picklists);
			var net = component.get('v.netedit');
			if(net.Group__c){
				component.set('v.selectedGroups', component.get('v.netedit.Group__c').split(';'))
			}

			$A.createComponent('lightning:dualListBox',
				{
					"name" : "grp_picklist",
					"label" : "Group",
					"options" : result.picklists.Group__c,
					"sourceLabel" : "Available",
					"selectedLabel" : "Selected",
					"required" : true,
					"value" : component.getReference('v.selectedGroups')
				},
				function(cmp, status, err){
					if(status === 'SUCCESS'){
						component.find('groupdiv').set('v.body', cmp);
					}
					else{
						component.error(err);
					}
				}
			)
		}

		component.call(action, null, onsuccess);
	},

	upsert : function(component){
		var action = component.get('c.saveData');

		var params = {
			network : component.get('v.netedit'),
			groups : component.get('v.selectedGroups')
		};

		var onsuccess = function(component, result){
			var e = $A.get('e.force:navigateToSObject');
			e.setParams({
				recordId : result.network.Id			
			});
			e.fire();
		}

		component.call(action, params, onsuccess);
	},

	setNetworkSizes : function(component){
		var n = component.get('v.netedit');
		var values = [];
		if(n.Type__c == 'IPv4'){
			component.find('networkpl').set('v.disabled', false);
			for(var i = 30; i >= 0; i--){
				values.push({
					label : '/' + i,
					value : '/' + i
				})
			}
		}
		else if(n.Type__c == 'IPv6'){
			component.find('networkpl').set('v.disabled', false);
			values.push({
				label : '/64',
				value : '/64',
			});
			values.push({
				label : '/126',
				value : '/126',
			});
		}
		else{
			component.find('networkpl').set('v.disabled', true);
		}
		component.set('v.networkSizes', values);
	}

})