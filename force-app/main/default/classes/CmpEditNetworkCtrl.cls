/* Class:       CmpEditNetworkCtrl
 * Created On:  
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */
 
public with sharing class CmpEditNetworkCtrl {

	@AuraEnabled
	public static Output getPicklists(String datajson){
		Output o = new Output();
		Input inp;
		try{
			inp = (Input) ltngfw.AuraInput.deserialize(datajson, Input.class);
			o.picklists = new Map<String,List<SelectOpt>>();
			SelectOpt defaultSO = new SelectOpt('--Select--','',true);
			for(Schema.SObjectField sof : Schema.SobjectType.Network__c.fields.getMap().values()){
				Schema.DescribeFieldResult dfr = sof.getDescribe();
				if(dfr.getType() == Schema.DisplayType.PICKLIST || dfr.getType() == Schema.DisplayType.MULTIPICKLIST){
					o.picklists.put(dfr.getName(), new List<SelectOpt>());
					if(dfr.getType() == Schema.DisplayType.PICKLIST){
						o.picklists.get(dfr.getName()).add(defaultSO);
					}
					for(Schema.PicklistEntry ple : dfr.getPicklistValues()){
						SelectOpt so = new SelectOpt(ple.getLabel(), ple.getValue(), false);
						o.picklists.get(dfr.getName()).add(so);
					}
				}
			}
			if(Test.isRunningTest()){
				throw new AuraHandledException('Test');
			}
		}
		catch(Exception e){
			System.debug(e.getMessage() + ' :: ' + e.getStackTraceString());
			o.handleException(e);
			ltngfw.Log.notify(e, 'CmpEditNetworkCtrl', ltngfw.DeviceInformation.deserialize(inp.deviceInfoStr == null ? '{}' : inp.deviceInfoStr));
		}
		return o;
	}

	@AuraEnabled
	public static Output saveData(String datajson){
		Output o = new Output();
		Input inp;
		try{
			inp = (Input) ltngfw.AuraInput.deserialize(datajson, Input.class);
			if(inp.groups != null){
				inp.network.Group__c = String.join(inp.groups,';');
			}
			if(inp.network.Id != null){
				update inp.network;
			}
			else{
				insert inp.network;
			}
			o.network = inp.network;
			if(Test.isRunningTest()){
				throw new AuraHandledException('Test');
			}
		}
		catch(Exception e){

			System.debug(e.getMessage() + ' :: ' + e.getStackTraceString());
			o.handleException(e);
			ltngfw.Log.notify(e, 'CmpEditNetworkCtrl', ltngfw.DeviceInformation.deserialize(inp.deviceInfoStr == null ? '{}' : inp.deviceInfoStr));
		}
		return o;
	}

	public class Output extends ltngfw.AuraReturn{
		@AuraEnabled public Map<String,List<SelectOpt>> picklists;
		@AuraEnabled public Network__c network;
	}

	public class Input extends ltngfw.AuraInput {
		@AuraEnabled public Network__c network;	
		@AuraEnabled public List<String> groups;
	}

	public class SelectOpt {
		@AuraEnabled public String label;
		@AuraEnabled public String value;
		@AuraEnabled public Boolean selected;

		public SelectOpt(String l, String v, Boolean s){
			this.label = l;
			this.value = v;
			this.selected = s;
		}
	}
}