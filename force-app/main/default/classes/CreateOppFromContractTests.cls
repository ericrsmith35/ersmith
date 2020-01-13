/* Class:       CreateOppFromContractTests
 * Created On:  Aug 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: Test class for CreateOppFromContractHelper, CreateRenewalOppFromContract, CreateTurnDownOppFromContract, CreateChangeOppFromContract
 */

@isTest
public class CreateOppFromContractTests {
	
	@testSetup static void buildData(){
		Account a = DataFactory.buildAccount('Test Account');
		insert a;

		Opportunity o = DataFactory.buildOpportunity('Test Opp', 'New Customer', a.Id, 'Residential Customer');
		o.Default_Delivery_Method__c = 'Copper';
		insert o;

		Contract c = DataFactory.buildContract(o.Id, a.Id);
		insert c;

		c.Status = 'Activated';
		update c;

		Product2 p1 = DataFactory.buildProduct('Product 1', 'CPE');
		Product2 p2 = DataFactory.buildProduct('Product 2', 'CPE');
		Product2 p3 = DataFactory.buildProduct('Product 3', 'Service');
		Product2 p4 = DataFactory.buildProduct('Product 4', 'Service');
		p1.Track_Delivery_Method__c = false;
		p2.Track_Delivery_Method__c = false;
		p3.Track_Delivery_Method__c = false;
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
		insert new OpportunityLineItem[] {oli1,oli2,oli3,oli4};

		Asset s1 = DataFactory.buildAsset(o.Id, oli1, p1, a.Id, 'Active');
		Asset s2 = DataFactory.buildAsset(o.Id, oli1, p1, a.Id, 'Active');
		Asset s3 = DataFactory.buildAsset(o.Id, oli2, p2, a.Id, 'Active');
		Asset s4 = DataFactory.buildAsset(o.Id, oli3, p3, a.Id, 'Active');
		Asset s5 = DataFactory.buildAsset(o.Id, oli3, p3, a.Id, 'Active');
		Asset s6 = DataFactory.buildAsset(o.Id, oli4, p4, a.Id, 'Active');
		insert new Asset[] {s1,s2,s3,s4,s5,s6};

	}

	//test methods

	static testMethod void renewalTest() {
		Account a = [Select Id from Account];
		Opportunity o = [Select Id from Opportunity];
		Contract c = new Contract(Id=[Select Id from Contract].Id);
		List<String> assetFields = new List<String>(SObjectType.Asset.fields.getMap().keySet());
		List<String> oppFields = new List<String>(SObjectType.Opportunity.fields.getMap().keySet());
		List<String> oliFields = new List<String>(SObjectType.OpportunityLineItem.fields.getMap().keySet());
		List<String> contractFields = new List<String>(SObjectType.Contract.fields.getMap().keySet());
		Asset[] cpes = Database.query('Select ' + String.join(assetFields,',') + ' from Asset where Asset_Type__c = \'CPE\'');
		Asset[] prods = Database.query('Select ' + String.join(assetFields,',') + ' from Asset where Asset_Type__c != \'CPE\'');
		CreateRenewalOppFromContract.CreateRenewalOppFromContractRequest req = new CreateRenewalOppFromContract.CreateRenewalOppFromContractRequest();
		req.oppId = o.Id;
		req.contract = c;
		req.newOpp = DataFactory.buildOpportunity('Renewal Opp', 'New Customer', a.Id, 'Residential Customer');
		req.startOnInstall = String.valueOf(System.today().addDays(1));
		req.cpeAssets = cpes;
		req.prodAssets = prods;
		CreateRenewalOppFromContract.CreateRenewalOppFromContractRequest[] data = new CreateRenewalOppFromContract.CreateRenewalOppFromContractRequest[]{req};

		CreateRenewalOppFromContract.CreateRenewalOppFromContractResponse res = CreateRenewalOppFromContract.createOpp(data)[0];
		System.assert(res.success, res.msg);

		Opportunity newopp = Database.query('Select ' + String.join(oppFields,',') + ' from Opportunity where Id != \'' + o.Id + '\'');
		OpportunityLineItem[] olis = Database.query('Select ' + String.join(oliFields,',') + ' from OpportunityLineItem where OpportunityId = \'' + newopp.Id + '\'');
		cpes = Database.query('Select ' + String.join(assetFields,',') + ' from Asset where Asset_Type__c = \'CPE\'');
		prods = Database.query('Select ' + String.join(assetFields,',') + ' from Asset where Asset_Type__c != \'CPE\'');

		System.debug('new opp:\n' + JSON.serializePretty(newOpp));
		System.debug('olis:\n' + JSON.serializePretty(olis));
		System.debug('cpes:\n' + JSON.serializePretty(cpes));
		System.debug('prods:\n' + JSON.serializePretty(prods));

		System.assertEquals(2, olis.size());
		for(OpportunityLineItem oli : olis){
			if(oli.Name == 'Renewal Opp Product 3'){
				System.assertEquals(2, oli.Quantity);
			}
			else if(oli.Name == 'Renewal Opp Product 4'){
				System.assertEquals(1, oli.Quantity);	
			}
		}

		for(Asset cpe : cpes){
			System.assertEquals(newOpp.Id, cpe.Renewal_Opportunity__c);
		}

		for(Asset p : prods){
			System.assertEquals(newOpp.Id, p.Renewal_Opportunity__c);
		}
	}
	
	static testMethod void changeTest() {
		Account a = [Select Id from Account];
		Opportunity o = [Select Id from Opportunity];
		Contract c = new Contract(Id=[Select Id from Contract].Id);
		List<String> assetFields = new List<String>(SObjectType.Asset.fields.getMap().keySet());
		List<String> oppFields = new List<String>(SObjectType.Opportunity.fields.getMap().keySet());
		List<String> oliFields = new List<String>(SObjectType.OpportunityLineItem.fields.getMap().keySet());
		List<String> contractFields = new List<String>(SObjectType.Contract.fields.getMap().keySet());
		Set<ID> originalAssets = new Set<Id>();
		Asset[] turndowns = Database.query('Select ' + String.join(assetFields,',') + ' from Asset where Name = \'Product 3\'');
		Asset[] moves = Database.query('Select ' + String.join(assetFields,',') + ' from Asset where Name = \'Product 4\'');
		for(Asset ass : turndowns) originalAssets.add(ass.Id);
		for(Asset ass : moves) originalAssets.add(ass.Id);
		CreateChangeOppFromContract.CreateChangeOppFromContractRequest req = new CreateChangeOppFromContract.CreateChangeOppFromContractRequest();
		req.oppId = o.Id;
		req.contract = c;
		req.newOpp = DataFactory.buildOpportunity('Change Opp', 'New Customer', a.Id, 'Residential Customer');
		req.turndowns = turndowns;
		req.moves = moves;
		CreateChangeOppFromContract.CreateChangeOppFromContractRequest[] data = new CreateChangeOppFromContract.CreateChangeOppFromContractRequest[]{req};

		CreateChangeOppFromContract.CreateChangeOppFromContractResponse res = CreateChangeOppFromContract.createOpp(data)[0];
		System.assert(res.success, res.msg);

		Opportunity newopp = Database.query('Select ' + String.join(oppFields,',') + ' from Opportunity where Id != \'' + o.Id + '\'');
		OpportunityLineItem[] olis = Database.query('Select ' + String.join(oliFields,',') + ' from OpportunityLineItem where OpportunityId = \'' + newopp.Id + '\'');
		OpportunityLineItem[] oldolis = Database.query('Select ' + String.join(oliFields,',') + ' from OpportunityLineItem where OpportunityId = \'' + o.Id + '\'');
		turndowns = Database.query('Select ' + String.join(assetFields,',') + ' from Asset where Name = \'Product 3\'');
		moves = Database.query('Select ' + String.join(assetFields,',') + ' from Asset where Name = \'Product 4\'');

		System.debug('new opp:\n' + JSON.serializePretty(newOpp));
		System.debug('olis:\n' + JSON.serializePretty(olis));
		System.debug('oldolis:\n' + JSON.serializePretty(oldolis));
		System.debug('turndowns:\n' + JSON.serializePretty(turndowns));
		System.debug('moves:\n' + JSON.serializePretty(moves));

		System.assertEquals(3, olis.size());
		for(OpportunityLineItem oli : olis){
			if(oli.Name == 'Change Opp Product 3'){
				System.assert(oli.Quantity == -2 || oli.Quantity == 2);
			}
			else if(oli.Name == 'Change Opp Product 4'){
				System.assert(oli.Quantity == -1 || oli.Quantity == 1);	
			}
		}

		System.assertEquals(4, oldolis.size());
		for(OpportunityLineItem oli : oldolis){
			if(oli.Name == 'Test Opp Product 3'){
				System.assertEquals(2, oli.Quantity);
			}
			else if(oli.Name == 'Test Opp Product 4'){
				System.assert(oli.Quantity == 1 || oli.Quantity == -1);	
			}
		}

		for(Asset ass : turndowns){
			//if(!originalAssets.contains(ass.Id)) continue;
			System.assertEquals(newOpp.Id, ass.Disconnect_Opportunity__c);
			System.assertEquals('Selected for Turn-Down', ass.Status);
		}

		for(Asset ass : moves){
			//if(!originalAssets.contains(ass.Id)) continue;
			System.assertEquals(newOpp.Id, ass.Disconnect_Opportunity__c);
		}
	}

	static testMethod void turndownTest() {
		Account a = [Select Id from Account];
		Opportunity o = [Select Id from Opportunity];
		Contract c = new Contract(Id=[Select Id from Contract].Id);
		List<String> assetFields = new List<String>(SObjectType.Asset.fields.getMap().keySet());
		List<String> oppFields = new List<String>(SObjectType.Opportunity.fields.getMap().keySet());
		List<String> oliFields = new List<String>(SObjectType.OpportunityLineItem.fields.getMap().keySet());
		List<String> contractFields = new List<String>(SObjectType.Contract.fields.getMap().keySet());
		Asset[] cpes = Database.query('Select ' + String.join(assetFields,',') + ' from Asset where Asset_Type__c = \'CPE\'');
		Asset[] prods = Database.query('Select ' + String.join(assetFields,',') + ' from Asset where Asset_Type__c != \'CPE\'');
		CreateTurnDownOppFromContract.CreateTurnDownOppFromContractRequest req = new CreateTurnDownOppFromContract.CreateTurnDownOppFromContractRequest();
		req.oppId = o.Id;
		req.contract = c;
		req.newOpp = DataFactory.buildOpportunity('Turn-Down Opp', 'New Customer', a.Id, 'Residential Customer');
		req.cpeAssets = cpes;
		req.prodAssets = prods;
		CreateTurnDownOppFromContract.CreateTurnDownOppFromContractRequest[] data = new CreateTurnDownOppFromContract.CreateTurnDownOppFromContractRequest[]{req};

		CreateTurnDownOppFromContract.CreateTurnDownOppFromContractResponse res = CreateTurnDownOppFromContract.createOpp(data)[0];
		System.assert(res.success, res.msg);

		Opportunity newopp = Database.query('Select ' + String.join(oppFields,',') + ' from Opportunity where Id != \'' + o.Id + '\'');
		OpportunityLineItem[] olis = Database.query('Select ' + String.join(oliFields,',') + ' from OpportunityLineItem where OpportunityId = \'' + newopp.Id + '\'');
		
		System.assertEquals(2, olis.size());
		for(OpportunityLineItem oli : olis){
			System.assertEquals(true, oli.IsConverted__c);
		}

	
	}
	
}