@isTest
private class Email_Unsubscribe_Test {
    // The following test methods provide adequate code coverage 
    // for the unsubscribe email class.
    // There are two methods, one that does the testing
    // with a valid "unsubcribe" in the subject line
    // and one the does not contain "unsubscribe" in the
    // subject line.        
    static testMethod void testUnsubscribe() {
    
       // Create a new email and envelope object.
       Messaging.InboundEmail email = new Messaging.InboundEmail() ;
       Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
    
       // Create a new test lead and insert it in the test method.
//       Lead l = new lead(firstName='John456454',
//                lastName='Smith4564646',
//                Company='Salesforce',
//                Email='user45131245612@acme.com',
//                HasOptedOutOfEmail=false);
        Lead l = DataFactory.buildLead('Smith4564646', 'Salesforce');
        l.Email='user45131245612@acme.com';
        l.HasOptedOutOfEmail = false;
       Database.DMLOptions opts = new Database.DMLOptions();
       opts.DuplicateRuleHeader.allowSave = true;
       Database.insert(l,opts);
    
       // Create a new test contact and insert it in the test method.
//       Contact c = new Contact(firstName='John456454',
//                    lastName='Smith4564646',
//                    Email='user45131245612@acme.com',
//                    HasOptedOutOfEmail=false);
        Contact c = DataFactory.buildContact('John456454 Smith4564646', null);
        c.Email = 'user45131245612@acme.com';
        c.HasOptedOutOfEmail=false;
       Database.insert(c,opts);
       
       // Test with the subject that matches the unsubscribe statement.
       email.subject = 'test unsubscribe test';
       env.fromAddress = 'user45131245612@acme.com';
       
       // Call the class and test it with the data in the testMethod.
       Email_Unsubscribe unsubscribeObj = new Email_Unsubscribe();
       unsubscribeObj.handleInboundEmail(email, env );
                            
    }
     
    static testMethod void testUnsubscribe2() {
    
       // Create a new email and envelope object.
       Messaging.InboundEmail email = new Messaging.InboundEmail();
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
       // Create a new test lead and insert it in the test method.        
       
       Lead l = DataFactory.buildLead('smith456123', 'Salesforce');
        l.Email='user7896453124864564@acme.com';
        l.HasOptedOutOfEmail = false;
       Database.DMLOptions opts = new Database.DMLOptions();
       opts.DuplicateRuleHeader.allowSave = true;
       Database.insert(l,opts);
    
       // Create a new test contact and insert it in the test method.    

       Contact c = DataFactory.buildContact('john1231545 smith456123', null);
        c.Email = 'user7896453124864564@acme.com';
        c.HasOptedOutOfEmail=false;
       Database.insert(c,opts);
       
       // Test with a subject that does not contain "unsubscribe."
       email.subject = 'test';
       env.fromAddress = 'user7896453124864564@acme.com';
    
       // Call the class and test it with the data in the test method.
       Email_Unsubscribe unsubscribeObj = new Email_Unsubscribe();
       unsubscribeObj.handleInboundEmail(email, env );                      
    }     
}