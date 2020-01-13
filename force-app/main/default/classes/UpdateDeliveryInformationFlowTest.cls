/* Class:       UpdateDeliveryInformationFlowTest
 * Created On:  Oct 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */

@isTest
public class UpdateDeliveryInformationFlowTest {
	
	@testSetup static void buildData(){
		Account a = DataFactory.buildAccount('Test Account');
		insert a;

		Opportunity o = DataFactory.buildOpportunity('Test Opp', 'New Customer', a.Id, 'Residential Customer');
		o.Default_Delivery_Method__c = 'Copper';
		insert o;

		Product2 p1 = DataFactory.buildProduct('Product 1', 'CPE');
		Product2 p2 = DataFactory.buildProduct('Product 2', 'CPE');
		Product2 p3 = DataFactory.buildProduct('Product 3', 'Service');
		Product2 p4 = DataFactory.buildProduct('Product 4', 'Service');
		p1.Track_Delivery_Method__c = true;
		p2.Track_Delivery_Method__c = true;
		p3.Track_Delivery_Method__c = true;
		p4.Track_Delivery_Method__c = false;
		insert new Product2[]{p1,p2,p3,p4};

		PricebookEntry pb1 = DataFactory.buildPBE(p1.Id);
		PricebookEntry pb2 = DataFactory.buildPBE(p2.Id);
		PricebookEntry pb3 = DataFactory.buildPBE(p3.Id);
		PricebookEntry pb4 = DataFactory.buildPBE(p4.Id);
		insert new PricebookEntry[]{pb1,pb2,pb3,pb4};

		OpportunityLineItem oli1 = DataFactory.buildOLI(o.Id, pb1.Id, 2);
		OpportunityLineItem oli2 = DataFactory.buildOLI(o.Id, pb2.Id, 1);
		OpportunityLineItem oli3 = DataFactory.buildOLI(o.Id, pb3.Id, 2);
		OpportunityLineItem oli4 = DataFactory.buildOLI(o.Id, pb4.Id, 1);
		oli1.Accept_Default_Delivery_Method__c = true;
		oli2.Accept_Default_Delivery_Method__c = true;
		oli3.Accept_Default_Delivery_Method__c = false;
		oli4.Accept_Default_Delivery_Method__c = true;
		insert new OpportunityLineItem[] {oli1,oli2,oli3,oli4};

		insert DataFactory.buildDeliverySysOwner('Owner');
	}

	//test methods

	static testMethod void positive() {
		Opportunity o = [Select Id from Opportunity];
		Delivery_System_Owner__c dso = [Select Id from Delivery_System_Owner__c];

		UpdateDeliveryInformationFlow.Intake i = new UpdateDeliveryInformationFlow.Intake();
		i.oppId = o.Id;
		i.deliveryMethod = 'Wireless';
		i.deliveryOwner = dso.Id;

		UpdateDeliveryInformationFlow.updateDeliveryInformation(new UpdateDeliveryInformationFlow.Intake[]{i});

		for(OpportunityLineItem oli :[Select Id, Delivery_Method__c, Delivery_System_Owner__c, Product2.Name from OpportunityLineItem]){
			if(oli.Product2.Name == 'Product 1' || oli.Product2.Name == 'Product 2'){
				System.assertEquals(i.deliveryMethod, oli.Delivery_Method__c);
				System.assertEquals(i.deliveryOwner, oli.Delivery_System_Owner__c);
			}
			else{
				System.assertEquals(null, oli.Delivery_Method__c);
				System.assertEquals(null, oli.Delivery_System_Owner__c);
			}
		}
	}
	
	static testMethod void positive2() {
		Opportunity o = [Select Id from Opportunity];
		Delivery_System_Owner__c dso1 = [Select Id from Delivery_System_Owner__c];
		Delivery_System_Owner__c dso2 = DataFactory.buildDeliverySysOwner('Owner2');
		insert dso2;

		OpportunityLineItem[] lstOLIS = [Select Id, Delivery_Method__c, Delivery_System_Owner__c, Product2.Name from OpportunityLineItem];
		for(OpportunityLineItem oli : lstOLIS){
			if(oli.Product2.Name == 'Product 3' || oli.Product2.Name == 'Product 4'){
				oli.Delivery_Method__c = 'Other';
				oli.Delivery_System_Owner__c = dso2.Id;
			}
		}
		update lstOLIS;

		UpdateDeliveryInformationFlow.Intake i = new UpdateDeliveryInformationFlow.Intake();
		i.oppId = o.Id;
		i.deliveryMethod = 'Wireless';
		i.deliveryOwner = dso1.Id;

		UpdateDeliveryInformationFlow.updateDeliveryInformation(new UpdateDeliveryInformationFlow.Intake[]{i});

		for(OpportunityLineItem oli :[Select Id, Delivery_Method__c, Delivery_System_Owner__c, Product2.Name from OpportunityLineItem]){
			if(oli.Product2.Name == 'Product 1' || oli.Product2.Name == 'Product 2'){
				System.assertEquals(i.deliveryMethod, oli.Delivery_Method__c);
				System.assertEquals(i.deliveryOwner, oli.Delivery_System_Owner__c);
			}
			else{
				System.assertEquals('Other', oli.Delivery_Method__c);
				System.assertEquals(dso2.Id, oli.Delivery_System_Owner__c);
			}
		}
	}
	
}