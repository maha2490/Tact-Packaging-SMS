@isTest
public with sharing class AttachmentTriggerHandler_TEST {
	@TestSetup
	public static void setupData(){
		TestUtil.setStandardTestConditions();
	}

	@isTest
	public static void validateAttachmentTrigger(){
		SMS__c msg = new SMS__c(Direction__c = 'Inbound');
		insert msg;
		Attachment attachment = new Attachment(Name='An attachment',body=blob.valueof('b'),parentId=msg.Id);
		insert attachment;		
	}

}