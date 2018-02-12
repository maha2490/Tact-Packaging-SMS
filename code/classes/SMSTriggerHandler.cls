public with sharing class SMSTriggerHandler implements TriggerDispatch.ITriggerClass{

    /**************************Static Variables**********************************/

    /**************************State Control Variables**********************************/
    public static boolean mainHasRun = false;
    public static boolean inProgressHasRun = false;
    
    /**************************Constructors**********************************************/
    
    /**************************Execution Control - Entry Points**********************************/
    public void MainEntry(TriggerDispatch.TriggerContext tc){       
        mainHasRun = true;
            
        if(tc.handler == 'SMSTriggerHandler' && tc.isBefore && tc.isInsert) onBeforeInsert(tc);
        else if(tc.handler == 'SMSTriggerHandler' && tc.isBefore && tc.isUpdate) onBeforeUpdate(tc);
        else if(tc.handler == 'SMSTriggerHandler' && tc.isBefore && tc.isDelete) onBeforeDelete(tc);
        
        //the following lines should theoretically never be called but could be called from a simulated transaction
        else if(tc.handler == 'SMSTriggerHandler' && tc.isAfter && tc.isInsert) onAfterInsert(tc);
        else if(tc.handler == 'SMSTriggerHandler' && tc.isAfter && tc.isUpdate) onAfterUpdate(tc);
        else if(tc.handler == 'SMSTriggerHandler' && tc.isAfter && tc.isDelete) onAfterDelete(tc);
        else if(tc.handler == 'SMSTriggerHandler' && tc.isAfter && tc.isUndelete) onAfterUndelete(tc);
            

    }
    public void InProgressEntry(TriggerDispatch.TriggerContext tc){
        inProgressHasRun = true;
    
         //Call Desired Functions - Or Not - Given this is InProgressEntry
        if(tc.handler == 'SMSTriggerHandler' && tc.isBefore && tc.isInsert) onBeforeInsert(tc);
        else if(tc.handler == 'SMSTriggerHandler' && tc.isBefore && tc.isUpdate) onBeforeUpdate(tc);
        else if(tc.handler == 'SMSTriggerHandler' && tc.isBefore && tc.isDelete) onBeforeDelete(tc);
        else if(tc.handler == 'SMSTriggerHandler' && tc.isAfter && tc.isInsert) onAfterInsert(tc);
        else if(tc.handler == 'SMSTriggerHandler' && tc.isAfter && tc.isUpdate) onAfterUpdate(tc);
        else if(tc.handler == 'SMSTriggerHandler' && tc.isAfter && tc.isDelete) onAfterDelete(tc);
        else if(tc.handler == 'SMSTriggerHandler' && tc.isAfter && tc.isUndelete) onAfterUndelete(tc);
        
        //This is where to decide whether or not to allow other triggers to fire based upon DML on other handlerects
        else if(tc.handler != 'SMSTriggerHandler'){
            //Determine what to do with other triggers - either kill them or forward them along
            TriggerDispatch.forwardTrigger(tc, this);               
        }

    }
    
    public void onBeforeInsert(TriggerDispatch.TriggerContext tc){
       //Recast the trigger context variables into the appropriate shandlerect types
        List<SMS__c> newSMSList = (List<SMS__c>)tc.newList;
        //This is where you should call your business logic

        //Set the defaults if they are blank
        Set<ID> contactIDs = new Set<ID>();
        Set<ID> leadIDs = new Set<ID>();
        for(SMS__c sms : newSMSList){
            //Get the contact phone numbers just in case
            contactIDs.add(sms.Contact__c);
            leadIDs.add(sms.Lead__c);
        }
        SystemContext sc = new SystemContext();
        Map<ID, Contact> contactsByID = new Map<ID, Contact>(sc.queryContacts(contactIDs));
        Map<ID, Lead> leadsByID = new Map<ID, Lead>(sc.queryLeads(leadIDs));


        for(SMS__c sms : newSMSList){
            if(contactsByID.containsKey(sms.Contact__c)){
                sms.Message__c = parseReplacements(sms.Message__c, '{{', '}}', contactsByID.get(sms.Contact__c), null);
                sms.Status__c = (contactsByID.get(sms.Contact__c).Mogli_Opt_Out__c ? 'Opted Out' : sms.Status__c);
            } else if(leadsByID.containsKey(sms.Lead__c)){
                sms.Message__c = parseReplacements(sms.Message__c, '{{', '}}', null, leadsByID.get(sms.Lead__c));
                sms.Status__c = (leadsByID.get(sms.Lead__c).Mogli_Opt_Out__c ? 'Opted Out' : sms.Status__c);
            }
            Boolean useDefaultGateway = false;
            if(!String.isBlank(sms.Contact__c)){
                if(String.isBlank(sms.Phone_Number__c)){
                    if(contactsByID.containsKey(sms.Contact__c)){
                        sms.Phone_Number__c = contactsByID.get(sms.Contact__c).Mogli_Number__c;
                    }
                }
                if(String.isBlank(sms.Gateway__c)){
                    if(contactsByID.containsKey(sms.Contact__c)){
                        if(String.isNotBlank(contactsByID.get(sms.Contact__c).Default_Gateway__c)){
                            sms.Gateway__c = contactsByID.get(sms.Contact__c).Default_Gateway__c;                            
                        } else {
                            useDefaultGateway = true;
                        }
                    } else {
                        useDefaultGateway = true;
                    }
                }
            }
            if(!String.isBlank(sms.Lead__c)){
                if(String.isBlank(sms.Phone_Number__c)){
                    if(leadsByID.containsKey(sms.Lead__c)){
    //                    sms.Phone_Number__c = leadsByID.get(sms.Lead__c).MobilePhone;
                        sms.Phone_Number__c = leadsByID.get(sms.Lead__c).Mogli_Number__c;
                    }                
                }
                if(String.isBlank(sms.Gateway__c)){
                    if(leadsByID.containsKey(sms.Lead__c)){
                        if(String.isNotBlank(leadsByID.get(sms.Lead__c).Default_Gateway__c)){
                            sms.Gateway__c = leadsByID.get(sms.Lead__c).Default_Gateway__c;                            
                        } else {
                            useDefaultGateway = true;
                        }
                    } else {
                        useDefaultGateway = true;
                    }
                }                
            }
            if(useDefaultGateway){
                sms.Gateway__c = MogliSMSSettings.getAppSettings().DefaultGateway__c;
            }
            if(String.isBlank(sms.Direction__c)){
                sms.Direction__c = 'Outgoing';
            }
            if((String.isBlank(sms.Status__c)) && (sms.Direction__c == 'Outgoing')){
                sms.Status__c = 'Queued';
            }
        }


    }
    public void onBeforeUpdate(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<SMS__c> newSMSList = (List<SMS__c>)tc.newList;
        List<SMS__c> oldSMSList = (List<SMS__c>)tc.oldList;
        Map<ID, SMS__c> newSMSMap = (Map<ID, SMS__c>)tc.newMap;
        Map<ID, SMS__c> oldSMSMap = (Map<ID, SMS__c>)tc.oldMap;
        //This is where you should call your business logic

        
    }
    public void onBeforeDelete(TriggerDispatch.TriggerContext tc){
       //Recast the trigger context variables into the appropriate shandlerect types
        List<SMS__c> oldSMSList = (List<SMS__c>)tc.oldList;
        Map<ID, SMS__c> oldSMSMap = (Map<ID, SMS__c>)tc.oldMap;
        //This is where you should call your business logic
        
  
    }
    
    /****************************After logic****************************************/
    public void onAfterInsert(TriggerDispatch.TriggerContext tc){
         //Recast the trigger context variables into the appropriate shandlerect types
        List<SMS__c> newSMSList = (List<SMS__c>)tc.newList;
        Map<ID, SMS__c> newSMSMap = (Map<ID, SMS__c>)tc.newMap;
        //This is where you should call your business logic
        
        Map<ID, SMS__C> outgoingQueuedSMSByID = new Map<ID, SMS__C>();
        Map<ID, SMS__c> incomingReceivedSMSByIDs = new Map<ID, SMS__C>();
        for(SMS__c sms : newSMSList){
        	if((sms.Direction__c == 'Outgoing') && (sms.Status__c == 'Queued')){
        		outgoingQueuedSMSByID.put(sms.id, sms);
        	}
        	if((sms.Direction__c == 'Incoming') && (sms.Status__c == 'Received Successfully')){
        		incomingReceivedSMSByIDs.put(sms.id, sms);
        	}
        }
        if(outgoingQueuedSMSByID.size()>0){
        	handleOutgoingQueued(outgoingQueuedSMSByID);
            insertNewFormsAndQuestionsFromOutgoingSMS(outgoingQueuedSMSByID);        	
        }
        if(incomingReceivedSMSByIDs.size()>0){
            captureQuestionResponseOnInbound(incomingReceivedSMSByIDs);
            insertNewFormsFromIncomingSMS(incomingReceivedSMSByIDs);           
        }
    }
    public void onAfterUpdate(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<SMS__c> newSMSList = (List<SMS__c>)tc.newList;
        List<SMS__c> oldSMSList = (List<SMS__c>)tc.oldList;
        Map<ID, SMS__c> newSMSMap = (Map<ID, SMS__c>)tc.newMap;
        Map<ID, SMS__c> oldSMSMap = (Map<ID, SMS__c>)tc.oldMap;
        //This is where you should call your business logic
        Map<ID, SMS__C> outgoingQueuedSMSByID = new Map<ID, SMS__C>();
        Map<ID, SMS__c> incomingReceivedSMSByIDs = new Map<ID, SMS__C>();
        Map<ID, SMS__c> outgoingSendingSMSByID = new Map<ID, SMS__c>();
        for(SMS__c sms : newSMSList){
            if(sms.Status__c != oldSMSMap.get(sms.id).Status__c){
                if((sms.Direction__c == 'Outgoing') && (sms.Status__c == 'Queued')){
                    outgoingQueuedSMSByID.put(sms.id, sms);
                }
                if((sms.Direction__c == 'Outgoing') && (sms.Status__c == 'Sending')){//batch
                    outgoingSendingSMSByID.put(sms.id, sms);
                }
                if((sms.Direction__c == 'Incoming') && (sms.Status__c == 'Received Successfully')){
                    incomingReceivedSMSByIDs.put(sms.id, sms);
                }                
            }

        }
        if(outgoingQueuedSMSByID.size()>0){
        	handleOutgoingQueued(outgoingQueuedSMSByID);         	
        }
        if(outgoingSendingSMSByID.size()>0){
            insertNewFormsAndQuestionsFromOutgoingSMS(outgoingSendingSMSByID);             
        }


    }
    
    public void onAfterDelete(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<SMS__c> oldSMSList = (List<SMS__c>)tc.oldList;
        Map<ID, SMS__c> oldSMSMap = (Map<ID, SMS__c>)tc.oldMap;
        //This is where you should call your business logic

     }
    public void onAfterUndelete(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<SMS__c> newSMSList = (List<SMS__c>)tc.newList;
        Map<ID, SMS__c> newSMSMap = (Map<ID, SMS__c>)tc.newMap;
        //This is where you should call your business logic

    }
    private static void handleOutgoingQueued(Map<ID, SMS__c> outgoingSMSByID){
    	//Send these messages.  Determine how many need to be sent and use the correct mechanism

    	//Following code assumes there is less to go outbound then the remaining number of callouts
		OutgoingSMSAsync2 job = new OutgoingSMSAsync2(outgoingSMSByID.keySet());
		if(!Test.isRunningTest()){
			system.enqueueJob(job);
		}
    }

    private void insertNewFormsAndQuestionsFromOutgoingSMS(Map<ID, SMS__c> newOutgoingSMSMap){
system.debug('***OutgoingSMSTriggerHandler.insertNewFormsAndQuestionsFromOutgoingSMS');

        //Loop thrrough each new outgoing SMS and see if it is a new form being initiated
        
//        //First collect all of the outgoing messages and see if they match aginst SMSTemplates that are tied to forms
system.debug('Runnning Query');


        SystemContext sc = new SystemContext();
        Map<ID, SMS_Template__c> smsPossibleSMSTemplatesByID = new Map<ID, SMS_Template__c>(sc.queryPossibleSMSTemplates());

system.debug('smsPossibleSMSTemplatesByID:'+smsPossibleSMSTemplatesByID);

        Map<ID, SMS_Template__c> matchingSMSTemplatesBySMSID = new Map<ID, SMS_Template__c>();
        for(SMS__c sms : newOutgoingSMSMap.values()){
            for(SMS_Template__c template : smsPossibleSMSTemplatesByID.values()){
                if(sms.Message__c == template.Text__c){
                    matchingSMSTemplatesBySMSID.put(sms.id, template);
                    break;
                }
            }
        }

        //for any matches found, initiate a new form for the contact on the sms
        List<Form__c> newForms = new List<Form__c>();
        for(ID smsId : matchingSMSTemplatesBySMSID.keySet()){

            if(!String.isEmpty(newOutgoingSMSMap.get(smsId).Phone_Number__c)){
                //Create a new form for the Phone Number
                Form__c newForm = new Form__c();
                newForm.Contact__c = newOutgoingSMSMap.get(smsId).Contact__c;

                newForm.FormTemplate__c = matchingSMSTemplatesBySMSID.get(smsId).FormTemplate__c;
                newForm.Status__c = MogliSMSSettings.getAppSettings().Active_Form_Instance_Status__c;
                newForm.Phone_Number__c = newOutgoingSMSMap.get(smsId).Phone_Number__c;
                newForm.Contact__c = newOutgoingSMSMap.get(smsId).Contact__c; //watch for this on b4l for security purposes
                newForm.Lead__c = newOutgoingSMSMap.get(smsId).Lead__c;//watch for this on b4l for security purposes
                if(newOutgoingSMSMap.get(smsId).Offline__c){
                    newForm.Offline__c = true;
                }
                newForms.add(newForm);
            }
        }
system.debug('newForms:'+newForms);
        if(newForms.size()>0){
            if(MogliUtil.respectUserSecurityDML()){
                if(Form__c.sObjectType.getDescribe().isCreateable()){
                    Database.insert(newForms,true);            
                } else {
                    throw new SMSTriggerHandlerException('SMSTriggerHandler - Insufficient Access to Insert Form__c');
                }
            } else {
                Database.insert(newForms,true);            
            }

        }
        //debugging code here
        Set<ID> formIDs = new Set<ID>();
        for(Form__c frm : newForms){
            system.debug('frm:'+frm);
         	formIDs.add(frm.id);
        }//end debugging
        //Now get the latest forms for the contacts.
        //If the message is one of the possible questions from the active form template it should be captured as a question instance
        Set<String> phoneNumbers = new Set<String>();
        for(SMS__c sms : newOutgoingSMSMap.values()){
            phoneNumbers.add(sms.Phone_Number__c);
        }


        Map<ID, Form__c> currentFormsByID = new Map<ID, Form__c>(sc.queryCurrentFormsByPhoneNumbers(phoneNumbers));


system.debug('currentFormsByID:'+currentFormsByID);

        //Sort forms by the phone numbers
        Map<String, Form__c> currentFormsByPhoneNumber = new Map<String, Form__c>();
        for(Form__c form : currentFormsByID.values()){
            currentFormsByPhoneNumber.put(form.Phone_Number__c, form);
        }

        //Get the question templates corresponding to the formTemplates being used
        Set<ID> formTemplateIDs = new Set<ID>();
        for(Form__c form : currentFormsByID.values()){
            formTemplateIDs.add(form.FormTemplate__c);
        }

        Map<ID, QuestionTemplate__c> questionTemplatesByIDs = new Map<ID, QuestionTemplate__c>(sc.queryQuestionTemplates(formTemplateIDs));


system.debug('questionTemplatesByIDs:'+questionTemplatesByIDs);

        //Sort the questions by the message_text
        Map<String, QuestionTemplate__c> questionTemplatesByMessage = new Map<String, QuestionTemplate__c>();
        for(QuestionTemplate__c questionT : questionTemplatesByIDs.values()){
            questionTemplatesByMessage.put(questionT.Message_Text__c, questionT);
        }

        //Loop through the incoming smss and decide what action, if any to take
        Set<ID> formIDsToComplete = new Set<ID>();
        List<QuestionResponse__c> questionsToCreate = new List<QuestionResponse__c>();
        for(SMS__c sms : newOutgoingSMSMap.values()){
system.debug('***:'+currentFormsByPhoneNumber);            
            if(currentFormsByPhoneNumber.containsKey(sms.Phone_Number__c)){
                if(questionTemplatesByMessage.containsKey(sms.Message__c)){ //matches the text from the question template
                    //make sure the current form for the contact is the same form as the matching template
    system.debug(sms.Phone_Number__c);
    system.debug(sms.Message__c);
    system.debug(currentFormsByPhoneNumber.get(sms.Phone_Number__c).FormTemplate__c);
    system.debug(questionTemplatesByMessage.get(sms.Message__c).FormTemplate__c);           
                    if((currentFormsByPhoneNumber.get(sms.Phone_Number__c).FormTemplate__c) == (questionTemplatesByMessage.get(sms.Message__c).FormTemplate__c)){
                          //its a match to a question template on the active form - so copy the question to the question instance
                        questionsToCreate.add(new QuestionResponse__c(QuestionTemplate__c = questionTemplatesByMessage.get(sms.Message__c).id,
                                                                      Question_Text__c = sms.Message__c,
                                                                      Mogli_Question__c = sms.id,
                                                                      Gateway__c = sms.Gateway__c,
                                                                        Form__c = currentFormsByPhoneNumber.get(sms.Phone_Number__c).id));
                        if(questionTemplatesByMessage.get(sms.Message__c).FormComplete__c){
                            //the current form should be closed based upon the FormComplete flag

                            formIDsToComplete.add(currentFormsByPhoneNumber.get(sms.Phone_Number__c).id);
                        }
                    }
                }                
            }
    
        }

system.debug('questionsToCreate:'+questionsToCreate);
        if(questionsToCreate.size()>0){

            if(MogliUtil.respectUserSecurityDML()){
                if(QuestionResponse__c.sObjectType.getDescribe().isCreateable()){
                    Database.insert(questionsToCreate,true);            
                } else {
                    throw new SMSTriggerHandlerException('SMSTriggerHandler - Insufficient Access to Insert QuestionResponse__c');
                }
            } else {
                Database.insert(questionsToCreate,true);            
            }

        }
system.debug('formIDsToComplete:'+formIDsToComplete);
        if(formIDsToComplete.size()>0){
            completeForms(formIDsToComplete);
        }
    }

    private void insertNewFormsFromIncomingSMS(Map<ID, SMS__c> newIncomingSMSMap){
system.debug('***OutgoingSMSTriggerHandler.insertNewFormsFromIncomingSMS');

        //Loop thrrough each new incoming SMS and see if it is a new form being initiated
        
        //First collect all of the incoming messages and see if they match aginst SMSTemplates that are tied to forms
system.debug('Runnning Query');


        SystemContext sc = new SystemContext();
        Map<ID, SMS_Template__c> smsPossibleSMSTemplatesByID = new Map<ID, SMS_Template__c>(sc.queryPossibleSMSTemplates());

system.debug('smsPossibleSMSTemplatesByID:'+smsPossibleSMSTemplatesByID);

        Map<ID, SMS_Template__c> matchingSMSTemplatesBySMSID = new Map<ID, SMS_Template__c>();
        for(SMS__c sms : newIncomingSMSMap.values()){
            for(SMS_Template__c template : smsPossibleSMSTemplatesByID.values()){
                if(String.isNotEmpty(sms.Message__c)){
                    if(sms.Message__c.equalsIgnoreCase(template.FormTemplate__r.Query_String__c)){
                        matchingSMSTemplatesBySMSID.put(sms.id, template);
                        break;
                    }                    
                }
            }
        }
system.debug('matchingSMSTemplatesBySMSID'+matchingSMSTemplatesBySMSID);

        //for any matches found, initiate a new form for the contact on the sms
        List<SMS__c> newSMSs = new List<SMS__c>();
        for(ID smsId : matchingSMSTemplatesBySMSID.keySet()){
            if(!String.isEmpty(newIncomingSMSMap.get(smsId).Phone_Number__c)){
                //Create a new SMS for the Phone Number
                SMS__c newSMS = new SMS__c();
                newSMS.Message__c = matchingSMSTemplatesBySMSID.get(smsId).Text__c;
                newSMS.Direction__c = 'Outgoing';
                newSMS.Status__c = 'Queued';
                newSMS.Phone_Number__c = newIncomingSMSMap.get(smsId).Phone_Number__c;
                newSMS.Contact__c = newIncomingSMSMap.get(smsId).Contact__c; //watch for this on b4l for security purposes
                newSMS.Lead__c = newIncomingSMSMap.get(smsId).Lead__c;//watch for this on b4l for security purposes
                if(newIncomingSMSMap.get(smsId).Offline__c){
                    newSMS.Offline__c = true;
                }
                newSMS.Gateway__c = newIncomingSMSMap.get(smsID).Gateway__c;

                newSMSs.add(newSMS);
            }
        }





        if(newSMSs.size()>0){
            if(MogliUtil.respectUserSecurityDML()){
                if(SMS__c.sObjectType.getDescribe().isCreateable()){
                    Database.insert(newSMSs,true);            
                } else {
                    throw new SMSTriggerHandlerException('SMSTriggerHandlerException - Insufficient Access to Insert SMS__c');
                }
            } else {
                Database.insert(newSMSs,true);            
            }
        }
    }




    private static void completeForms(Set<ID> formIDsToComplete){
system.debug('***OutgoingSMSTriggerHandler.completeForms');


        CompleteFormsAsync job = new CompleteFormsAsync(formIDsToComplete);
        system.enqueueJob(job);
    }


    private void captureQuestionResponseOnInbound(Map<ID, SMS__c> newIncomingSMSMap){
system.debug('***IncomingSMSTriggerHandler.captureQuestionResponse');

        //Get the latest questions for all of the active forms on these contacts
        Set<String> phoneNumbers = new Set<String>();
        for(SMS__c sms : newIncomingSMSMap.values()){
            phoneNumbers.add(sms.Phone_Number__c);
        }

system.debug('Running Query');

        SystemContext sc = new SystemContext();
//Removing link to contact to test for b4l         
//        Map<ID, QuestionResponse__c> activeQuestionsByID = new Map<ID, QuestionResponse__c>(sc.queryActiveQuestions(contactIDs));
        Map<ID, QuestionResponse__c> activeQuestionsByID = new Map<ID, QuestionResponse__c>(sc.queryActiveQuestionsByPhoneNumbers(phoneNumbers));

system.debug('activeQuestionsByID:'+activeQuestionsByID);

//system.debug('activeQuestionsByContactID:'+activeQuestionsByContactID);
        //Order by Phone_Number__c
        Map<String, List<QuestionResponse__c>> activeQuestionsByPhoneNumber = new Map<String, List<QuestionResponse__c>>();
        for(QuestionResponse__c question : activeQuestionsByID.values()){
            if(!activeQuestionsByPhoneNumber.containsKey(question.Form__r.Phone_Number__c)){
                activeQuestionsByPhoneNumber.put(question.Form__r.Phone_Number__c, new List<QuestionResponse__c>());
            }
            activeQuestionsByPhoneNumber.get(question.Form__r.Phone_Number__c).add(question);
        }
system.debug('activeQuestionsByPhoneNumber:'+activeQuestionsByPhoneNumber);

        //Make sure there is only one question per contact

        Map<String, QuestionResponse__c> mostRecentQuestionByPhoneNumber = new Map<String, QuestionResponse__c>();
        for(String phoneNumber : activeQuestionsByPhoneNumber.keySet()){
            DateTime mostRecentDate = null;
            ID mostRecentQuestionID = null;
            for(QuestionResponse__c question : activeQuestionsByPhoneNumber.get(phoneNumber)){
                if(mostRecentDate == null) {
                    mostRecentDate = question.CreatedDate;
                    mostRecentQuestionID = question.Id;
                } else {
                    if(question.CreatedDate > mostRecentDate){
                        mostRecentDate = question.CreatedDate;
                        mostRecentQuestionID = question.ID;
                    }
                }
            }
            mostRecentQuestionByPhoneNumber.put(phoneNumber, activeQuestionsByID.get(mostRecentQuestionID));
        }

system.debug('mostRecentQuestionByPhoneNumber:'+mostRecentQuestionByPhoneNumber);


        //Now handle the responses
        List<QuestionResponse__c> questionsToUpdate = new List<QuestionResponse__c>();
        for(SMS__c sms : newIncomingSMSMap.values()){
            if(mostRecentQuestionByPhoneNumber.containsKey(sms.Phone_Number__c)){
                questionsToUpdate.add(new QuestionResponse__c(id = mostRecentQuestionByPhoneNumber.get(sms.Phone_Number__c).id,
                                                                Response__c = sms.Message__c,
                                                                Mogli_Response__c = sms.id,
                                                                Gateway__c = sms.Gateway__c));
            }
        }
system.debug('questionsToUpdate:'+questionsToUpdate);
        if(questionsToUpdate.size()>0){

            if(MogliUtil.respectUserSecurityDML()){
                if(QuestionResponse__c.sObjectType.getDescribe().isUpdateable()){
                    Database.update(questionsToUpdate,true);            
                } else {
                    throw new SMSTriggerHandlerException('SMSTriggerHandler - Insufficient Access to Update QuestionResponse__c');
                }
            } else {
                Database.update(questionsToUpdate,true);            
            }
        }

    }

    public static String parseReplacements(String str, String delimBegin, String delimEnd, Contact cont, Lead ld){
        String returnString = str;
        system.debug('str:'+str);
        if(str != null && str.contains('{{') && str.contains('}}')){
            List<String> segments = new List<String>();
            system.debug('str:'+str);
            system.debug('str.length:'+str.length());
            for(Integer i = 0; i<str.length(); null){
                String currentSegment = str.substring(i, str.length());
                system.debug('currentSegment:'+currentSegment);
                String newSegment = '';
                //system.debug('i:'+i);
                //system.debug('charAt(str, i):'+charAt(str, i));
                if(MogliStringUtil.charAt(str, i) == '{' && MogliStringUtil.charAt(str, i+1) == '{'){
                    system.debug('found replacementSegment');
                    //found the beginning of a segment.  
                    system.debug('subString.indexOf(}}:'+currentSegment.indexOf('}}'));
                    if(currentSegment.indexOf('}}') != -1){
                        //found an end of the segment
                        //Capture the entire segment and move the pointer
                        newSegment = currentSegment.substringBetween('{{','}}');
                        i = i+newSegment.length()+4;
                       // try{
                            if(cont != null){
                                //attempt to replace the segnent with the info on the contact
                                newSegment = String.valueOf(cont.get(newSegment));                          
                            } else if(ld != null){
                                newSegment = String.valueOf(ld.get(newSegment));    
                            }
                     //   } catch (Exception e){
                     //       system.debug(e.getMessage());
                     //       return returnString;
                    //    }
                        segments.add(newSegment);
                        system.debug('newSegment:'+newSegment);
        
                    } else {
                        //didn't find the end of the replacement - so just advance the pointer
                        i++;
                    }
                } else {
                    //not a replacement - capture the substring up until the length of the next replacement
                    system.debug('NOT a replacement segment');
                    //system.debug('subString before({{):'+currentSegment.substringBefore('{{'));
                    newSegment = currentSegment.subStringBefore('{{');
                    system.debug('newSegment:'+newSegment);
                    segments.add(newSegment);
                    //advance the counter until the beginning of the next segment
                    i = i+newSegment.length();
                    system.debug('new i ='+i);

                }
            }

            returnString = '';
            for(String st : segments){
                returnString += st;
            }
            //system.debug('segments:'+segments);
            system.debug('returnString:'+returnString);
            return returnString;

        } else {
            return str;
        }
    }


    public without sharing class SystemContext{
        public List<QuestionResponse__c> queryActiveQuestions(Set<ID> contactIDs){
            return [SELECT id, Form__c, QuestionTemplate__c, Question_Text__c, Response__c, CreatedDate, Form__r.Contact__c 
                    FROM QuestionResponse__c
                    WHERE Form__r.Status__c = :MogliSMSSettings.getAppSettings().Active_Form_Instance_Status__c
                    and Form__r.Contact__c = :contactIDs
                    LIMIT 50000];
        }
        public List<QuestionResponse__c> queryActiveQuestionsByPhoneNumbers(Set<String> phoneNumbers){
            return [SELECT id, Form__c, QuestionTemplate__c, Question_Text__c, Response__c, CreatedDate, Form__r.Phone_Number__c 
                    FROM QuestionResponse__c
                    WHERE Form__r.Status__c = :MogliSMSSettings.getAppSettings().Active_Form_Instance_Status__c
                    and Form__r.Phone_Number__c = :phoneNumbers
                    LIMIT 50000];
        }


        public List<SMS_Template__c> queryPossibleSMSTemplates(){
            return [SELECT id, Name__c, Text__c, FormTemplate__c, FormTemplate__r.Status__c, FormTemplate__r.Query_String__c
                     FROM SMS_Template__c
                     WHERE FormTemplate__c != null
                     and FormTemplate__r.Status__c = 'Active'
                     LIMIT 50000];
        }
        public List<Form__c> queryCurrentForms(Set<ID> contactIDs){
            return [SELECT id, Contact__c, Status__c, FormTemplate__c
                    FROM Form__c
                    WHERE Contact__c = :contactIDs
                    and Status__c = :MogliSMSSettings.getAppSettings().Active_Form_Instance_Status__c
                    LIMIT 50000];
        }

        public List<Form__c> queryCurrentFormsByPhoneNumbers(Set<String> phoneNumbers){
            return [SELECT id, Lead__c, Phone_Number__c, Contact__c, Status__c, FormTemplate__c
                    FROM Form__c
                    WHERE Phone_Number__c = :phoneNumbers
                    and Status__c = :MogliSMSSettings.getAppSettings().Active_Form_Instance_Status__c
                    LIMIT 50000];
        }





        public List<QuestionTemplate__c> queryQuestionTemplates(Set<ID> formTemplateIDs){
            return [SELECT id, DefaultNextQuestion__c, FirstQuestion__c, FormComplete__c, FormTemplate__c, Message_Text__c
                    FROM QuestionTemplate__c
                    WHERE FormTemplate__c = :formTemplateIDs
                    LIMIT 50000];
        }
        public List<Lead> queryLeads(Set<ID> leadIDs){
            String query = 'SELECT id, MobilePhone, Mogli_Number__c, Mogli_Opt_Out__c, Default_Gateway__c';
            if(String.isNotEmpty(MogliSMSSettings.getAppSettings().LeadMergeFields__c)){
                query += ', ' + MogliSMSSettings.getAppSettings().LeadMergeFields__c;
            }
            query += ' from Lead where ID = :leadIDs LIMIT 50000';
            system.debug(query);


            return (List<Lead>)database.query(query);
        }
        public List<Contact> queryContacts(Set<ID> contactIDs){
            String query = 'SELECT id, MobilePhone, Mogli_Number__c, Mogli_Opt_Out__c, Default_Gateway__c';
            if(String.isNotEmpty(MogliSMSSettings.getAppSettings().ContactMergeFields__c)){
                query += ', ' + MogliSMSSettings.getAppSettings().ContactMergeFields__c;
            }
            query += ' from Contact where ID = :contactIDs LIMIT 50000';
            system.debug(query);


            return (List<Contact>)database.query(query);
        }
    }

    public class SMSTriggerHandlerException extends Exception {}
 }