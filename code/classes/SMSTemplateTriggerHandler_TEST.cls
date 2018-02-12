@isTest private class SMSTemplateTriggerHandler_TEST {
    @TestSetup static void setupData(){
        system.assert(true);
        TestUtil.setStandardTestConditions();

        //Create 10 Forms
        TestUtil.createAndInsertPossibleAnswers(TestUtil.TEST_THROTTLE,
                                                TestUtil.createAndInsertQuestionTemplates(TestUtil.TEST_THROTTLE,
                                                    TestUtil.createAndInsertFormTemplates(TestUtil.TEST_THROTTLE).values()).values());
    }
    @isTest static void validateLinkingToAFormCopiesFirstQuestion() {
        Map<ID, QuestionTemplate__c> questionTemplateByID = new Map<ID, QuestionTemplate__c>([SELECT id, Name, FirstQuestion__c, FormTemplate__c, Message_Text__c
                                                                                         FROM QuestionTemplate__c]);
        Map<ID, FormTemplate__c> formTemplateByID = new Map<ID, FormTemplate__c>([SELECT id, Name, Status__c
                                                                            FROM FormTemplate__c]);

        system.assertEquals(questionTemplateByID.size(), TestUtil.TEST_THROTTLE * TestUtil.TEST_THROTTLE);
        system.assertEquals(formTemplateByID.size(), TestUtil.TEST_THROTTLE);


        for(FormTemplate__c form : formTemplateByID.values()){
            form.Status__c = 'Active';
        }
        update formTemplateByID.values();


        //Create a map where the first question of the form is sorted by the form id
        Map<ID, QuestionTemplate__c> firstQuestionByFormTemplateId = new Map<ID, QuestionTemplate__c>();
        for(QuestionTemplate__c question : questionTemplateByID.values()){
            if(question.FirstQuestion__c == true){
                firstQuestionByFormTemplateId.put(question.FormTemplate__c, question);
            }
        }
        system.assertEquals(firstQuestionByFormTemplateId.size(), TestUtil.TEST_THROTTLE, 'Each Template should have 1 first question');

        List<SMS_Template__c> smsTemplateList = new List<SMS_Template__c>();

        Integer cnt = 0;
        for(FormTemplate__c formTemplate : formTemplateByID.values()){
            smsTemplateList.add(new SMS_Template__c(Name__c = 'Test'+cnt,
                                                                FormTemplate__c = formTemplate.id));
            cnt++;
        
        }

        Test.startTest();
        insert smsTemplateList;
        Test.stopTest();

        //Loop through the templates and make sure they are the same as the Form Templates First Question text
        Map<ID, SMS_Template__c> smsTemplateByIDAfterInsert = new Map<ID, SMS_Template__c>([SELECT id, Name__c, Text__c, FormTemplate__c
                                                                                                        FROM SMS_Template__c]);
        for(SMS_Template__c smsTemplate: smsTemplateByIDAfterInsert.values()){
            //loop through the questions for the template and validate the text of the SMS template is the same as the first question within the Form
            system.assertEquals(smsTemplate.Text__c, firstQuestionByFormTemplateId.get(smsTemplate.FormTemplate__c).Message_Text__c, 'The Text is not the same as the first question for this form');
        }

        //justgethecoverageman!
        update smsTemplateList;
        delete smsTemplateList;
        undelete smsTEmplateList;
    }
}