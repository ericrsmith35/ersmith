public with sharing class UpsertUserContact {
    @Future
    public static void execute(Set<Id> userIds) {
 
        List<Contact> contactsToUpsert = new List<Contact>(); // Create a list of contacts to upsert
 
        List<RecordType> employeeRTs = [SELECT Id FROM RecordType
                                        WHERE SobjectType = 'Contact' AND DeveloperName = 'Employee'
                                        LIMIT 1];
 
        List <Employee_Contact_Setting__mdt> companyAcctIds = [SELECT ID__c
                                                               FROM Employee_Contact_Setting__mdt
                                                               WHERE DeveloperName =: 'Company_Account'
                                                               LIMIT 1];
 
        List<User> users =
            [SELECT Id, Email, FirstName, LastName, Department, ManagerId, Fax, Phone, MobilePhone, Title, Street, City, State, PostalCode, Country
             FROM User
             WHERE Id IN : userIds AND IsActive = true AND UserType = 'Standard'];
 
        List<Id> userManagerIds = new List<Id>();
 
        for(User managedUser: users){
            if (managedUser.ManagerId != null){
                userManagerIds.add(managedUser.ManagerId);
            }
        }
 
        List<Contact> managerContacts = [SELECT Id,User__c from Contact
                                         WHERE User__c IN : userManagerIds];
 
        Map <Id,Id> managerContactMap = new Map<Id,Id>();   // Create a manager contact map of userId, contactId
 
        for(Contact managerContact: managerContacts){
            managerContactMap.put(managerContact.User__c,managerContact.Id);
        }
 
        List<Contact> contacts =
            [SELECT Id, User__c
             FROM Contact
             WHERE User__c IN: userIds];
 
        Map <Id,Id> userContactMap = new Map <Id,Id>(); // Create a user contact map of userId, contactId
 
        for(Contact userContact: contacts){
            userContactMap.put(userContact.User__c,userContact.Id);
        }
 
        for (User u : users){                               // Loop through each upserted user
 
            Contact c = new Contact(                        // Create a contact record in memory
                RecordTypeId = employeeRTs[0].Id,           // Populate the record type
                User__c = u.Id,                             // Populate the user lookup
                Email = u.Email,                            // Populate the email
                FirstName = u.FirstName,                    // Populate the first name
                LastName = u.LastName,                      // Populate the last name
                Department = u.Department,                  // Populate the user department
                Fax = u.Fax,                                // Populate the fax number
                Phone = u.Phone,                            // Populate the phone number
                MobilePhone = u.MobilePhone,                // Populate the mobile phone number
                Title = u.Title,                            // Populate the title of user
                MailingStreet = u.Street,                   // Populate the mailing street
                MailingCity = u.City,                       // Populate the mailing city
                MailingState = u.State,                     // Populate the mailing state
                MailingPostalCode = u.PostalCode,           // Populate the postal code
                MailingCountry = u.Country,                 // Populate the country
                OwnerId = u.Id);                            // Populate the contact owner
            if (companyAcctIds.size() > 0) {
                c.AccountId = companyAcctIds[0].ID__c;      // Populate the account lookup
            }
            if (managerContactMap.get(u.ManagerId) != null) {
                c.ReportsToId = managerContactMap.get(u.ManagerId); // Populate the Reports To field
            }
            if (userContactMap.get(u.Id) != null) {
                c.Id = userContactMap.get(u.Id);            // specify the contact to be updated
            }
 
            contactsToUpsert.add(c);                        // Add the contact to the bulk upsert list
 
        }
 
        if(contactsToUpsert.size() > 0){
            upsert contactsToUpsert;                        // Upsert all contacts in single DML statement
        }
    }
 
}