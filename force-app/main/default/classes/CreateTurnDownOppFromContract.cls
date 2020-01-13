/* Class:       CreateTurnDownOppFromContract
 * Created On:  
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */
 
public with sharing class CreateTurnDownOppFromContract {

	@InvocableMethod(label='Create Turn-Down Opp from Contract')
	public static CreateTurnDownOppFromContractResponse[] createOpp(CreateTurnDownOppFromContractRequest[] datas){
		CreateTurnDownOppFromContractResponse res = new CreateTurnDownOppFromContractResponse();
		SavePoint sp = Database.setSavePoint();
		try{
			CreateTurnDownOppFromContractRequest data = datas[0];
			System.debug('DATA INPUT FROM FLOW:\n' + JSON.serializePretty(data));

			CreateOppFromContractHelper.parsePLs(data.newOpp);

			System.debug('NEW OPP:\n' + JSON.serializePretty(data.newOpp));
			insert data.newOpp;
			
			if(data.cpeAssets != null){
				update data.cpeAssets;
			}
			
			List<CreateOppFromContractHelper.AssetData> prods = new List<CreateOppFromContractHelper.AssetData>();
			Set<Id> prodAssetIds = (new Map<Id,Asset>(data.prodAssets)).keySet();
			data.prodAssets = [Select Id, Price, Product2Id, Product2.Bulk_Asset__c, Quantity, Status, Asset_Type__c, 
				In_Production__c, Total_Asset_Price__c, AccountId, Service_Address__c, Service_Address_Account_Id__c, 
				Renewal_Opportunity__c, Disconnect_Opportunity__c
				from Asset where Id in :prodAssetIds];

			for(Asset a : data.prodAssets){
				a.Disconnect_Opportunity__c = data.newOpp.Id;
				a.Status = 'In Turn-Down';
				prods.add(new CreateOppFromContractHelper.AssetData(a));
			}
			
			CreateOppFromContractHelper helper = new CreateOppFromContractHelper(prods, data.newOpp.Id, null, data.newOpp.Pricebook2Id);

			OpportunityLineItem[] newolis = helper.initOlis();
			for(OpportunityLineItem oli : newolis){
				oli.IsConverted__c = true;
				oli.Quantity = -(oli.Quantity);
			}

			helper.insertOlis();
			helper.updateAssets();
			
			data.contract.Description = data.newOpp.Description + '\n---------------------------------\n' + data.contract.Description;
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
		return new CreateTurnDownOppFromContractResponse[]{res};
	}

	public class CreateTurnDownOppFromContractRequest {
		@InvocableVariable(label='Original Opportunity Id' required=false)
		public String oppId;

		@InvocableVariable(label='Contract' required=true)
		public Contract contract;

		@InvocableVariable(label='New Opportunity' required=true)
		public Opportunity newOpp;

		@InvocableVariable(label='CPE Assets' required=false)
		public Asset[] cpeAssets;

		@InvocableVariable(label='Product Assets' required=true)
		public Asset[] prodAssets;
	}

	public class CreateTurnDownOppFromContractResponse {
		@InvocableVariable
		public String msg;

		@InvocableVariable
		public Boolean success = true;

		@InvocableVariable
		public String newOppId;
	}
}