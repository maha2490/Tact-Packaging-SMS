public with sharing class SetupCTRL {
    public Integer scheduleFrequency {get;set;}

    public SetupCTRL(){
        scheduleFrequency = 10;
    }
    public PageReference scheduleSMSCleanupUtil(){
        try{

            Integer numberOfJobs = 60 / scheduleFrequency;
system.debug(numberOfJobs);

            if(numberOfJobs > 0){
                for(Integer i = 0; i<numberOfJobs; i++){
                    ScheduledDispatch.ScheduledDispatchContext scheduledCtx = new ScheduledDispatch.ScheduledDispatchContext();
                    scheduledCtx.scheduledHandler = 'SMSCleanupUtilityScheduledHandler';
                    ScheduledDispatch scJob = new ScheduledDispatch(scheduledCtx);
                    String sch = '0 ' + String.valueOf(i*scheduleFrequency) + ' * * * ?'; 
                    String jobID = system.schedule('MogliSMS - SMS Cleanup Utility '+ String.valueOf(i+1), sch, scJob);


                }                
            }




/*

            ScheduledDispatch.ScheduledDispatchContext scheduledCtx1 = new ScheduledDispatch.ScheduledDispatchContext();
            scheduledCtx1.scheduledHandler = 'SMSCleanupUtilityScheduledHandler';
            ScheduledDispatch scJob1 = new ScheduledDispatch(scheduledCtx1);
            String sch1 = '0 0 * * * ?'; 
            String jobID1 = system.schedule('MogliSMS - SMS Cleanup Utility 1', sch1, scJob1);
            
            ScheduledDispatch.ScheduledDispatchContext scheduledCtx2 = new ScheduledDispatch.ScheduledDispatchContext();
            scheduledCtx2.scheduledHandler = 'SMSCleanupUtilityScheduledHandler';
            ScheduledDispatch scJob2 = new ScheduledDispatch(scheduledCtx2);
            String sch2 = '0 10 * * * ?'; 
            String jobID2 = system.schedule('MogliSMS - SMS Cleanup Utility 2', sch2, scJob2);
            
            ScheduledDispatch.ScheduledDispatchContext scheduledCtx3 = new ScheduledDispatch.ScheduledDispatchContext();
            scheduledCtx3.scheduledHandler = 'SMSCleanupUtilityScheduledHandler';
            ScheduledDispatch scJob3 = new ScheduledDispatch(scheduledCtx3);
            String sch3 = '0 20 * * * ?';
            String jobID3 = system.schedule('MogliSMS - SMS Cleanup Utility 3', sch3, scJob3);
            
            ScheduledDispatch.ScheduledDispatchContext scheduledCtx4 = new ScheduledDispatch.ScheduledDispatchContext();
            scheduledCtx4.scheduledHandler = 'SMSCleanupUtilityScheduledHandler';
            ScheduledDispatch scJob4 = new ScheduledDispatch(scheduledCtx4);
            String sch4 = '0 30 * * * ?'; 
            String jobID4 = system.schedule('MogliSMS - SMS Cleanup Utility 4', sch4, scJob4);
            
            ScheduledDispatch.ScheduledDispatchContext scheduledCtx5 = new ScheduledDispatch.ScheduledDispatchContext();
            scheduledCtx5.scheduledHandler = 'SMSCleanupUtilityScheduledHandler';
            ScheduledDispatch scJob5 = new ScheduledDispatch(scheduledCtx5);
            String sch5 = '0 40 * * * ?'; 
            String jobID5 = system.schedule('MogliSMS - SMS Cleanup Utility 5', sch5, scJob5);
            
            ScheduledDispatch.ScheduledDispatchContext scheduledCtx6 = new ScheduledDispatch.ScheduledDispatchContext();
            scheduledCtx6.scheduledHandler = 'SMSCleanupUtilityScheduledHandler';
            ScheduledDispatch scJob6 = new ScheduledDispatch(scheduledCtx6);
            String sch6 = '0 50 * * * ?'; 
            String jobID6 = system.schedule('MogliSMS - SMS Cleanup Utility 6', sch6, scJob6);     */       
        } catch (Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error!! '+e.getMessage());
            ApexPages.addMessage(myMsg);
        }

        return null;
    }

    public PageReference unscheduleSMSCleanupUtil(){
        try{
            String JOB_NAME = 'MogliSMS - SMS Cleanup Utility%';
            List<CronJobDetail> cronDetails =  [SELECT Id, Name, JobType FROM CronJobDetail WHERE Name like :JOB_NAME];
system.debug(cronDetails);
            Set<ID> cronTriggerIDs = new Set<ID>();
            for(CronJobDetail cjd : cronDetails){
                cronTriggerIDs.add(cjd.id);

                 
            }
            List<CronTrigger> abort_job = [SELECT id from CronTrigger where CronJobDetailId = :cronTriggerIDs];
system.debug(abort_job);
            for(CronTrigger ct : abort_job){
system.debug('abort job');
                system.abortJob(ct.id);     
            } 

        } catch (Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error!! '+e.getMessage());
            ApexPages.addMessage(myMsg);            
        }
        return null;
    }
}