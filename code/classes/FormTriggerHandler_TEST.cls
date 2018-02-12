@isTest private class FormTriggerHandler_TEST {

    @TestSetup static void setupData(){
        TestUtil.setStandardTestConditions();
        TestUtil.createAndInsertContacts(TestUtil.TEST_THROTTLE);
        system.assert(true);
    }

    @isTest static void validateOnlyOneActiveForm() {

        Test.startTest();
        //Create a form for a contact
        Map<ID, Form__c> formsByIDsBeforeInsert = TestUtil.createAndInsertFormsForContacts(TestUtil.TEST_THROTTLE, [SELECT id from Contact], 
            MogliSMSSettings.getAppSettings().Active_Form_Instance_Status__c);
		
        system.debug([SElect MobilePhone from Contact]);
        system.debug([Select Phone_Number__c from Form__c]);
        system.assertEquals(TestUtil.TEST_THROTTLE, [SELECT id from Form__c where Status__c = :MogliSMSSettings.getAppSettings().Active_Form_Instance_Status__c].size(),
            'There should 1 active form per contact');


        Map<ID,Form__c> formsByIDAfterInsert = new Map<ID, Form__c>([SELECT id, Contact__c, Status__c from Form__c]);

        List<Form__c> activeForms = new List<Form__c>();
        for(Form__c form : formsByIDAfterInsert.values()){
            if(form.Status__c == MogliSMSSettings.getAppSettings().Active_Form_Instance_Status__c){
                activeForms.add(form);
            }
        }
        system.assertEquals(activeForms.size(), TestUtil.TEST_THROTTLE, 'There should be 1 active form per contact');
        FormTriggerHandler.validateOneActiveStatusPerPhone = true;//treat it as a seperate transaction
        delete activeForms;

        system.assertEquals(0, [SELECT id from Form__c where Status__c = :MogliSMSSettings.getAppSettings().Active_Form_Instance_Status__c].size(),
            'There should be no active forms');

        //Update all the remaining forms to active
        List<Form__c> formsToUpdate = new List<Form__c>();
        for(Form__c form : [SELECT id, Status__c from Form__c]){
            form.Status__c = MogliSMSSettings.getAppSettings().Active_Form_Instance_Status__c;
            formsToUpdate.add(form);
        }
        FormTriggerHandler.validateOneActiveStatusPerPhone = true; //treat it as a seperate transaction
        update formsToUpdate;

        Integer count;
        if(TestUtil.TEST_THROTTLE>1){
            count = TestUtil.TEST_THROTTLE;
        } else {
            count = 0;
        }
        system.assertEquals(count, [SELECT id from Form__c where Status__c = :MogliSMSSettings.getAppSettings().Active_Form_Instance_Status__c].size(),
            'There should 1 active form per contact');

        FormTriggerHandler.validateOneActiveStatusPerPhone = true;//treat it as a seperate transaction
        undelete activeForms;

        Test.stopTest();


        system.assertEquals(TestUtil.TEST_THROTTLE, [SELECT id from Form__c where Status__c = :MogliSMSSettings.getAppSettings().Active_Form_Instance_Status__c].size(),
            'There should 1 active form per contact');      


        Map<ID,Form__c> formsByIDAfterAll = new Map<ID, Form__c>([SELECT id, Contact__c, Status__c from Form__c]);

        
        //Build a map of the forms by contact id to verify there is only one active status per contact
        Map<ID, List<Form__c>> formsByContactID = new Map<ID, List<Form__c>>();
        for(Form__c form : formsByIDAfterAll.values()){
            if(!formsByContactID.containsKey(form.Contact__c)){
                formsByContactID.put(form.Contact__c, new List<Form__c>());
            }
            formsByContactID.get(form.Contact__c).add(form);
        }

        //Now iterate through the list ensuring there is only one active status on the form
        for(ID contID : formsByContactID.keySet()){
            Integer countOfActive = 0;
            for(Form__c form: formsByContactID.get(contID)){
                if(form.Status__c == MogliSMSSettings.getAppSettings().Active_Form_Instance_Status__c){
                    countOfActive++;
                }
            }
            system.assertEquals(countOfActive, 1, 'There should only be 1 active form per contact');
        }
    }


}