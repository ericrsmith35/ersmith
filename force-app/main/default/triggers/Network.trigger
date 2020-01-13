/*
** Trigger: Network
** SObject: Network__c
** Created by J. Pipkin (OpFocus, Inc) on 
*/

trigger Network on Network__c (before insert, before update, before delete, after insert, after update, after delete){
	
	if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
		NetworkTriggerHandler.updateName();
		NetworkTriggerHandler.populateOctets();
		NetworkTriggerHandler.copyToHistory();
	}

}