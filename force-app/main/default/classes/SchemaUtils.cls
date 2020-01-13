/* Class:       SchemaUtils
 * Created On:  Aug 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: Utility class for accessing Schema
 */
 
public class SchemaUtils {

	static Map<SObjectType,Map<String,Id>> checkedRecordTypes = new Map<SObjectType,Map<String,Id>>();

	public static Id getRecordTypeId(SObjectType sot, String rtName){
		// check if we already have the ID
		Map<String,Id> objectRTs = checkedRecordTypes.get(sot);
		if(objectRTs != null){
			Id rt = objectRTs.get(rtName);
			if(rt != null){
				// if we already have it, just return
				return rt;
			}
		}
		else{
			// this sobject has not been checked
			objectRTs = new Map<String,Id>();
		}
		// get the id
		Id rtId = sot.getDescribe().getRecordTypeInfosByName().get(rtName).getRecordTypeId();
		// store the ID in the SObjectType map
		objectRTs.put(rtName, rtId);
		// store SObjectType map for next call
		checkedRecordTypes.put(sot, objectRTs);
		// return the id
		return rtId;
	}
}