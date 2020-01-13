/* Class:       NetworkTriggerHandler
 * Created On:  Oct 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */
 
public with sharing class NetworkTriggerHandler {

	/**
	 * populate start and end octets for searching index
	 */
	public static void populateOctets(){
		for(Network__c net : (Network__c[]) Trigger.new){
			Boolean doLogic = false;
			if(Trigger.isInsert){
				doLogic = true;
			}
			if(Trigger.isUpdate){
				Network__c oldNet = (Network__c) Trigger.oldMap.get(net.Id);
				if(net.Network_Size__c != oldNet.Network_Size__c || net.Type__c != oldNet.Type__c || net.Starting_Address__c != oldNet.Starting_Address__c){
					doLogic = true;
				}
			}
			if(doLogic){
				String size = net.Network_Size__c;
				String typex = net.Type__c;
				String startIP = net.Starting_Address__c;
				String endIP = IPUtils.getEndIPFromStart(typex, startIP, size);
				String[] startingOctets = IPUtils.getOctets(startIP, typex);
				String[] endingOctets;
				if(endIP != null){
					endingOctets = IPUtils.getOctets(endIP, typex);
				}
				for(Integer indx = 0; indx < startingOctets.size(); indx++){
					net.put('Octet_' + (indx + 1) + '_Start__c', startingOctets[indx]);
					if(endingOctets != null){
						net.put('Octet_' + (indx + 1) + '_End__c', endingOctets[indx]);
					}
				}
			}
		}
	}

	/**
	 * fill network name with StartingIP/CIDR
	 */
	public static void updateName(){
		for(Network__c net : (Network__c[]) Trigger.new){
			Boolean doLogic = false;
			if(Trigger.isInsert){
				doLogic = true;
			}
			if(Trigger.isUpdate){
				Network__c oldNet = (Network__c) Trigger.oldMap.get(net.Id);
				if(net.Network_Size__c != oldNet.Network_Size__c || net.Starting_Address__c != oldNet.Starting_Address__c){
					doLogic = true;
				}
			}
			if(doLogic){
				net.Name = net.Starting_Address__c + net.Network_Size__c;
			}
		}
	}

	/**
	 * sync history record
	 */
	public static void copyToHistory(){
		Set<Id> historyIds = new Set<Id>();
		Map<Id,Network__c> newHistory = new Map<Id,Network__c>();
		Id historyRT = Schema.SObjectType.Network__c.getRecordTypeInfosByName().get('History').getRecordTypeId();
		
		for(Network__c net : (Network__c[]) Trigger.new){
			if(net.RecordTypeId != historyRT){
				Network__c n = net.clone(false, false, false, false);
				n.GUID__c = null;
				n.RecordTypeId = historyRT;
				n.Network_History__c = null;
				if(Trigger.isUpdate){
					n.Id = net.Network_History__c;
				}
				newHistory.put(net.Id,n);
			}
		}
		
		upsert newHistory.values();
		
		for(Network__c net : (Network__c[]) Trigger.new){
			if(net.RecordTypeId != historyRT){
				net.Network_History__c = newHistory.get(net.Id).Id;
			}
		}
		
	}
}