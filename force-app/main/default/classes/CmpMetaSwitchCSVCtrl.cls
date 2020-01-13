/* Class:       CmpMetaSwitchCSVCtrl
 * Created On:  Sept 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */
 
public with sharing class CmpMetaSwitchCSVCtrl {

	/**
	 * init method to get data for page
	 * @param  datajson [input params json]
	 * @return          [description]
	 */
	@AuraEnabled
	public static Output getAssets(String datajson){
		Output o = new Output();
		Input data;
		try{
			data = (Input) ltngfw.AuraInput.deserialize(datajson, Input.class);

			// #1008
			// query assets for opp
			Asset[] lstA = [Select Id,  Name, Metaswitch_Number_Status__c, Account.Name, Account.PlatID_Display__c,Service_Address__r.Name, 
				Business_Group__c, EAS_Class_of_Service__c, Department__c, Calling_Party_Number__c,Metaswitch_Template__c,
				Metaswitch_Subscriber_Template__c, (Select Id, Service_Number__r.Name, Service_Number__r.Type__c, Service_Number__r.Calling_Features__c from Assigned_Service_Numbers__r)
				from Asset where Purchase_Opportunity__c =: data.recordId and Built_In_Switch__c = false and Total_Service_Numbers_Needed__c = 1
				and Product2.Build_in_Metaswitch__c = true];

			// now need to gather service number prefix for BBI query
			Set<String> bbiSearches = new Set<String>();
			for(Asset a : lstA){
				if(a.Assigned_Service_Numbers__r.isEmpty()){
					continue;
				}
				o.assets.add(new CmpMetaSwitchCSVCtrl.AssetWrapper(a,a.Assigned_Service_Numbers__r[0]));
				String sn = a.Assigned_Service_Numbers__r[0].Service_Number__r.Name;
				if(sn != null){
					if(sn.length() <= 6){
						bbiSearches.add(sn);
					}
					else{ 
						bbiSearches.add(sn.substring(0,6));
					}
				}
			}
			System.debug('bbi searches:\n' + JSON.serializePretty(bbiSearches));

			// find BBI associated with numbers
			BBI_metaswitch_rate_centers__c[] lstBBI = [Select Id, Tandem_Id__c, switch_value__c, Npa_nxx__c from BBI_metaswitch_rate_centers__c where Npa_nxx__c in :bbiSearches];
			for(BBI_metaswitch_rate_centers__c bbi : lstBBI){
				o.bbiMap.put(bbi.Npa_nxx__c, bbi);
			}

			// get template types from picklist field on Asset
			Metaswitch_Template__c[] lstMT = [Select Id, Template_Type__c, Name from Metaswitch_Template__c Order By Name ASC];
			for(Metaswitch_Template__c mt : lstMT){
				o.templates.put(mt.Id, mt);
			}

			List<Schema.PicklistEntry> lstPLE = Schema.SObjectType.Asset.fields.EAS_Class_of_Service__c.getPicklistValues();
			for(Schema.PicklistEntry ple : lstPLE){
				o.easPLS.add(new SelectOpt(ple.getLabel(), ple.getValue()));
			}

			if(Test.isRunningTest()){
				throw new UnitTestException('UnitTest');
			}
		}
		catch(Exception e){
			ltngfw.Log.notify(e, 'CmpMetaSwitchCSVCtrl', ltngfw.DeviceInformation.deserialize(data.deviceInfoStr));
			o.handleException(e);
		}
		return o;
	}

	/**
	 * marks assets as built in switch
	 * @param  datajson [input params json]
	 * @return          [description]
	 */
	@AuraEnabled
	public static Output markAssets(String datajson){
		Output o = new Output();
		Input data;
		try{
			data = (Input) ltngfw.AuraInput.deserialize(datajson, Input.class);

			// de-dupe list by parsing to set
			Set<String> assetIds = new Set<String>(data.assetIds);
			Map<Id,Asset> mapAssets = new Map<Id,Asset>();
			for(Id aid : assetIds){
				mapAssets.put(aid, new Asset(Id=aid,Built_In_Switch__c=true));
			}
			ltngfw.Log.log('assetss: ' + JSON.serializePretty(data.assetIds));
			update mapAssets.values();

			if(Test.isRunningTest()){
				throw new UnitTestException('UnitTest');
			}
		}
		catch(Exception e){
			ltngfw.Log.notify(e, 'CmpMetaSwitchCSVCtrl', ltngfw.DeviceInformation.deserialize(data.deviceInfoStr));
			o.handleException(e);
		}
		return o;
	}

	/**
	 * creates a downloadable file
	 * @param  datajson [input params json]
	 * @return          [description]
	 */
	@AuraEnabled
	public static Output createFile(String datajson){
		Output o = new Output();
		Input data;
		try{
			data = (Input) ltngfw.AuraInput.deserialize(datajson, Input.class);

			//create file
			ContentVersion cv = new ContentVersion();
			cv.Title = data.filename;
			cv.PathOnClient = data.filename;
			cv.VersionData = Blob.valueOf(data.csv);
			insert cv;

			// get created content document id
			Id cdid = [Select Id, ContentDocumentId from ContentVersion where Id =:cv.Id].ContentDocumentId;

			// create a link between opp and file for the file to show up under Files related list and inherit sharing
			ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.ContentDocumentId = cdid;
			cdl.LinkedEntityId = data.recordId;
			cdl.Visibility = 'InternalUsers';
			cdl.ShareType = 'V';
			insert cdl;

			if(Test.isRunningTest()){
				throw new UnitTestException('UnitTest');
			}
		}
		catch(Exception e){
			ltngfw.Log.notify(e, 'CmpMetaSwitchCSVCtrl', ltngfw.DeviceInformation.deserialize(data.deviceInfoStr));
			o.handleException(e);
		}
		return o;
	}

	/**
	 * for commercial templates, save user-input data 
	 * @param  datajson [description]
	 * @return          [description]
	 */
	@AuraEnabled
	public static Output saveAssets(String datajson){
		Output o = new Output();
		Input data;
		try{
			data = (Input) ltngfw.AuraInput.deserialize(datajson, Input.class);
			
			// de-dupe list by parsing to set
			Map<Id,Asset> mapAssets = new Map<Id,Asset>();
			for(AssetWrapper aw : data.assets){
				Asset a = aw.setNewValues();
				mapAssets.put(a.Id, a);
			}
			ltngfw.Log.log('assets: ' + JSON.serializePretty(mapAssets));
			update mapAssets.values();

			if(Test.isRunningTest()){
				throw new UnitTestException('UnitTest');
			}
		}
		catch(Exception e){
			ltngfw.Log.notify(e, 'CmpMetaSwitchCSVCtrl', ltngfw.DeviceInformation.deserialize(data.deviceInfoStr));
			o.handleException(e);
		}
		return o;
	}

	public class Output extends ltngfw.AuraReturn {
		@AuraEnabled public CmpMetaSwitchCSVCtrl.AssetWrapper[] assets = new List<CmpMetaSwitchCSVCtrl.AssetWrapper>();
		@AuraEnabled public Map<Id,Metaswitch_Template__c> templates = new Map<Id,Metaswitch_Template__c>();
		@AuraEnabled public Map<String,BBI_metaswitch_rate_centers__c> bbiMap = new Map<String,BBI_metaswitch_rate_centers__c>();
		@AuraEnabled public List<SelectOpt> easPLs = new List<SelectOpt>();
	}


	public class AssetWrapper {
		@AuraEnabled public Boolean selected = false;
		@AuraEnabled public Asset asset;
		@AuraEnabled public Id snid;
		@AuraEnabled public String assetName;
		@AuraEnabled public Account acct;
		@AuraEnabled public Service_Address__c sa;
		@AuraEnabled public String metaswitch_Subscriber_Template;
		@AuraEnabled public String service_Number_Name;
		@AuraEnabled public String service_Number_Type;
		@AuraEnabled public String service_Number_Calling_Features;
		@AuraEnabled public String bizGroup;
		@AuraEnabled public String easCOS;
		@AuraEnabled public String department;
		@AuraEnabled public String cpNumber;
		@AuraEnabled public String pinaes;
		@AuraEnabled public String easpw;

		public AssetWrapper(Asset a, Assigned_Service_Number__c asn){
			this.asset = new Asset(Id=a.Id, Name=a.Name);
			this.assetName = a.Name;
			this.acct = a.Account;
			this.sa = a.Service_Address__r;
			this.metaswitch_Subscriber_Template = a.Metaswitch_Template__c;
			this.asset.Metaswitch_Number_Status__c = a.Metaswitch_Number_Status__c;
			this.asset.Metaswitch_Template__c = a.Metaswitch_Template__c;
			if(asn != null){
				this.service_Number_Name = asn.Service_Number__r.Name;
				this.service_Number_Type = asn.Service_Number__r.Type__c;
				this.service_Number_Calling_Features = asn.Service_Number__r.Calling_Features__c;
			}
			this.bizGroup = a.Business_Group__c;
			this.easCOS = a.EAS_Class_of_Service__c;
			this.department = a.Department__c;
			this.cpNumber = a.Calling_Party_Number__c;
		}

		public Asset setNewValues(){
			asset.Metaswitch_Template__c = metaswitch_Subscriber_Template;
			asset.Business_Group__c = bizGroup;
			asset.EAS_Class_of_Service__c = easCOS;
			asset.Department__c = department;
			asset.Calling_Party_Number__c = cpNumber;
			return asset;
		}
	}

	public class SelectOpt {
		@AuraEnabled public String label;
		@AuraEnabled public String value;

		public SelectOpt(String l, String v){
			this.label = l;
			this.value = v;
		}
	}

	public class Input extends ltngfw.AuraInput {
		@AuraEnabled public String recordId;
		@AuraEnabled public String csv;
		@AuraEnabled public String filename;
		@AuraEnabled public String[] assetIds;
		@AuraEnabled public CmpMetaSwitchCSVCtrl.AssetWrapper[] assets = new List<CmpMetaSwitchCSVCtrl.AssetWrapper>();
	}

	public class UnitTestException extends Exception{}
}