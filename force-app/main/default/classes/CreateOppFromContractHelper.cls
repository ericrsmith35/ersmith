/* Class:       CreateOppFromContractHelper
 * Created On:  Aug 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */
 
public with sharing class CreateOppFromContractHelper {

	public class CreateOppFromContractException extends Exception{}

	// wrapper for data processing
	public class AssetData {
		public Id productId;
		public Id serviceAddressId;
		public Id accountId;
		public Id serviceAddressAccountId;
		public Asset asset;
		public OpportunityLineItem oli;
		public String key {
			get{
				return '' + productId + serviceAddressId + accountId + serviceAddressAccountId + String.valueOf(asset.Total_Asset_Price__c / asset.Quantity);
			}
		}

		public AssetData(Asset ad){
			this.productId = ad.Product2Id;
			this.serviceAddressId = ad.Service_Address__c;
			this.accountId = ad.AccountId;
			this.serviceAddressAccountId = ad.Service_Address_Account_ID__c;
			this.asset = ad;
		}

		public void linkOli(){
			asset.Oli_Id__c = oli.Id;
		}
	}

	Map<String,AssetData[]> dataMap;

	public List<OpportunityLineItem> newOlis = new List<OpportunityLineItem>();
	public AssetData[] data;
	public Map<Id,Id> pbeMap = new Map<Id,Id>();
	public Id oppId;
	public Id oldOppId;

	// consteructor. inits data
	public CreateOppFromContractHelper(AssetData[] data, Id newOppId, Id oldOppId, Id pbId){
		this.data = data;
		this.oppId = newOppId;
		this.oldOppId = oldOppId;
		Set<Id> productIds = new Set<Id>();
		if(dataMap == null){
			dataMap = new Map<String,AssetData[]>();
			for(AssetData ad : data){
				productIds.add(ad.productId);
				if(dataMap.get(ad.key) == null){
					dataMap.put(ad.key, new List<AssetData>());
				}
				dataMap.get(ad.key).add(ad);
			}
		}
		System.debug('datamap:\n\n ' + JSON.serializePretty(dataMap));
		PricebookEntry[] pbes = [Select Id, Product2Id from PricebookEntry where Product2Id in : productIds and Pricebook2Id =: pbId];
		for(PricebookEntry pbe : pbes){
			pbeMap.put(pbe.Product2Id, pbe.Id);
		}
	}

	/**
	 * builds oli records based on assets
	 * @return [new oli records]
	 */
	public OpportunityLineItem[] initOlis(){
		for(String key : dataMap.keyset()){
			AssetData[] datalist = dataMap.get(key);
			if(datalist == null) continue;
			AssetData firstAD = datalist[0];
			if(firstAD.asset.Product2.Bulk_Asset__c){
				for(AssetData ad : datalist){
					newOlis.add(buildOLIFromAssetData(ad, ad.asset.Quantity));
				}
			}
			else{
				newOlis.add(buildOLIFromAssetData(firstAD, datalist.size()));
			}
		}
		System.debug('NEW OLIS:\n' +JSON.serializePretty(newOlis));
		return newOlis;
	}

	public OpportunityLineItem[] negativeQuantityOLIs(){
		List<OpportunityLineItem> negOlis = new List<OpportunityLineItem>();
		for(OpportunityLineItem oli : newOlis){
			OpportunityLineItem noli = new OpportunityLineItem();
			noli.Id = null;
			noli.IsConverted__c = true;
			noli.OpportunityId = oppId;
			noli.Quantity = -(oli.Quantity);
			noli.Product2Id = oli.Product2Id;
			noli.UnitPrice = oli.UnitPrice;
			noli.PricebookEntryId = oli.PricebookEntryId;
			noli.Account__c = oli.Account__c;
			noli.Service_Address__c = oli.Service_Address__c;
			noli.Deliver_to_Account__c = oli.Deliver_to_Account__c;
			negOlis.add(noli);
		}
		System.debug(JSON.serializePretty(negOlis));
		newOlis.addAll(negOlis);
		return newOlis;
	}

	private OpportunityLineItem buildOLIFromAssetData(AssetData ad, Decimal qty){
		OpportunityLineItem newoli = new OpportunityLineItem();
		newoli.OpportunityId = oppId;
		newoli.Product2Id = ad.productId;
		newoli.Quantity = qty;
		newoli.UnitPrice = ad.asset.Total_Asset_Price__c / ad.asset.Quantity;
		newoli.PricebookEntryId = pbeMap.get(ad.productId);
		newoli.Account__c = ad.accountId;
		newoli.Service_Address__c = ad.serviceAddressId;
		newoli.Deliver_to_Account__c = ad.serviceAddressAccountId;
		return newoli;
	}

	/**
	 * inserts new oli records and links to asset it was created from
	 */
	public void insertOLIs(){
		System.debug('all new olis\n' + JSON.serializePretty(newOlis));
		insert newOlis;
		// now link the olis to the corresponding asset
		for(OpportunityLineItem oli : newOlis){
			String key = '' + oli.Product2Id + oli.Service_Address__c + oli.Account__c + oli.Deliver_to_Account__c + String.valueOf(oli.UnitPrice);
			System.debug('Looking for key ' + key + ' in ' + dataMap.keySet());
			AssetData[] datalist = dataMap.get(key);
			if(datalist == null) continue;
			for(AssetData ad : datalist){
				ad.oli = oli;
				ad.linkOli();
			}
		}
		System.debug('AssetData after oli insert:\n' +JSON.serializePretty(data));
	}

	/**
	 * update assets in wrapper list
	 */
	public void updateAssets(){
		Asset[] updAssets = new List<Asset>();
		for(AssetData ad : data){
			updAssets.add(ad.asset);
		}
		update updAssets;
	}


	/**
	 * parses picklist object given by flow field assignment to String so apex can read it
	 * @param  o [description]
	 * @return   [description]
	 */
	public static Opportunity parsePLs(Opportunity o){
		Map<String,Object> objMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(o));
		for(String key : objMap.keySet()){
			Object prop = objMap.get(key);
			if(prop instanceof Map<String,Object>){
				Map<String,Object> value = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(prop));
				if(value.containsKey('value')){
					o.put(key, String.valueOf(value.get('value')));
				}
			}
		}
		return o;
	}
}