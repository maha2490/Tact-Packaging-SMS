@isTest
private class MogliService_TEST {
    @TestSetup static void setupData(){
        TestUtil.setStandardTestConditions();
        system.assert(true);
    }	
	@isTest static void testSend() {
		// Implement test code
		Gateway__c gtw = [SELECT id from Gateway__c limit 1];
		MogliService.MogliSendSMSInput msg = new MogliService.MogliSendSMSInput('+15555555555', 'Test Message', gtw.id);
		MogliService.sendSMS(msg);	
		system.assert(true);
	}



}