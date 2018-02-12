global with sharing class MogliService {
    
    global interface IMogliServiceHandler {
        MogliSendSMSOutput sendSMSMessage (MogliSendSMSInput input);
    }
    global class MogliSendSMSInput {
        global String phoneNumber {get;set;}
        global String smsBody {get;set;}
        global String gatewayID {get;set;}
        global MogliSendSMSInput(String phoneNumber, String smsBody){
            this.phoneNumber = phoneNumber;
            this.smsBody = smsBody;
        }
        global MogliSendSMSInput(String phoneNumber, String smsBody, Id gatewayID){
            this.phoneNumber = phoneNumber;
            this.smsBody = smsBody;
            this.gatewayID = gatewayID;
        }
    }
    global class MogliSendSMSOutput {
        global MogliSendSMSOutput(){

        }        
    }

    global class TwilioSendSMSHandler implements IMogliServiceHandler{
        public MogliSendSMSOutput sendSMSMessage (MogliSendSMSInput input){
System.debug('MogliService.TwilioSendSMSHandler()');
          
            Gateway__c gatewayObj = GatewayUtil.gatewayMap.get(input.gatewayID);

            if(!Test.isRunningTest()){


                TwilioRestClient client = new TwilioRestClient(gatewayObj.TwilioAccountSid__c,
                    gatewayObj.TwilioAuthToken__c);

                Map<String,String> properties = new Map<String,String> {
                    'To'   => input.phoneNumber,
                    'From' =>  gatewayObj.PhoneNumber__c,
                    'Body' => input.smsBody
                };
                TwilioMessage message = client.getAccount().getMessages().create(properties);
                System.debug('message:'+message);
            }



            return new MogliSendSMSOutput();
        
       }
    }

    public static MogliSendSMSOutput sendSMS(MogliSendSMSInput input){
        System.debug('MogliService.sendSMS()');
 
        System.debug('input:'+input);

        Gateway__c gatewayObj = GatewayUtil.gatewayMap.get(input.gatewayID);
        if(gatewayObj == null) throw new MogliServiceException('No gatewayObj:'+input.gatewayID);

        System.debug('gatewayObj:'+gatewayObj);
        String handlerClassStr;                  
                 
        if(MogliUtil.getRecordTypeLabelNameByID('Gateway__c', gatewayObj.RecordTypeID) == 'Twilio'){
            handlerClassStr = 'MogliService.TwilioSendSMSHandler';
        } else if(MogliUtil.getRecordTypeLabelNameByID('Gateway__c', gatewayObj.RecordTypeID) == 'Telerivet'){
            handlerClassStr = 'Mogli_Gateways.TelerivetSendSMSHandler2';
        } else if(MogliUtil.getRecordTypeLabelNameByID('Gateway__c', gatewayObj.RecordTypeID) == 'Textwire'){
            handlerClassStr = 'Mogli_Gateways.TxtWireSendSMSHandler2';
        } else if(MogliUtil.getRecordTypeLabelNameByID('Gateway__c', gatewayObj.RecordTypeID) == 'Custom'){                           
            handlerClassStr = gatewayObj.CustomSMSServiceHandler__c;                         

        }   
        System.debug('handlerClassStr:'+handlerClassStr);
        System.debug('gatewayObj.RecordTypeID:'+gatewayObj.RecordTypeID);

        Type handlerClass = Type.forName(handlerClassStr);
        System.debug('handlerClass:'+handlerClass);
        IMogliServiceHandler activeServiceHandler = (IMogliServiceHandler)handlerClass.newInstance();
        MogliSendSMSOutput returnVal = activeServiceHandler.sendSMSMessage(input);
        System.debug('returnVal:'+returnVal);
        return returnVal;

    }

    public with sharing class AssociateSMS implements Queueable{
        public void execute(QueueableContext context){
            System.debug('MogliService.AssociateSMS.execute()');
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
            if(MogliSMSSettings.getAppSettings().Create_Anonymous_Leads__c){
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
                        throw new MogliServiceException('MogliService - Insufficient Access to Update SMS__c');
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
                        throw new MogliServiceException('MogliService - Insufficient Access to Create Lead');
                    }
                } else {
//                    Database.insert(anonLeads,true);            
                }
            }
        }
    }
    public with sharing class AssociateForms implements Queueable{
        public void execute(QueueableContext context){
            System.debug('MogliService.AssociateForms.execute()');

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
                        throw new MogliServiceException('MogliService - Insufficient Access to Update Form__c');
                    }
                } else {
                    Database.update(formsToUpdate,true);            
                }
            }
        }
    }
    public with sharing class SendScheduledSMS implements Queueable{
        public void execute(QueueableContext context){
            System.debug('MogliService.SendScheduledSMS.execute()');
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
                        throw new MogliServiceException('MogliService - Insufficient Access to Update SMS__c');
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
            System.debug('MogliService.RetryDelayedSMS.execute()');
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
                        throw new MogliServiceException('MogliService - Insufficient Access to Update SMS__c');
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
                        throw new MogliServiceException('MogliService - Insufficient Access to Update SMS__c');
                    }
                } else {
                    Database.update(delayedSMS,true);            
                }

            }
        }
    }

    public class MogliServiceException extends Exception{}
}