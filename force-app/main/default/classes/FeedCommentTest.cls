// Handles all testing for FeedComment trigger
// GWI - Eric Smith - Jan 2018

@isTest
public with sharing class FeedCommentTest {
    
    @IsTest static void myTest() {
        //Account a = new Account(Name = 'Test');
        Account a = DataFactory.buildAccount('Test');
        insert a;
        //Contact c = new Contact(LastName = 'Test', AccountId = a.Id);
        Contact c = DataFactory.buildContact('Test', a.Id);
        insert c;
        //FeedItem fi = new FeedItem(Body = 'Test', ParentId = c.Id);
        FeedItem fi = DataFactory.buildFeedItem(c.Id, 'Test');
        insert fi;
        FeedComment fc = DataFactory.buildFeedComment(fi.Id, '#ticket');
        //FeedComment fc = new FeedComment(FeedItemId = fi.Id, CommentBody = '#ticket');
        insert fc;
    }
    
}