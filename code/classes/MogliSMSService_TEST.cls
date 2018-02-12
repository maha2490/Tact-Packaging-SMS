@isTest
private class MogliSMSService_TEST {
    @TestSetup static void setupData(){
        TestUtil.setStandardTestConditions();
        system.assert(true);
    }	
	@isTest static void testSend() {
		// Implement test code
		MogliSMSService.MogliSendSMSInput msg = new MogliSMSService.MogliSendSMSInput('+15555555555', 'Test Message');
		MogliSMSService.sendSMS(msg);	
		system.assert(true);
	}



}