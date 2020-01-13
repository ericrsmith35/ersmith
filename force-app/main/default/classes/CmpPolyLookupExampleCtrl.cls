public class CmpPolyLookupExampleCtrl {
 //
 //CmpPolyLookupExampleCtrl.cls
 //
 @AuraEnabled
 public static List<List<String>> getUsers()
 {
     User[] users = [Select Id, Name From User 
                      Where UserType = 'Standard' and
                      IsActive = true and LastName != 'Site Guest User'
                      order by Name]; 
     List<List<String>> records = new List<List<String>>();

     records.add(new List<String>{'All', '--All Users--'});

     for(User u : users) 
     {
         records.add(new List<String>{u.Id, u.Name});
     }

     return records;
 }


 @AuraEnabled
 public static List<List<String>> getUserGroups()
 {

     Schema.DescribeFieldResult fieldResult = User.User_Group__c.getDescribe();
     List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
 
     List<List<String>> records = new List<List<String>>();
     Map<String, Schema.PicklistEntry> mapPLEntryByLabel = new Map<String, Schema.PicklistEntry>();
     for( Schema.PicklistEntry f : ple)
     {
         mapPLEntryByLabel.put(f.getLabel(), f);
     } 
     List<String> lstLabels = new List<String>(mapPLEntryByLabel.keySet());
     lstLabels.sort();

     records.add(new List<String>{'All', '--All User Groups--'});
     for(String label: lstLabels)
     {
         Schema.PicklistEntry pe = mapPLEntryByLabel.get(label);
         records.add(new List<String>{pe.getValue(), pe.getLabel()});
     }

     return records;
 }
}