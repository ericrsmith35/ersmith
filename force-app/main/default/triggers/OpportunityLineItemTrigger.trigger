/*
** Trigger: OpportunityLineItemTrigger
** SObject: OpportunityLineItem
** Created by J. Pipkin (OpFocus, Inc) on Aug 2018
*/

trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update, before delete, after insert, after update, after delete){
	
	if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
		OpportunityLineItemTriggerHandler.rollupServiceNumberOnOpportunity(Trigger.new, Trigger.oldMap);
	}
}