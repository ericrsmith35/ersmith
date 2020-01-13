/* Class:       ContentDocumentLinkTriggerHandler
 * Created On:  Aug 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: Trigger handler for ContentDocumentLinkTrigger
 */
 
public with sharing class ContentDocumentLinkTriggerHandler {

	/**
	 * shares salesforce files connected to records with community users
	 * @param  TriggerNew [description]
	 * @return            [description]
	 */
	public static ContentDocumentLink[] shareWithAllUsers(ContentDocumentLink[] TriggerNew){
		for(ContentDocumentLink cdl : TriggerNew){
			cdl.Visibility = 'AllUsers';
		}
		return TriggerNew;
	}
}