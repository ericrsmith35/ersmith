/* Class:       AssignedServiceNumberTriggerHandler
 * Created On:  Oct 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */
 
public with sharing class AssignedServiceNumberTriggerHandler {

	/**
	 * set key on new Assigned_Service_Number__c record
	 * @param lstASN [description]
	 */
	public static void setKey(List<Assigned_Service_Number__c> lstASN){
		for(Assigned_Service_Number__c asn : lstASN){
			asn.Key__c = asn.Asset__c + '||' + asn.Service_Number__c;
		}
	}
}