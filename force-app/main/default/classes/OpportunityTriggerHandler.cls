/* Class:       OpportunityTriggerHandler
 * Created On:  Aug 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */
 
public with sharing class OpportunityTriggerHandler {

	/**
	 * rollup how many service numbers the opportunity needs by aggregating the oli records with products
	 * marked for needing a service number
	 * @param newMap [Trigger.newMap]
	 * @param oldMap [Trigger.oldMap]
	 */
	public static void rollupServiceNumberCount(Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap){
		Set<Id> oppIds = new Set<Id>();
		for(Opportunity opp : newMap.values()){
			Opportunity oldOpp = oldMap.get(opp.Id);
			if(opp.Rollup_Service_Numbers__c != oldOpp.Rollup_Service_Numbers__c && opp.Rollup_Service_Numbers__c){
				oppIds.add(opp.Id);
			}
		}

		if(oppIds.isEmpty()) return;

		AggregateResult[] lstAR = [Select OpportunityId oppId, SUM(Total_Service_Numbers_Needed__c) qty from OpportunityLineItem 
			where OpportunityId in :oppIds and Product2.Requires_Service_Number__c > 0  and Quantity > 0 Group By OpportunityId];

		for(AggregateResult ar : lstAR){
			Opportunity opp = newMap.get((Id) ar.get('oppId'));
			opp.Service_Numbers_Needed__c = (Decimal) ar.get('qty');
			opp.Rollup_Service_Numbers__c = false;
		}
	}
}