/* Class:       OpportunityLineItemTriggerHandler
 * Created On:  Aug 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */
 
public with sharing class OpportunityLineItemTriggerHandler {

	/**
	 * if OLI is inserted or quantity changes, check opp checkbox to rollup how many products require service number
	 * @param lstOLI [Trigger.new]
	 * @param oldMap [Trigger.oldMap]
	 */
	public static void rollupServiceNumberOnOpportunity(OpportunityLineItem[] lstOLI, Map<Id,OpportunityLineItem> oldMap){
		Set<Id> oppIds = new Set<Id>();
		for(OpportunityLineItem oli : lstOLI){
			if(Trigger.isInsert){
				oppIds.add(oli.OpportunityId);
			}
			else if(Trigger.isUpdate){
				OpportunityLineItem oldOLI = oldMap.get(oli.Id);
				if(oli.Product2Id != oldOLI.Product2Id || oli.Quantity != oldOLI.Quantity){
					oppIds.add(oli.OpportunityId);
				}
			}
		}

		if(oppIds.isEmpty()) return;

		Map<Id,Opportunity> oppUpdates = new Map<Id,Opportunity>();
		for(Id oid : oppIds){
			Opportunity o = new Opportunity(Id=oid);
			o.Rollup_Service_Numbers__c = true;
			oppUpdates.put(o.Id, o);
		}

		update oppUpdates.values();
	}
}