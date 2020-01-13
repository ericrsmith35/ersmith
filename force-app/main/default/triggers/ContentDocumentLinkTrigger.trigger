/*
** Trigger: ContentDocumentLinkTrigger
** SObject: ContentDocumentLink
** Created by J. Pipkin (OpFocus, Inc) on Aug 2018
*/

trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, before update, before delete, after insert, after update, after delete){
	
	if(Trigger.isInsert && Trigger.isBefore){
		ContentDocumentLinkTriggerHandler.shareWithAllUsers(Trigger.new);
	}
}