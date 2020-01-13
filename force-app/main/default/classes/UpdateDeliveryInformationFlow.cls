/* Class:       UpdateDeliveryInformationFlow
 * Created On:  Oct 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: Invocable method for updating opportunity product delivery method. called by Opportunity - Record Changes process
 */
 
public with sharing class UpdateDeliveryInformationFlow {

	@InvocableMethod(label='Update Delivery Information Opportunity')
	public static void updateDeliveryInformation(Intake[] intakes){
		Intake i = intakes[0];

		OpportunityLineItem[] lstOLIs = [Select Id, Accept_Default_Delivery_Method__c, Product2.Track_Delivery_Method__c, Delivery_Method__c, Delivery_System_Owner__c 
			from OpportunityLineItem where OpportunityId =: i.oppId];
		List<OpportunityLineItem> oliUpdates = new List<OpportunityLineItem>();
		for(OpportunityLineItem oli : lstOLIs){
			if(!oli.Accept_Default_Delivery_Method__c) continue;
			if(!oli.Product2.Track_Delivery_Method__c) continue;
			oli.Delivery_Method__c = i.deliveryMethod;
			oli.Delivery_System_Owner__c = i.deliveryOwner;
			oliUpdates.add(oli);
		}
		if(!oliUpdates.isEmpty()) update oliUpdates;
	}

	public class Intake {
		@InvocableVariable(label='Opportunity Id' required=true)
		public String oppId;
		@InvocableVariable(label='Delivery Method')
		public String deliveryMethod;
		@InvocableVariable(label='Delivery System Owner' required=true)
		public String deliveryOwner;
	}
}