public with sharing class GatewayUtil {
	public static Map<ID, Gateway__c> gatewayMap = new Map<ID, Gateway__c>([SELECT id,
																				   Name,
																				   RecordTypeID,
																				   DisplaySequence__c,
																				   Inactive__c,
																				   WebhookIdentifier__c,
																				   CustomSMSServiceHandler__c,
																				   CustomWebServiceHandler__c,
																				   PhoneNumber__c,
																				   TwilioAccountSid__c,
																				   TwilioAuthToken__c
																		 	FROM Gateway__c
																		 	WHERE Inactive__c = false
																		 	Order By DisplaySequence__c
																		 	LIMIT 50000]);
	public static Map<String, Gateway__c> gatewayByWebhook = new Map<String, Gateway__c>();
	public static Map<String, Gateway__c> gatewayByName = new Map<String, Gateway__c>();
	static {
		for(Gateway__c gtw : gatewayMap.values()){
			gatewayByWebhook.put(gtw.WebhookIdentifier__c, gtw);
			gatewayByName.put(gtw.Name, gtw);
		}
	}
}