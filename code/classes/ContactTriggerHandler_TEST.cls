@isTest private class ContactTriggerHandler_TEST {
    @TestSetup
    public static void setupData(){
        TestUtil.setStandardTestConditions();
    }
    
    @isTest static void validateMessageSentOnInsert() {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i< 100; i++){
            Contact cont = new Contact();
            cont.LastName = 'test'+String.valueOf(i);
            cont.MobilePhone = '5555555555';
            cont.Mogli_Number__c = '5555555555';
            cont.SMS_Message_To_Send__c = 'test';
            contacts.add(cont);         
        }
        system.assertEquals([SELECT id from SMS__c].size(), 0, 'There should be no messages in the SMS__c');
        Test.startTest();
        insert contacts;
        Test.stopTest();
        system.assertEquals([SELECT id from SMS__c].size(), 100, 'There should be messages in the SMS__c');
    }
    @isTest static void validateMessageSentOnUpdate() {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i< 100; i++){
            Contact cont = new Contact();
            cont.LastName = 'test'+String.valueOf(i);
            cont.MobilePhone = '5555555555';
            cont.Mogli_Number__c = '5555555555';
            contacts.add(cont);         
        }

        insert contacts;
        for(Contact cont : contacts){
            cont.SMS_Message_To_Send__c = 'test';
        }
        system.assertEquals([SELECT id from SMS__c].size(), 0, 'There should be no messages in the SMS__c');
        Test.startTest();
        ContactTriggerHandler.hasSent = false;
        update contacts;
        Test.stopTest();
        system.assertEquals([SELECT id from SMS__c].size(), 100, 'There should be messages in the SMS__c');
    }
}