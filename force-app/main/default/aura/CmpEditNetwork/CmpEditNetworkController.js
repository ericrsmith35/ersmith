({
	init : function(component, event, helper) {
		try{
			component.find('data').reloadRecord(false,function(){
				var n = component.get('v.net');
				var net = {'sobjectType':'Network__c'};
				for(var f in n){
					if(!f.endsWith('__r') && f.indexOf('.') == -1 && f != 'RecordType')
						net[f] = n[f];
				}
				console.log(JSON.stringify(net))
				component.set('v.netedit', net);
				component.find('pnet').doInit();
				component.find('cust').doInit();
				helper.getPLValues(component);
				helper.setNetworkSizes(component);
			});
			
		}
		catch(e){
			component.notify(e, 'CmpEditNetwork');
		}
	},

	detectType : function(component, event, helper) {
		try{
			var val = event.getSource().get('v.value');
			var net = component.get('v.netedit');
			net.Type__c = val.indexOf('.') > -1 ? 'IPv4' : (val.indexOf(':') > -1 ? 'IPv6' : null);
			component.set('v.netedit', net);
			helper.setNetworkSizes(component);
		}
		catch(e){
			component.notify(e, 'CmpEditNetwork');
		}
	},

	validateAddress : function(component, event, helper) {
		try{
			var val = event.getSource().get('v.value');
			var net = component.get('v.netedit');
			if(net.Type__c == 'IPv4'){
				if(!(/(\d{1,4}\.){3}\d{1,4}$/g.test(val))){
					component.warn('Not a valid IPv4 Address','dismissible');
					return
				}
			}
			else if(net.Type__c == 'IPv6'){
				var octets = val.split(':');
				var octetslen = octets.length;
				var filledOctets = 0;
				for(var o in octets){
					if(octets[o] != ''){
						filledOctets++;
					}
				}
				var numberOfOctetsNeeded = 8 - filledOctets;
				// for(var o in octets){
				for(var o = 0; o < 9; o++){
					if(octets.length == o) break;
					if(octets[o] != ''){
						if(octets[o].length < 4){
							octets[o] = '0'.repeat(4 - octets[o].length) + octets[o];
						}
					}
					else{
						octets.splice(o, 1, '0000');
						numberOfOctetsNeeded--;
						while(numberOfOctetsNeeded > 0){
							octets.splice(o, 0, '0000');
							numberOfOctetsNeeded--;
							// o++;
						}
					}
				}
				if(octets.length == 9){
					octets.pop();
				}

				var sa = octets.join(':');

				if(!(/([a-f0-9]{4}:){7}[a-f0-9]{4}$/g.test(sa))){
					component.warn('Not a valid IPv6 Address','dismissible');
					return;
				}
				net.Starting_Address__c = sa;
				component.set('v.netedit',net);
				
			}
		}
		catch(e){
			component.notify(e, 'CmpEditNetwork');
		}
	},

	save : function(component, event, helper) {
		try{
			helper.upsert(component);
		}
		catch(e){
			component.notify(e, 'CmpEditNetwork');
		}
	},

	cancel : function(component, event, helper) {
		try{
			window.history.back();
		}
		catch(e){
			component.notify(e, 'CmpEditNetwork');
		}
	},
})