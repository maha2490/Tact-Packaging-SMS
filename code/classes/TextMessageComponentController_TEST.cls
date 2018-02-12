@isTest
public class TextMessageComponentController_TEST {

	@TestSetup static void setupData(){
        TestUtil.setStandardTestConditions();
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Mogli_Number__c ='+7777';
        insert con;

        Gateway__c gat = new Gateway__c();
        gat.Name = 'Default Gateway';
        gat.Inactive__c = false;
        insert gat;

        SMS__c sms = new SMS__c();
        sms.Message__c = 'Test Message';
        sms.Phone_Number__c = '+7777';
        sms.Direction__c = 'Incoming';
        sms.Gateway__c = gat.Id;
        insert sms;


        System.assert(true);
    }


	static testMethod void testGetSMSMessageThread(){
		Contact con = [select Id from Contact where Mogli_Number__c = '+7777' ];
		Test.startTest();
		List<SMS__c> smss = TextMessageComponentController.getSMSMessageThread(con.Id);
		Test.stopTest();
		System.assertEquals(1, smss.size());
	}

	static testMethod void testSendSMSMessage(){
		Contact con = [select Id from Contact where Mogli_Number__c = '+7777' ];
		Test.startTest();
		TextMessageComponentController.sendSMSMessage(con.Id, 'Message', '-Default-');
		Test.stopTest();
		List<SMS__c> smss = [Select Id from SMS__c where Phone_Number__c = '+7777'];
		System.assertEquals(2, smss.size());
	}

	static testMethod void testGetSessionId(){
		Test.startTest();
		String sessionId = TextMessageComponentController.getSessionId();
		Test.stopTest();
	}

	static testMethod void testVerifyMessage(){
		Contact con = [select Id from Contact where Mogli_Number__c = '+7777' ];
		Test.startTest();
		Boolean verified = TextMessageComponentController.verifyMessage(con.Id, '+7777');
		Test.stopTest();
		System.assert(verified);
	}

	static testMethod void testGetOriginationList(){
		Test.startTest();
		List<String> gateways = TextMessageComponentController.getOriginationList();
		Test.stopTest();
		System.assertEquals(3, gateways.size());
	}
    
    static testMethod void testGetSMSTemplates(){
        SMS_Template__c temp = new SMS_Template__c();
        temp.Name__c = 'Template1';
        temp.Text__c = 'Message';
        insert temp;
        Test.startTest();
        List<SMS_Template__c> result = TextMessageComponentController.getSMSTemplates();
        Test.stopTest();
        System.assertEquals(1, result.size());
    }
	
}