global with sharing class OutgoingSMSAsync implements Queueable, Database.AllowsCallouts{
	global OutgoingSMSAsync() {
//		this.smsIDs = new List<String>();
	}
/*	global OutgoingSMSAsync(String smsID){
		this.smsIDs = new List<String>();
		this.smsIDs.add(smsID);
	}*/
	global OutgoingSMSAsync(Set<ID> smsIDs){
		this.smsIDs = smsIDs;
	}
	public Set<ID> smsIDs = new Set<ID>();
	public void execute(QueueableContext context){
//List<Log__c> logs = new List<Log__c>();
System.debug('OutgoingSMSAsync.execute()');
//logs.add(new Log__c(Message__c=('OutgoingSMSAsync.execute()'))); 


		SystemContext sc = new SystemContext();
		List<SMS__c> outgoingMessages = sc.queryMessages(smsIDs);

//logs.add(new Log__c(Message__c=('outgoingMessages'+outgoingMessages))); 
		//Now send them
		for(SMS__c sms : outgoingMessages){
			MogliSMSService.MogliSendSMSInput msg = new MogliSMSService.MogliSendSMSInput(sms.Phone_Number__c, sms.Message__c);
			MogliSMSService.sendSMS(msg);		
		}	
		

		for(SMS__c sms : outgoingMessages){
			//Update the status to 'Sent Successfully'
			sms.Status__c = 'Sent Successfully';
		}
		update outgoingMessages;
//logs.add(new Log__c(Message__c=('outgoingMessages'+outgoingMessages))); 
//insert logs;
	}
	
	public without sharing class SystemContext{
		public List<SMS__c> queryMessages(Set<ID> smsIDS){
			return [SELECT id, Phone_Number__c, Message__c, Status__c,
											Contact__c, Campaign__c, Direction__c 
												FROM SMS__c where id = :smsIDs
												FOR UPDATE];
		}
	}


	global class OutgoingSMSAsyncException extends Exception {}
}