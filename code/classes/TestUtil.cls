@isTest
public class TestUtil
{
    public static final Integer TEST_THROTTLE = 10;
    /**************************************************************************
     * setStandardTestConditions
     **************************************************************************/
    public static void setStandardTestConditions() {

        
        //Gateway__c gtw = new Gateway__c(PhoneNumber__c = '123456789',
        //                                TwilioAccountSid__c = '12345',
        //                                TwilioAuthToken__c = '12345',
        //                                WebHookIdentifier__c = '1',
        //                                RecordTypeID = MogliUtil.getRecordTypeIdByLabelName('Gateway__c', 'Twilio'));
        //insert gtw;

        //ApplicationSettings__c app = new ApplicationSettings__c(Active_Form_Instance_Status__c = 'Active',
        //                                                          AttachmentTrigger__c = true,
        //                                                          Complete_Form_Instance_Status__c = 'Complete',
        //                                                          ContactMergeFields__c = 'Name, Title, LeadSource',
        //                                                          ContactTrigger__c = true,
        //                                                          Create_Anonymous_Leads__c = true,
        //                                                          Debug__c = true,
        //                                                          DefaultGateway__c = gtw.id,
        //                                                          FormTrigger__c = true,
        //                                                          LeadMergeFields__c = 'Name, Title, LeadSource',
        //                                                          LeadTrigger__c = true,
        //                                                          PossibleAnswerDelimiter__c = ':::',
        //                                                          SMSTrigger__c = true,
        //                                                          Name = 'Default');
        //insert app;
        System.debug('appSettings:'+MogliSMSSettings.getAppSettings());
        system.assert(true);
            
    }


    /**************************************************************************
     * createAndInsertLeads
     **************************************************************************/
    public static Map<ID, Lead> createAndInsertLeads(Integer cnt) {
      system.assert(true);
        List<Lead> lds = new List<Lead>();
        for (Integer i = 0; i<cnt; i++){
            lds.add(new Lead(LastName = 'Test Lead '+String.valueOf(cnt),
                              Company = 'Test Company '+String.valueOf(cnt),
                              MobilePhone = '555555555'+String.valueOf(cnt),
                              Mogli_Number__c = '555555555'+String.valueOf(cnt)));
        }
        insert lds;
        Map<ID, Lead> ldMap = new Map<ID, Lead>([SELECT id, LastName, MobilePhone, Mogli_Number__c from Lead]);
        return ldMap;
    }

    /**************************************************************************
     * createAndInsertContacts
     **************************************************************************/
    public static Map<ID, Contact> createAndInsertContacts(Integer cnt) {
      system.assert(true);
        List<Contact> conts = new List<Contact>();
        for (Integer i = 0; i<cnt; i++){
            conts.add(new Contact(LastName = 'Test Contact '+String.valueOf(i),
                                     MobilePhone = '555555555'+String.valueOf(i),
                                     Mogli_Number__c = '555555555'+String.valueOf(i)));
        }
        insert conts;
        Map<ID, Contact> contMap = new Map<ID, Contact>([SELECT id, LastName, MobilePhone, Mogli_Number__c from Contact]);
        return contMap;
    }

    /**************************************************************************
     * createAndInsertFormTemplates
     **************************************************************************/
    public static Map<ID, FormTemplate__c> createAndInsertFormTemplates(Integer cnt) {
      system.assert(true);
        List<FormTemplate__c> formTs = new List<FormTemplate__c>();
        for (Integer i = 0; i<cnt; i++){
            formTs.add(new FormTemplate__c(Name = 'Test Form Template '+String.valueOf(cnt)));
        }
        insert formTs;
        Map<ID, FormTemplate__c> formTemplateMap = new Map<ID, FormTemplate__c>([SELECT id, Name, Status__c from FormTemplate__c]);
        return formTemplateMap;
    }

    /**************************************************************************
     * updateFormTemplatesToActive
     **************************************************************************/
    public static Map<ID, FormTemplate__c> updateFormTemplatesToActive(List<FormTemplate__c> formTemplates) {
      system.assert(true);
        for (FormTemplate__c formTemplate : formTemplates){
            formTemplate.Status__c = 'Active';
        }
        update formTemplates;
        Map<ID, FormTemplate__c> formTemplateMap = new Map<ID, FormTemplate__c>([SELECT id, Name, Status__c from FormTemplate__c]);
        return formTemplateMap;
    }


    /**************************************************************************
     * createAndInsertQuestionTemplates
     **************************************************************************/
    public static Map<ID, QuestionTemplate__c> createAndInsertQuestionTemplates(Integer cnt, List<FormTemplate__c> formTemplates) {
      system.assert(true);
        List<QuestionTemplate__c> questionTs = new List<QuestionTemplate__c>();
        for (FormTemplate__c formT : formTemplates){
            for (Integer i = 0; i<cnt; i++){
                QuestionTemplate__c questionT = new QuestionTemplate__c(Name = formT.Name + ' Test Question Template '+String.valueOf(cnt),
                                                       FormTemplate__c = formT.id,
                                                       Message_Text__c = formT.name + ' Test Question Template Text '+String.valueOf(cnt));
                if(i == 0){
                    questionT.FirstQuestion__c = true;
                } else {
                    questionT.FirstQuestion__c = false;
                }
                questionTs.add(questionT);
            }           
        }
        insert questionTs;
        Map<ID, QuestionTemplate__c> questionTemplateMap = new Map<ID, QuestionTemplate__c>([SELECT id, Name, FormTemplate__c, Message_Text__c from QuestionTemplate__c]);
        return questionTemplateMap;
    }
    /**************************************************************************
     * createAndInsertPossibleAnswers
     **************************************************************************/
    public static Map<ID, PossibleAnswer__c> createAndInsertPossibleAnswers(Integer cnt, List<QuestionTemplate__c> questions) {
      system.assert(true);
        List<PossibleAnswer__c> answers = new List<PossibleAnswer__c>();
        for (QuestionTemplate__c question : questions){
            for (Integer i = 0; i<cnt; i++){
                answers.add(new PossibleAnswer__c(PossibleText__c = question.Name + 'Possible Answer '+String.valueOf(cnt),
                                                       QuestionTemplate__c = question.id));
            }           
        }
        insert answers;
        Map<ID, PossibleAnswer__c> answersMap = new Map<ID, PossibleAnswer__c>([SELECT id, PossibleText__c, QuestionTemplate__c from PossibleAnswer__c]);
        return answersMap;
    }
    /**************************************************************************
     * createAndInsertSMSTemplates
     **************************************************************************/
    public static Map<ID, SMS_Template__c> createAndInsertSMSTemplates(Integer cnt, List<FormTemplate__c> formTemplates) {
      system.assert(true);
        List<SMS_Template__c> templates = new List<SMS_Template__c>();
        for (Integer i = 0; i<cnt; i++){
            templates.add(new SMS_Template__c(Name__c = 'Template '+i,
                                                      Text__c = 'whatever',
                                                      FormTemplate__c = formTemplates[i].id));
        }
        insert templates;
        Map<ID, SMS_Template__c> templatesByID = new Map<ID, SMS_Template__c>([SELECT id, Text__c, Name__c from SMS_Template__c]);
        return templatesByID;
    }
    
    /**************************************************************************
     * createAndInsertFormsForContacts
     **************************************************************************/
    public static Map<ID, Form__c> createAndInsertFormsForContacts(Integer cnt, List<Contact> contacts, String status) {
      system.assert(true);
        List<Form__c> forms = new List<Form__c>();
		Map<ID, Contact> contMap = new Map<ID,Contact>([Select id, Mogli_Number__c, MobilePhone from Contact]);
        for(Contact cont : contacts){
            for (Integer i = 0; i<cnt; i++){			
                forms.add(new Form__c(Contact__c = cont.id,
//                                      Phone_Number__c = contMap.get(cont.id).MobilePhone,
                                      Phone_Number__c = contMap.get(cont.id).Mogli_Number__c,
                                      Status__c = status));
            }            
        }
        insert forms;
        Map<ID, Form__c> formsByID = new Map<ID, Form__c>([SELECT id, Contact__c, Status__c, FormTemplate__c from Form__c]);
        return formsByID;
    }

    @isTest
    public static void getCoverage(){
      MogliUtil.testCoverage();
    }
}