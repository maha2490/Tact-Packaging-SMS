public with sharing class OutgoingSMSAsyncHandler {
	public OutgoingSMSAsyncHandler() {
		
	}

	public static void execute(Set<ID> smsIDs){

System.debug('OutgoingSMSAsyncHandler.execute()');
 
system.debug(Limits.getCallouts());
system.debug(Limits.getLimitCallouts())	;


		//Determine the number of sms to send and whether to relaunch the job
		Integer numberToSend = Limits.getLimitCallouts() - Limits.getCallouts();


		SystemContext sc = new SystemContext();
		List<SMS__c> outgoingMessages = sc.queryMessages(smsIDs, numberToSend);
system.debug('outgoingMessages:'+outgoingMessages);
system.debug('smsIDs.size():'+smsIDs.size());
system.debug('numberToSend:'+numberToSend);
		


		//Now send them
		for(SMS__c sms : outgoingMessages){ 
			if(!sms.Offline__c){
				try {
					MogliService.MogliSendSMSInput msg = new MogliService.MogliSendSMSInput(sms.Phone_Number__c, sms.Message__c, sms.Gateway__c);
					MogliService.sendSMS(msg);	
					sms.Status__c = 'Sent Successfully';

				} catch (Exception e) {
					sms.Status__c = 'Error: ' + e.getMessage();
system.debug('***Exception:' + e.getMessage());
				}
	


			}
		}	
		


        if(MogliUtil.respectUserSecurityDML()){
            if(SMS__c.sObjectType.getDescribe().isUpdateable()){
                Database.update(outgoingMessages,true);            
            } else {
                throw new OutgoingSMSAsyncHandlerException('OutgoingSMSAsyncHandler - Insufficient Access to Update SMS__c');
            }
        } else {
            Database.update(outgoingMessages,true); 
        }
system.debug(Limits.getCallouts());
system.debug(Limits.getLimitCallouts())	;

		//Determine whether to relaunch the job
		if (smsIDs.size() > numberToSend){

			List<SMS__c> batchSendSMS = sc.queryMessages(smsIDs, 50000);
			for (SMS__c sms : batchSendSMS){
				sms.Status__c = 'Sending';

			}

	        if(MogliUtil.respectUserSecurityDML()){
	            if(SMS__c.sObjectType.getDescribe().isUpdateable()){
	                Database.update(batchSendSMS,true);            
	            } else {
	                throw new OutgoingSMSAsyncHandlerException('OutgoingSMSAsyncHandler - Insufficient Access to Update SMS__c');
	            }
	        } else {
	            Database.update(outgoingMessages,true); 
	        }


			//Batch the rest
			BatchDispatch.BatchDispatchContext bc = new BatchDispatch.BatchDispatchContext();
			bc.batchHandler = 'SendSMSBatchHandler';
			BatchDispatch job = new BatchDispatch(bc);
			Database.executeBatch(job, 100);


		}	




	}
	public without sharing class SystemContext{
		public List<SMS__c> queryMessages(Set<ID> smsIDS, Integer numberToSend){
system.debug('OutgoingSMSAsyncHandler.SystemContext.queryMessages()');
	        if((Schema.sObjectType.SMS__c.isAccessible()) &&
	           (Schema.sObjectType.SMS__c.fields.Phone_Number__c.isAccessible()) &&
	           (Schema.sObjectType.SMS__c.fields.Offline__c.isAccessible()) &&
	           (Schema.sObjectType.SMS__c.fields.Message__c.isAccessible()) &&
				(Schema.sObjectType.SMS__c.fields.Status__c.isAccessible()) &&
//				(Schema.sObjectType.SMS__c.fields.Contact__c.isAccessible()) &&
				(Schema.sObjectType.SMS__c.fields.Direction__c.isAccessible())){
				return [SELECT id, Offline__c, Phone_Number__c, Message__c, Status__c, Gateway__c,
												Contact__c, Direction__c 
													FROM SMS__c
													WHERE id = :smsIDs and Status__c = 'Queued'
													LIMIT :numberToSend
													FOR UPDATE];
	        } else {

system.debug('UserInfo:'+String.valueOf(UserInfo.getUserName()));
system.debug(Schema.sObjectType.SMS__c.isAccessible());
system.debug(Schema.sObjectType.SMS__c.fields.Phone_Number__c.isAccessible());
system.debug(Schema.sObjectType.SMS__c.fields.Offline__c.isAccessible());
system.debug(Schema.sObjectType.SMS__c.fields.Message__c.isAccessible());
system.debug(Schema.sObjectType.SMS__c.fields.Status__c.isAccessible());
system.debug(Schema.sObjectType.SMS__c.fields.Contact__c.isAccessible());
system.debug(Schema.sObjectType.SMS__c.fields.Direction__c.isAccessible());

system.debug('fields not accessible');
	        	return null;
	        }

		}

	}
	public class OutgoingSMSAsyncHandlerException extends Exception {}
}