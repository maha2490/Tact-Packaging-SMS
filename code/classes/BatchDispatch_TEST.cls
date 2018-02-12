@isTest
private class BatchDispatch_TEST {
    @TestSetup
    public static void setupData(){
        TestUtil.setStandardTestConditions();
    }
    
    @isTest
    private static void validateDispatch(){
        List<AsyncApexJob> beforeJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
				                            TotalJobItems, CreatedBy.Email
				                            FROM AsyncApexJob];
        System.assertEquals(beforeJobs.size(), 0, 'No Jobs should exist'); 				                            
        Test.startTest();
    	BatchDispatch.BatchDispatchContext bc = new BatchDispatch.BatchDispatchContext();
        bc.batchHandler = 'BatchDispatch.MockBatchDispatch';
        BatchDispatch job = new BatchDispatch(bc);
    	Database.executeBatch(job);
    	Test.stopTest();
        List<AsyncApexJob> afterJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
				                            TotalJobItems, CreatedBy.Email
				                            FROM AsyncApexJob];
        System.assert(afterJobs.size()>= beforeJobs.size() + 1, afterJobs);    	
    }

}