/* Class:       CmpTestCtrl
 * Created On:  
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */
 
public with sharing class CmpTestCtrl {
	public class Input extends ltngfw.AuraParams {
		@AuraEnabled public String str;
	}

	public class Output extends ltngfw.AuraReturn {
		@AuraEnabled public ltngfw__Application_Error__c ae;
	}

	@AuraEnabled
	public static Output getAE(String datajson){
		Output o = new Output();
		Input i;
		System.debug(datajson);
		try{
			i = (Input) ltngfw.AuraParams.deserialize(datajson, Input.class);
			System.debug(i);
			o.ae = [Select Id, Name from ltngfw__Application_Error__c where Id =:i.str];
		}
		catch(Exception e){
			System.debug(e.getMessage() + ':: ' + e.getStackTraceString());
			ltngfw.Log.notify(e, 'TEST', ltngfw.DeviceInformation.deserialize(i.deviceInfoStr));
			o.handleException(e);
		}
		return o;
	}
}