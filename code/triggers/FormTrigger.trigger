trigger FormTrigger on Form__c (after delete, after insert, after undelete, 
                                                after update, before delete, before insert, before update) {
    if(MogliSMSSettings.getAppSettings().FormTrigger__c) {
        TriggerDispatch.TriggerContext tc = new TriggerDispatch.TriggerContext(Trigger.isExecuting, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
                                                                                Trigger.isBefore, Trigger.isAfter, Trigger.isUndelete,
                                                                                Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.size, 'FormTriggerHandler');
        TriggerDispatch.dispatchTriggerHandler(tc);
    }
}