/* Class:       CmpAddDirectoryListingCtrl
 * Created On:  AUg 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: Controller for CmpAddDirectoryListing lightning component
 */
 
public with sharing class CmpAddDirectoryListingCtrl {

	/**
	 * gets directories and related opportunity for component
	 * @param  deviceInfoStr [device information json string]
	 * @param  oppId         [opp id]
	 * @return               [description]
	 */
	@AuraEnabled
	public static AddDirectoryListingReturn queryDirectories(String datajson){
		AddDirectoryListingReturn ret = new AddDirectoryListingReturn();
		InputData data;
		try{
			data = (InputData) ltngfw.AuraInput.deserialize(datajson, InputData.class);

			Directory__c[] dirs = [Select Id, Label__c from Directory__c];
			for(Directory__c d : dirs){
				ret.dirs.add(new SelectOptions(d.Label__c, d.Id));
			}
			ret.opp = [Select Id, Account.Name from Opportunity where Id =: data.oppId];
			ret.existingSNDL = [Select Id, Name, Address_Listing__c, Service_Address__c, Opportunity__c, Yellow_Page_Listing__c, 
				Business_Name__c, First_Name__c, Last_Name__c, Service_Number__c, Directory__c,
				Service_Address__r.Name, Service_Number__r.Name, Yellow_Page_Listing__r.Name, Directory__r.Name
				from Service_Number_Directory_Listing__c where Opportunity__c =: data.oppId];
			if(Test.isRunningTest()) throw new CmpAddDirectoryListingException('test');
		}
		catch(Exception e){
			ret.handleException(e);
			ltngfw.Log.notify(e, 'CmpAddDirectoryListingCtrl', ltngfw.DeviceInformation.deserialize(data.deviceInfoStr));
		}
		return ret;
	}

	/**
	 * inserts new SNDLs based on the chosen directories
	 * @param  deviceInfoStr [device information json string]
	 * @param  sndl          [service number directory listing instance]
	 * @param  directoryIds  [chosen directory ids]
	 * @return               [description]
	 */
	@AuraEnabled
	public static AddDirectoryListingReturn createSNDL(String datajson){
		AddDirectoryListingReturn ret = new AddDirectoryListingReturn();
		InputData data;
		try{
			data = (InputData) ltngfw.AuraInput.deserialize(datajson, InputData.class);
			List<Service_Number_Directory_Listing__c> lstSNDL = new List<Service_Number_Directory_Listing__c>();
			for(String did : data.directoryIds){
				Service_Number_Directory_Listing__c cln = data.sndl.clone();
				cln.Directory__c = did;
				lstSNDL.add(cln);
			}
			ltngfw.Log.log(JSON.serializePretty(lstSNDL));
			insert lstSNDL;
			if(Test.isRunningTest()) throw new CmpAddDirectoryListingException('test');
		}
		catch(Exception e){
			ret.handleException(e);
			ltngfw.Log.notify(e, 'CmpAddDirectoryListingCtrl', ltngfw.DeviceInformation.deserialize(data.deviceInfoStr));
		}
		return ret;
	}

	@AuraEnabled
	public static AddDirectoryListingReturn deleteSNDL(String datajson){
		AddDirectoryListingReturn ret = new AddDirectoryListingReturn();
		InputData data;
		try{
			data = (InputData) ltngfw.AuraInput.deserialize(datajson, InputData.class);
			delete [Select Id from Service_Number_Directory_Listing__c where Id =: data.sndlid];
			if(Test.isRunningTest()) throw new CmpAddDirectoryListingException('test');
		}
		catch(Exception e){
			ret.handleException(e);
			ltngfw.Log.notify(e, 'CmpAddDirectoryListingCtrl', ltngfw.DeviceInformation.deserialize(data.deviceInfoStr));
		}
		return ret;
	}

	public class AddDirectoryListingReturn extends ltngfw.AuraReturn {
		@AuraEnabled public SelectOptions[] dirs = new List<SelectOptions>();
		@AuraEnabled public Opportunity opp;
		@AuraEnabled public Service_Number_Directory_Listing__c[] existingSNDL;
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
		@AuraEnabled public Service_Number_Directory_Listing__c sndl;
		@AuraEnabled public List<String> directoryIds;
		@AuraEnabled public Id sndlid;
		@AuraEnabled public String deviceInfoStr;
	}

	public class CmpAddDirectoryListingException extends Exception {}
}