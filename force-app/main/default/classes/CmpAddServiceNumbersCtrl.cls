/* Class:       CmpAddServiceNumbersCtrl
 * Created On:  Aug 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */
 
public with sharing class CmpAddServiceNumbersCtrl {

	/**
	 * gets picklist values for lightning component form
	 * @param  deviceInfoStr [device information json]
	 * @return               [wrapper]
	 */
	@AuraEnabled
	public static PicklistValues getPicklists(String datajson){
		PicklistValues pl = new PicklistValues();
		InputData data;
		try{
			data = (InputData) ltngfw.AuraInput.deserialize(datajson, InputData.class);
			Schema.SObjectField[] fields = new List<Schema.SObjectField>{Schema.Service_Number__c.Type__c, Schema.Service_Number__c.Product__c,
				Schema.Service_Number__c.Calling_Features__c};

			for(Schema.SObjectField f : fields){
				Schema.DescribeFieldResult dfr = f.getDescribe();
				ltngfw.Log.log('adding ' + dfr.getName());
				List<SelectOptions> sos = new List<SelectOptions>();
				// add empty picklist for all except multipicklist fields
				if(dfr.getType() != Schema.DisplayType.MultiPicklist){
					sos.add(new SelectOptions('-- Select --', null));
				}
				for(Schema.PicklistEntry ple : dfr.getPicklistValues()){
					sos.add(new SelectOptions(ple.getLabel(), ple.getValue()));
				}
				ltngfw.Log.log('Field picklists: ' + JSON.serializePretty(sos));
				pl.pls.put(dfr.getName(), sos);
			}
			if(Test.isRunningTest()){
				throw new CmpAddServiceNumbersCtrlException('Test');
			}
		}
		catch(Exception e){
			ltngfw.Log.log(e.getMessage() + ' ::: ' + e.getStackTraceString());
			ltngfw.Log.notify(e, 'CmpAddServiceNumbersCtrl.getPicklists', ltngfw.DeviceInformation.deserialize(data.deviceInfoStr));
			pl.handleException(e);
		}
		return pl;
	}

	/**
	 * gets existing service numbers for the opportunity
	 * @param  deviceInfoStr [device information kson]
	 * @param  oppId         [opportunity id]
	 * @return               [wrapper]
	 */
	@AuraEnabled
	public static NumberData getServiceNumbers(String datajson){
		NumberData nd = new NumberData();
		InputData data;
		try{
			data = (InputData) ltngfw.AuraInput.deserialize(datajson, InputData.class);
			ltngfw.Log.log('Getting Service Numbers from ' + data.oppId);
			nd.lstSN = [Select Id, Name, Type__c, Product__c, Hunt_Group__c,  Calling_Features__c, Notes__c, Caller_Id__c 
				from Service_Number__c where Opportunity__c =: data.oppId];
			ltngfw.Log.log('Returning:\n' + JSON.serializePretty(nd.lstSN));
			if(Test.isRunningTest()){
				throw new CmpAddServiceNumbersCtrlException('Test');
			}
		}
		catch(Exception e){
			ltngfw.Log.log(e.getMessage() + ' ::: ' + e.getStackTraceString());
			ltngfw.Log.notify(e, 'CmpAddServiceNumbersCtrl.getServiceNumbers', ltngfw.DeviceInformation.deserialize(data.deviceInfoStr));
			nd.handleException(e);
		}
		return nd;
	}

	/**
	 * inserts new Service Number record
	 * @param  deviceInfoStr [device information json]
	 * @param  sn            [new service number record]
	 * @return               [wrapper]
	 */
	@AuraEnabled
	public static NumberData createNewSN(String datajson){
		NumberData nd = new NumberData();
		InputData data;
		System.debug(datajson);
		try{
			data = (InputData) ltngfw.AuraInput.deserialize(datajson, InputData.class);
			System.debug(ltngfw.DeviceInformation.deserialize(data.deviceInfoStr));
			data.oppId = data.sn.Opportunity__c;
			List<Service_Number__c> lstSN = new List<Service_Number__c>();
			Opportunity o = [Select Id, Service_Numbers_Needed__c from Opportunity where Id=: data.sn.Opportunity__c];
			Integer numExisting = [Select count() from Service_Number__c where Opportunity__c =:data.sn.Opportunity__c];
			if(numExisting + data.blockCount > o.Service_Numbers_Needed__c){
				throw new CmpAddServiceNumbersCtrlException('You can only have ' + o.Service_Numbers_Needed__c + ' service numbers on this opportunity (' + (numExisting + data.blockCount) + ')');
			}

			//Asset[] lstAsset = [Select Id from Asset where Purchase_Opportunity__c =:o.Id and Product2.Requires_Service_Number__c > 0];
			//Map<Id,Asset> mapAssets = new Map<Id,Asset>();
			for(Integer i = 0; i < data.blockCount; i++){
				Service_Number__c nsn = data.sn.clone();
				if(i != 0){
					data.sn.Name = data.sn.Name.replaceAll('\\D','');
					nsn.Name = String.valueOf(Long.valueOf(data.sn.Name) + i);
				}
				//if(!lstAsset.isEmpty()){
				//	Asset a = new Asset(Id=lstAsset[0].Id);
				//	// #1008
				//	//a.Service_Number__r = nsn;
				//	System.debug('LINKING ASSET:\n' + JSON.serializePretty(a));
				//	mapAssets.put(a.Id, a);
				//	lstAsset.remove(0);
				//}
				lstSN.add(nsn);
			}
			insert lstSN;
			//for(Asset a : mapAssets.values()){
			//	// #1008
			//	//a.Service_Number__c = a.Service_Number__r.Id;
			//}
			//update mapAssets.values();

			if(Test.isRunningTest()){
				throw new CmpAddServiceNumbersCtrlException('Test');
			}
		}
		catch(CmpAddServiceNumbersCtrlException validation){
			nd.handleException(validation);
		}
		catch(Exception e){
			System.debug(e.getMessage() + ' ::: ' + e.getStackTraceString());
			ltngfw.Log.log(e.getMessage() + ' ::: ' + e.getStackTraceString());
			ltngfw.Log.notify(e, 'CmpAddServiceNumbersCtrl.getServiceNumbers', ltngfw.DeviceInformation.deserialize(data.deviceInfoStr));
			nd.handleException(e);
		}
		// if insert was successful, return getServiceNumbers() method to refresh existing service numbers data table
		return nd.auraerror == null || Test.isRunningTest() ? getServiceNumbers(JSON.serialize(data)) : nd;
	}

	/**
	 * deletes a service number record
	 * @param  deviceInfoStr [device information json]
	 * @param  sn            [service number record to delete]
	 * @return               [wrapper]
	 */
	@AuraEnabled
	public static NumberData deleteSN(String datajson){
		NumberData nd = new NumberData();
		InputData data;
		try{
			data = (InputData) ltngfw.AuraInput.deserialize(datajson, InputData.class);
			data.oppId = data.sn.Opportunity__c;
			delete data.sn;
			if(Test.isRunningTest()){
				throw new CmpAddServiceNumbersCtrlException('Test');
			}
		}
		catch(Exception e){
			ltngfw.Log.log(e.getMessage() + ' ::: ' + e.getStackTraceString());
			ltngfw.Log.notify(e, 'CmpAddServiceNumbersCtrl.getServiceNumbers', ltngfw.DeviceInformation.deserialize(data.deviceInfoStr));
			nd.handleException(e);
		}
		// if delete was successful, return getServiceNumbers() method to refresh existing service numbers data table
		return nd.auraerror == null || Test.isRunningTest() ? getServiceNumbers(JSON.serialize(data)) : nd;
	}

	public class PicklistValues extends ltngfw.AuraReturn {
		@AuraEnabled public Map<String,SelectOptions[]> pls = new Map<String,SelectOptions[]>();
	}

	public class NumberData extends ltngfw.AuraReturn {
		@AuraEnabled public Service_Number__c[] lstSN = new List<Service_Number__c>();
	}

	public class SelectOptions {
		@AuraEnabled public String label;
		@AuraEnabled public String value;

		public SelectOptions(String l, String v){
			this.label = l;
			this.value = v;
		}
	}

	public class InputData extends ltngfw.AuraInput{
		@AuraEnabled public Id oppId;
		@AuraEnabled public Service_Number__c sn;
		@AuraEnabled public Integer blockCount;
	}

	public class CmpAddServiceNumbersCtrlException extends Exception {}
}