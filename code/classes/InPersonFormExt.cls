public with sharing class InPersonFormExt {

	private final sObject mysObject;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public InPersonFormExt(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();

        responseSMS = new SMS__c();
        formSurveysToChoose = new List<SelectOption>();
        contactForSurvey = new Contact();

        if((Schema.sObjectType.SMS_Template__c.isAccessible()) &&
           (Schema.sObjectType.SMS_Template__c.fields.Name__c.isAccessible())&&
           (Schema.sObjectType.SMS_Template__c.fields.Text__c.isAccessible())){
            List<SMS_Template__c> templates = new List<SMS_Template__c>([Select id, Name__c, Text__c from SMS_Template__c limit 10000]);
            for(SMS_Template__c temp : templates){
                formSurveysToChoose.add(new SelectOption(temp.Text__c,temp.Text__c));
            } 
        } else {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The User does not have the correct access on SMS_Template__c'));           
        }
        
                                                                   
        renderSetup = true;
        renderOutputText = false;
        surveyOver = false;
        renderRespondButton = false;
        renderRestartButton = false;
    }

    public String getRecordName() {
        return 'Hello ' + (String)mysObject.get('name') + ' (' + (Id)mysObject.get('Id') + ')';
    }

    private SMS__c initialSMS = new SMS__c();
 
    public SMS__c responseSMS {get;set;}
    public Contact contactForSurvey {get;set;}
    public List<SelectOption> formSurveysToChoose {get;set;}
    public String selectedSurvey {get;set;}
    
    public Boolean renderSetup {get;set;}
    public Boolean renderOutputText {get;set;}
    public Boolean renderCompleteSection {get;set;}
    public Boolean renderRespondButton {get;set;}
    public Boolean renderRestartButton {get;set;}
    
    public Boolean surveyOver {get;set;}
    
    public String outputText {
        get{
            QuestionResponse__c lastQuestion = new QuestionResponse__c();
            try{
                if((Schema.sObjectType.QuestionResponse__c.isAccessible()) &&
                   (Schema.sObjectType.QuestionResponse__c.fields.Form__c.isAccessible())&&
                   (Schema.sObjectType.QuestionResponse__c.fields.Question_Text__c.isAccessible())&&
                   (Schema.sObjectType.QuestionResponse__c.fields.Response__c.isAccessible())&&
                   (Schema.sObjectType.Form__c.isAccessible())&&
                   (Schema.sObjectType.Form__c.fields.Contact__c.isAccessible())&&
                   (Schema.sObjectType.Form__c.fields.Phone_Number__c.isAccessible())&&
                   (Schema.sObjectType.Form__c.fields.Offline__c.isAccessible())&&
                   (Schema.sObjectType.QuestionTemplate__c.isAccessible())&&
                   (Schema.sObjectType.QuestionTemplate__c.fields.FormComplete__c.isAccessible())){
                        lastQuestion = [SELECT id, Form__c, Question_Text__c, Response__c,
                                        Form__r.Contact__c, Form__r.Phone_Number__c, Form__r.Offline__c,
                                        QuestionTemplate__r.FormComplete__c
                                        FROM QuestionResponse__c
                                        WHERE Form__r.Offline__c = true AND
                                        Form__r.Contact__c = :contactForSurvey.ReportsToId AND
                                        Form__r.Status__c = 'Active' AND
                                        Response__c = ''
                                        LIMIT 50000];
                } else {
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The User does not have the correct access on QuestionResponse__c, Form__c, or QuestionTemplate__c'));           
                }



                if(lastQuestion.QuestionTemplate__r.FormComplete__c){
                    renderOutputText = false;
                    surveyOver = true;
                    renderCompleteSection = true;
                    renderRespondButton = false;
                }
                return lastQuestion.Question_Text__c;                
            } catch (Exception e){
                surveyOver = true;
                renderOutputText = false;
                renderCompleteSection = true;
                renderRespondButton = false;
                return null;
            }

        }
        set;
    }

    public PageReference start(){
system.debug(selectedSurvey);
system.debug(contactForSurvey);
        initialSMS.Message__c = selectedSurvey;
        initialSMS.Status__c = 'Queued';
        initialSMS.Offline__c = true;
        initialSMS.Direction__c = 'Outgoing';

        Contact cont = new Contact();
        if((Schema.sObjectType.Contact.isAccessible()) &&
           (Schema.sObjectType.Contact.fields.MobilePhone.isAccessible())){
            cont = [Select id, MobilePhone, Mogli_Number__c from Contact where id = :contactForSurvey.ReportsToId limit 1];

        } else {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The User does not have the correct access on Contact'));           
        }


 //       initialSMS.Phone_Number__c = cont.MobilePhone;
        initialSMS.Phone_Number__c = cont.Mogli_Number__c;
        initialSMS.Contact__c = cont.id;
        
        if(MogliUtil.respectUserSecurityDML()){
            if((SMS__C.sObjectType.getDescribe().isCreateable()) &&
               (Schema.sObjectType.SMS__c.fields.Status__c.isAccessible()) &&
               (Schema.sObjectType.SMS__c.fields.Phone_Number__c.isAccessible())&&
               (Schema.sObjectType.SMS__c.fields.Offline__c.isAccessible()) &&
               (Schema.sObjectType.SMS__c.fields.Message__c.isAccessible()) &&
               (Schema.sObjectType.SMS__c.fields.Direction__c.isAccessible())){
                Database.insert(initialSMS,true);            
            } else {
                throw new InPersonFormExtException('InPersonFormExt - Insufficient Access to Insert SMS__c');
            }
        } else {
 //           Database.insert(initialSMS,true); 
        }        


        renderSetup = false;
        renderOutputText = true;
        renderRespondButton = true;
        renderRestartButton = true;
        return null;
    }

    public PageReference respond(){
        responseSMS.Status__c = 'Received Successfully';
        responseSMS.Offline__c = true;
        responseSMS.Direction__c = 'Incoming';
        responseSMS.Phone_Number__c = initialSMS.Phone_Number__c;
        responseSMS.Contact__c = initialSMS.Contact__c;


        if(MogliUtil.respectUserSecurityDML()){
            if((SMS__C.sObjectType.getDescribe().isCreateable()) &&
               (Schema.sObjectType.SMS__c.fields.Status__c.isAccessible()) &&
               (Schema.sObjectType.SMS__c.fields.Phone_Number__c.isAccessible())&&
               (Schema.sObjectType.SMS__c.fields.Offline__c.isAccessible()) &&
               (Schema.sObjectType.SMS__c.fields.Message__c.isAccessible()) &&
               (Schema.sObjectType.SMS__c.fields.Direction__c.isAccessible())){
                Database.insert(responseSMS,true);            
            } else {
                throw new InPersonFormExtException('InPersonFormExt - Insufficient Access to Insert SMS__c');
            }
        } else {
//            Database.insert(responseSMS,true); 
        }    

        
        responseSMS = new SMS__c();
 /*       
        MogliSMSService.AssociateSMS job = new MogliSMSService.AssociateSMS();
        System.enqueueJob(job);
        MogliSMSService.AssociateForms job2 = new MogliSMSService.AssociateForms();
        System.enqueueJob(job2);
 */       
        return null;
    }
    public PageReference restart(){
        initialSMS = new SMS__c();
        initialSMS.Message__c = selectedSurvey;
        initialSMS.Status__c = 'Queued';
        initialSMS.Offline__c = true;
        initialSMS.Direction__c = 'Outgoing';

 
        Contact cont = new Contact();
        if((Schema.sObjectType.Contact.isAccessible()) &&
           (Schema.sObjectType.Contact.fields.MobilePhone.isAccessible())){
            cont = [Select id, MobilePhone, Mogli_Number__c from Contact where id = :contactForSurvey.ReportsToId limit 1];

        } else {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The User does not have the correct access on Contact'));           
        }


 //       initialSMS.Phone_Number__c = cont.MobilePhone;
        initialSMS.Phone_Number__c = cont.Mogli_Number__c;
        initialSMS.Contact__c = cont.id;


        if(MogliUtil.respectUserSecurityDML()){
            if((SMS__C.sObjectType.getDescribe().isCreateable()) &&
               (Schema.sObjectType.SMS__c.fields.Status__c.isAccessible()) &&
               (Schema.sObjectType.SMS__c.fields.Phone_Number__c.isAccessible())&&
               (Schema.sObjectType.SMS__c.fields.Offline__c.isAccessible()) &&
               (Schema.sObjectType.SMS__c.fields.Message__c.isAccessible()) &&
               (Schema.sObjectType.SMS__c.fields.Direction__c.isAccessible())){
                Database.insert(initialSMS,true);            
            } else {
                throw new InPersonFormExtException('InPersonFormExt - Insufficient Access to Insert SMS__c');
            }
        } else {
//            Database.insert(initialSMS,true); 
        }  
        
        renderSetup = false;
        renderOutputText = true;
        renderCompleteSection = false;
        return null;
    }
    public PageReference newSurvey(){
        initialSMS = new SMS__c();
        renderSetup = true;
        renderOutputText = false;
        renderCompleteSection = false;
		return ApexPages.currentPage();
    }

    public class InPersonFormExtException extends Exception {}
}