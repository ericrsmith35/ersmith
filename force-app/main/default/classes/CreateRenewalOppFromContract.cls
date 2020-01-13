/* Class:       CreateRenewalOppFromContract
 * Created On:  Aug 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: Creates a renewal opp from the contract. Invoked by visual flows
 */
 
public with sharing class CreateRenewalOppFromContract {

	@InvocableMethod(label='Create Renewal Opp from Contract')
	public static CreateRenewalOppFromContractResponse[] createOpp(CreateRenewalOppFromContractRequest[] datas){
		CreateRenewalOppFromContractResponse res = new CreateRenewalOppFromContractResponse();
		SavePoint sp = Database.setSavePoint();
		try{
			CreateRenewalOppFromContractRequest data = datas[0];
			System.debug('DATA INPUT FROM FLOW:\n' + JSON.serializePretty(data));

			CreateOppFromContractHelper.parsePLs(data.newOpp);				
			System.debug('NEW OPP:\n' + JSON.serializePretty(data.newOpp));

			insert data.newOpp;

			if(data.cpeAssets != null){
				for(Asset a : data.cpeAssets){
					a.Renewal_Opportunity__c = data.newOpp.Id;
				}
				update data.cpeAssets;
			}

			List<CreateOppFromContractHelper.AssetData> prods = new List<CreateOppFromContractHelper.AssetData>();
			Set<Id> prodAssetIds = (new Map<Id,Asset>(data.prodAssets)).keySet();
			data.prodAssets = [Select Id, Price, Product2Id, Product2.Bulk_Asset__c, Quantity, Status, Asset_Type__c, 
				In_Production__c, Total_Asset_Price__c, AccountId, Service_Address__c, Service_Address_Account_Id__c, 
				Renewal_Opportunity__c, Disconnect_Opportunity__c
				from Asset where Id in :prodAssetIds];
			for(Asset a : data.prodAssets){
				a.Renewal_Opportunity__c = data.newOpp.Id;
				prods.add(new CreateOppFromContractHelper.AssetData(a));
			}
			
			

			CreateOppFromContractHelper helper = new CreateOppFromContractHelper(prods, data.newOpp.Id, null, data.newOpp.Pricebook2Id);

			OpportunityLineItem[] newolis = helper.initOlis();
			for(OpportunityLineItem oli : newolis){
				oli.IsConverted__c = true;
			}

			helper.insertOlis();
			helper.updateAssets();
			

			// update contract fields
			data.contract.Description = data.newOpp.Description + '\n---------------------------------\n' + data.contract.Description;
			data.contract.Renewal_Opportunity__c = data.newOpp.Id;
			data.contract.Start_on_Installation__c = data.startOnInstall;
			update data.contract;

			// store Counts Created on new opp
			data.newOpp = [Select Id, Counts_Created__c, Counts_Now__c from Opportunity where Id =: data.newOpp.Id];
			data.newOpp.Counts_Created__c = data.newOpp.Counts_Now__c;
			update data.newOpp;
			res.newOppId = data.newOpp.Id;
		}
		catch(Exception e){
			System.debug('exception details *****');
			System.debug(e.getMessage());
			System.debug(e.getStackTraceString());
			res.success = false;
			res.msg = e.getMessage();
			Database.rollback(sp);
		}
		return new CreateRenewalOppFromContractResponse[]{res};
	}

	public class CreateRenewalOppFromContractRequest {
		@InvocableVariable(label='Original Opportunity Id' required=false)
		public String oppId;

		@InvocableVariable(label='Contract' required=true)
		public Contract contract;

		@InvocableVariable(label='New Opportunity' required=true)
		public Opportunity newOpp;

		@InvocableVariable(label='Start on Install' required=true)
		public String startOnInstall;

		@InvocableVariable(label='CPE Assets' required=false)
		public Asset[] cpeAssets;

		@InvocableVariable(label='Product Assets' required=true)
		public Asset[] prodAssets;
	}

	public class CreateRenewalOppFromContractResponse {
		@InvocableVariable
		public String msg;

		@InvocableVariable
		public Boolean success = true;
		@InvocableVariable
		public String newOppId;
	}
}