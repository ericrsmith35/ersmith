({
	/**
	 * queries asset records for opp
	 * @param  {[type]} component [description]
	 * @return {[type]}           [description]
	 */
	getData : function(component){
		var action = component.get('c.getAssets');
		var helper = this;
		var onsuccess = function(component, result){
			
			component.set('v.assets', result.assets);
			component.set('v.bbimap',result.bbiMap);
			component.set('v.templateRecords', result.templates);
			var mtSO = new Array();
			mtSO.push({
				label : '--Select--',
				value : 'null'
			})
			for(var mt in result.templates){
				mtSO.push({
					label : result.templates[mt].Name,
					value : result.templates[mt].Id
				});
			}
			
			if(!component.get('v.selectedTemplate')){
				component.set('v.templates', mtSO);
				component.set('v.selectedTemplate', mtSO[0].value);
			}
			component.set('v.easPLs', result.easPLs);
			helper.getTemplate(component);
		}

		component.call(action, {recordId : component.get('v.recordId')}, onsuccess);
	},

	/**
	 * get template for building csv from static resource
	 * @param  {[type]} component [description]
	 * @return {[type]}           [description]
	 */
	getTemplate : function(component){
		var selected = component.get('v.selectedTemplate');
		if(selected == 'null'){
			this.disableDownload(component);
			return;
		}
		this.enableDownload(component);

		var t = this.getSelectedTemplate(component);
		component.set('v.tempType', t.Template_Type__c);
		
		var t = $A.get('$Resource.metaswitchTemplate_' + t.Template_Type__c);
		var req = new XMLHttpRequest();
        req.open("GET", t);
        var $this = this;
        req.addEventListener("load", $A.getCallback(function() {
        	console.log(req.response);
            $this.initTemplateVariables(component, req.response)
            $this.setColumns(component);
        }));
        req.send(null);
	},

	getSelectedTemplate : function(component){
		var selected = component.get('v.selectedTemplate');
		return component.get('v.templateRecords')[selected]
	},

	/**
	 * set data table column info
	 * @param {[type]} component [description]
	 */
	setColumns : function(component){
		if(component.get('v.tempType') == 'Residential'){
			component.set('v.tableCols', [
				{label:'Asset', fieldName:'assetName',type:'text'},
				{label:'Service Number', fieldName:'service_Number_Name',type:'text'},
				{label:'Metaswitch Number Status', fieldName:'service_Number_Type',type:'text'},
				// {label:'Metaswitch Subscriber Template', fieldName:'metaswitch_Subscriber_Template',type:'text'},
				{label:'Service Number Features', fieldName:'service_Number_Calling_Features',type:'text'},
			])
		}
		else if(component.get('v.tempType') == 'Commercial'){
			component.set('v.tableCols', [
				{label:'Asset', fieldName:'assetName',type:'text'},
				{label:'Service Number', fieldName:'service_Number_Name',type:'text'},
				{label:'Metaswitch Number Status', fieldName:'service_Number_Type',type:'text'},
				// {label:'Metaswitch Subscriber Template', fieldName:'metaswitch_Subscriber_Template',type:'text'},
				{label:'Service Number Features', fieldName:'service_Number_Calling_Features',type:'text'},
				{label:'Business Group', fieldName:'bizGroup',type:'text', editable : 'true'},
				{label:'EAS Class of Service', fieldName:'easCOS',type:'text'},
				{label:'Department', fieldName:'department',type:'text', editable : 'true'},
				{label:'Calling Party Number', fieldName:'cpNumber',type:'text', editable : 'true'},
				{label:'PIN (EAS)', fieldName:'pinaes',type:'text', editable : 'true'},
				{label:'EAS Password', fieldName:'easpw',type:'text', editable : 'true'},
			])
		}
		else component.set('v.tableCols', new Array());
	},

	/**
	 * parse template data for processing
	 * @param  {[type]} component [description]
	 * @param  {[type]} raw       [raw template data]
	 * @return {[type]}           [description]
	 */
	initTemplateVariables : function(component, raw){
		component.set('v.csvString', raw);
		component.set('v.headers', raw.split(','));
	},

	/**
	 * creates a random number between 1000-9999
	 * @return {[type]} [description]
	 */
	randomNumber : function() {
		var ri = Math.floor(1000 + (9999 - 1000) * Math.random());
		return ri;
	},

	/**
	 * creates a random string with at least 1 upper case, 1 lower case, 1 number, and 1 special character
	 * @param  {[type]} length [string length]
	 * @return {[type]}        [description]
	 */
	randomString : function(length){
		var allChar = '';
	    allChar += 'abcdefghijklmnopqrstuvwxyz';
	    allChar += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	    allChar += '0123456789';
	    allChar += '~`!@#$%^&*()_+-={}[]:";\'<>?./|\\';
	    var result = '';

	    // loop through generator until criteria has been met
	    while(!(/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*\W)/.test(result))){
	    	result = '';
		    for (var i = length; i > 0; --i){
		    	result += allChar[Math.floor(Math.random() * allChar.length)];
		    }
	    }
		    
	    return result;
	},

	/**
	 * creates the csv files
	 * @param  {[type]} component [description]
	 * @return {[type]}           [description]
	 */
	buildCSV : function(component){
		var mapping = this.getMapping(this);

		var headers = component.get('v.headers');
		var selectedTemplate = component.get('v.selectedTemplate')
		var assets = component.get('v.table').getSelectedRows();

		// make sure at least 1 asset was selected in data table
		if(assets.length == 0){
			component.warn('Please select at least one asset','dismissible');
			return;
		}
		

		// get base csv template string
		var csv = component.get('v.csvString');
		var st = this.getSelectedTemplate(component).Name;
		var listObj = { st : assets};
		component.log(listObj)
		var assetIds = [];
		var createdFile = false;

		// loop through each template type and build csv
		for(var list in listObj){
			var assets = listObj[list];
			component.log(assets)

			//if empty, move on to next
			if(assets.length == 0) continue;
			var mycsv = csv;
			createdFile = true;

			console.log(headers);
			// add in asset data rows
			for(var a in assets){
				var asset = assets[a];
				assetIds.push(asset.asset.Id);
				var assetData = [];

				for(var h in headers){
					component.log(headers[h])

					// mapping object returns functions to get data.
					var data = mapping[headers[h]](component, asset);
					assetData.push(data);
				}
				
				// add new data row
				mycsv += '\n' + assetData.join(',');
			}

			// downloads csv
			this.downloadCSV(component, mycsv, list);
		}

		component.log('createdFile: ' + createdFile);

		if(!createdFile){
			component.warn('Assets do not have enough data to create a CSV file','dismissible');
			return;
		}
		var action = component.get('c.markAssets');
		var $this = this;
		var onsuccess = function(cmp,res){
			cmp.success('Exported!');
			$this.getData(cmp);
			cmp.set('v.selectedRows',[]);
		}
		console.log(assetIds);
		component.call(action, {assetIds : assetIds}, onsuccess);
	},

	/**
	 * downloads csv on user's browser
	 * @param  {[type]} csv  [csv string]
	 * @param  {[type]} name [file name]
	 * @return {[type]}      [description]
	 */
	downloadCSV : function(component, csv, name){
		var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; 
        var filename = 'Metaswitch - ' + component.get('v.opp').Name + ' - ' + new Date() + '.csv';
        hiddenElement.download = filename;  
        document.body.appendChild(hiddenElement); // required for FireFox
    	hiddenElement.click();

    	var action = component.get('c.createFile');
    	var p = {csv : csv, filename : filename, recordId : component.get('v.recordId')};

    	component.call(action, p);
	},

	/**
	 * gets data from asset field in salesforce
	 * @param  {[type]} data [asset record]
	 * @param  {[type]} arg  [field name]
	 * @return {[type]}      [description]
	 */
	getFromSalesforceField : function(data, arg){
		// check if relationship reference
		if(arg.includes('.')){
			var res = data;
			var objarray = arg.split('.')
			for(var i = 0; i < objarray.length; i++){
				res = res[objarray[i]];
				if(res == null){
					return '';
				}
			}
			return res;
		}
		else return data[arg];
	},

	/**
	 * handles unique mapping types
	 * @param  {[type]} component [description]
	 * @param  {[type]} data      [asset record]
	 * @param  {[type]} arg       [mapping type]
	 * @return {[type]}           [description]
	 */
	getSpecial : function(component, data, arg){
		var r = '';
		switch(arg){
			case 'pin':
				r = this.randomNumber();
				break;

			case 'sip':
				r = this.randomString(8);
				break;

			case 'ForceLNP':
				if(this.getFromSalesforceField(data, 'service_Number_Type') == 'N'){
					r = "false";
				}
				else r = "true"
				break;

			case 'BBIMap':
				var sn = this.getFromSalesforceField(data, 'service_Number_Name');
				if(sn == '' || sn == null) return r;
				sn = sn.substring(0,6);
				
				var bbi = component.get('v.bbimap')[sn];
				if(!bbi) return r;
				r = bbi['switch_value__c']
				break;

			case 'BBITandem':
				var sn = this.getFromSalesforceField(data, 'service_Number_Name');
				if(sn == '' || sn == null) return r;
				sn = sn.substring(0,6);

				var bbi = component.get('v.bbimap')[sn];
				if(!bbi) return "2911";

				if(bbi['tandem_id__c'] == 2){
					r = "1911";
				}
				else r = "2911";
				break;

			case 'CFSCI':
				r = '"' + (this.getFromSalesforceField(data, 'acct.Name') + ' ' + this.getFromSalesforceField(data, 'sa.Name')).trim() + '"';
				break;

			case 'CFS_Number_Status':
				r = this.getFromSalesforceField(data, 'service_Number_Type') == 'N' ? 'Normal' : 'Ported to';
				break;

		}
		return r;
	},

	/**
	 * mapping object definition. maps csv headers to callback functions to get corresponding row data
	 * @param  {[type]} $this [helper instance]
	 * @return {[type]}       [description]
	 */
	getMapping : function($this) {
		return {
			"MetaSphere CFS" : $A.getCallback(
				function(component, asset){
					return "GWI1"
				}
			),
			"Phone number" : $A.getCallback(
				function(component, asset){
					return $this.getFromSalesforceField(asset,'service_Number_Name')
				}
			),
			"CFS Number status" : $A.getCallback(
				function(component, asset){
					return $this.getFromSalesforceField(asset,'service_Number_Type')
				}
			),
			"Force LNP lookup for calls to this subscriber" : $A.getCallback(
				function(component, asset){
					return $this.getSpecial(component, asset,'ForceLNP')
				}
			),
			"Name (CFS)" : $A.getCallback(
				function(component, asset){
					if($this.getSelectedTemplate(component).Template_Type__c == 'Residential'){
						return $this.getFromSalesforceField(asset,'acct.Name')
					}
					else if($this.getSelectedTemplate(component).Template_Type__c == 'Commercial'){
						return $this.getFromSalesforceField(asset,'assetName')
					}
				}
			),
			"PIN (CFS)" : $A.getCallback(
				function(component, asset){
					return $this.getSpecial(component, asset,'pin')
				}
			),
			"New SIP password" : $A.getCallback(
				function(component, asset){
					return $this.getSpecial(component, asset,'sip')
				}
			),
			"CFS Customer info" : $A.getCallback(
				function(component, asset){
					return $this.getSpecial(component, asset,'CFSCI')
				}
			),
			"CFS Customer info 2" : $A.getCallback(
				function(component, asset){
					return "GWI"
				}
			),
			"CFS Customer info 3" : $A.getCallback(
				function(component, asset){
					return $this.getFromSalesforceField(asset,'acct.PlatID_Display__c')
				}
			),
			"Line Class Code 1" : $A.getCallback(
				function(component, asset){
					return $this.getSpecial(component, asset,'BBIMap')
				}
			),
			"Line Class Code 2" : $A.getCallback(
				function(component, asset){
					return "120 MAINE"
				}
			),
			"Line Class Code 3" : $A.getCallback(
				function(component, asset){
					return "207"
				}
			),
			"Line Class Code 4" : $A.getCallback(
				function(component, asset){
					return $this.getSpecial(component, asset,'BBITandem')
				}
			),
			"CFS Subscriber Group" : $A.getCallback(
				function(component, asset){
					return "Subscribers in Lata 120"
				}
			),
			"Template" : $A.getCallback(
				function(component, asset){
					return $this.getSelectedTemplate(component).Name;
				}
			),
			"MetaSphere EAS" : $A.getCallback(
				function(component, asset){
					return "GWIEAS"
				}
			),
			"Business Group (CFS)" : $A.getCallback(
				function(component, asset){
					return $this.getFromSalesforceField(asset,'bizGroup');
				}
			),

			"Business Group (EAS)" : $A.getCallback(
				function(component, asset){
					return $this.getFromSalesforceField(asset,'bizGroup');
				}
			),

			"EAS Account Type" : $A.getCallback(
				function(component, asset){
					return "Primary";
				}
			),

			"EAS Device Type" : $A.getCallback(
				function(component, asset){
					return "Landline";
				}
			),

			"EAS Customer Group" : $A.getCallback(
				function(component, asset){
					return "GWIGroup";
				}
			),

			"Delegated Management Group" : $A.getCallback(
				function(component, asset){
					return "GWI";
				}
			),

			"Name (EAS)" : $A.getCallback(
				function(component, asset){
					return $this.getFromSalesforceField(asset,'assetName')
				}
			),

			"PIN (EAS)" : $A.getCallback(
				function(component, asset){
					return $this.getFromSalesforceField(asset,'pinaes');
				}
			),

			"EAS Password" : $A.getCallback(
				function(component, asset){
					return $this.getFromSalesforceField(asset,'easpw');
				}
			),

			"EAS Class of Service" : $A.getCallback(
				function(component, asset){
					return $this.getFromSalesforceField(asset,'easCOS');
				}
			),

			"Department (CFS)" : $A.getCallback(
				function(component, asset){
					return $this.getFromSalesforceField(asset,'department');
				}
			),

			"Department (EAS)" : $A.getCallback(
				function(component, asset){
					return $this.getFromSalesforceField(asset,'department');
				}
			),

			"Calling party number" : $A.getCallback(
				function(component, asset){
					return $this.getFromSalesforceField(asset,'cpNumber');
				}
			),

			"CFS Persistent Profile" : $A.getCallback(
				function(component, asset){
					return $this.getSelectedTemplate(component).Name;
				}
			),
		}
	},

	disableDownload : function(component){
		component.find('downloadbtn').set('v.disabled', true);
	},

	enableDownload : function(component){
		component.find('downloadbtn').set('v.disabled', false);
	},

	createTable : function(component){
		
		$A.createComponent('lightning:datatable',{
			'columns' : component.getReference("{!v.tableCols}"), 
			'data' : component.getReference("{!v.assets}"),
			'keyField' : "id",
			'selectedRows' : component.getReference("{!v.selectedRows}"),
			'onsave' : component.getReference("{!c.saveTable}"),
			'oncellchange' : component.getReference("{!c.cellChange}"),
			'oncancel' : component.getReference("{!c.cancel}")
			
		},function(cmp, status, mesg){
			if(status === 'SUCCESS'){
				component.find('dtbl').set('v.body', cmp);
				component.set('v.table', cmp);
			}
			else{
				throw mesg;
			}
		})
	},

	destroyTable : function(component){
		component.get('v.table').destroy();
	},

	updateWrappers : function(component, event, saveToSFDC){
		var changes = event.getParam('draftValues');
		var assets = component.get('v.assets');
		for(var i in changes){
			var record = changes[i];
			var a = assets[record.id.replace(/row-/g,'')];
			for(var f in record){
				if(f != 'id'){
					a[f] = record[f];
				}
			}
		}

		if(saveToSFDC){
			component.set('v.assets', assets);

			var action = component.get('c.saveAssets');
			var params = {
				assets : assets
			}

			component.call(action, params, null);
		}
	}
})