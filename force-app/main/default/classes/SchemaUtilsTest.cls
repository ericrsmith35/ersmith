/* Class:       SchemaUtilsTest
 * Created On:  Aug 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */

@isTest
public class SchemaUtilsTest {
	
	static testMethod void getRecordTypeTest() {
		Id rt = [Select Id from RecordType where SObjectType = 'Opportunity' and Name = 'Residential Customer'].Id;
		System.assertEquals(rt, SchemaUtils.getRecordTypeId(Opportunity.SObjectType, 'Residential Customer'));
		System.assertEquals(rt, SchemaUtils.getRecordTypeId(Opportunity.SObjectType, 'Residential Customer'));
	}
	
}