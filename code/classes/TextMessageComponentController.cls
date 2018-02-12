public with sharing class TextMessageComponentController {
	public static String objectType;

	@AuraEnabled
	public static List<SMS__c> getSMSMessageThread(String recordId){
        Map<Id, SMS__c> smsMap = new Map<Id, SMS__c>();
        if(recordId != null){
            String keyPrefix = recordId.substring(0,3);
            String contactPrefix = Contact.sobjecttype.getDescribe().getKeyPrefix();
            String leadPrefix = Lead.sobjecttype.getDescribe().getKeyPrefix();
            
            String personQuery = '';
            personQuery += 'SELECT Id, Mogli_SMS__Mogli_Number__c ';
            if(keyPrefix == contactPrefix){
                personQuery += 'FROM Contact ';
            }
            else if(keyPrefix == leadPrefix){
                personQuery += 'FROM Lead ';
            }
            else{
                //Did not get a correct record type
                System.debug('Did not get a record Id of type Lead of Contact');
                return null;
            }
            personQuery += 'WHERE Id = \'' + recordId + '\' ';
            sObject person = Database.query(personQuery);
            
            String smsQuery = '';		
            smsQuery += 'SELECT CreatedDate, Mogli_SMS__Message__c, Mogli_SMS__Offline__c, Mogli_SMS__Phone_Number__c, Mogli_SMS__Status__c, Mogli_SMS__Direction__c, Mogli_SMS__Gateway__r.Name ';
            smsQuery += 'FROM Mogli_SMS__SMS__c ';
            smsQuery += 'WHERE Mogli_SMS__Phone_Number__c = \'' + person.get('Mogli_SMS__Mogli_Number__c') + '\' ';
            smsQuery += 'ORDER BY CreatedDate DESC, Name DESC ';
            smsQuery += 'LIMIT 200 ';
            smsMap = new Map<Id, SMS__c>((List<SMS__c>)Database.query(smsQuery));
        }
        List<SMS__c> smss = smsMap.values();
        /*
        List<SMS__c> flipedSMSs = new List<SMS__c>();
        for(Integer i = smss.size() - 1; i >=0; i--){
            flipedSMSs.add(smss.get(i));
        }
		return flipedSMSs;
		*/
        return smss;
	}

	@AuraEnabled
	public static Boolean sendSMSMessage(String recordId, String message, String gatewayName){
		System.debug('Running sendSMSMessage');
		try{
			String contactPrefix = Contact.sobjecttype.getDescribe().getKeyPrefix();
			String leadPrefix = Lead.sobjecttype.getDescribe().getKeyPrefix();
			String keyPrefix = recordId.substring(0,3);
			Boolean isContact = true;

			String objQuery = '';
			objQuery += 'SELECT Id, Mogli_SMS__Mogli_Number__c ';
			if(keyPrefix == contactPrefix){
				isContact = true;
				objQuery += 'FROM Contact ';
			}
			else if(keyPrefix == leadPrefix){
				isContact = false;
				objQuery += 'FROM Lead ';
			}
			objQuery += 'WHERE Id = \'' + recordId + '\' ';
			sObject sObj = Database.query(objQuery);
			
			SMS__c sms = new SMS__c();
			if(isContact){
				sms.Contact__c = sObj.Id;
			}
			else{
				sms.Lead__c = sObj.Id;
			}
			sms.Direction__c = 'Outgoing';
			sms.Message__c = message;
	        sms.Phone_Number__c = (String)sObj.get('Mogli_SMS__Mogli_Number__c');
			sms.Status__c = 'Queued';	
			Gateway__c gate;
			if(gatewayName != null && gatewayName != '-Default-'){
				gate = [Select Id from Gateway__c where Name =: gatewayName];
				sms.Gateway__c = gate.Id;
			}
			insert sms;
		}
		catch(Exception e){
			System.debug('Exception = ' + e.getMessage());
			System.debug('Stack Trace = ' + e.getStackTraceString());
		}
		return null;
	}

	@AuraEnabled
	public static String getSessionId(){
		return UserInfo.getSessionId();
	}

	@AuraEnabled
	public static Boolean verifyMessage(String recordId, String msgNumber){
		System.debug('Verifying Message!');
		System.debug('Message Number = ' + msgNumber);
		Boolean verified = false;
		String keyPrefix = recordId.substring(0,3);
		String contactPrefix = Contact.sobjecttype.getDescribe().getKeyPrefix();
		String leadPrefix = Lead.sobjecttype.getDescribe().getKeyPrefix();

		String personQuery = '';
		personQuery += 'SELECT Id, Mogli_SMS__Mogli_Number__c ';
		if(keyPrefix == contactPrefix){
			personQuery += 'FROM Contact ';
		}
		else if(keyPrefix == leadPrefix){
			personQuery += 'FROM Lead ';
		}
		else{
			//Did not get a correct record type
			System.debug('Did not get a record Id of type Lead of Contact');
			return null;
		}
		personQuery += 'WHERE Id = \'' + recordId + '\' ';
		sObject person = Database.query(personQuery);
		if(person.get('Mogli_SMS__Mogli_Number__c') == msgNumber){
			verified = true;
		}
		return verified;
	}

	@AuraEnabled
	public static List<String> getOriginationList() {
        List<String> options = new List<String>();
        options.add('-Default-');
        for(Gateway__c gtw : [SELECT id, Name from Gateway__c where Inactive__c = false Order by DisplaySequence__c]){
            options.add(gtw.Name);
        }
        return options;
    }
    
    @AuraEnabled
    public static List<SMS_Template__c> getSMSTemplates(){
        List<SMS_Template__c> templates = [SELECT Mogli_SMS__Name__c, Mogli_SMS__Text__c FROM Mogli_SMS__SMS_Template__c];
        return templates;
    }
 

}