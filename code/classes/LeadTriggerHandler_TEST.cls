@isTest private class LeadTriggerHandler_TEST {
    @TestSetup static void setupData(){
        TestUtil.setStandardTestConditions();
        system.assert(true);
    }
    @isTest static void validateMessageSentOnInsert() {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i< 100; i++){
            Lead ld = new Lead();
            ld.LastName = 'test'+String.valueOf(i);
            ld.Company = 'test company '+String.valueOf(i);
            ld.MobilePhone = '5555555555';
            ld.Mogli_Number__c = '+15555555555';
            ld.SMS_Message_To_Send__c = 'test';
            leads.add(ld);         
        }
        system.assertEquals([SELECT id from SMS__c].size(), 0, 'There should be no messages in the SMS__c');
        Test.startTest();
        insert leads;
        Test.stopTest();
        system.assertEquals([SELECT id from SMS__c].size(), 100, 'There should be messages in the SMS__c');
    }
    @isTest static void validateMessageSentOnUpdate() {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i< 100; i++){
            Lead ld = new Lead();
            ld.LastName = 'test'+String.valueOf(i);
            ld.Company = 'test company '+String.valueOf(i);
            ld.MobilePhone = '5555555555';
            ld.Mogli_Number__c = '+15555555555';
            leads.add(ld);         
        }

        insert leads;
        for(Lead ld : leads){
            ld.SMS_Message_To_Send__c = 'test';
        }
        system.assertEquals([SELECT id from SMS__c].size(), 0, 'There should be no messages in the SMS__c');
        Test.startTest();
        LeadTriggerHandler.sendSMSFromLeadHasRun = false;
        update leads;
        Test.stopTest();
        system.assertEquals([SELECT id from SMS__c].size(), 100, 'There should be messages in the SMS__c');
    }
}