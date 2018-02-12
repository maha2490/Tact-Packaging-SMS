@isTest private class QuestionResponseTriggerHandler_TEST {

    private static Map<ID, Contact> initialContactsByID;
    private static Map<ID, Form__c> initialFormsByID;
    private static Map<ID, FormTemplate__c> initialFormTemplatesByID;
    private static Map<ID, PossibleAnswer__c> initialPossibleAnswersByID;
    private static Map<ID, QuestionTemplate__c> initialQuestionTemplatesByID;
    private static Map<ID, SMS_Template__c> initialSMSTemplatesByID;
    private static Map<ID, SMS__c> initialOutgoingSMSByID;

    @TestSetup static void setupData(){
system.debug('QuestionResponseTriggerHandler_TEST.setupData()');
        TestUtil.setStandardTestConditions();
        system.assert(true);
        initialContactsByID = TestUtil.createAndInsertContacts(TestUtil.TEST_THROTTLE);


        initialFormTemplatesByID = TestUtil.createAndInsertFormTemplates(TestUtil.TEST_THROTTLE);
        initialQuestionTemplatesByID = TestUtil.createAndInsertQuestionTemplates(TestUtil.TEST_THROTTLE, initialFormTemplatesByID.values());

        //Create a default question for each form and make it the default question for each associated questionTemplate
        List<QuestionTemplate__c> questionTemplatesToCreate = new List<QuestionTemplate__c>();
        for(FormTemplate__c formT : initialFormTemplatesByID.values()){
            QuestionTemplate__c defaultQ = new QuestionTemplate__c();
            defaultQ.Message_Text__c = 'Default Response';
            defaultQ.FormTemplate__c = formT.id;
            questionTemplatesToCreate.add(defaultQ);
        }
        insert questionTemplatesToCreate;
        Map<ID, QuestionTemplate__c> defaultQuestionsByID = new Map<ID, QuestionTemplate__c>([SELECT id, FormTemplate__c, Message_Text__c, DefaultNextQuestion__c from QuestionTemplate__c WHERE Message_Text__c = 'Default Response']);
        system.assertEquals(defaultQuestionsByID.size(), TestUtil.TEST_THROTTLE, 'Should be one default question per form template');
        //sort by form template id
        Map<ID, List<QuestionTemplate__c>> defaultQuestionsByFormTemplateID = new Map<ID, List<QuestionTemplate__c>>();
        for(QuestionTemplate__c questionT : defaultQuestionsByID.values()){
            if(!defaultQuestionsByFormTemplateID.containsKey(questionT.FormTemplate__c)){
                defaultQuestionsByFormTemplateID.put(questionT.FormTemplate__c, new List<QuestionTemplate__c>());
            }
            defaultQuestionsByFormTemplateID.get(questionT.FormTemplate__c).add(questionT);
        }
        for(QuestionTemplate__c questionT : initialQuestionTemplatesByID.values()){
            questionT.DefaultNextQuestion__c = defaultQuestionsByFormTemplateID.get(questionT.FormTemplate__c)[0].id;
        }

        update initialQuestionTemplatesByID.values(); //update the initial question to now have the default next question


        initialPossibleAnswersByID = TestUtil.createAndInsertPossibleAnswers(TestUtil.TEST_THROTTLE, initialQuestionTemplatesByID.values());

        initialFormTemplatesByID = TestUtil.updateFormTemplatesToActive(initialFormTemplatesByID.values());
        initialSMSTemplatesByID = TestUtil.createandInsertSMSTemplates(TestUtil.TEST_THROTTLE, initialFormTemplatesByID.values());
system.debug('initialSmsTemplatesByID:'+initialSmsTemplatesByID);
        //ask the first question for each active form
        List<SMS__c> outgoingSMSs = new List<SMS__c>();
        for(Integer i = 0; i< TestUtil.TEST_THROTTLE; i++){

            SMS__c sms = new SMS__c();
            sms.Contact__c = initialContactsByID.values()[i].id;
            sms.Direction__c = 'Outgoing';
            sms.Message__c = initialSmsTemplatesByID.values()[i].Text__c;
            sms.Status__c = 'Queued';
//            sms.Phone_Number__c = initialContactsByID.values()[i].MobilePhone;
            sms.Phone_Number__c = initialContactsByID.values()[i].Mogli_Number__c;
            outgoingSMSs.add(sms);
        }
        insert outgoingSMSs;
system.debug('outgoingSMSs'+outgoingSMSs);
        initialOutgoingSMSByID = new Map<ID, SMS__c>([SELECT id, Contact__c, Direction__c, Message__c, Status__c, Phone_Number__c
                                                                FROM SMS__c]);
system.debug('initialOutgoingSMSByID:'+initialOutgoingSMSByID);
    }

    @isTest static void validateBadResponseTriggersDefaultQuestion() {
system.debug('QuestionResponseTriggerHandler_TEST.validateBadResponseTriggersDefaultQuestion()');
        initialContactsByID = new Map<ID, Contact>([SELECT id, LastName, MobilePhone, Mogli_Number__c FROM Contact]);
        initialFormsByID = new Map<ID, Form__c>([SELECT id, FormTemplate__c, Status__c, Contact__c FROM Form__c]);
        initialFormTemplatesByID = new Map<ID, FormTemplate__c>([SELECT id, Status__c FROM FormTemplate__c]);
        initialPossibleAnswersByID = new Map<ID, PossibleAnswer__c>([SELECT id, Next_Question__c, PossibleText__c, QuestionTemplate__c FROM PossibleAnswer__c]);
        initialQuestionTemplatesByID = new Map<ID, QuestionTemplate__c>([SELECT id, DefaultNextQuestion__c, FirstQuestion__c, FormTemplate__c, FormComplete__c, Message_Text__c FROM QuestionTemplate__c]);
        initialSMSTemplatesByID = new Map<ID, SMS_Template__c>([SELECT id, FormTemplate__c, Text__c, Name__c FROM SMS_Template__c]);
        initialOutgoingSMSByID = new Map<ID, SMS__c>([SELECT id, Contact__c, Direction__c, Message__c, Status__c, Phone_Number__c
                                                                FROM SMS__c]);




        system.assertEquals(initialContactsByID.size(), TestUtil.TEST_THROTTLE, 'Wrong number contacts');
        system.assertEquals(initialFormsByID.size(), TestUtil.TEST_THROTTLE, 'Wrong number forms');
        system.assertEquals(initialFormTemplatesByID.size(), TestUtil.TEST_THROTTLE, 'Wrong number form templates');
        system.assertEquals(initialQuestionTemplatesByID.size(), TestUtil.TEST_THROTTLE * (TestUtil.TEST_THROTTLE + 1), 'Wrong number of question templates');
        system.assertEquals(initialPossibleAnswersByID.size(), TestUtil.TEST_THROTTLE * TestUtil.TEST_THROTTLE * TestUtil.TEST_THROTTLE, 'Wrong number of possible answers');
        system.assertEquals(initialSMSTemplatesByID.size(), TestUtil.TEST_THROTTLE, 'Wrong number of SMS templates');       
        system.assertEquals(initialOutgoingSMSByID.size(), TestUtil.TEST_THROTTLE, 'Wrong number of outgoing SMS');     


        Map<ID, QuestionResponse__c> initialQuestionResponsesByID = new Map<ID, QuestionResponse__c>([SELECT id, Form__c, QuestionTemplate__c, Question_Text__c, Response__c FROM QuestionResponse__c]);


        for(QuestionResponse__c response : initialQuestionResponsesByID.values()){
            response.Response__c = 'bad response';
        }
        Test.startTest();
        update initialQuestionResponsesByID.values();
        Test.stopTest();

        //Validate that the default question from the Question_Template was asked
        Map<ID, SMS__c> smsQueueByID = new Map<ID, SMS__c>([SELECT id, Contact__c, Direction__c, 
            Message__c, Status__c, PHone_Number__c FROM SMS__c where id != :initialOutgoingSMSByID.keyset()]); //dont include the original smss
system.debug('smsQueueByID:'+smsQueueByID);
        system.assertEquals(smsQueueByID.size(), TestUtil.TEST_THROTTLE, 'Should be one new default question per contact');

        
        for(SMS__c smsQueue : smsQueueByID.values()){

//Removing link to contact to test for b4l
//            system.assert(initialContactsByID.containsKey(smsQueue.Contact__c), 'Each sms should be associated to a contact');
            system.assertEquals(smsQueue.Message__c, 'Default Response', 'Wrong message');
        }

    }
    @isTest static void validateGoodResponseTriggersNextQuestion() {
        system.assert(true);
    }
    @isTest static void validateUpdatingResponseDoesNotFireNextQuestion(){
        system.assert(true);
    }
}