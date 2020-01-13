/* Class:       CreateChangeOppFromContract
 * Created On:  Aug 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: Creates an Add/Move/Change opp from contract
 */
 
public with sharing class CreateChangeOppFromContract {

	@InvocableMethod(label='Create Change Opp from Contract')
	public static CreateChangeOppFromContractResponse[] createOpp(CreateChangeOppFromContractRequest[] datas){
		CreateChangeOppFromContractResponse res = new CreateChangeOppFromContractResponse();
		SavePoint sp = Database.setSavePoint();

		try{
			CreateChangeOppFromContractRequest data = datas[0];
			System.debug('DATA INPUT FROM FLOW:\n' + JSON.serializePretty(data));
			List<CreateOppFromContractHelper.AssetData> movedata = new List<CreateOppFromContractHelper.AssetData>();

			// picklist values from flow get passed as objects, so need to parse to string
			CreateOppFromContractHelper.parsePLs(data.newOpp);
			System.debug('NEW OPP:\n' + JSON.serializePretty(data.newOpp));
			// insert new opportunity
			upsert data.newOpp;



			List<Asset> newAssets = new List<Asset>();
			List<Asset> oldAssets = new List<Asset>();

			data.moves = data.moves == null ? new List<Asset>() : data.moves;
			data.turndowns = data.turndowns == null ? new List<Asset>() : data.turndowns;

			Set<Id> moveIds = (new Map<Id,Asset>(data.moves)).keySet();
			data.moves = [Select Id, Name, Price, Product2Id, Product2.Bulk_Asset__c, Quantity, Status, Asset_Type__c, 
				In_Production__c, Total_Asset_Price__c, AccountId, Service_Address__c, Service_Address_Account_Id__c, 
				Renewal_Opportunity__c, Disconnect_Opportunity__c, Purchase_Opportunity__c, Display__c
				from Asset where Id in :moveIds];
			
			// loop through move assets
			for(Asset a : data.moves){
				a.Disconnect_Opportunity__c = data.newOpp.Id;
				CreateOppFromContractHelper.AssetData ad = new CreateOppFromContractHelper.AssetData(a);
				movedata.add(ad);
				// deactivate old asset
				a.Status = 'Selected for Turn-Down';
				oldAssets.add(a);
			}

			// deactivate old assets
			update oldAssets;

			// init data for proceossing
			CreateOppFromContractHelper movehelper = new CreateOppFromContractHelper(movedata, data.newOpp.Id, data.oppId, data.newOpp.Pricebook2Id);
			OpportunityLineItem[] newolis = movehelper.initOlis();
			movehelper.negativeQuantityOLIs();
			// insert new olis and link to assets
			movehelper.insertOlis();
			movehelper.updateAssets();
			

			// now process turn down
			List<CreateOppFromContractHelper.AssetData> tddata = new List<CreateOppFromContractHelper.AssetData>();
			Set<Id> turnDownIds = (new Map<Id,Asset>(data.turndowns)).keySet();
			data.turndowns = [Select Id, Name, Price, Product2Id, Product2.Bulk_Asset__c, Quantity, Status, Asset_Type__c, 
				In_Production__c, Total_Asset_Price__c, AccountId, Service_Address__c, Service_Address_Account_Id__c, 
				Renewal_Opportunity__c, Disconnect_Opportunity__c, Display__c
				from Asset where Id in :turnDownIds];
			
			for(Asset a : data.turndowns){
				a.Status = 'Selected for Turn-Down';
				a.Disconnect_Opportunity__c = data.newOpp.Id;
				tddata.add(new CreateOppFromContractHelper.AssetData(a));
			}
			CreateOppFromContractHelper tdhelper = new CreateOppFromContractHelper(tddata, data.newOpp.Id, data.oppId, data.newOpp.Pricebook2Id);
			newolis = tdhelper.initOlis();
			for(OpportunityLineItem oli : newolis){
				oli.IsConverted__c = true;
				oli.Quantity = -(oli.Quantity);
			}
			tdhelper.insertOlis();
			tdhelper.updateAssets();
			

			// update contract fields
			data.contract.Description = data.newOpp.description + '\n---------------------------------\n' + data.contract.Description;
			data.contract.Turn_Down_Opportunity__c = data.newOpp.Id;
			update data.contract;
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
		
		return new CreateChangeOppFromContractResponse[]{res};
	}

	public class CreateChangeOppFromContractRequest {
		@InvocableVariable(label='Original Opportunity Id' required=true)
		public String oppId;

		@InvocableVariable(label='Contract' required=true)
		public Contract contract;

		@InvocableVariable(label='New Opportunity' required=true)
		public Opportunity newOpp;

		@InvocableVariable(label='Assets for Turn-Down' required=false)
		public Asset[] turndowns;

		@InvocableVariable(label='Assets for Move' required=false)
		public Asset[] moves;
	}

	public class CreateChangeOppFromContractResponse {
		@InvocableVariable
		public String msg;

		@InvocableVariable
		public Boolean success = true;

		@InvocableVariable
		public String newOppId;
	}












}