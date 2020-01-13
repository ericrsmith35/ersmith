@IsTest
public class Islesboro_Services_Test {

    static testmethod void testIslesboro() {

        System_ID__c sid = new System_ID__c(Name='Islesboro - FttP');
        insert sid;    	
//        Account pa = new Account(Name='Parent', Primary_System_ID__c = sid.id);
        Account pa = DataFactory.buildAccount('Parent');
        pa.Primary_System_ID__c = sid.id;
        insert pa;
//        Account pc = new Account(Name='Child', Primary_System_ID__c = sid.id, ParentId=pa.id);
        Account pc = DataFactory.buildAccount('Child');
        pc.Primary_System_ID__c = sid.id;
        pc.ParentId=pa.id;
        insert pc;
        
        PageReference pref = Page.Islesboro_Services;
        pref.getParameters().put('id',pc.id);
        Test.setCurrentPage(pref);
        
        Islesboro_Services isl = new Islesboro_Services();
        system.assertEquals(pc.id, isl.getAcct().id);
        
    }
}