@isTest
private class ScheduledDispatch_TEST {
    @TestSetup static void setupData(){
        TestUtil.setStandardTestConditions();
        system.assert(true);
    }
    /////////////////////////////////////////////////////////////////////////
    //Test Case: validateBalance
    /////////////////////////////////////////////////////////////////////////
    @isTest static void validateScheduledDispatch(){

        List<AsyncApexJob> beforeJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                                            TotalJobItems, CreatedBy.Email
                                            FROM AsyncApexJob];
                                     
        Test.startTest();

        ScheduledDispatch.ScheduledDispatchContext scheduledCtx = new ScheduledDispatch.ScheduledDispatchContext();
        ScheduledDispatch scJob = new ScheduledDispatch(scheduledCtx);
        String sch = '0 0 * * * ?'; //run every hour at 11 after
        String jobID = system.schedule('Mock Scheduled Test', sch, scJob);
        Test.stopTest();
        List<AsyncApexJob> afterJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                                            TotalJobItems, CreatedBy.Email
                                            FROM AsyncApexJob];
        System.assert(afterJobs.size()>= beforeJobs.size() + 1, 'Should have more jobs');     
    }
}