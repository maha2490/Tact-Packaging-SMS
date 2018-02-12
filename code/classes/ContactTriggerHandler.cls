public with sharing class ContactTriggerHandler implements TriggerDispatch.ITriggerClass{

    /**************************Static Variables**********************************/

    /**************************State Control Variables**********************************/
    public static boolean mainHasRun = false;
    public static boolean inProgressHasRun = false;
    public static boolean hasSent = false;
    /**************************Constructors**********************************************/
    
    /**************************Execution Control - Entry Points**********************************/
    public void MainEntry(TriggerDispatch.TriggerContext tc){       
        mainHasRun = true;
            
        if(tc.handler == 'ContactTriggerHandler' && tc.isBefore && tc.isInsert) onBeforeInsert(tc);
        else if(tc.handler == 'ContactTriggerHandler' && tc.isBefore && tc.isUpdate) onBeforeUpdate(tc);
        else if(tc.handler == 'ContactTriggerHandler' && tc.isBefore && tc.isDelete) onBeforeDelete(tc);
        
        //the following lines should theoretically never be called but could be called from a simulated transaction
        else if(tc.handler == 'ContactTriggerHandler' && tc.isAfter && tc.isInsert) onAfterInsert(tc);
        else if(tc.handler == 'ContactTriggerHandler' && tc.isAfter && tc.isUpdate) onAfterUpdate(tc);
        else if(tc.handler == 'ContactTriggerHandler' && tc.isAfter && tc.isDelete) onAfterDelete(tc);
        else if(tc.handler == 'ContactTriggerHandler' && tc.isAfter && tc.isUndelete) onAfterUndelete(tc);
            

    }
    public void InProgressEntry(TriggerDispatch.TriggerContext tc){
        inProgressHasRun = true;
    
         //Call Desired Functions - Or Not - Given this is InProgressEntry
        if(tc.handler == 'ContactTriggerHandler' && tc.isBefore && tc.isInsert) onBeforeInsert(tc);
        else if(tc.handler == 'ContactTriggerHandler' && tc.isBefore && tc.isUpdate) onBeforeUpdate(tc);
        else if(tc.handler == 'ContactTriggerHandler' && tc.isBefore && tc.isDelete) onBeforeDelete(tc);
        else if(tc.handler == 'ContactTriggerHandler' && tc.isAfter && tc.isInsert) onAfterInsert(tc);
        else if(tc.handler == 'ContactTriggerHandler' && tc.isAfter && tc.isUpdate) onAfterUpdate(tc);
        else if(tc.handler == 'ContactTriggerHandler' && tc.isAfter && tc.isDelete) onAfterDelete(tc);
        else if(tc.handler == 'ContactTriggerHandler' && tc.isAfter && tc.isUndelete) onAfterUndelete(tc);
        
        //This is where to decide whether or not to allow other triggers to fire based upon DML on other handlerects
        else if(tc.handler != 'ContactTriggerHandler'){
            //Determine what to do with other triggers - either kill them or forward them along
            TriggerDispatch.forwardTrigger(tc, this);               
        }

    }
    
    public void onBeforeInsert(TriggerDispatch.TriggerContext tc){
       //Recast the trigger context variables into the appropriate shandlerect types
        List<Contact> newContactList = (List<Contact>)tc.newList;
        //This is where you should call your business logic

    }
    public void onBeforeUpdate(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<Contact> newContactList = (List<Contact>)tc.newList;
        List<Contact> oldContactList = (List<Contact>)tc.oldList;
        Map<ID, Contact> newContactMap = (Map<ID, Contact>)tc.newMap;
        Map<ID, Contact> oldContactMap = (Map<ID, Contact>)tc.oldMap;
        //This is where you should call your business logic

        
    }
    public void onBeforeDelete(TriggerDispatch.TriggerContext tc){
       //Recast the trigger context variables into the appropriate shandlerect types
        List<Contact> oldContactList = (List<Contact>)tc.oldList;
        Map<ID, Contact> oldContactMap = (Map<ID, Contact>)tc.oldMap;
        //This is where you should call your business logic
        
  
    }
    
    /****************************After logic****************************************/
    public void onAfterInsert(TriggerDispatch.TriggerContext tc){
         //Recast the trigger context variables into the appropriate shandlerect types
        List<Contact> newContactList = (List<Contact>)tc.newList;
        Map<ID, Contact> newContactMap = (Map<ID, Contact>)tc.newMap;
        //This is where you should call your business logic
        
        Map<ID, Contact> contactsToSendSMS = new Map<ID, Contact>();
        for(Contact cont : newContactList){
        	if(!String.isBlank(cont.SMS_Message_To_Send__c)){
        		contactsToSendSMS.put(cont.id, cont);
        	}
        }
        sendSMSFromContact(contactsToSendSMS);
    }
    public void onAfterUpdate(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<Contact> newContactList = (List<Contact>)tc.newList;
        List<Contact> oldContactList = (List<Contact>)tc.oldList;
        Map<ID, Contact> newContactMap = (Map<ID, Contact>)tc.newMap;
        Map<ID, Contact> oldContactMap = (Map<ID, Contact>)tc.oldMap;
        //This is where you should call your business logic
        
        Map<ID, Contact> contactsToSendSMS = new Map<ID, Contact>();
        for(Contact cont : newContactList){
        	if((!String.isBlank(cont.SMS_Message_To_Send__c))&&
        	   (cont.SMS_Message_To_Send__c != oldContactMap.get(cont.id).SMS_Message_To_Send__c)){
        		contactsToSendSMS.put(cont.id, cont);
        	}
        }
        sendSMSFromContact(contactsToSendSMS);
    }
    
    public void onAfterDelete(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<Contact> oldContactList = (List<Contact>)tc.oldList;
        Map<ID, Contact> oldContactMap = (Map<ID, Contact>)tc.oldMap;
        //This is where you should call your business logic

     }
    public void onAfterUndelete(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<Contact> newContactList = (List<Contact>)tc.newList;
        Map<ID, Contact> newContactMap = (Map<ID, Contact>)tc.newMap;
        //This is where you should call your business logic

    }
    private void sendSMSFromContact(Map<ID, Contact> contactsToSendSMS){
        if(!hasSent){
        	List<SMS__c> newSMS = new List<SMS__c>();
        	for(Contact cont : contactsToSendSMS.values()){
        		if((!String.isEmpty(cont.SMS_Message_To_Send__c))&&
    //    		   (!String.isEmpty(cont.MobilePhone))){
                   (!String.isEmpty(cont.Mogli_Number__c))){

        			SMS__c sms = new SMS__c();
        			sms.Contact__c = cont.id;
        			sms.Direction__c = 'Outgoing';
        			sms.Message__c = cont.SMS_Message_To_Send__c;
    //    			sms.Phone_Number__c = cont.MobilePhone;
                    sms.Phone_Number__c = cont.Mogli_Number__c;
        			sms.Status__c = 'Queued';
        			newSMS.add(sms);
        		}
        	}
        	if(newSMS.size()>0){
                if(MogliUtil.respectUserSecurityDML()){
                    if(SMS__c.sObjectType.getDescribe().isCreateable()){
                        Database.insert(newSMS,true);            
                    } else {
                        throw new ContactTriggerHandlerException('ContactTriggerHandler - Insufficient Access to Insert SMS__c');
                    }
                } else {
                    Database.insert(newSMS,true);            
                }
        	}
            hasSent = true;
        } else {
            System.debug('has sent');
        }
    }
    public class ContactTriggerHandlerException extends Exception {}
 }