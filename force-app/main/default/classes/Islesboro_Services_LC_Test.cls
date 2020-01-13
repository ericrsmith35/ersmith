@isTest
public class Islesboro_Services_LC_Test {
    
    static testMethod void testAll() {
        Boolean success = true;
        try {
            System_ID__c sid = new System_ID__c(Name='Islesboro - FttP');
            insert sid;
//            Account pa = new Account(Name='Parent', Primary_System_ID__c = sid.id);
            Account pa = DataFactory.buildAccount('Parent');
            pa.Primary_System_ID__c = sid.id;
            insert pa;
//            Account ca = new Account(Name='Child', Primary_System_ID__c = sid.id, ParentId=pa.id);
            Account ca = DataFactory.buildAccount('Child');
            ca.Primary_System_ID__c = sid.id;
            ca.ParentId=pa.id;
            insert ca;
//            Service_Address__c sa = new Service_Address__c(Account__c=ca.id, SANO__c='1', SASN__c='Test', SATH__c='ST', Zip__c='04848');
            Service_Address__c sa = DataFactory.buildServiceAddress(ca.id, 'Test SA', '04848');
            sa.SANO__c='1';
            sa.SASN__c='Test';
            sa.SATH__c='ST';
            insert sa;
            Product2 p = new Product2(Name='Test', Asset_Type__c='Service');
            //Product2 p = DataFactory.buildProduct('Test', 'Service');
			insert p;
//			Asset da = new Asset(Name='Residential Internet - Islesboro', AccountID=pa.id, Status='Active', Asset_Type__c='Service', Service_Address__c=sa.id, Product2Id=p.id);
            Asset da = DataFactory.buildAsset(pa.Id, 'Residential Internet - Islesboro');
            da.Status='Active';
            da.Asset_Type__c='Service';
            da.Service_Address__c=sa.id;
            da.Product2Id=p.id;
            insert da;
//			Asset va = new Asset(Name='Residential Unlimited Phone', AccountID=ca.id, Status='Active', Asset_Type__c='Service', Service_Address__c=sa.id, Product2Id=p.id);
            Asset va = DataFactory.buildAsset(ca.Id, 'Residential Unlimited Phone');
            va.Status='Active';
            va.Asset_Type__c='Service';
            va.Service_Address__c=sa.id;
            va.Product2Id=p.id;
            insert va;
            Test.startTest();          
            System.assertEquals(Islesboro_Services_LC.getDataCount(ca.id),'1');
            System.assertEquals(Islesboro_Services_LC.getVoiceCount(ca.id),'1');
            System.assertEquals(Islesboro_Services_LC.getDataList(ca.id).size(),1);
            System.assertEquals(Islesboro_Services_LC.getVoiceList(ca.id).size(),1);            
            da.Status='Removed/Disposed';
            update da;
            va.Status='Removed/Disposed';
            update va;            
            System.assertEquals(Islesboro_Services_LC.getDataCount(ca.id),'0');
            System.assertEquals(Islesboro_Services_LC.getVoiceCount(ca.id),'0');  
            Test.stopTest();       
        } catch (Exception e) {
            success = false;
        } finally {
            System.assert(success);
        }
    }
    
}