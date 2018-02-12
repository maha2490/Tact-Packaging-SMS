public with sharing class LeadTriggerHandler implements TriggerDispatch.ITriggerClass{

    /**************************Static Variables**********************************/

    /**************************State Control Variables**********************************/
    public static boolean mainHasRun = false;
    public static boolean inProgressHasRun = false;
    public static boolean sendSMSFromLeadHasRun = false;
    
    /**************************Constructors**********************************************/
    
    /**************************Execution Control - Entry Points**********************************/
    public void MainEntry(TriggerDispatch.TriggerContext tc){       
        mainHasRun = true;
            
        if(tc.handler == 'LeadTriggerHandler' && tc.isBefore && tc.isInsert) onBeforeInsert(tc);
        else if(tc.handler == 'LeadTriggerHandler' && tc.isBefore && tc.isUpdate) onBeforeUpdate(tc);
        else if(tc.handler == 'LeadTriggerHandler' && tc.isBefore && tc.isDelete) onBeforeDelete(tc);
        
        //the following lines should theoretically never be called but could be called from a simulated transaction
        else if(tc.handler == 'LeadTriggerHandler' && tc.isAfter && tc.isInsert) onAfterInsert(tc);
        else if(tc.handler == 'LeadTriggerHandler' && tc.isAfter && tc.isUpdate) onAfterUpdate(tc);
        else if(tc.handler == 'LeadTriggerHandler' && tc.isAfter && tc.isDelete) onAfterDelete(tc);
        else if(tc.handler == 'LeadTriggerHandler' && tc.isAfter && tc.isUndelete) onAfterUndelete(tc);
            

    }
    public void InProgressEntry(TriggerDispatch.TriggerContext tc){
        inProgressHasRun = true;
    
         //Call Desired Functions - Or Not - Given this is InProgressEntry
        if(tc.handler == 'LeadTriggerHandler' && tc.isBefore && tc.isInsert) onBeforeInsert(tc);
        else if(tc.handler == 'LeadTriggerHandler' && tc.isBefore && tc.isUpdate) onBeforeUpdate(tc);
        else if(tc.handler == 'LeadTriggerHandler' && tc.isBefore && tc.isDelete) onBeforeDelete(tc);
        else if(tc.handler == 'LeadTriggerHandler' && tc.isAfter && tc.isInsert) onAfterInsert(tc);
        else if(tc.handler == 'LeadTriggerHandler' && tc.isAfter && tc.isUpdate) onAfterUpdate(tc);
        else if(tc.handler == 'LeadTriggerHandler' && tc.isAfter && tc.isDelete) onAfterDelete(tc);
        else if(tc.handler == 'LeadTriggerHandler' && tc.isAfter && tc.isUndelete) onAfterUndelete(tc);
        
        //This is where to decide whether or not to allow other triggers to fire based upon DML on other handlerects
        else if(tc.handler != 'LeadTriggerHandler'){
            //Determine what to do with other triggers - either kill them or forward them along
            TriggerDispatch.forwardTrigger(tc, this);               
        }

    }
    
    public void onBeforeInsert(TriggerDispatch.TriggerContext tc){
       //Recast the trigger context variables into the appropriate shandlerect types
        List<Lead> newLeadList = (List<Lead>)tc.newList;
        //This is where you should call your business logic

    }
    public void onBeforeUpdate(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<Lead> newLeadList = (List<Lead>)tc.newList;
        List<Lead> oldLeadList = (List<Lead>)tc.oldList;
        Map<ID, Lead> newLeadMap = (Map<ID, Lead>)tc.newMap;
        Map<ID, Lead> oldLeadMap = (Map<ID, Lead>)tc.oldMap;
        //This is where you should call your business logic

        
    }
    public void onBeforeDelete(TriggerDispatch.TriggerContext tc){
       //Recast the trigger context variables into the appropriate shandlerect types
        List<Lead> oldLeadList = (List<Lead>)tc.oldList;
        Map<ID, Lead> oldLeadMap = (Map<ID, Lead>)tc.oldMap;
        //This is where you should call your business logic
        
  
    }
    
    /****************************After logic****************************************/
    public void onAfterInsert(TriggerDispatch.TriggerContext tc){
         //Recast the trigger context variables into the appropriate shandlerect types
        List<Lead> newLeadList = (List<Lead>)tc.newList;
        Map<ID, Lead> newLeadMap = (Map<ID, Lead>)tc.newMap;
        //This is where you should call your business logic
        
        Map<ID, Lead> leadsToSendSMS = new Map<ID, Lead>();
        for(Lead ld : newLeadList){
        	if(!String.isBlank(ld.SMS_Message_To_Send__c)){
        		leadsToSendSMS.put(ld.id, ld);
        	}
        }
        sendSMSFromLead(leadsToSendSMS);
    }
    public void onAfterUpdate(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<Lead> newLeadList = (List<Lead>)tc.newList;
        List<Lead> oldLeadList = (List<Lead>)tc.oldList;
        Map<ID, Lead> newLeadMap = (Map<ID, Lead>)tc.newMap;
        Map<ID, Lead> oldLeadMap = (Map<ID, Lead>)tc.oldMap;
        //This is where you should call your business logic
        
        Map<ID, Lead> leadsToSendSMS = new Map<ID, Lead>();
        for(Lead ld : newLeadList){
        	if((!String.isBlank(ld.SMS_Message_To_Send__c))&&
        	   (ld.SMS_Message_To_Send__c != oldLeadMap.get(ld.id).SMS_Message_To_Send__c)){
        		leadsToSendSMS.put(ld.id, ld);
        	}
        }
        sendSMSFromLead(leadsToSendSMS);
    }
    
    public void onAfterDelete(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<Lead> oldLeadList = (List<Lead>)tc.oldList;
        Map<ID, Lead> oldLeadMap = (Map<ID, Lead>)tc.oldMap;
        //This is where you should call your business logic

     }
    public void onAfterUndelete(TriggerDispatch.TriggerContext tc){
        //Recast the trigger context variables into the appropriate shandlerect types
        List<Lead> newLeadList = (List<Lead>)tc.newList;
        Map<ID, Lead> newLeadMap = (Map<ID, Lead>)tc.newMap;
        //This is where you should call your business logic

    }
    private void sendSMSFromLead(Map<ID, Lead> leadsToSendSMS){
System.debug('LeadTriggerHandler.sendSMSFromLead()');
    	List<SMS__c> newSMS = new List<SMS__c>();
        if(!sendSMSFromLeadHasRun){
            for(Lead ld : leadsToSendSMS.values()){
                if((!String.isEmpty(ld.SMS_Message_To_Send__c))&&
    //             (!String.isEmpty(ld.MobilePhone))){
                   (!String.isEmpty(ld.Mogli_Number__c))){
                    SMS__c sms = new SMS__c();
                    sms.Lead__c = ld.id;
                    sms.Direction__c = 'Outgoing';
                    sms.Message__c = ld.SMS_Message_To_Send__c;
                    sms.Phone_Number__c = ld.Mogli_Number__c;
                    sms.Status__c = 'Queued';
                    newSMS.add(sms);
                }
            }
            if(newSMS.size()>0){
                if(MogliUtil.respectUserSecurityDML()){
                    if(SMS__c.sObjectType.getDescribe().isCreateable()){
                        Database.insert(newSMS,true);            
                    } else {
                        throw new LeadTriggerHandlerException('LeadTriggerHandler - Insufficient Access to Insert SMS__c');
                    }
                } else {
                    Database.insert(newSMS,true);            
                }
            }          
        }
        sendSMSFromLeadHasRun = true;

    }
    public class LeadTriggerHandlerException extends Exception {}
 }