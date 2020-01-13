/*
** Trigger:  CaseTrigger
** SObject:  Case
** Created by OpFocus on Date
** Description: Trigger for Case object. Currently, these are the triggers defined.
**     +When a Case is created and does not have a Entitlment pre-defined but does have an account, let's get the Default Entitlment form the Account

		+When a case is opened or closed, capture email alert body and store in task
*/
trigger CaseTrigger on Case (before Insert, before Update, after Insert, after Update) {
	List<Case> lstCasesToAssignEntitlmentsFor = new List<Case>();
	if(trigger.isBefore && ( trigger.isInsert || trigger.isUpdate)){
		for(Case c : trigger.new){
			if(c.EntitlementId == null && c.AccountId != null){
				lstCasesToAssignEntitlmentsFor.add(c);
			}
		}
	}

	if(lstCasesToAssignEntitlmentsFor.isEmpty() == false){
		CaseHelper.setDefaultEntitlmentFromAccount(lstCasesToAssignEntitlmentsFor);
	}

	if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
		CaseHelper.caseOpenCloseEmailTask();
	}

	if(Trigger.isBefore && Trigger.isInsert){
		CaseHelper.preventE2CLoop();
	}

	if(Trigger.isAfter && Trigger.isInsert){
		CaseHelper.deleteE2CCase();
	}

}