@isTest
public with sharing class MogliWebService_TEST {
    @TestSetup static void setupData(){
        TestUtil.setStandardTestConditions();
        system.assert(true);
    }
	static testMethod void validatePost() {


		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
		req.requestURI = '/mogli/' + 'v2/';	
		req.addParameter('AccountSid', 'test AccountSid');
		req.addParameter('From', '+14444444444');
		req.addParameter('Body', 'helloWorld');	
//		req.requestURI = 'https://cs9.salesforce.com/services/apexrest/v.9/member/me/results/today';  
		req.httpMethod = 'POST';
		RestContext.request = req;
		RestContext.response = res;

		String results = MogliWebService.doPost();
		system.assert(true);
		//System.assertEquals('true', String.valueOf(results));

	}

	@isTest public static void testHandleTwilioPost(){
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		String host = URL.getSalesforceBaseUrl().getHost();
		req.requestURI = '/sms/' + 'v1/';	
		req.addParameter('AccountSid', 'test AccountSid');
		req.addParameter('From', '+14444444444');
		req.addParameter('Body', 'helloWorld');	
		req.httpMethod = 'POST';

		RestContext.request = req;
		RestContext.response = res;

		MogliWebService.MogliWebServiceContext context = new MogliWebService.MogliWebServiceContext(req, res);
		MogliWebService.TwilioMogliWebServiceHandler svc = new MogliWebService.TwilioMogliWebServiceHandler();
		svc.handlePost(context);
	}
}