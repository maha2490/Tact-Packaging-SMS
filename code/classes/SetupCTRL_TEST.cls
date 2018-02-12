@isTest
public with sharing class SetupCTRL_TEST {
    @TestSetup static void setupData(){
        TestUtil.setStandardTestConditions();
        system.assert(true);
    }    
    @isTest
    static void validateSetupCTRL(){
        PageReference pageRef = Page.Setup;
        Test.setCurrentPage(pageRef);

        SetupCTRL cont = new SetupCTRL();
        system.assertNotEquals(cont, null);
        cont.scheduleSMSCleanupUtil();

    }
}