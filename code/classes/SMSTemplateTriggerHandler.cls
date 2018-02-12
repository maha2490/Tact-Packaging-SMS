public with sharing class SMSTemplateTriggerHandler implements TriggerDispatch.ITriggerClass{

    /**************************Static Variables**********************************/

    /**************************State Control Variables**********************************/
    public static boolean mainHasRun = false;
    public static boolean inProgressHasRun = false;
    
    /**************************Constructors**********************************************/
    
    /**************************Execution Control - Entry Points**********************************/
    public void MainEntry(TriggerDispatch.TriggerContext tc){
system.debug('***SMSTemplateTriggerHandler.MainEntry');
       
        mainHasRun = true;
            
        if(tc.handler == 'SMSTemplateTriggerHandler' && tc.isBefore && tc.isInsert) onBeforeInsert(tc);
        else if(tc.handler == 'SMSTemplateTriggerHandler' && tc.isBefore && tc.isUpdate) onBeforeUpdate(tc);
        else if(tc.handler == 'SMSTemplateTriggerHandler' && tc.isBefore && tc.isDelete) onBeforeDelete(tc);
        
        //the following lines should theoretically never be called but could be called from a simulated transaction
        else if(tc.handler == 'SMSTemplateTriggerHandler' && tc.isAfter && tc.isInsert) onAfterInsert(tc);
        else if(tc.handler == 'SMSTemplateTriggerHandler' && tc.isAfter && tc.isUpdate) onAfterUpdate(tc);
        else if(tc.handler == 'SMSTemplateTriggerHandler' && tc.isAfter && tc.isDelete) onAfterDelete(tc);
        else if(tc.handler == 'SMSTemplateTriggerHandler' && tc.isAfter && tc.isUndelete) onAfterUndelete(tc);
            

    }
    public void InProgressEntry(TriggerDispatch.TriggerContext tc){
system.debug('***SMSTemplateTriggerHandler.InProgressEntry');

        inProgressHasRun = true;
    
         //Call Desired Functions - Or Not - Given this is InProgressEntry
        if(tc.handler == 'SMSTemplateTriggerHandler' && tc.isBefore && tc.isInsert) onBeforeInsert(tc);
        else if(tc.handler == 'SMSTemplateTriggerHandler' && tc.isBefore && tc.isUpdate) onBeforeUpdate(tc);
        else if(tc.handler == 'SMSTemplateTriggerHandler' && tc.isBefore && tc.isDelete) onBeforeDelete(tc);
        else if(tc.handler == 'SMSTemplateTriggerHandler' && tc.isAfter && tc.isInsert) onAfterInsert(tc);
        else if(tc.handler == 'SMSTemplateTriggerHandler' && tc.isAfter && tc.isUpdate) onAfterUpdate(tc);
        else if(tc.handler == 'SMSTemplateTriggerHandler' && tc.isAfter && tc.isDelete) onAfterDelete(tc);
        else if(tc.handler == 'SMSTemplateTriggerHandler' && tc.isAfter && tc.isUndelete) onAfterUndelete(tc);
        
        //This is where to decide whether or not to allow other triggers to fire based upon DML on other handlerects
        else if(tc.handler != 'SMSTemplateTriggerHandler'){
            //Determine what to do with other triggers - either kill them or forward them along
            TriggerDispatch.forwardTrigger(tc, this);               
        }

    }
    
    public void onBeforeInsert(TriggerDispatch.TriggerContext tc){
system.debug('***SMSTemplateTriggerHandler.onBeforeInsert');

       //Recast the trigger context variables into the appropriate shandlerect types
        List<SMS_Template__c> newSMSTemplateList = (List<SMS_Template__c>)tc.newList;
        //This is where you should call your business logic

        copyFirstQuestion(newSMSTemplateList);
    }
    public void onBeforeUpdate(TriggerDispatch.TriggerContext tc){
system.debug('***SMSTemplateTriggerHandler.onBeforeUpdate');

        //Recast the trigger context variables into the appropriate shandlerect types
        List<SMS_Template__c> newSMSTemplateList = (List<SMS_Template__c>)tc.newList;
        List<SMS_Template__c> oldSMSTemplateList = (List<SMS_Template__c>)tc.oldList;
        Map<ID, SMS_Template__c> newSMSTemplateMap = (Map<ID, SMS_Template__c>)tc.newMap;
        Map<ID, SMS_Template__c> oldSMSTemplateMap = (Map<ID, SMS_Template__c>)tc.oldMap;
        //This is where you should call your business logic

        copyFirstQuestion(newSMSTemplateList);
        
    }
    public void onBeforeDelete(TriggerDispatch.TriggerContext tc){
       //Recast the trigger context variables into the appropriate shandlerect types
        List<SMS_Template__c> oldSMSTemplateList = (List<SMS_Template__c>)tc.oldList;
        Map<ID, SMS_Template__c> oldSMSTemplateMap = (Map<ID, SMS_Template__c>)tc.oldMap;
        //This is where you should call your business logic
        
  
    }
    
    /****************************After logic****************************************/
    public void onAfterInsert(TriggerDispatch.TriggerContext tc){
         //Recast the trigger context variables into the appropriate shandlerect types
        List<SMS_Template__c> newSMSTemplateList = (List<SMS_Template__c>)tc.newList;
        Map<ID, SMS_Template__c> newSMSTemplateMap = (Map<ID, SMS_Template__c>)tc.newMap;
        //This is where you should call your business logic

        }
    public void onAfterUpdate(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<SMS_Template__c> newSMSTemplateList = (List<SMS_Template__c>)tc.newList;
        List<SMS_Template__c> oldSMSTemplateList = (List<SMS_Template__c>)tc.oldList;
        Map<ID, SMS_Template__c> newSMSTemplateMap = (Map<ID, SMS_Template__c>)tc.newMap;
        Map<ID, SMS_Template__c> oldSMSTemplateMap = (Map<ID, SMS_Template__c>)tc.oldMap;
        //This is where you should call your business logic

    }
    
    public void onAfterDelete(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<SMS_Template__c> oldSMSTemplateList = (List<SMS_Template__c>)tc.oldList;
        Map<ID, SMS_Template__c> oldSMSTemplateMap = (Map<ID, SMS_Template__c>)tc.oldMap;
        //This is where you should call your business logic

     }
    public void onAfterUndelete(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<SMS_Template__c> newSMSTemplateList = (List<SMS_Template__c>)tc.newList;
        Map<ID, SMS_Template__c> newSMSTemplateMap = (Map<ID, SMS_Template__c>)tc.newMap;
        //This is where you should call your business logic
        
    }
    
    private void copyFirstQuestion(List<SMS_Template__c> newSMSTemplateList){
system.debug('***SMSTemplateTriggerHandler.copyFirstQuestion');

        //determine which template need to have the first questions copied over
        Set<ID> formTemplateIDs = new Set<ID>();
        for(SMS_Template__c smsTemplate : newSMSTemplateList){
            if(!String.isEmpty(smsTemplate.FormTemplate__c)){
                formTemplateIDs.add(smsTemplate.FormTemplate__c);
            }
        }
        SystemContext sc = new SystemContext();
        Map<ID, QuestionTemplate__c> firstQuestions = new Map<ID, QuestionTemplate__c>(sc.queryFirstQuestions(formTemplateIDs));

        Map<ID, QuestionTemplate__c> firstQuestionsByFormTemplateID = new Map<ID, QuestionTemplate__c>();
        for(QuestionTemplate__c question : firstQuestions.values()){
            firstQuestionsByFormTemplateID.put(question.FormTemplate__c, question);
        }

        for(SMS_Template__c smsTemplate : newSMSTemplateList){
            if(!String.isEmpty(smsTemplate.FormTemplate__c)){
                smsTemplate.Text__c = firstQuestionsByFormTemplateID.get(smsTemplate.FormTemplate__c).Message_Text__c;
            }
        }
    }


    public without sharing class SystemContext{
        public List<QuestionTemplate__c> queryFirstQuestions(Set<ID> formTemplateIDs){
            if((Schema.sObjectType.QuestionTemplate__c.isAccessible()) &&
               (Schema.sObjectType.QuestionTemplate__c.fields.Message_Text__c.isAccessible())&&
               (Schema.sObjectType.QuestionTemplate__c.fields.FormTemplate__c.isAccessible())&&                
               (Schema.sObjectType.QuestionTemplate__c.fields.FirstQuestion__c.isAccessible())){
                return [SELECT id, Name, Message_Text__c, FormTemplate__c, FirstQuestion__c
                        FROM QuestionTemplate__c where FormTemplate__c = :formTemplateIDs and FirstQuestion__c = true LIMIT 50000];
            } else {
                return null;
            }
 

        }
    }




 }