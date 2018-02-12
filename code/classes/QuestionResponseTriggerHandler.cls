public with sharing class QuestionResponseTriggerHandler implements TriggerDispatch.ITriggerClass{

    /**************************Static Variables**********************************/

    /**************************State Control Variables**********************************/
    public static boolean mainHasRun = false;
    public static boolean inProgressHasRun = false;
    
    /**************************Constructors**********************************************/
    
    /**************************Execution Control - Entry Points**********************************/
    public void MainEntry(TriggerDispatch.TriggerContext tc){
system.debug('***QuestionResponseTriggerHandler.MainEntry');
       
        mainHasRun = true;
            
        if(tc.handler == 'QuestionResponseTriggerHandler' && tc.isBefore && tc.isInsert) onBeforeInsert(tc);
        else if(tc.handler == 'QuestionResponseTriggerHandler' && tc.isBefore && tc.isUpdate) onBeforeUpdate(tc);
        else if(tc.handler == 'QuestionResponseTriggerHandler' && tc.isBefore && tc.isDelete) onBeforeDelete(tc);
        
        //the following lines should theoretically never be called but could be called from a simulated transaction
        else if(tc.handler == 'QuestionResponseTriggerHandler' && tc.isAfter && tc.isInsert) onAfterInsert(tc);
        else if(tc.handler == 'QuestionResponseTriggerHandler' && tc.isAfter && tc.isUpdate) onAfterUpdate(tc);
        else if(tc.handler == 'QuestionResponseTriggerHandler' && tc.isAfter && tc.isDelete) onAfterDelete(tc);
        else if(tc.handler == 'QuestionResponseTriggerHandler' && tc.isAfter && tc.isUndelete) onAfterUndelete(tc);
            

    }
    public void InProgressEntry(TriggerDispatch.TriggerContext tc){
system.debug('***QuestionResponseTriggerHandler.InProgressEntry');

        inProgressHasRun = true;
    
         //Call Desired Functions - Or Not - Given this is InProgressEntry
        if(tc.handler == 'QuestionResponseTriggerHandler' && tc.isBefore && tc.isInsert) onBeforeInsert(tc);
        else if(tc.handler == 'QuestionResponseTriggerHandler' && tc.isBefore && tc.isUpdate) onBeforeUpdate(tc);
        else if(tc.handler == 'QuestionResponseTriggerHandler' && tc.isBefore && tc.isDelete) onBeforeDelete(tc);
        else if(tc.handler == 'QuestionResponseTriggerHandler' && tc.isAfter && tc.isInsert) onAfterInsert(tc);
        else if(tc.handler == 'QuestionResponseTriggerHandler' && tc.isAfter && tc.isUpdate) onAfterUpdate(tc);
        else if(tc.handler == 'QuestionResponseTriggerHandler' && tc.isAfter && tc.isDelete) onAfterDelete(tc);
        else if(tc.handler == 'QuestionResponseTriggerHandler' && tc.isAfter && tc.isUndelete) onAfterUndelete(tc);
        
        //This is where to decide whether or not to allow other triggers to fire based upon DML on other handlerects
        else if(tc.handler != 'QuestionResponseTriggerHandler'){
            //Determine what to do with other triggers - either kill them or forward them along
            TriggerDispatch.forwardTrigger(tc, this);               
        }

    }
    
    public void onBeforeInsert(TriggerDispatch.TriggerContext tc){
       //Recast the trigger context variables into the appropriate shandlerect types
        List<QuestionResponse__c> newQuestionResponseList = (List<QuestionResponse__c>)tc.newList;
        //This is where you should call your business logic

    }
    public void onBeforeUpdate(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<QuestionResponse__c> newQuestionResponseList = (List<QuestionResponse__c>)tc.newList;
        List<QuestionResponse__c> oldQuestionResponseList = (List<QuestionResponse__c>)tc.oldList;
        Map<ID, QuestionResponse__c> newQuestionResponseMap = (Map<ID, QuestionResponse__c>)tc.newMap;
        Map<ID, QuestionResponse__c> oldQuestionResponseMap = (Map<ID, QuestionResponse__c>)tc.oldMap;
        //This is where you should call your business logic



        
    }
    public void onBeforeDelete(TriggerDispatch.TriggerContext tc){
       //Recast the trigger context variables into the appropriate shandlerect types
        List<QuestionResponse__c> oldQuestionResponseList = (List<QuestionResponse__c>)tc.oldList;
        Map<ID, QuestionResponse__c> oldQuestionResponseMap = (Map<ID, QuestionResponse__c>)tc.oldMap;
        //This is where you should call your business logic
        
  
    }
    
    /****************************After logic****************************************/
    public void onAfterInsert(TriggerDispatch.TriggerContext tc){
         //Recast the trigger context variables into the appropriate shandlerect types
        List<QuestionResponse__c> newQuestionResponseList = (List<QuestionResponse__c>)tc.newList;
        Map<ID, QuestionResponse__c> newQuestionResponseMap = (Map<ID, QuestionResponse__c>)tc.newMap;
        //This is where you should call your business logic

        }
    public void onAfterUpdate(TriggerDispatch.TriggerContext tc){
system.debug('***QuestionResponseTriggerHandler.onAfterUpdate');

        //Recast the trigger context variables into the appropriate shandlerect types
        List<QuestionResponse__c> newQuestionResponseList = (List<QuestionResponse__c>)tc.newList;
        List<QuestionResponse__c> oldQuestionResponseList = (List<QuestionResponse__c>)tc.oldList;
        Map<ID, QuestionResponse__c> newQuestionResponseMap = (Map<ID, QuestionResponse__c>)tc.newMap;
        Map<ID, QuestionResponse__c> oldQuestionResponseMap = (Map<ID, QuestionResponse__c>)tc.oldMap;
        
        //This is where you should call your business logic
        Set<ID> responseIDsToHandle = new Set<ID>();
        for(QuestionResponse__c qr : newQuestionResponseList){
            if((!String.isEmpty(qr.Response__c)) && (String.isEmpty(oldQuestionResponseMap.get(qr.id).Response__c))){
                responseIDsToHandle.add(qr.id); //only add the ids of records whose response was changed from a blank value
            }
        }
        //handleResponse(newQuestionResponseMap.keySet());
        handleResponse(responseIDsToHandle);
    }
    
    public void onAfterDelete(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<QuestionResponse__c> oldQuestionResponseList = (List<QuestionResponse__c>)tc.oldList;
        Map<ID, QuestionResponse__c> oldQuestionResponseMap = (Map<ID, QuestionResponse__c>)tc.oldMap;
        //This is where you should call your business logic

     }
    public void onAfterUndelete(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<QuestionResponse__c> newQuestionResponseList = (List<QuestionResponse__c>)tc.newList;
        Map<ID, QuestionResponse__c> newQuestionResponseMap = (Map<ID, QuestionResponse__c>)tc.newMap;
        //This is where you should call your business logic

    }


    private static void handleResponse(Set<ID> questionResponseIDs){
system.debug('***QuestionResponseTriggerHandler.handleResponse');

system.debug('***RUNNING REHYDRATION QUERY****');

        SystemContext sc = new SystemContext();

        Map<ID, QuestionResponse__c> newQuestionResponsesByID = new Map<ID, QuestionResponse__c>(sc.queryQuestionResponses(questionResponseIDs));

system.debug('newQuestionResponsesByID:'+newQuestionResponsesByID);
        //Get the possible answers to the QuestionTemplates
        Set<ID> questionTemplateIDs = new Set<ID>();
        for(QuestionResponse__c response : newQuestionResponsesByID.values()){
            questionTemplateIDs.add(response.QuestionTemplate__c);
        }

        Map<ID, PossibleAnswer__c> possibleAnswersByID = new Map<ID, PossibleAnswer__c>(sc.queryPossibleAnswers(questionTemplateIDs));

        //Check to see if the answer received is in the list of possible answers
        Map<String, PossibleAnswer__c> possibleAnswerByText = new Map<String, PossibleAnswer__c>();
        for(PossibleAnswer__c answer : possibleAnswersByID.values()){
            //parse the possible text into unique strings
            List<String> possibleAnswers = answer.PossibleText__c.split(MogliSMSSettings.getAppSettings().PossibleAnswerDelimiter__c);
            for(String s: possibleAnswers){
                possibleAnswerByText.put(s.toUpperCase(), answer);
            }
        }
system.debug('newQuestionResponsesByID:'+newQuestionResponsesByID);
system.debug('possibleAnswerByText:'+possibleAnswerByText);     

        List<SMS__c> nextQuestionsToAsk = new List<SMS__c>();
        for(QuestionResponse__c response : newQuestionResponsesByID.values()){
            if(!String.isEmpty(response.Response__c)){ //make sure the response contains a string
                if(possibleAnswerByText.containsKey((response.Response__c).toUpperCase())){
                    //response was found - handle it accordingly
                    if(!String.isEmpty(possibleAnswerByText.get(response.Response__c.toUpperCase()).Next_Question__c)){ //the answer found has a next question
                        if(!String.isEmpty(possibleAnswerByText.get(response.Response__c.toUpperCase()).Next_Question__r.Message_Text__c)){ //the next question has appropriate text
                            SMS__c newQuestion = new SMS__c();

                            newQuestion.Phone_Number__c = response.Form__r.Phone_Number__c;
                            newQuestion.Message__c = possibleAnswerByText.get(response.Response__c.toUpperCase()).Next_Question__r.Message_Text__c;
                            newQuestion.Direction__c = 'Outgoing';
                            newQuestion.Status__c = 'Queued';
                            newQuestion.Offline__c = response.Form__r.Offline__c;
                            newQuestion.Gateway__c = response.Gateway__c;

                            nextQuestionsToAsk.add(newQuestion);
                        }
                    }

                } else {
                    if(!String.isEmpty(response.QuestionTemplate__c)){ //Response has an associated question template
                        if(!String.isEmpty(response.QuestionTemplate__r.DefaultNextQuestion__c)) {//question template has a default next question
                            if(!String.isEmpty(response.QuestionTemplate__r.DefaultNextQuestion__r.Message_Text__c)){ //default question has appropriate text
                                //response was not found but a default question was found - so ask it
                                SMS__c newQuestion = new SMS__c();

                                newQuestion.Phone_Number__c = response.Form__r.Phone_Number__c;
                                newQuestion.Message__c = response.QuestionTemplate__r.DefaultNextQuestion__r.Message_Text__c;
                                newQuestion.Direction__c = 'Outgoing';
                                newQuestion.Status__c = 'Queued';
                                newQuestion.Offline__c = response.Form__r.Offline__c;
                                newQuestion.Gateway__c = response.Gateway__c;

                                nextQuestionsToAsk.add(newQuestion);
                            }
                        } 
                    }
                }           
            }
        }




system.debug('nextQuestionsToAsk:'+nextQuestionsToAsk);
        if(nextQuestionsToAsk.size()>0){
            if(MogliUtil.respectUserSecurityDML()){
                if(SMS__c.sObjectType.getDescribe().isCreateable()){
                    Database.insert(nextQuestionsToAsk,true);            
                } else {
                    throw new QuestionResponseTriggerHandlerException('QuestionResponseTriggerHandler - Insufficient Access to Insert SMS__c');
                }
            } else {
                Database.insert(nextQuestionsToAsk,true);            
            }
        }
    }

    public without sharing class SystemContext{
        public List<QuestionResponse__c> queryQuestionResponses(Set<ID> questionResponseIDs){
system.debug('QuestionResponseTriggerHandler.SystemContext.queryQuestionResponses()');
            if((Schema.sObjectType.QuestionResponse__c.isAccessible()) &&
               (Schema.sObjectType.QuestionResponse__c.fields.Form__c.isAccessible()) &&
               (Schema.sObjectType.QuestionResponse__c.fields.QuestionTemplate__c.isAccessible()) &&
               (Schema.sObjectType.QuestionResponse__c.fields.Question_Text__c.isAccessible()) &&
                (Schema.sObjectType.QuestionResponse__c.fields.Response__c.isAccessible()) &&
                (Schema.sObjectType.Form__c.isAccessible()) &&
                (Schema.sObjectType.Form__c.fields.Phone_Number__c.isAccessible()) &&
//                (Schema.sObjectType.Form__c.fields.Contact__c.isAccessible()) &&
                (Schema.sObjectType.Form__c.fields.Offline__c.isAccessible()) &&
//                (Schema.sObjectType.Contact.isAccessible()) &&   
//                (Schema.sObjectType.Contact.fields.MobilePhone.isAccessible()) &&
                (Schema.sObjectType.QuestionTemplate__c.isAccessible()) &&   
                (Schema.sObjectType.QuestionTemplate__c.fields.DefaultNextQuestion__c.isAccessible()) &&
                (Schema.sObjectType.QuestionTemplate__c.fields.Message_Text__c.isAccessible())){
                    return [SELECT id, Form__c, Form__r.Phone_Number__c, Form__r.Contact__r.MobilePhone, Form__r.Contact__r.Mogli_Number__c, Form__r.Contact__c,
                            Form__r.Offline__c,
                            QuestionTemplate__c, QuestionTemplate__r.DefaultNextQuestion__c,
                            QuestionTemplate__r.DefaultNextQuestion__r.Message_Text__c,
                            Question_Text__c, Response__c, Mogli_Question__c, Mogli_Response__c, Gateway__c 
                            FROM QuestionResponse__c where ID = :questionResponseIDs
                            LIMIT 50000];
            } else {
system.debug('fields not accessible');
                return null;
            }


        }

        public List<PossibleAnswer__c> queryPossibleAnswers(Set<ID> questionTemplateIDs){
system.debug('QuestionResponseTriggerHandler.SystemContext.queryPossibleAnswers()'); 
            if((Schema.sObjectType.PossibleAnswer__c.isAccessible()) &&
               (Schema.sObjectType.PossibleAnswer__c.fields.Next_Question__c.isAccessible()) &&
               (Schema.sObjectType.PossibleAnswer__c.fields.PossibleText__c.isAccessible()) &&
               (Schema.sObjectType.PossibleAnswer__c.fields.QuestionTemplate__c.isAccessible()) &&
                (Schema.sObjectType.QuestionTemplate__c.isAccessible()) &&
                (Schema.sObjectType.QuestionTemplate__c.fields.Message_Text__c.isAccessible())){
                return [SELECT ID, Next_Question__c, PossibleText__c, QuestionTemplate__c,
                        Next_Question__r.Message_Text__c
                        FROM PossibleAnswer__c
                        WHERE QuestionTemplate__c = :questionTemplateIDs
                        LIMIT 50000];            
            } else {
                return null;
            }

        }
    }


    public class QuestionResponseTriggerHandlerException extends Exception {}
 }