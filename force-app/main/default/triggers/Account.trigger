/*
** Trigger:  Account
** SObject:  Account
** Created by OpFocus on Nov 23, 2015
** Description: Trigger for Account object. Currently, these are the triggers defined.
**     + When a Account is created with a Support_Account_Type__c value we want to create an new Entitlement for it.  
*/
trigger Account on Account (After Insert, After Update) {
	List<Account> lstAccountsToCreatEntitlementsFor = new List<Account>();

	// When a Account is created with a Support_Account_Type__c value we want to create an new Entitlement for it.
	if(trigger.isAfter && trigger.isInsert){
		for(Account a : trigger.new){
			if(a.Support_Account_Type__c != null){
				lstAccountsToCreatEntitlementsFor.add(a);
			}
		}
	}
	// When a Account is Updated with a Support_Account_Type__c haveing a value when previously it didn't, we want to create an new Entitlement for it.
	if(trigger.isAfter && trigger.isUpdate){
		for(Account a : trigger.new){
			if(a.Support_Account_Type__c != null && trigger.oldMap.get(a.Id).Support_Account_Type__c == null){
				lstAccountsToCreatEntitlementsFor.add(a);
			}
		}
	}

	if(lstAccountsToCreatEntitlementsFor.isEmpty() == false){
		insert AccountHelper.CreateDefaultEntitlement(lstAccountsToCreatEntitlementsFor);
	}
	
}