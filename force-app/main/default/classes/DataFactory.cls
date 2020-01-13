/* Class:       DataFactory
 * Created On:  Aug 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: Class for creating data for unit tests
 */

@IsTest 
public class DataFactory {

	public static Account buildAccount(String name){
		Account a = new Account();
		a.Name = name;
		return a;
	}

	public static Contact buildContact(String name, Id accountId){
		Contact c = new Contact();
		c.LastName = name;
		c.AccountId = accountId;
		return c;
	}

	public static Opportunity buildOpportunity(String name, String type, Id accountId, String recordType){
		Opportunity o = new Opportunity();
		o.Name = name;
		o.AccountId = accountId;
		o.StageName = [Select ApiName from OpportunityStage where IsClosed = false Order By SortOrder ASC LIMIT 1].ApiName;
		o.CloseDate = System.today().addMonths(1);
		o.Type = type;
		if(recordType != null){
			o.RecordTypeId = SchemaUtils.getRecordTypeId(Opportunity.SObjectType, recordType);
		}
		o.Pricebook2Id = Test.getStandardPricebookId();
		o.Default_Delivery_Method__c = 'Copper';
		return o;
	}

	public static Opportunity buildOpportunity(String name, Id accountId){
		return buildOpportunity(name, 'New Customer', accountId, 'Residential Customer');
	}

	public static Contract buildContract(Id oppId, Id acctId){
		Contract c = new Contract();
		c.AccountId = acctId;
		c.Opportunity__c = oppId;
		c.Status = 'Draft';
		c.StartDate = System.today();
		c.ContractTerm = 12;
		return c;
	}

	public static Product2 buildProduct(String name, String type){
		Product2 p = new Product2();
		p.Asset_Type__c = type;
		p.Description = name;
		p.Name = name;
		p.IsActive = true;
		return p;
	}


	public static PricebookEntry buildPBE(Id productId){
		PricebookEntry p = new PricebookEntry();
		p.IsActive = true;
		p.Product2Id = productId;
		p.Pricebook2Id = Test.getStandardPricebookId();
		p.UnitPrice = 100;
		return p;
	}

	public static OpportunityLineItem buildOLI(Id oppId, Id pbeId, Integer qty){
		OpportunityLineItem o = new OpportunityLineItem();
		o.PricebookEntryId = pbeId;
		o.OpportunityId = oppId;
		o.Quantity = qty;
		o.UnitPrice = 100;
		o.IsConverted__c = false;
		return o;
	}

	public static Asset buildAsset(Id oppId, OpportunityLineItem oli, Product2 prod, Id acctId, String status){
		Asset a = new Asset();
		a.AccountId = acctId;
		a.Asset_Type__c = prod.Asset_Type__c;
		a.Purchase_Opportunity__c = oppId;
		a.Product2Id = prod.Id;
		a.Oli_Id__c = oli.Id;
		a.Name = prod.Name;
		a.Quantity = 1;
		a.Total_Asset_Price__c = 100;
		a.Status = status;
		return a;
	}

	public static Asset buildAsset(Id acctId, String name){
		Asset a = new Asset();
		a.AccountId = acctId;
		a.Name = name;
		a.Quantity = 1;
		a.Total_Asset_Price__c = 100;
		return a;
	}

	public static Service_Address__c buildServiceAddress(Id accountId, String name, String zipcode){
		Service_Address__c sa = new Service_Address__c();
		sa.Name = name;
		sa.Account__c = accountId;
		sa.Zip__c = zipcode;
		return sa;
	}

	public static Service_Number__c buildServiceNumber(Id oppId, String num, String type, String product){
		Service_Number__c sn = new Service_Number__c();
		sn.Name = num;
		sn.Opportunity__c = oppId;
		sn.Type__c = type;
		sn.Product__c = product;
		return sn;
	}

	public static Yellow_Page_Listing__c buildYPListing(String listing){
		Yellow_Page_Listing__c yp = new Yellow_Page_Listing__c();
		yp.Listing__c = listing;
		return yp;
	}

	public static Directory__c buildDirectory(String name){
		Directory__c d = new Directory__c();
		d.Name = name;
		return d;
	}

	public static BBI_metaswitch_rate_centers__c buildBBI(Integer npa, Integer nxx, String name, Integer tandem){
		BBI_metaswitch_rate_centers__c b = new BBI_metaswitch_rate_centers__c();
		b.npa__c = npa;
		b.nxx__c = nxx;
		b.name__c = String.valueOf(npa);
		b.tandem_id__c = tandem;
		b.switch_value__c = b.npa__c + b.nxx__c + b.name__c;
		return b;
	}

	public static Assigned_Service_Number__c buildAssignedNumber(Id snid, Id assetId){
		Assigned_Service_Number__c asn = new Assigned_Service_Number__c();
		asn.Asset__c = assetId;
		asn.Service_Number__c = snid;
		return asn;
	}

	public static Metaswitch_Template__c buildMetaswitchTemplate(String name, String type){
		Metaswitch_Template__c mt = new Metaswitch_Template__c();
		mt.Template_Type__c = type;
		mt.Name = name;
		return mt;
	}

	public static Network__c buildNetwork(String startIP, String size, String groups, String recordTypeName){
		Network__c n = new Network__c();
		n.Starting_Address__c = startIP;
		n.Network_Size__c = size;
		n.Group__c = groups;
		n.RecordTypeId = Schema.SObjectType.Network__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
		n.Type__c = startIP.indexOf('.') > -1 ? 'IPv4' : 'IPv6';
		n.Usage__c = 'Customer';
		return n;
	}

	public static Delivery_System_Owner__c buildDeliverySysOwner(String name){
		Delivery_System_Owner__c d = new Delivery_System_Owner__c();
		d.Name = name;
		return d;
	}

	public static Case buildCase(Id acctId, Id serviceAddressId, String recordTypeName){
		Case c = new Case();
		c.AccountId = acctId;
		c.Service_Address__c = serviceAddressId;
		if(recordTypeName != null){
			c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
		}
		return c;
	}

	public static Lead buildLead(String lastName, String company){
		Lead l = new Lead();
		l.LastName = lastName;
		l.Company = company;
		return l;
	}

	public static ContentVersion buildContentVersion(String title, String path){
		ContentVersion cv = new ContentVersion();
		cv.Title = title;
		cv.PathOnClient = path;
		cv.VersionData = Blob.valueOf('String o');
		return cv;
	}

	public static FeedItem buildFeedItem(Id parentId, String body){
		FeedItem fi = new FeedItem();
		fi.ParentId = parentId;
		fi.Body = body;
		return fi;
	}

	public static FeedComment buildFeedComment(Id feedItemId, String com){
		FeedComment fc = new FeedComment();
		fc.FeedItemId = feedItemId;
		fc.CommentBody = com;
		return fc;
	}

	public static Project__c buildProject(Id oppId){
		Project__c p = new Project__c();
		p.Opp_Name__c = oppId;
		return p;
	}

}