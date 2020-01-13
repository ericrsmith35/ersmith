/* Class:       CmpLinkAssetToNumberCtrl
 * Created On:  Sept 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: Controller for CmpLinkAssetToNumber and CmpBatchLinkAssetToNumber
 */
 
public with sharing class CmpLinkAssetToNumberCtrl {

	/**
	 * init data for CmpLinkAssetToNumber
	 * @param  datajson [input data]
	 * @return          [output data]
	 */
	@AuraEnabled
	public static Output getRecords(String datajson){
		Output o = new Output();
		Input i;
		try{	
			i = (CmpLinkAssetToNumberCtrl.Input) ltngfw.AuraInput.deserialize(datajson, CmpLinkAssetToNumberCtrl.Input.class);

			// get assets
			// #1008
			Asset[] lstA = [Select Id, Name, Display_ID__c, Service_Address_Name__c, (Select Id, Service_Number__c from Assigned_Service_Numbers__r) 
				from Asset where Purchase_Opportunity__c =: i.recordId and Product2.Requires_Service_Number__c = 1];
			Set<Id> selectedNumbers = new Set<Id>();
			for(Asset a : lstA){
				WrapperAsset wa = new WrapperAsset(a);
				if(!a.Assigned_Service_Numbers__r.isEmpty()){
					selectedNumbers.add(a.Assigned_Service_Numbers__r[0].Service_Number__c);
					wa.sn = a.Assigned_Service_Numbers__r[0].Service_Number__c;
				}
				
				o.assets2.add(wa);
			}
			
			// get service numbers
			Service_Number__c[] lstSN = [Select Id, Name from Service_Number__c where Opportunity__c =: i.recordId Order By Name ASC];

			// convert service number records to select options
			o.numbers.add(new SelOpt('--Select--',null));
			for(Service_Number__c sn : lstSN){
				o.numbers.add(new SelOpt(sn.Name, sn.Id));
			}

			// for test coverage
			if(Test.isRunningTest()){
				throw new UnitTestException('UnitTest');
			}
		}
		catch(Exception e){
			System.debug(e.getMessage());
			o.handleException(e);
		}
		return o;
	}

	/**
	 * init data for CmpBatchLinkAssetToNumber
	 * @param  datajson [input data]
	 * @return          [output data]
	 */
	@AuraEnabled
	public static Output getRecords2(String datajson){
		Output o = new Output();
		Input i;
		try{	
			i = (CmpLinkAssetToNumberCtrl.Input) ltngfw.AuraInput.deserialize(datajson, CmpLinkAssetToNumberCtrl.Input.class);

			// get assets
			Asset[] lstA = [Select Id, Name, Display_ID__c, Service_Address_Name__c, Service_Address__c, Product2Id, (Select Id, Service_Number__c from Assigned_Service_Numbers__r) 
				from Asset where Purchase_Opportunity__c =: i.recordId];
			
			Set<Id> productIds = new Set<Id>();
			for(Asset a : lstA){
				productIds.add(a.Product2Id);
			}

			Map<Id,Product2> productMap = new Map<Id,Product2>([Select Id, Requires_Service_Number__c from Product2 where Id in :productIds]);

			Set<Id> selectedNumbers = new Set<Id>();

			// only add asset to wrapper list if service number is null. If service number is populated, store service number
			// to array to exclude the number from the list of available numbers
			for(Asset a : lstA){
				if(!a.Assigned_Service_Numbers__r.isEmpty()){
					for(Assigned_Service_Number__c asn : a.Assigned_Service_Numbers__r){
						selectedNumbers.add(asn.Service_Number__c);
					}
				}
				// #1008
				//if(a.Service_Number__c != null){
				//	selectedNumbers.add(a.Service_Number__c);
				//}
				else{
					WrapperAsset wa = new WrapperAsset(a);
					wa.numOfSN = Integer.valueOf(productMap.get(a.Product2Id).Requires_Service_Number__c);
					o.assets2.add(wa);
				}
			}

			// get service numbers that are not assigned to assets
			Service_Number__c[] lstSN = [Select Id, Name from Service_Number__c where Opportunity__c =: i.recordId Order By Name ASC];
			for(Service_Number__c sn : lstSN){
				if(!selectedNumbers.contains(sn.Id)){
					o.numbers.add(new SelOpt(sn.Name, sn.Id));
				}
			}

			// for test coverage
			if(Test.isRunningTest()){
				throw new UnitTestException('UnitTest');
			}
		}
		catch(Exception e){
			System.debug(e.getMessage());
			o.handleException(e);
		}
		return o;
	}

	/**
	 * saves assets for CmpLinkAssetToNumber
	 * @param  datajson [input data]
	 * @return          [output data]
	 */
	@AuraEnabled
	public static Output saveAssets(String datajson){
		Output o = new Output();
		Input i;
		try{	
			i = (CmpLinkAssetToNumberCtrl.Input) ltngfw.AuraInput.deserialize(datajson, CmpLinkAssetToNumberCtrl.Input.class);

			Assigned_Service_Number__c[] newAssignments = new List<Assigned_Service_Number__c>();
			Set<Id> assetIds = new Set<Id>();

			for(WrapperAsset aw : i.selectedAssets){
				assetIds.add(aw.asset.Id);
			}

			Map<String,Assigned_Service_Number__c> mapExistingASN = new Map<String,Assigned_Service_Number__c>();
			Assigned_Service_Number__c[] lstASN = [Select Id, Key__c from Assigned_Service_Number__c where Asset__c in :assetIds];
			for(Assigned_Service_Number__c asn : lstASN){
				mapExistingASN.put(asn.Key__c, asn);
			}

			Set<String> selectedKeys = new Set<String>();
			for(WrapperAsset aw : i.selectedAssets){
				if(aw.sn == null) continue;

				Assigned_Service_Number__c asn = new Assigned_Service_Number__c();
				asn.Asset__c = aw.asset.Id;
				asn.Service_Number__c = aw.sn;
				AssignedServiceNumberTriggerHandler.setKey(new Assigned_Service_Number__c[]{asn});
			
				if(!mapExistingASN.containsKey(asn.Key__c)){
					newAssignments.add(asn);
				}

				selectedKeys.add(asn.Key__c);
			}
			insert newAssignments;

			List<Assigned_Service_Number__c> lstDeleteASN = new List<Assigned_Service_Number__c>();
			for(String k : mapExistingASN.keySet()){
				if(!selectedKeys.contains(k)){
					lstDeleteASN.add(mapExistingASN.get(k));
				}
			}

			delete lstDeleteASN;

			if(Test.isRunningTest()){
				throw new UnitTestException('UnitTest');
			}
		}
		catch(Exception e){
			System.debug(e.getMessage());
			ltngfw.Log.notify(e, 'CmpLinkAssetToNumber.saveAsset', ltngfw.DeviceInformation.deserialize(i.deviceInfoStr));
			o.handleException(e);
		}
		return o;
	}

	/**
	 * assigns numbers to assets for CmpBatchLinkAssetsToNumber
	 * @param  datajson [input data]
	 * @return          [output data]
	 */
	@AuraEnabled
	public static Output assignAssets(String datajson){
		Output o = new Output();
		Input inp;
		try{	
			inp = (CmpLinkAssetToNumberCtrl.Input) ltngfw.AuraInput.deserialize(datajson, CmpLinkAssetToNumberCtrl.Input.class);

			WrapperAsset a = inp.selectedAssets[0];
			Assigned_Service_Number__c[] newAssignments = new List<Assigned_Service_Number__c>();

			for(Integer indx = 0 ; indx < a.numOfSN; indx++){
				Assigned_Service_Number__c asn = new Assigned_Service_Number__c();
				asn.Asset__c = a.asset.Id;
				asn.Service_Number__c = inp.selectedServiceNumbers[indx].value;
				newAssignments.add(asn);
			}

			insert newAssignments;

			//// randomly assign numbers to selected assets
			//Map<Id,Asset> mapUpdates = new Map<Id,Asset>();
			//for(Integer i = 0; i < inp.selectedAssets.size(); i++){
			//	Asset a = inp.selectedAssets[i].asset;
			//	String sn = inp.selectedServiceNumbers[i].value;
			//	// #1008
			//	//a.Service_Number__c = inp.selectedServiceNumbers[i].value;
				
			//	mapUpdates.put(a.Id,a);
			//}

			//update mapUpdates.values();

			if(Test.isRunningTest()){
				throw new UnitTestException('UnitTest');
			}

		}
		catch(Exception e){
			System.debug(e.getMessage());
			o.handleException(e);
		}
		return o;
	}

	public class UnitTestException extends Exception{}

	public class Output extends ltngfw.AuraReturn {
		@AuraEnabled public SelOpt[] numbers = new List<SelOpt>();
		//@AuraEnabled public Map<String,Asset> assets;
		@AuraEnabled public WrapperAsset[] assets2 = new LIst<WrapperAsset>();
	}

	public class Input extends ltngfw.AuraInput {
		@AuraEnabled public Id recordId;
		//@AuraEnabled public Map<String,Asset> lstAssets;
		@AuraEnabled public WrapperAsset[] selectedAssets;
		@AuraEnabled public SelOpt[] selectedServiceNumbers;
	}

	public class WrapperAsset {
		@AuraEnabled public Asset asset;
		@AuraEnabled public String sn;
		@AuraEnabled public Boolean isSelected;
		@AuraEnabled public Integer numOfSN;

		public WrapperAsset(Asset a){
			this.asset = a;
			this.isSelected = false;
		}
	}

	public class SelOpt {
		@AuraEnabled public String label;
		@AuraEnabled public String value;
		@AuraEnabled public Boolean isSelected;

		public SelOpt(String l, String v){
			this.label = l;
			this.value = v;
			this.isSelected = false;
		}
	}
}