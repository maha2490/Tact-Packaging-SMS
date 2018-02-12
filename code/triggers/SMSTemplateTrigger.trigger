trigger SMSTemplateTrigger on SMS_Template__c (after delete, after insert, after undelete, 
                                                after update, before delete, before insert, before update) {

//    if(MogliSMSSettings.getAppSettings().SMSTemplateTrigger__c) {
        TriggerDispatch.TriggerContext tc = new TriggerDispatch.TriggerContext(Trigger.isExecuting, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
                                                                                Trigger.isBefore, Trigger.isAfter, Trigger.isUndelete,
                                                                                Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.size, 'SMSTemplateTriggerHandler');
        TriggerDispatch.dispatchTriggerHandler(tc);
//    }
}