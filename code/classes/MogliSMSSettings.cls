global with sharing class MogliSMSSettings {
    global static MogliSMS_Settings__mdt settings = [SELECT Id, DeveloperName, MasterLabel, Gateway__c, Language, NamespacePrefix,
                                        Label, QualifiedApiName, CustomWebServiceHandler__c, TwilioAccountSid__c, TwilioAuthToken__c,
                                        TelerivetProjectID__c, TelerivetSecret__c, TwilioPhone__c, CustomSMSServiceHandler__c,
                                        TelerivetPhoneId__c, TelerivetAPIKey__c,ContactTrigger__c, SMSTrigger__c,
                                        Active_Form_Instance_Status__c, Complete_Form_Instance_Status__c, FormTrigger__c,
                                        PossibleAnswerDelimiter__c, Create_Anonymous_Leads__c, AttachmentTrigger__c,
                                        LeadMergeFields__c, ContactMergeFields__c, Debug__c,
                                        LeadTrigger__c 
                                        FROM MogliSMS_Settings__mdt WHERE DeveloperName = 'MogliSMSSettings' limit 1];

//add these back in once the bug is fixed https://success.salesforce.com/issues_view?id=a1p300000008bS6AAI
                                        //QuestionResponseTrigger__c,
                                        //SMSTemplateTrigger__c,
    global static ApplicationSettings__c appSettings;

    public static ApplicationSettings__c getAppSettings(){
        try{
            if(appSettings == null){
                appSettings = [SELECT Id, ContactTrigger__c, SMSTrigger__c,
                                        Active_Form_Instance_Status__c, Complete_Form_Instance_Status__c, FormTrigger__c,
                                        PossibleAnswerDelimiter__c, Create_Anonymous_Leads__c, AttachmentTrigger__c,
                                        LeadMergeFields__c, ContactMergeFields__c, Debug__c, DefaultGateway__c,
                                        LeadTrigger__c
                                        FROM ApplicationSettings__c WHERE Name = 'Default' limit 1];
            }   
        } catch (Exception e) {

            Gateway__c gtw = new Gateway__c(PhoneNumber__c = '123456789',
                                            TwilioAccountSid__c = '12345',
                                            TwilioAuthToken__c = '12345',
                                            WebHookIdentifier__c = '1',
                                            RecordTypeID = MogliUtil.getRecordTypeIdByLabelName('Gateway__c', 'Twilio'));
            insert gtw;

            appSettings = new ApplicationSettings__c(Active_Form_Instance_Status__c = 'Active',
                                                                  AttachmentTrigger__c = true,
                                                                  Complete_Form_Instance_Status__c = 'Complete',
                                                                  ContactMergeFields__c = 'Name, Title, LeadSource',
                                                                  ContactTrigger__c = true,
                                                                  Create_Anonymous_Leads__c = true,
                                                                  Debug__c = true,
                                                                  DefaultGateway__c = gtw.id,
                                                                  FormTrigger__c = true,
                                                                  LeadMergeFields__c = 'Name, Title, LeadSource',
                                                                  LeadTrigger__c = true,
                                                                  PossibleAnswerDelimiter__c = ':::',
                                                                  SMSTrigger__c = true,
                                                                  Name = 'Default');


            insert appSettings;

        }
        return appSettings;
    }
}