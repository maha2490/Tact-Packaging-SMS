@isTest
public with sharing class InPersonFormExt_TEST {
    @TestSetup static void setupData(){
        TestUtil.setStandardTestConditions();
        system.assert(true);
    } 

    @isTest
    static void validateCTRL(){
        PageReference pageRef = Page.InPersonForm;
        Test.setCurrentPage(pageRef);



      	Contact conta1 = new Contact(LastName = 'Test User', MobilePhone = '+15555555555', Mogli_Number__c = '+15555555555');
      	insert conta1;
       	Contact conta2 = new Contact(LastName = 'Test User', MobilePhone = '+16666666666', Mogli_Number__c = '+16666666666', ReportsToId = conta1.id);
      	insert conta2;

        ApexPages.StandardController sc = new ApexPages.StandardController(new SMS__c());
        InPersonFormExt cont = new InPersonFormExt(sc);

        cont.contactForSurvey = conta2;

        system.assertNotEquals(cont, null);

        cont.getRecordName();
        cont.start();
        cont.respond();
        cont.restart();
        cont.newSurvey();

        


    }
}