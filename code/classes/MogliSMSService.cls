global with sharing class MogliSMSService {
    global interface IMogliSMSServiceHandler {
        MogliSendSMSOutput sendSMSMessage (MogliSendSMSInput input);
    }
    global class MogliSendSMSInput {
        global String phoneNumber {get;set;}
        global String smsBody {get;set;}
        global String originationID {get;set;}
        global MogliSendSMSInput(String phoneNumber, String smsBody){
            this.phoneNumber = phoneNumber;
            this.smsBody = smsBody;
        }
    }
    global class MogliSendSMSOutput {
        global MogliSendSMSOutput(){

        }        
    }

    global class TwilioSendSMSHandler implements IMogliSMSServiceHandler{
        public MogliSendSMSOutput sendSMSMessage (MogliSendSMSInput input){
System.debug('MogliSMSService.TwilioSendSMSHandler()');
          



            if(!Test.isRunningTest()){
                TwilioRestClient client = new TwilioRestClient(MogliSMSSettings.settings.TwilioAccountSid__c,
                    MogliSMSSettings.settings.TwilioAuthToken__c);

                Map<String,String> properties = new Map<String,String> {
                    'To'   => input.phoneNumber,
                    'From' =>  MogliSMSSettings.settings.TwilioPhone__c,
                    'Body' => input.smsBody
                };
                TwilioMessage message = client.getAccount().getMessages().create(properties);
                System.debug('message:'+message);
            }



            return new MogliSendSMSOutput();
        
       }
    }

    global class TelerivetSendSMSHandler implements IMogliSMSServiceHandler{
        public MogliSendSMSOutput sendSMSMessage(MogliSendSMSInput input){
            //moving out of package
/*System.debug('MogliSMSService.TelerivetSendSMSHandler()');

  
            HTTPRequest req = new HTTPRequest();

            String encodedPhoneID = EncodingUtil.urlEncode(MogliSMSSettings.settings.TelerivetPhoneID__c,'UTF-8');
            String encodedPhoneNumber = EncodingUtil.urlEncode(input.phoneNumber,'UTF-8');
            String encodedMsg        = EncodingUtil.urlEncode(input.smsBody,'UTF-8');

            String reqUrl = 'https://api.telerivet.com/v1/projects/'+MogliSMSSettings.settings.TelerivetProjectID__c+'/messages/outgoing?';
            reqUrl = reqUrl + 'phone_id='+encodedPhoneID+'&to_number='+encodedPhoneNumber+'&content='+encodedMsg;
            
            req.setEndPoint(reqURL);

            Blob headerValue = Blob.valueOf(MogliSMSSettings.settings.TelerivetAPIKey__c+':'+'');
            String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setTimeout(20000);
            req.setMethod('POST');

            system.debug('req:'+req);
            
            HTTPResponse res = new HTTPResponse();
            if(!Test.isRunningTest()){
                res = new Http().send(req);                
            }


            system.debug('res:'+res);
            system.debug('res.getBody():'+res.getBody());
            system.debug('res.getStatus()'+res.getStatus());
            system.debug('res.getStatusCode():'+res.getStatusCode());

            JSONParser parser = JSON.createParser(res.getBody());


            Boolean msgStatus = false;        
            Map<String,String> info = new Map<String,String>();
            while(parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                    String field = parser.getText();
                    parser.nextToken();
                    String value=parser.getText();
                    if(field=='status' && (value=='sent' || value=='queued' || value=='retrying')){
                        msgStatus = true;
                        info.put(field,value);
                    }
                    if(field=='to_number'){
                        info.put(field,value);
                    }else if(field == 'content'){
                        info.put(field,value);
                    }else if(field == 'message_type'){
                        info.put(field,value);
                    }else if(field == 'Sent'){
                        info.put(field,value);
                    }else if(field == 'direction'){
                        info.put(field,value);
                    }
                }
            }

System.debug('Sent Msg Status: '+info.get('status'));
System.debug('info:'+info);*/
            return new MogliSendSMSOutput();
        }
    }


    public static MogliSendSMSOutput sendSMS(MogliSendSMSInput input){
        System.debug('MogliSMSService.sendSMS()');
 

        String handlerClassStr;
        if(MogliSMSSettings.settings.Gateway__c == 'TWILIO'){
            handlerClassStr = 'MogliSMSService.TwilioSendSMSHandler';
        } else if(MogliSMSSettings.settings.Gateway__c == 'TELERIVET'){
            handlerClassStr = 'Mogli_Gateways.TelerivetSendSMSHandler';
        } else if(MogliSMSSettings.settings.Gateway__c == 'TXTWIRE'){
            handlerClassStr = 'Mogli_Gateways.TxtWireSendSMSHandler';                         
        } else if(MogliSMSSettings.settings.Gateway__c == 'CUSTOM'){
            handlerClassStr = MogliSMSSettings.settings.CustomSMSServiceHandler__c;                         
        }                   


        Type handlerClass = Type.forName(handlerClassStr);
        IMogliSMSServiceHandler activeServiceHandler = (IMogliSMSServiceHandler)handlerClass.newInstance();
        MogliSendSMSOutput returnVal = activeServiceHandler.sendSMSMessage(input);

        return returnVal;

    }

    public with sharing class AssociateSMS implements Queueable{
        public void execute(QueueableContext context){
            System.debug('MogliSMSService.AssociateSMS.execute()');
            List<SMS__c> unassociatedSMS = new List<SMS__c>();
            if((Schema.sObjectType.SMS__c.isAccessible()) &&
               (Schema.sObjectType.SMS__c.fields.Phone_Number__c.isAccessible())){//} &&
 //              (Schema.sObjectType.SMS__c.fields.Lead__c.isAccessible()) &&
//               (Schema.sObjectType.SMS__c.fields.Contact__c.isAccessible())){
                unassociatedSMS = [SELECT id, Phone_Number__c, Lead__c, Contact__c
                                    FROM SMS__c
                                    WHERE Lead__c = null and
                                            Contact__c = null
                                            and Status__c != 'Queued' limit 1000];
            } else {
//                unassociatedSMS = null;
            }
 

            System.debug('unassociatedSMS:'+unassociatedSMS);
            Set<String> likeFilters = new Set<String>();
            if(unassociatedSMS!=null){
                for(SMS__c sms : unassociatedSMS){
                    likeFilters.add('%'+sms.Phone_Number__c+'%');
                }                
            }

            System.debug('likeFilters:'+likeFilters);
            List<Contact> contactList = new List<Contact>();
            List<Lead> leadList = new List<Lead>();     
//            if((Schema.sObjectType.Contact.isAccessible()) &&
//               (Schema.sObjectType.Contact.fields.MobilePhone.isAccessible())){
            contactList = [SELECT id, MobilePhone, Mogli_Number__c FROM Contact where Mogli_Number__c like :likeFilters limit 24000];
//            if((Schema.sObjectType.Lead.isAccessible()) &&
//               (Schema.sObjectType.Lead.fields.MobilePhone.isAccessible())){
            leadList = [SELECT id, MobilePhone, Mogli_Number__c from Lead WHERE Mogli_Number__c like: likeFilters limit 25000];

            System.debug(contactList);
            System.debug(leadList);

            Map<String, Contact> contactByNumber = new Map<String, Contact>();
            Map<String, Lead> leadByNumber = new Map<String, Lead>();
            for(Contact cont : contactList){
                if(!contactByNumber.containsKey(cont.Mogli_Number__c)){
                    contactByNumber.put(cont.Mogli_Number__c, cont);
                }
            }
            for(Lead ld : leadList){
                if(!leadByNumber.containsKey(ld.Mogli_Number__c)){
                    leadByNumber.put(ld.Mogli_Number__c, ld);
                }
            }

            List<SMS__c> smsToUpdate = new List<SMS__c>();
            Set<String> anonPhoneNumbers = new Set<String>();
            List<Lead> anonLeads = new List<Lead>();
            for(SMS__c sms : unassociatedSMS){
                System.debug('sms:'+sms);
                if(contactByNumber.containsKey(sms.Phone_Number__c)){
                    sms.Contact__c = contactByNumber.get(sms.Phone_Number__c).id;
                    smsToUpdate.add(sms);
                } else if (leadByNumber.containsKey(sms.Phone_Number__c)){
                    sms.Lead__c = leadByNumber.get(sms.Phone_Number__c).id;
                    smsToUpdate.add(sms);
                } else {
                    anonPhoneNumbers.add(sms.Phone_Number__c);
                }
            }
            if(MogliSMSSettings.settings.Create_Anonymous_Leads__c){
                for(String phone : anonPhoneNumbers){
                    anonLeads.add(new Lead(LastName = 'Anonymous Lead from Mogli',
                                            Company = 'Anonymous',
                                            Mogli_Number__c = phone));
                }                
            }


            if(smsToUpdate.size()>0){
                System.debug('smsToUpdate'+smsToUpdate);
                if(MogliUtil.respectUserSecurityDML()){
                    if(SMS__c.sObjectType.getDescribe().isUpdateable()){
                        Database.update(smsToUpdate,true);            
                    } else {
                        throw new MogliSMSServiceException('MogliSMSService - Insufficient Access to Update SMS__c');
                    }
                } else {
//                    Database.update(smsToUpdate,true);            
                }

            }

            if(anonLeads.size()>0){
                System.debug('anonLeads'+anonLeads);
                if(MogliUtil.respectUserSecurityDML()){
                    if(Lead.sObjectType.getDescribe().isCreateable()){
                        Database.insert(anonLeads,true);            
                    } else {
                        throw new MogliSMSServiceException('MogliSMSService - Insufficient Access to Create Lead');
                    }
                } else {
//                    Database.insert(anonLeads,true);            
                }
            }
        }
    }
    public with sharing class AssociateForms implements Queueable{
        public void execute(QueueableContext context){
            System.debug('MogliSMSService.AssociateForms.execute()');

            List<Form__c> unassociatedForms = new List<Form__c>();
            if((Schema.sObjectType.Form__c.isAccessible()) &&
               (Schema.sObjectType.Form__c.fields.Phone_Number__c.isAccessible())){//} &&
//               (Schema.sObjectType.Form__c.fields.Lead__c.isAccessible()) &&
//               (Schema.sObjectType.Form__c.fields.Contact__c.isAccessible())){
                    unassociatedForms = [SELECT id, Phone_Number__c, Lead__c, Contact__c
                                                  FROM Form__c
                                                  WHERE Lead__c = null and
                                                        Contact__c = null limit 1000];
            }


            System.debug('unassociatedForms:'+unassociatedForms);

            Set<String> likeFilters = new Set<String>();
            if(unassociatedForms!=null){
                 for(Form__c form : unassociatedForms){
                    likeFilters.add('%'+form.Phone_Number__c+'%');
                }               
            }

            System.debug('likeFilters:'+likeFilters);

            List<Contact> contactList = new List<Contact>();
            List<Lead> leadList = new List<Lead>();     
//            if((Schema.sObjectType.Contact.isAccessible()) &&
//               (Schema.sObjectType.Contact.fields.MobilePhone.isAccessible())){
                contactList = [SELECT id, MobilePhone, Mogli_Number__c FROM Contact where Mogli_Number__c like :likeFilters limit 24000];

//            if((Schema.sObjectType.Lead.isAccessible()) &&
//               (Schema.sObjectType.Lead.fields.MobilePhone.isAccessible())){
                leadList = [SELECT id, MobilePhone, Mogli_Number__c from Lead WHERE Mogli_Number__c like: likeFilters limit 25000];



            System.debug(leadList);

            Map<String, Contact> contactByNumber = new Map<String, Contact>();
            Map<String, Lead> leadByNumber = new Map<String, Lead>();
            for(Contact cont : contactList){
                if(!contactByNumber.containsKey(cont.Mogli_Number__c)){
                    contactByNumber.put(cont.Mogli_Number__c, cont);
                }
            }
            for(Lead ld : leadList){
                if(!leadByNumber.containsKey(ld.Mogli_Number__c)){
                    leadByNumber.put(ld.Mogli_Number__c, ld);
                }
            }

            List<Form__c> formsToUpdate = new List<Form__c>();
            for(Form__c form : unassociatedForms){
                if(contactByNumber.containsKey(form.Phone_Number__c)){
                    form.Contact__c = contactByNumber.get(form.Phone_Number__c).id;
                    formsToUpdate.add(form);
                } else if (leadByNumber.containsKey(form.Phone_Number__c)){
                    form.Lead__c = leadByNumber.get(form.Phone_Number__c).id;
                    formsToUpdate.add(form);
                }
            }
            if(formsToUpdate.size()>0){

                if(MogliUtil.respectUserSecurityDML()){
                    if(Form__c.sObjectType.getDescribe().isUpdateable()){
                        Database.update(formsToUpdate,true);            
                    } else {
                        throw new MogliSMSServiceException('MogliSMSService - Insufficient Access to Update Form__c');
                    }
                } else {
                    Database.update(formsToUpdate,true);            
                }
            }
        }
    }
    public with sharing class SendScheduledSMS implements Queueable{
        public void execute(QueueableContext context){
            System.debug('MogliSMSService.SendScheduledSMS.execute()');
            List<SMS__c> scheduledSMS = new List<SMS__c>();
            if((Schema.sObjectType.SMS__c.isAccessible()) &&
               (Schema.sObjectType.SMS__c.fields.Message__c.isAccessible()) &&
               (Schema.sObjectType.SMS__c.fields.Status__c.isAccessible())){
                scheduledSMS = [SELECT id, Message__c, Status__c from SMS__c where Status__c = 'Scheduled' and Scheduled_Delivery__c < :DateTime.Now() limit 50000];
                system.debug('scheduledSMS:'+scheduledSMS);
            } else {
                scheduledSMS = null;
            }

            for (SMS__c sms : scheduledSMS){
                sms.Status__c = 'Sending';
            }
            if(scheduledSMS.size()>0){
                if(MogliUtil.respectUserSecurityDML()){
                    if(SMS__c.sObjectType.getDescribe().isUpdateable()){
                        Database.update(scheduledSMS,true);            
                    } else {
                        throw new MogliSMSServiceException('MogliSMSService - Insufficient Access to Update SMS__c');
                    }
                } else {
                    Database.update(scheduledSMS,true);            
                }

            }


            //Batch them
            BatchDispatch.BatchDispatchContext bc = new BatchDispatch.BatchDispatchContext();
            bc.batchHandler = 'SendSMSBatchHandler';
            BatchDispatch job = new BatchDispatch(bc);
            Database.executeBatch(job, 100);


        }
    }
    public with sharing class RetryDelayedSMS implements Queueable{
        public void execute(QueueableContext context){
            System.debug('MogliSMSService.RetryDelayedSMS.execute()');
            List<SMS__c> delayedSMS = new List<SMS__c>();
            if((Schema.sObjectType.SMS__c.isAccessible()) &&
               (Schema.sObjectType.SMS__c.fields.Message__c.isAccessible()) &&
               (Schema.sObjectType.SMS__c.fields.Status__c.isAccessible())){
                delayedSMS = [SELECT id, Message__c, Status__c from SMS__c where Status__c = 'Queued'
                                                                            and SystemModStamp < :DateTime.Now().addMinutes(-1) limit 50000];
            } else {
                delayedSMS = null;
            }

            for (SMS__c sms : delayedSMS){
                sms.Status__c = 'Retry';
            }
            if(delayedSMS.size()>0){
                if(MogliUtil.respectUserSecurityDML()){
                    if(SMS__c.sObjectType.getDescribe().isUpdateable()){
                        Database.update(delayedSMS,true);            
                    } else {
                        throw new MogliSMSServiceException('MogliSMSService - Insufficient Access to Update SMS__c');
                    }
                } else {
                    Database.update(delayedSMS,true);            
                }

            }
            for (SMS__c sms : delayedSMS){
                sms.Status__c = 'Queued';
            }
            if(delayedSMS.size()>0){
                if(MogliUtil.respectUserSecurityDML()){
                    if(SMS__c.sObjectType.getDescribe().isUpdateable()){
                        Database.update(delayedSMS,true);            
                    } else {
                        throw new MogliSMSServiceException('MogliSMSService - Insufficient Access to Update SMS__c');
                    }
                } else {
                    Database.update(delayedSMS,true);            
                }

            }
        }
    }

    public class MogliSMSServiceException extends Exception{}
}