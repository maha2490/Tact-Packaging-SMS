public with sharing class OutgoingSMSAsync2 implements Queueable, Database.AllowsCallouts{
	public OutgoingSMSAsync2() {
		
	}

	public OutgoingSMSAsync2(Set<ID> smsIDs){
		this.smsIDs = smsIDs;
	}
	public Set<ID> smsIDs = new Set<ID>();
	public void execute(QueueableContext context){
system.debug('OutgoingSMSAsync2.execute()');
		OutgoingSMSAsyncHandler.execute(smsIDs);
	}
	
	public class OutgoingSMSAsync2Exception extends Exception {} 
}