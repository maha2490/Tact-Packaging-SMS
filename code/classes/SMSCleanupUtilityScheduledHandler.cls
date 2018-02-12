public with sharing class SMSCleanupUtilityScheduledHandler implements ScheduledDispatch.IScheduledHandlerClass{

    /////////////////////////////////////////////////////////////////////////////////
    //This boilder plate code must be in each of the scheduled handler classes
    ////////////////////////////////////////////////////////////////////////////////
    private ScheduledDispatch.ScheduledDispatchContext scheduledDispatchCtx;

    public String serialize(){
system.debug('SMSCleanupUtilityScheduledHandler.serialize()');
        return JSON.serialize(scheduledDispatchCtx);
    }
    public ScheduledDispatch.ScheduledDispatchContext deserialize(String serializedScheduledDispatchContext){
system.debug('SMSCleanupUtilityScheduledHandler.deserialize()');
        this.scheduledDispatchCtx = (ScheduledDispatch.ScheduledDispatchContext)JSON.deserialize(serializedScheduledDispatchContext,
            ScheduledDispatch.ScheduledDispatchContext.class);
        return this.scheduledDispatchCtx;
    }   
    public ScheduledDispatch.ScheduledDispatchContext getContext(){
system.debug('SMSCleanupUtilityScheduledHandler.getContext()');
        return this.scheduledDispatchCtx;
    }
    public void setContext(ScheduledDispatch.ScheduledDispatchContext scheduledDispatchCtx){
system.debug('SMSCleanupUtilityScheduledHandler.setContext()');
        this.scheduledDispatchCtx = scheduledDispatchCtx;
    }


    public void execute(ScheduledDispatch ths){
system.debug('SMSCleanupUtilityScheduledHandler.execute()');

        MogliService.AssociateSMS job = new MogliService.AssociateSMS();
        System.enqueueJob(job);
        MogliService.AssociateForms job2 = new MogliService.AssociateForms();
        System.enqueueJob(job2);
        MogliService.SendScheduledSMS job3 = new MogliService.SendScheduledSMS();
        System.enqueueJob(job3);       
        MogliService.RetryDelayedSMS job4 = new MogliService.RetryDelayedSMS();
        System.enqueueJob(job4); 
	}



	/*To Schedule:

ScheduledDispatch.ScheduledDispatchContext scheduledCtx = new ScheduledDispatch.ScheduledDispatchContext();
scheduledCtx.scheduledHandler = 'SMSCleanupUtilityScheduledHandler';
ScheduledDispatch scJob = new ScheduledDispatch(scheduledCtx);
String sch = '0 0 * * * ?'; //run every hour at 11 after
String jobID = system.schedule('MogliSMS - SMS Cleanup Utility', sch, scJob);




	*/
}