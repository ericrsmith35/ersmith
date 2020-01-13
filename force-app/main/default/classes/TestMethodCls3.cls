@isTest
private class TestMethodCls3 {

    static testMethod void myTest1() {

        // This code runs as the system user

        User u1;

        try{
          u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'System Administrator'  LIMIT 1];
        } catch (QueryException qe){

        List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];

        for(User u : users){
            if(u.Profile.PermissionsModifyAllData = true){
              u1 = u;
              break;
        }
        }

        }

        System.debug(u1);

       //*****Create Queue 
       
       Group testGroup = new Group ();
       testGroup.Name = 'TestQueue';
       testGroup.Type = 'Queue';
       insert testGroup;
       
       QueueSObject testQueue = new QueueSObject();
       testQueue.QueueId = testGroup.id;
       testQueue.SObjectType = 'Lead';
       insert testQueue;

       // Second Queue       
       Group testGroup2 = new Group ();
       testGroup2.Name = 'TestQueue2';
       testGroup2.Type = 'Queue';
       insert testGroup2;
       
       QueueSObject testQueue2 = new QueueSObject();
       testQueue2.QueueId = testGroup2.id;
       testQueue2.SObjectType = 'Lead';
       insert testQueue2;


       test.starttest();
        
        //Run test

        //Assign Lead with out any Assignment Groups
        //Lead c1 = new Lead (LastName='testLead',Company='fake',TempOwnerID__c=testGroup2.id, OwnerID=u1.id); //TempOwnerID__c=testGroup2.id,  
        Lead c1 = DataFactory.buildLead('testLead','fake');
        c1.TempOwnerID__c = testGroup2.id;
        c1.OwnerID = u1.id;
        insert c1;
        update c1;
        
        
        //Create Assignment Group
        Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Lead');
        insert ag1;

         
        //Add bad queue name
        Assignment_Group_Queues__c agqBad = new Assignment_Group_Queues__c(name='Bad Queue',Assignment_Group_Name__c = ag1.id );

        try {
            insert agqBad; 
        } catch (DmlException e){
             System.assert(e.getMessage().contains('CUSTOM_VALIDATION_EXCEPTION'), e.getMessage()); 
        
        } //catch

        test.stoptest();
        
    }
    
    static testMethod void myTest2() {

        // This code runs as the system user

        User u1;

        try{
          u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'System Administrator'  LIMIT 1];
        } catch (QueryException qe){

        List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];

        for(User u : users){
            if(u.Profile.PermissionsModifyAllData = true){
              u1 = u;
              break;
        }
        }

        }

        System.debug(u1);

       //*****Create Queue 
       
       Group testGroup = new Group ();
       testGroup.Name = 'TestQueue';
       testGroup.Type = 'Queue';
       insert testGroup;
       
       QueueSObject testQueue = new QueueSObject();
       testQueue.QueueId = testGroup.id;
       testQueue.SObjectType = 'Lead';
       insert testQueue;

       // Second Queue       
       Group testGroup2 = new Group ();
       testGroup2.Name = 'TestQueue2';
       testGroup2.Type = 'Queue';
       insert testGroup2;
       
       QueueSObject testQueue2 = new QueueSObject();
       testQueue2.QueueId = testGroup2.id;
       testQueue2.SObjectType = 'Lead';
       insert testQueue2;


       test.starttest();
        
        //Run test
       
        
        //Create Assignment Group
        Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Lead');
        insert ag1;        

        //Add Good Queue to Assignment Group
        Assignment_Group_Queues__c agq1 = new Assignment_Group_Queues__c(name=testGroup.Name ,Assignment_Group_Name__c = ag1.id );
        insert agq1;
        
        
        //Add User to Assignment Groups Users
        Assignment_Groups__c agu1 = new Assignment_Groups__c (User__c = u1.id, Active__c='True', Group_Name__c = ag1.id, Last_Assignment__c = datetime.valueOf('2009-01-01 21:13:24') );
        insert agu1;

        Lead c2 = new Lead (LastName='testLead2', Company='fake2',TempOwnerID__c=testGroup2.id , OwnerID=testGroup.id); //Set owner ID to Queue
        insert c2;
        update c2;        

        test.stoptest();
        
    }

    static testMethod void myTest3() {

        // This code runs as the system user

        User u1;

        try{
          u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'System Administrator'  LIMIT 1];
        } catch (QueryException qe){

        List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];

        for(User u : users){
            if(u.Profile.PermissionsModifyAllData = true){
              u1 = u;
              break;
        }
        }

        }

        System.debug(u1);

       //*****Create Queue 
       
       Group testGroup = new Group ();
       testGroup.Name = 'TestQueue';
       testGroup.Type = 'Queue';
       insert testGroup;
       
       QueueSObject testQueue = new QueueSObject();
       testQueue.QueueId = testGroup.id;
       testQueue.SObjectType = 'Lead';
       insert testQueue;

       test.starttest();
        
        //Run test        
        
        //Create Assignment Group
        Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Lead');
        insert ag1;        

        //Add Good Queue to Assignment Group
        Assignment_Group_Queues__c agq1 = new Assignment_Group_Queues__c(name=testGroup.Name ,Assignment_Group_Name__c = ag1.id );
        insert agq1;
        
        
        //Add User to Assignment Groups Users
        Assignment_Groups__c agu1 = new Assignment_Groups__c (User__c = u1.id, Active__c='True', Group_Name__c = ag1.id, Last_Assignment__c = datetime.valueOf('2009-01-01 21:13:24') );
        insert agu1;      
 
        Lead c3 = new Lead (LastName='testLead3', Company='test company 3',OwnerID=testGroup.id); //Set owner ID to Queue
        insert c3;
        update c3;

        test.stoptest();
        
    }

    static testMethod void myTest4() {

        // This code runs as the system user

        User u1;

        try{
          u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'System Administrator'  LIMIT 1];
        } catch (QueryException qe){

        List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];

        for(User u : users){
            if(u.Profile.PermissionsModifyAllData = true){
              u1 = u;
              break;
        }
        }

        }

        System.debug(u1);

       //*****Create Queue 
       
       Group testGroup = new Group ();
       testGroup.Name = 'TestQueue';
       testGroup.Type = 'Queue';
       insert testGroup;
       
       QueueSObject testQueue = new QueueSObject();
       testQueue.QueueId = testGroup.id;
       testQueue.SObjectType = 'Lead';
       insert testQueue;
      

       test.starttest();
        
        //Run test

        //Create Assignment Group
        Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Lead');
        insert ag1;        

        //Add Good Queue to Assignment Group
        Assignment_Group_Queues__c agq1 = new Assignment_Group_Queues__c(name=testGroup.Name ,Assignment_Group_Name__c = ag1.id );
        insert agq1;
        
          //Test for AG-Queues already assigned to another Assignment Group
        Assignment_Group_Queues__c agq2 = new Assignment_Group_Queues__c(name=testGroup.Name,Assignment_Group_Name__c = ag1.id );
        try {
            insert agq2;
        } catch (DmlException e){
             System.assert(e.getMessage().contains('CUSTOM_VALIDATION_EXCEPTION'), e.getMessage()); 
        } //catch

        test.stoptest();
        
    }
    
    static testMethod void myTest5() {

        // This code runs as the system user
        User u1;

        try{
          u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'System Administrator'  LIMIT 1];
        } catch (QueryException qe){

        List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];

        for(User u : users){
            if(u.Profile.PermissionsModifyAllData = true){
              u1 = u;
              break;
        }
        }
        }

        System.debug(u1);

       //*****Create Queue 
       Group testGroup = new Group ();
       testGroup.Name = 'TestQueue';
       testGroup.Type = 'Queue';
       insert testGroup;
       
       Group testGroup2 = new Group();
       testGroup2.Name = 'TestQueue2';
       testGroup2.Type = 'Queue';
       insert testGroup2;
       
       QueueSObject testQueue = new QueueSObject();
       testQueue.QueueId = testGroup.id;
       testQueue.SObjectType = 'Lead';
       insert testQueue;
      
       QueueSObject testQueue2 = new QueueSObject();
       testQueue2.QueueId = testGroup2.id;
       testQueue2.SObjectType = 'Lead';
       insert testQueue2;

       test.starttest();
       
        //Run test
        //Create Assignment Group
        Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Lead');
        insert ag1;        

        //Add Good Queue to Assignment Group
        Assignment_Group_Queues__c agq1 = new Assignment_Group_Queues__c(name=testGroup.Name ,Assignment_Group_Name__c = ag1.id );
        insert agq1;
        
        //Add Group Member
        Assignment_Groups__c agu1 = new Assignment_Groups__c (User__c = u1.id, Active__c='True', Group_Name__c = ag1.id, Last_Assignment__c = datetime.valueOf('2009-01-01 21:13:24') );
        insert agu1;
        
        //Add Lead
        Lead l = new Lead(LastName = 'Tester', Company = 'LeadMD', Description = 'Testy', OwnerID = testGroup.id);
        insert l;
        system.assertEquals(l.OwnerID, testGroup.id);
        l.OwnerID = testGroup2.id;
        l.TempOwnerID__c = 'SKIP';
        update l;
        system.assertEquals(l.OwnerID, testGroup2.id);
        l.OwnerID = testGroup.id;
        l.TempOwnerID__c = '';
        update l;
        system.assertEquals(l.OwnerID, testGroup.id);
        
        //Test for AG-Queues already assigned to another Assignment Group
        Assignment_Group_Queues__c agq2 = new Assignment_Group_Queues__c(name=testGroup.Name,Assignment_Group_Name__c = ag1.id );
        try {
            insert agq2;
        } catch (DmlException e){
            System.assert(e.getMessage().contains('CUSTOM_VALIDATION_EXCEPTION'), e.getMessage()); 
        }
        
        Assignment_Group_Queues__c agqBad = new Assignment_Group_Queues__c(name='Bad Queue',Assignment_Group_Name__c = ag1.id);
        try {
            insert agqBad;
        } catch (DmlException e){
             System.assert(e.getMessage().contains('CUSTOM_VALIDATION_EXCEPTION'), e.getMessage());
        }
        
        ag1.Name = 'TestAG22';
        update ag1;
        
        system.assertEquals(ag1.Name, 'TestAG22');
        
        Assignment_Group_Name__c ag2 = new Assignment_Group_Name__c(Name='TestAG22', Type__c = 'Lead');
        insert ag2;
        Assignment_Group_Queues__c agq3 = new Assignment_Group_Queues__c(name=testGroup2.Name, Assignment_Group_Name__c = ag2.id);
        insert agq3;

        
        system.assertEquals(agq3.Name, 'TestQueue2');
        
        if(l.OwnerID == 'a06K0000001rYWl')
        {
            l.OwnerID = '';
        }else{
            l.OwnerID = testQueue2.id;
            System.assertEquals(l.OwnerID, testQueue2.id);
        }
                
        test.stoptest();
    }
    
}