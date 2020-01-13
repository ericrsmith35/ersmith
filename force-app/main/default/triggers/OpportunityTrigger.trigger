/*
** Trigger: OpportunityTrigger
** SObject: Opportunity
** Created by J. Pipkin (OpFocus, Inc) on Aug 2018
*/

trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete){
	
	if(Trigger.isBefore && Trigger.isUpdate){
		OpportunityTriggerHandler.rollupServiceNumberCount(Trigger.newMap, Trigger.oldMap);
	}
}