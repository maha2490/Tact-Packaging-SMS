public with sharing class FormTriggerHandler implements TriggerDispatch.ITriggerClass{

    /**************************Static Variables**********************************/

    /**************************State Control Variables**********************************/
    public static boolean mainHasRun = false;
    public static boolean inProgressHasRun = false;
//    public static boolean validateOneActiveStatusPerContact = true;
    public static boolean validateOneActiveStatusPerPhone = true;
    
    /**************************Constructors**********************************************/
    
    /**************************Execution Control - Entry Points**********************************/
    public void MainEntry(TriggerDispatch.TriggerContext tc){
system.debug('***FormTriggerHandler.MainEntry');
        mainHasRun = true;
            
        if(tc.handler == 'FormTriggerHandler' && tc.isBefore && tc.isInsert) onBeforeInsert(tc);
        else if(tc.handler == 'FormTriggerHandler' && tc.isBefore && tc.isUpdate) onBeforeUpdate(tc);
        else if(tc.handler == 'FormTriggerHandler' && tc.isBefore && tc.isDelete) onBeforeDelete(tc);
        
        //the following lines should theoretically never be called but could be called from a simulated transaction
        else if(tc.handler == 'FormTriggerHandler' && tc.isAfter && tc.isInsert) onAfterInsert(tc);
        else if(tc.handler == 'FormTriggerHandler' && tc.isAfter && tc.isUpdate) onAfterUpdate(tc);
        else if(tc.handler == 'FormTriggerHandler' && tc.isAfter && tc.isDelete) onAfterDelete(tc);
        else if(tc.handler == 'FormTriggerHandler' && tc.isAfter && tc.isUndelete) onAfterUndelete(tc);
            

    }
    public void InProgressEntry(TriggerDispatch.TriggerContext tc){
system.debug('***FormTriggerHandler.InProgressEntry');

        inProgressHasRun = true;
    
         //Call Desired Functions - Or Not - Given this is InProgressEntry
        if(tc.handler == 'FormTriggerHandler' && tc.isBefore && tc.isInsert) onBeforeInsert(tc);
        else if(tc.handler == 'FormTriggerHandler' && tc.isBefore && tc.isUpdate) onBeforeUpdate(tc);
        else if(tc.handler == 'FormTriggerHandler' && tc.isBefore && tc.isDelete) onBeforeDelete(tc);
        else if(tc.handler == 'FormTriggerHandler' && tc.isAfter && tc.isInsert) onAfterInsert(tc);
        else if(tc.handler == 'FormTriggerHandler' && tc.isAfter && tc.isUpdate) onAfterUpdate(tc);
        else if(tc.handler == 'FormTriggerHandler' && tc.isAfter && tc.isDelete) onAfterDelete(tc);
        else if(tc.handler == 'FormTriggerHandler' && tc.isAfter && tc.isUndelete) onAfterUndelete(tc);
        
        //This is where to decide whether or not to allow other triggers to fire based upon DML on other handlerects
        else if(tc.handler != 'FormTriggerHandler'){
            //Determine what to do with other triggers - either kill them or forward them along
            TriggerDispatch.forwardTrigger(tc, this);               
        }

    }
    
    public void onBeforeInsert(TriggerDispatch.TriggerContext tc){
       //Recast the trigger context variables into the appropriate shandlerect types
        List<Form__c> newFormList = (List<Form__c>)tc.newList;
        //This is where you should call your business logic

    }
    public void onBeforeUpdate(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<Form__c> newFormList = (List<Form__c>)tc.newList;
        List<Form__c> oldFormList = (List<Form__c>)tc.oldList;
        Map<ID, Form__c> newFormMap = (Map<ID, Form__c>)tc.newMap;
        Map<ID, Form__c> oldFormMap = (Map<ID, Form__c>)tc.oldMap;
        //This is where you should call your business logic

        
    }
    public void onBeforeDelete(TriggerDispatch.TriggerContext tc){
       //Recast the trigger context variables into the appropriate shandlerect types
        List<Form__c> oldFormList = (List<Form__c>)tc.oldList;
        Map<ID, Form__c> oldFormMap = (Map<ID, Form__c>)tc.oldMap;
        //This is where you should call your business logic
        
  
    }
    
    /****************************After logic****************************************/
    public void onAfterInsert(TriggerDispatch.TriggerContext tc){
system.debug('***FormTriggerHandler.onAfterInsert');

         //Recast the trigger context variables into the appropriate shandlerect types
        List<Form__c> newFormList = (List<Form__c>)tc.newList;
        Map<ID, Form__c> newFormMap = (Map<ID, Form__c>)tc.newMap;
        //This is where you should call your business logic
        ensureNoMoreThanOneActiveStatusPerPhone(newFormMap);

    }
    public void onAfterUpdate(TriggerDispatch.TriggerContext tc){
system.debug('***FormTriggerHandler.onAfterUpdate');

        //Recast the trigger context variables into the appropriate shandlerect types
        List<Form__c> newFormList = (List<Form__c>)tc.newList;
        List<Form__c> oldFormList = (List<Form__c>)tc.oldList;
        Map<ID, Form__c> newFormMap = (Map<ID, Form__c>)tc.newMap;
        Map<ID, Form__c> oldFormMap = (Map<ID, Form__c>)tc.oldMap;
        //This is where you should call your business logic
        ensureNoMoreThanOneActiveStatusPerPhone(newFormMap);
    }
    
    public void onAfterDelete(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<Form__c> oldFormList = (List<Form__c>)tc.oldList;
        Map<ID, Form__c> oldFormMap = (Map<ID, Form__c>)tc.oldMap;
        //This is where you should call your business logic

     }
    public void onAfterUndelete(TriggerDispatch.TriggerContext tc){
system.debug('***FormTriggerHandler.onAfterUndelete');

        //Recast the trigger context variables into the appropriate shandlerect types
        List<Form__c> newFormList = (List<Form__c>)tc.newList;
        Map<ID, Form__c> newFormMap = (Map<ID, Form__c>)tc.newMap;
        //This is where you should call your business logic
        ensureNoMoreThanOneActiveStatusPerPhone(newFormMap);
    }

    private void ensureNoMoreThanOneActiveStatusPerPhone(Map<ID, Form__c> newFormMap){
system.debug('***FormTriggerHandler.ensureNoMoreThanOneActiveStatusPerPhone');


        if(validateOneActiveStatusPerPhone){
            List<Form__c> formsToUpdate = new List<Form__c>();


            //Get all the active forms from the database for these phone numbers
            Set<ID> contactIDs = new Set<ID>();
            Set<String> phoneNums = new Set<String>();
            for(Form__c form: newFormMap.values()){
                phoneNums.add(form.Phone_Number__c);
            }

            SystemContext sc = new SystemContext();
            Map<ID, Form__c> existingActiveForms = new Map<ID, Form__c>(sc.queryExistingActiveForms(newFormMap.keyset(), phoneNums));

            //sort the list by phone
            Map<String, List<Form__c>> existingActiveFormsByPhone = new Map<String, List<Form__c>>();
            for(Form__c form : existingActiveForms.values()){
                if(!existingActiveFormsByPhone.containsKey(form.Phone_Number__c)){
                    existingActiveFormsByPhone.put(form.Phone_Number__c, new List<Form__c>());
                }
                existingActiveFormsByPhone.get(form.Phone_Number__c).add(form);
            }



            //Build a map of the incoming forms by phone to verify there is no more than one active status per phone within the trigger
            Map<String, List<Form__c>> formsByPhone = new Map<String, List<Form__c>>();
            for(Form__c form : newFormMap.values()){
                if(!formsByPhone.containsKey(form.Phone_Number__c)){
                    formsByPhone.put(form.Phone_Number__c, new List<Form__c>());
                }
                formsByPhone.get(form.Phone_Number__c).add(form);
            }

            //Now iterate through the list ensuring there is only one active status on the form

            for(String phone : formsByPhone.keySet()){
                Boolean foundActiveInTrigger = false;
                ID activeFormID = null;
                for(Form__c form: formsByPhone.get(phone)){
                    if(form.Status__c == MogliSMSSettings.getAppSettings().Active_Form_Instance_Status__c){
                        foundActiveInTrigger = true;
                        activeFormID = form.id;
                        break;
                    }
                }
                if(foundActiveInTrigger){
                    //loop through the trigger structure again and change all the statuses to Blank other than the active one
                    for(Form__c form: formsByPhone.get(phone)){
                        if(form.ID != activeFormID){
                            Form__c formToUpdate = new Form__c(id = form.id, Status__c = '');
                            formsToUpdate.add(formToUpdate);
                        }
                    }
                    //Also loop through the exisitng records and change all the status to Complete  
                    if(existingActiveFormsByPhone.containsKey(phone)){
                        for(Form__c form: existingActiveFormsByPhone.get(phone)){
                            if(form.ID != activeFormID){
                                Form__c formToUpdate = new Form__c(id = form.id, Status__c = MogliSMSSettings.getAppSettings().Complete_Form_Instance_Status__c);
                                formsToUpdate.add(formToUpdate);
                            }
                        }                       
                    }           

                }

            }

            if(formsToUpdate.size() > 0){
                validateOneActiveStatusPerPhone = false; //stop the recurrsion on this function
                if(MogliUtil.respectUserSecurityDML()){
                    if(Form__c.sObjectType.getDescribe().isUpdateable()){
                        Database.update(formsToUpdate,true);            
                    } else {
                        throw new FormTriggerHandlerException('FormTriggerHandler - Insufficient Access to Update Form__c');
                    }
                } else {
                    Database.update(formsToUpdate,true);            
                }
            }
        }

    }


    public without sharing class SystemContext{
        /*These quereies run without sharing so that all of the correct records can be returned regardless of user context*/
/*        public List<Form__c> queryExistingActiveForms(Set<ID> formIDs, Set<ID> contactIDs){
            if((Schema.sObjectType.Form__c.isAccessible()) &&
               (Schema.sObjectType.Form__c.fields.Status__c.isAccessible()) &&
               (Schema.sObjectType.Form__c.fields.Contact__c.isAccessible())){
                return [SELECT id, Contact__c, Status__c
                        FROM Form__c
                        WHERE Contact__c = :contactIDs
                        and Status__c = :MogliSMSSettings.getAppSettings().Active_Form_Instance_Status__c
                        and ID != :formIDs
                        LIMIT 50000];
            } else {
                return null;
            }
        }*/

         public List<Form__c> queryExistingActiveForms(Set<ID> formIDs, Set<String> phoneNums){
system.debug('FormTriggerHandler.SystemContext.queryExistingActiveForms()');
//            if((Schema.sObjectType.Form__c.isAccessible()) &&
//               (Schema.sObjectType.Form__c.fields.Status__c.isAccessible()) &&
//               (Schema.sObjectType.Form__c.fields.Phone_Number__c.isAccessible())){
                return [SELECT id, Phone_Number__c, Status__c
                        FROM Form__c
                        WHERE Phone_Number__c = :phoneNums
                        and Status__c = :MogliSMSSettings.getAppSettings().Active_Form_Instance_Status__c
                        and ID != :formIDs
                        LIMIT 50000];
//            } else {
//system.debug('UserInfo:'+String.valueOf(UserInfo.getUserName()));
//system.debug(Schema.sObjectType.Form__c.isAccessible());
//system.debug(Schema.sObjectType.Form__c.fields.Status__c.isAccessible());
//system.debug(Schema.sObjectType.Form__c.fields.Phone_Number__c.isAccessible());
//system.debug('fields not accessible');
//                return null;
//            }

        }
    }
    public class FormTriggerHandlerException extends Exception {}
 }