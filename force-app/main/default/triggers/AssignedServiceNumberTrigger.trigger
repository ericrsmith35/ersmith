/*
** Trigger: AssignedServiceNumberTrigger
** SObject: Assigned_Service_Number__c
** Created by J. Pipkin (OpFocus, Inc) on Oct 2018
*/

trigger AssignedServiceNumberTrigger on Assigned_Service_Number__c (before insert, before update, before delete, after insert, after update, after delete){
	
	if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
		AssignedServiceNumberTriggerHandler.setKey(Trigger.new);
	}	
}