public with sharing class AttachmentTriggerHandler implements TriggerDispatch.ITriggerClass {

    /**************************Static Variables***********************************/

    /**************************State Control Variables**********************************/
    public static boolean mainHasRun = false;
    public static boolean inProgressHasRun = false;
    
    /**************************Constructors**********************************************/
    
    /**************************Execution Control - Entry Points**********************************/
    /////////////////////////////////////////////////////////////////////////
    //Method: mainEntry
    /////////////////////////////////////////////////////////////////////////
    public void mainEntry(TriggerDispatch.TriggerContext tc){       
        mainHasRun = true;
            
        if(tc.handler == 'AttachmentTriggerHandler' && tc.isBefore && tc.isInsert) onBeforeInsert(tc);
        else if(tc.handler == 'AttachmentTriggerHandler' && tc.isBefore && tc.isUpdate) onBeforeUpdate(tc);
        else if(tc.handler == 'AttachmentTriggerHandler' && tc.isBefore && tc.isDelete) onBeforeDelete(tc);
        
        //the following lines should theoretically never be called but could be called from a simulated transaction
        else if(tc.handler == 'AttachmentTriggerHandler' && tc.isAfter && tc.isInsert) onAfterInsert(tc);
        else if(tc.handler == 'AttachmentTriggerHandler' && tc.isAfter && tc.isUpdate) onAfterUpdate(tc);
        else if(tc.handler == 'AttachmentTriggerHandler' && tc.isAfter && tc.isDelete) onAfterDelete(tc);
        else if(tc.handler == 'AttachmentTriggerHandler' && tc.isAfter && tc.isUndelete) onAfterUndelete(tc);
            

    }
    /////////////////////////////////////////////////////////////////////////
    //Method: inProgressEntry
    /////////////////////////////////////////////////////////////////////////
    public void inProgressEntry(TriggerDispatch.TriggerContext tc){
        inProgressHasRun = true;
    
         //Call Desired Functions - Or Not - Given this is InProgressEntry
        if(tc.handler == 'AttachmentTriggerHandler' && tc.isBefore && tc.isInsert) onBeforeInsert(tc);
        else if(tc.handler == 'AttachmentTriggerHandler' && tc.isBefore && tc.isUpdate) onBeforeUpdate(tc);
        else if(tc.handler == 'AttachmentTriggerHandler' && tc.isBefore && tc.isDelete) onBeforeDelete(tc);
        else if(tc.handler == 'AttachmentTriggerHandler' && tc.isAfter && tc.isInsert) onAfterInsert(tc);
        else if(tc.handler == 'AttachmentTriggerHandler' && tc.isAfter && tc.isUpdate) onAfterUpdate(tc);
        else if(tc.handler == 'AttachmentTriggerHandler' && tc.isAfter && tc.isDelete) onAfterDelete(tc);
        else if(tc.handler == 'AttachmentTriggerHandler' && tc.isAfter && tc.isUndelete) onAfterUndelete(tc);
        
        //This is where to decide whether or not to allow other triggers to fire based upon DML on other handlerects
        else if(tc.handler != 'AttachmentTriggerHandler'){
            //Determine what to do with other triggers - either kill them or forward them along
            TriggerDispatch.forwardTrigger(tc, this);               
        }

    }
    /////////////////////////////////////////////////////////////////////////
    //Method: onBeforeInsert
    /////////////////////////////////////////////////////////////////////////    
    public void onBeforeInsert(TriggerDispatch.TriggerContext tc){
system.debug('AttachmentTriggerHandler.onBeforeInsert()');
       //Recast the trigger context variables into the appropriate shandlerect types
        List<Attachment> newAttachmentList = (List<Attachment>)tc.newList;
        //This is where you should call your business logic


    }
    /////////////////////////////////////////////////////////////////////////
    //Method: onBeforeUpdate
    /////////////////////////////////////////////////////////////////////////
    public void onBeforeUpdate(TriggerDispatch.TriggerContext tc){
system.debug('AttachmentTriggerHandler.onBeforeUpdate()');
        //Recast the trigger context variables into the appropriate shandlerect types
        List<Attachment> newAttachmentList = (List<Attachment>)tc.newList;
        List<Attachment> oldAttachmentList = (List<Attachment>)tc.oldList;
        Map<ID, Attachment> newAttachmentMap = (Map<ID, Attachment>)tc.newMap;
        Map<ID, Attachment> oldAttachmentMap = (Map<ID, Attachment>)tc.oldMap;
        //This is where you should call your business logic
 
    }
    /////////////////////////////////////////////////////////////////////////
    //Method: onBeforeDelete
    /////////////////////////////////////////////////////////////////////////
    public void onBeforeDelete(TriggerDispatch.TriggerContext tc){
system.debug('AttachmentTriggerHandler.onBeforeDelete()');
       //Recast the trigger context variables into the appropriate shandlerect types
        List<Attachment> oldAttachmentList = (List<Attachment>)tc.oldList;
        Map<ID, Attachment> oldAttachmentMap = (Map<ID, Attachment>)tc.oldMap;
        //This is where you should call your business logic

    }
    
    /****************************After logic****************************************/
    /////////////////////////////////////////////////////////////////////////
    //Method: onAfterInsert
    /////////////////////////////////////////////////////////////////////////
    public void onAfterInsert(TriggerDispatch.TriggerContext tc){
system.debug('AttachmentTriggerHandler.onAfterInsert()');
         //Recast the trigger context variables into the appropriate shandlerect types
        List<Attachment> newAttachmentList = (List<Attachment>)tc.newList;
        Map<ID, Attachment> newAttachmentMap = (Map<ID, Attachment>)tc.newMap;
        //This is where you should call your business logic
		Map<String, Map<ID, Attachment>> attachmentsByObjectType = determineObjectType(newAttachmentMap);

		for(String objectType : attachmentsByObjectType.keyset()){
			if(objectType == 'SMS__c' || objectType == 'Mogli_SMS__SMS__c') handleMogliAttachments(null, newAttachmentMap);
		}

    }
    /////////////////////////////////////////////////////////////////////////
    //Method: onAfterUpdate
    /////////////////////////////////////////////////////////////////////////
    public void onAfterUpdate(TriggerDispatch.TriggerContext tc){
system.debug('AttachmentTriggerHandler.onAfterUpdate()');
        //Recast the trigger context variables into the appropriate shandlerect types
        List<Attachment> newAttachmentList = (List<Attachment>)tc.newList;
        List<Attachment> oldAttachmentList = (List<Attachment>)tc.oldList;
        Map<ID, Attachment> newAttachmentMap = (Map<ID, Attachment>)tc.newMap;
        Map<ID, Attachment> oldAttachmentMap = (Map<ID, Attachment>)tc.oldMap;
        //This is where you should call your business logic
        
        Map<String, Map<ID, Attachment>> attachmentsByObjectType = determineObjectType(newAttachmentMap);
        
		for(String objectType : attachmentsByObjectType.keyset()){
			if(objectType == 'SMS__c' || objectType == 'Mogli_SMS__SMS__c') handleMogliAttachments(null, newAttachmentMap);
		}
   }
    /////////////////////////////////////////////////////////////////////////
    //Method: onAfterDelete
    /////////////////////////////////////////////////////////////////////////    
    public void onAfterDelete(TriggerDispatch.TriggerContext tc){
system.debug('AttachmentTriggerHandler.onAfterDelete()');
        //Recast the trigger context variables into the appropriate shandlerect types
        List<Attachment> oldAttachmentList = (List<Attachment>)tc.oldList;
        Map<ID, Attachment> oldAttachmentMap = (Map<ID, Attachment>)tc.oldMap;
        //This is where you should call your business logic
        Map<String, Map<ID, Attachment>> attachmentsByObjectType = determineObjectType(oldAttachmentMap);
        
		for(String objectType : attachmentsByObjectType.keyset()){
			if(objectType == 'SMS__c' || objectType == 'Mogli_SMS__SMS__c') handleMogliAttachments(oldAttachmentMap, null);
		}
     }
    /////////////////////////////////////////////////////////////////////////
    //Method: onAfterUndelete
    /////////////////////////////////////////////////////////////////////////
    public void onAfterUndelete(TriggerDispatch.TriggerContext tc){
system.debug('AttachmentTriggerHandler.onAfterUndelete()');
        //Recast the trigger context variables into the appropriate shandlerect types
        List<Attachment> newAttachmentList = (List<Attachment>)tc.newList;
        Map<ID, Attachment> newAttachmentMap = (Map<ID, Attachment>)tc.newMap;
        //This is where you should call your business logic
        Map<String, Map<ID, Attachment>> attachmentsByObjectType = determineObjectType(newAttachmentMap);
        
		for(String objectType : attachmentsByObjectType.keyset()){
			if(objectType == 'SMS__c' || objectType == 'Mogli_SMS__SMS__c') handleMogliAttachments(null, newAttachmentMap);
		}        
    }

    
    /////////////////////////////////////////////////////////////////////////
    //Method: handleStudentProgramAttachments
    /////////////////////////////////////////////////////////////////////////
    private void handleMogliAttachments(Map<ID, Attachment> oldAttachmentMap, Map<ID, Attachment> newAttachmentMap){
system.debug('AttachmentTriggerHandler.handleMogliAttachments()'); 
        List<Attachment> attachments = (newAttachmentMap == null ? oldAttachmentMap.values() : newAttachmentMap.values());
        Set<ID> smsIDs = new Set<ID>();
        for(Attachment attach: attachments){
        	smsIDs.add(attach.ParentID);
        }	

		AggregateResult[] groupedResults
		  = [SELECT ParentID, Count(ID)
		      FROM Attachment
		      Where ParentID = :smsIDs
		      GROUP By ParentID];
		System.debug('groupedResults:'+groupedResults);
		Map<ID, Integer> attachmentCountBySMSID = new Map<ID, Integer>();
		List<SMS__c> smsToUpdate = new List<SMS__c>();
		for (AggregateResult ar : groupedResults)  {
		    System.debug('ParentID' + ar.get('ParentID'));
		    System.debug('Count' + ar.get('expr0'));
		    attachmentCountBySMSID.put((ID)ar.get('ParentID'), (Integer)ar.get('expr0'));
		}
		for(ID theID : smsIDs){
			Boolean attachmentsExist = (attachmentCountBySMSID.containsKey(theID) ? true : false);
			smsToUpdate.add(new SMS__c(ID = theID, Attachments__c = attachmentsExist));
		}

		if(smsToUpdate.size()>0){
			update smsToUpdate;
		}
    }  


    /////////////////////////////////////////////////////////////////////////
    //Method: determineObjectType
    /////////////////////////////////////////////////////////////////////////
    private Map<String, Map<ID, Attachment>> determineObjectType(Map<ID, Attachment> attachmentMap){
    	Map<String, Map<ID, Attachment>> attachmentByObjectType = new Map<String, Map<ID, Attachment>>();
	    for(Attachment attach : attachmentMap.values()){
	    	String objectType = String.valueOf(attach.ParentId.getSobjectType());
	    	if(!attachmentByObjectType.containsKey(objectType)) {
	    		attachmentByObjectType.put(objectType, new Map<ID, Attachment>());
	    	}
	    	attachmentByObjectType.get(objectType).put(attach.id, attach);
	    }
	    system.debug('attachmentByObjectType:'+attachmentByObjectType);
	    return attachmentByObjectType;
    }
    public class AttachmentTriggerHandlerException extends Exception {}
}