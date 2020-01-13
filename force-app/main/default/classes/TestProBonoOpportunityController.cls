/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root
 */

@isTest
public with sharing class TestProBonoOpportunityController {
    
    @testSetup
    static void setupData(){
        //Opportunity o = new Opportunity();
        
        //insert o;

        //Opportunity o2 = new Opportunity();
        //o2.Amount = 2000.00;
        //o2.Name = 'Another Test Opportunity For Unit Test Purposes';
        //o2.CloseDate = Date.Today().addDays(5);
        //o2.StageName = 'Prospecting';
        //o2.Description = 'Test Data';
        //insert o2;
        Opportunity o1 = DataFactory.buildOpportunity('Test Opportunity For Unit Test Purposes', null);
        o1.Amount = 1000.00;
        o1.StageName = 'Prospecting';

        Opportunity o2 = DataFactory.buildOpportunity('Another Test Opportunity For Unit Test Purposes', null);
        o2.Amount = 2000.00;
        o2.StageName = 'Prospecting';
        o2.CloseDate = Date.Today().addDays(5);
        o2.Description = 'Test Data';
        insert new Opportunity[]{o1,o2};
    }

    @isTest
    static void convertToProbonoOpportunity(){
        Opportunity opp = [SELECT Id, Amount, Description FROM Opportunity WHERE Name = 'Test Opportunity For Unit Test Purposes'];
        Test.startTest();
        ProBonoOpportunityController.convertToProbonoOpportunity(opp.Id);
        Test.stopTest();
        Opportunity updatedOpp = [SELECT Id, Amount, Description FROM Opportunity WHERE Name = 'Test Opportunity For Unit Test Purposes'];
        System.assertEquals(0, updatedOpp.Amount);
        System.assertEquals('Converted to Pro-Bono.', updatedOpp.Description);
    }

    @isTest
    static void convertToProbonoOpportunityWithDescription(){
        Opportunity opp = [SELECT Id, Amount, Description FROM Opportunity WHERE Name = 'Another Test Opportunity For Unit Test Purposes'];
        Test.startTest();
        ProBonoOpportunityController.convertToProbonoOpportunity(opp.Id);
        Test.stopTest();
        Opportunity updatedOpp = [SELECT Id, Amount, Description FROM Opportunity WHERE Name = 'Another Test Opportunity For Unit Test Purposes'];
        System.assertEquals(0, updatedOpp.Amount);
        System.assertEquals('Test Data. Converted to Pro-Bono.', updatedOpp.Description);
    }
}