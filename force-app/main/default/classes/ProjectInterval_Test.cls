@isTest
global Class ProjectInterval_Test
{
    @isTest global static void testProjectVoid()
    {   
        Account ac = DataFactory.buildAccount('Test');
        insert ac;

        Opportunity o = DataFactory.buildOpportunity('Test Opportunity', ac.Id);
        insert o;

        Project__c a = DataFactory.buildProject(o.Id);
        insert a;
        
        A = [SELECT Calculated_Interval__c
                 FROM Project__c
                 WHERE Id = :A.Id];
    }

    @isTest global static void testProjectEmpty()
    {
        
        Account ac = DataFactory.buildAccount('Test');
        insert ac;

        Opportunity o = DataFactory.buildOpportunity('Test Opportunity', ac.Id);
        insert o;

        Project__c a = DataFactory.buildProject(o.Id);
        a.osp_Build_Status__c = 'XXXXXXX';
        a.osp_Poles__c = 0;
        insert a;

        A = [SELECT Calculated_Interval__c
                    FROM Project__c
                 WHERE Id = :A.Id];
        System.assertEquals(A.Calculated_Interval__c,date.today().addDays(40));
    }
  
    @isTest global static void testProjectEmptyWithPole()
    {
        Account ac = DataFactory.buildAccount('Test');
        insert ac;

        Opportunity o = DataFactory.buildOpportunity('Test Opportunity', ac.Id);
        insert o;

        Project__c a = DataFactory.buildProject(o.Id);
        a.osp_Build_Status__c = 'XXXXXXX';
        a.osp_Poles__c = 1;
        insert a;
        A = [SELECT Calculated_Interval__c
                 FROM Project__c
                 WHERE Id = :A.Id];
        System.assertEquals(A.Calculated_Interval__c,date.today().addDays(40));
    }
  
    @isTest global static void testProjectSurvyedWithPolePast()
    {
        Account ac = DataFactory.buildAccount('Test');
        insert ac;

        Opportunity o = DataFactory.buildOpportunity('Test Opportunity', ac.Id);
        insert o;

        Project__c a = DataFactory.buildProject(o.Id);
        a.osp_Build_Status__c = 'XXXXXXX';
        a.osp_Poles__c = 1;
        A.osp_Submit__c = date.today().addDays(-100);
        A.osp_Survey__c = date.today().addDays(-100);
        insert a;
        A = [SELECT Calculated_Interval__c
                 FROM Project__c
                 WHERE Id = :A.Id];
        System.assertEquals(A.Calculated_Interval__c,date.today().addDays(30));
    }
    
    @isTest global static void testProjectAppReq()
    {  
        Account ac = DataFactory.buildAccount('Test');
        insert ac;

        Opportunity o = DataFactory.buildOpportunity('Test Opportunity', ac.Id);
        insert o;

        Project__c a = DataFactory.buildProject(o.Id);
        a.osp_Build_Status__c = 'XXXXXXX';
        a.osp_Poles__c = 1;
        A.Telco_Pole_App_Required__c = 'YES';
        A.Elco_Pole_App_Required__c = 'YES';
        A.Other_Pole_App_Required__c = 'YES';
        insert A;
        A = [SELECT Calculated_Interval__c
                 FROM Project__c
                 WHERE Id = :A.Id];
        System.assertEquals(A.Calculated_Interval__c,date.today().addDays(85));    
    }
  
    @isTest global static void testProjectAppSent()
    {  
        Account ac = DataFactory.buildAccount('Test');
        insert ac;

        Opportunity o = DataFactory.buildOpportunity('Test Opportunity', ac.Id);
        insert o;

        Project__c a = DataFactory.buildProject(o.Id);
        a.osp_Build_Status__c = 'XXXXXXX';
        a.osp_Poles__c = 1;
        A.Telco_Pole_App_Required__c = 'YES';
        A.Elco_Pole_App_Required__c = 'YES';
        A.Other_Pole_App_Required__c = 'YES';
        A.Telco_SentPA__c = date.today();
        A.Elco_SentPA__c = date.today().addDays(1);
        A.Other_SentPA__c = date.today().addDays(2);
        insert A;
        A = [SELECT Calculated_Interval__c
                 FROM Project__c
                 WHERE Id = :A.Id];
        System.assertEquals(A.Calculated_Interval__c,date.today().addDays(70));    
    }
  
    @isTest global static void testProjectAppSentPast()
    {  
        Account ac = DataFactory.buildAccount('Test');
        insert ac;

        Opportunity o = DataFactory.buildOpportunity('Test Opportunity', ac.Id);
        insert o;

        Project__c a = DataFactory.buildProject(o.Id);
        a.osp_Build_Status__c = 'XXXXXXX';
        a.osp_Poles__c = 1;
        A.Telco_Pole_App_Required__c = 'YES';
        A.Elco_Pole_App_Required__c = 'YES';
        A.Other_Pole_App_Required__c = 'YES';
        A.Telco_SentPA__c = date.today().addDays(-300);
        A.Elco_SentPA__c = date.today().addDays(-300);
        A.Other_SentPA__c = date.today().addDays(-300);
        insert A;
        A = [SELECT Calculated_Interval__c
                 FROM Project__c
                 WHERE Id = :A.Id];
        System.assertEquals(A.Calculated_Interval__c,date.today().addDays(23));    
    }
  
    @isTest global static void testProjectMRReq()
    {  
        Account ac = DataFactory.buildAccount('Test');
        insert ac;

        Opportunity o = DataFactory.buildOpportunity('Test Opportunity', ac.Id);
        insert o;

        Project__c a = DataFactory.buildProject(o.Id);
        a.osp_Build_Status__c = 'XXXXXXX';
        a.osp_Poles__c = 1;
        A.Telco_Pole_App_Required__c = 'YES';
        A.Elco_Pole_App_Required__c = 'YES';
        A.Other_Pole_App_Required__c = 'YES';
        A.Telco_MR_Req__c = 'YES';
        A.Elco_MR_Req__c = 'YES';
        A.Other_MR_Req__c = 'YES';
        insert A;
        A = [SELECT Calculated_Interval__c
                 FROM Project__c
                 WHERE Id = :A.Id];
        System.assertEquals(A.Calculated_Interval__c,date.today().addDays(137));    
    }
  
    @isTest global static void testProjectMREstRec()
    {  
        Account ac = DataFactory.buildAccount('Test');
        insert ac;

        Opportunity o = DataFactory.buildOpportunity('Test Opportunity', ac.Id);
        insert o;

        Project__c a = DataFactory.buildProject(o.Id);
        a.osp_Build_Status__c = 'XXXXXXX';
        a.osp_Poles__c = 1;
        A.Telco_Pole_App_Required__c = 'YES';
        A.Elco_Pole_App_Required__c = 'YES';
        A.Other_Pole_App_Required__c = 'YES';
        A.Telco_MR_Req__c = 'YES';
        A.Elco_MR_Req__c = 'YES';
        A.Other_MR_Req__c = 'YES';
        A.Telco_MR_EstRcvd__c = date.today();
        A.Elco_MR_EstRcvd__c = date.today();
        A.Other_MR_EstRcvd__c = date.today();
        insert A;
        A = [SELECT Calculated_Interval__c
                 FROM Project__c
                 WHERE Id = :A.Id];
        System.assertEquals(A.Calculated_Interval__c,date.today().addDays(75));    
    }
  
    @isTest global static void testProjectMREstRecPast()
    {  
        Account ac = DataFactory.buildAccount('Test');
        insert ac;

        Opportunity o = DataFactory.buildOpportunity('Test Opportunity', ac.Id);
        insert o;

        Project__c a = DataFactory.buildProject(o.Id);
        a.osp_Build_Status__c = 'XXXXXXX';
        a.osp_Poles__c = 1;
        A.Telco_Pole_App_Required__c = 'YES';
        A.Elco_Pole_App_Required__c = 'YES';
        A.Other_Pole_App_Required__c = 'YES';
        A.Telco_MR_Req__c = 'YES';
        A.Elco_MR_Req__c = 'YES';
        A.Other_MR_Req__c = 'YES';
        A.Telco_MR_EstRcvd__c = date.today().addDays(-100);
        A.Elco_MR_EstRcvd__c = date.today().addDays(-100);
        A.Other_MR_EstRcvd__c = date.today().addDays(-100);
        insert A;
        A = [SELECT Calculated_Interval__c
                 FROM Project__c
                 WHERE Id = :A.Id];
        System.assertEquals(A.Calculated_Interval__c,date.today().addDays(75));    
    }
  
    @isTest global static void testSched()
    {
        ProjectInterval.calculateAllDueDate();
    }
  
    @isTest global static void testProjectMRDone()
    {  
       Account ac = DataFactory.buildAccount('Test');
        insert ac;

        Opportunity o = DataFactory.buildOpportunity('Test Opportunity', ac.Id);
        insert o;

        Project__c a = DataFactory.buildProject(o.Id);
        a.osp_Build_Status__c = 'XXXXXXX';
        a.osp_Poles__c = 1;
        A.Telco_Pole_App_Required__c = 'YES';
        A.Elco_Pole_App_Required__c = 'YES';
        A.Other_Pole_App_Required__c = 'YES';
        A.Telco_MR_Req__c = 'YES';
        A.Elco_MR_Req__c = 'YES';
        A.Other_MR_Req__c = 'YES';
        A.Telco_MR_Cmpltd__c = date.today();
        A.Elco_MR_Cmpltd__c = date.today();
        A.Other_MR_Cmpltd__c = date.today();
        insert A;
        A = [SELECT Calculated_Interval__c
                     FROM Project__c
                 WHERE Id = :A.Id];
        System.assertEquals(A.Calculated_Interval__c,date.today().addDays(92));    
    } 
}