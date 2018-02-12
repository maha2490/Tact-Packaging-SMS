public without sharing class SendSMSBatchHandler implements BatchDispatch.IBatchHandlerClass{
//this class has to run without sharing. 

    /////////////////////////////////////////////////////////////////////////
    //Method: getDefaultQuery
    /////////////////////////////////////////////////////////////////////////
    public String getDefaultQuery(){
         if((Schema.sObjectType.SMS__c.isAccessible()) &&
           (Schema.sObjectType.SMS__c.fields.Offline__c.isAccessible()) &&
           (Schema.sObjectType.SMS__c.fields.Phone_Number__c.isAccessible()) &&
           (Schema.sObjectType.SMS__c.fields.Message__c.isAccessible()) &&
           (Schema.sObjectType.SMS__c.fields.Status__c.isAccessible()) &&
//           (Schema.sObjectType.SMS__c.fields.Contact__c.isAccessible()) &&
//           (Schema.sObjectType.SMS__c.fields.Campaign__c.isAccessible()) &&
           (Schema.sObjectType.SMS__c.fields.Direction__c.isAccessible())){
            return 'SELECT id, Offline__c, Gateway__c, Phone_Number__c, Message__c, Status__c, Contact__c, Campaign__c, Direction__c FROM SMS__c WHERE Status__c = \'Sending\'';

        } else {
            return null;
        }
       
     }   
    public void start(BatchDispatch batchJob){
system.debug('SendSMSBatchHandler.start()');
    }


    /////////////////////////////////////////////////////////////////////////////////
    //This boiconter plate code must be in each of the batch handler classes
    ////////////////////////////////////////////////////////////////////////////////
    private BatchDispatch.BatchDispatchContext batchDispatchCtx;

    public String serialize(){
system.debug('SendSMSBatchHandler.serialize()');
        return JSON.serialize(batchDispatchCtx);
    }
    public BatchDispatch.BatchDispatchContext deserialize(String serializedBatchDispatchContext){
system.debug('SendSMSBatchHandler.deserialize()');
        this.batchDispatchCtx = (BatchDispatch.BatchDispatchContext)JSON.deserialize(serializedBatchDispatchContext,
            BatchDispatch.BatchDispatchContext.class);
        return this.batchDispatchCtx;
    }   
    public BatchDispatch.BatchDispatchContext getContext(){
system.debug('SendSMSBatchHandler.getContext()');
        return this.batchDispatchCtx;
    }
    public void setContext(BatchDispatch.BatchDispatchContext batchDispatchCtx){
system.debug('SendSMSBatchHandler.setContext()');
        this.batchDispatchCtx = batchDispatchCtx;
    }

    /////////////////////////////////////////////////////////////////////////
    //Method: execute
    /////////////////////////////////////////////////////////////////////////    
    public void execute(BatchDispatch batchJob, List<sObject> scope){
system.debug('SendSMSBatchHandler.execute()');
		//Lock the records for update
		Set<ID> smsIDs = new Set<ID>();
		for(sObject sobj : scope){
			smsIDs.add(sobj.id);
		}

		SystemContext sc = new SystemContext();
		List<SMS__c> outgoingMessages = sc.queryMessages(smsIDs);
system.debug('outgoingMessages:'+outgoingMessages);
system.debug('smsIDs.size():'+smsIDs.size());


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
                throw new SendSMSBatchHandlerException('SendSMSBatchHandlerException - Insufficient Access to Update SMS__c');
            }
        } else {
            Database.update(outgoingMessages,true); 
        }




    }
    /////////////////////////////////////////////////////////////////////////
    //Method: finish
    /////////////////////////////////////////////////////////////////////////
    public void finish(BatchDispatch batchJob){
system.debug('SendSMSBatchHandler.finish()');


    }
	public without sharing class SystemContext{
		public List<SMS__c> queryMessages(Set<ID> smsIDS){

            if((Schema.sObjectType.SMS__c.isAccessible()) &&
            (Schema.sObjectType.SMS__c.fields.Offline__c.isAccessible()) &&
            (Schema.sObjectType.SMS__c.fields.Phone_Number__c.isAccessible()) &&
            (Schema.sObjectType.SMS__c.fields.Message__c.isAccessible()) &&
            (Schema.sObjectType.SMS__c.fields.Status__c.isAccessible()) &&
//            (Schema.sObjectType.SMS__c.fields.Contact__c.isAccessible()) &&
//            (Schema.sObjectType.SMS__c.fields.Campaign__c.isAccessible()) &&
            (Schema.sObjectType.SMS__c.fields.Direction__c.isAccessible())){
                return [SELECT id, Offline__c, Phone_Number__c, Message__c, Status__c,
                                                Contact__c, Campaign__c, Direction__c, Gateway__c 
                                                    FROM SMS__c
                                                    WHERE id = :smsIDs and Status__c = 'Sending'
                                                    LIMIT 100 
                                                    FOR UPDATE]; //100 is the callout limit
            } else {
                return null;
            }


		}

	}

    public class SendSMSBatchHandlerException extends Exception {}
}