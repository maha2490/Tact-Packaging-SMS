public with sharing class TriggerDispatch {
    public interface ITriggerClass {
        void MainEntry(TriggerContext tc);
        void InProgressEntry(TriggerContext tc);
        void onBeforeInsert(TriggerContext tc);
        void onBeforeUpdate(TriggerContext tc);
        void onBeforeDelete(TriggerContext tc);
        void onAfterInsert(TriggerContext tc);
        void onAfterUpdate(TriggerContext tc);
        void onAfterDelete(TriggerContext tc);
    }
    public class TriggerException extends Exception {}
    public class TriggerContext{
        public Boolean isExecuting {get; private set;}
        public Boolean isInsert {get; private set;}
        public Boolean isUpdate {get; private set;}
        public Boolean isDelete {get; private set;}
        public Boolean isBefore {get; private set;}
        public Boolean isAfter {get; private set;}
        public Boolean isUndelete {get; private set;}
        public List<SObject> newList {get; private set;}
        public Map<ID, SObject> newMap {get; private set;}
        public List<SObject> oldList {get; private set;}
        public Map<ID, SObject> oldMap {get; private set;}
        public Integer size {get; private set;}
        public String handler {get; private set;}

        public TriggerContext(Boolean isExecuting, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isBefore, Boolean isAfter, Boolean isUndelete,
                                  List<SObject> newList, Map<ID, SObject> newMap, List<SObject> oldList, Map<ID, SObject> oldMap, Integer size, String handler){
            this.isExecuting = isExecuting;
            this.isInsert = isInsert;
            this.isUpdate = isUpdate;
            this.isDelete = isDelete;
            this.isBefore = isBefore;
            this.isAfter = isAfter;
            this.isUndelete = isUndelete;
            this.newList = newList;
            this.newMap = newMap;
            this.oldList = oldList;
            this.oldMap = oldMap;
            this.size = size;
            this.handler = handler;
        }
    
    }
    private static Map<String,Integer> dispatchCounter = new Map<String,Integer>();
    private static ITriggerClass activeTriggerHandler = null;
    public static Integer getHandlerCount(String handler){
        if(dispatchCounter.containsKey(handler)){
            return dispatchCounter.get(handler);
        } else return 0;
    }
    
    public static void dispatchTriggerHandler(TriggerContext tc){
//system.debug('***TriggerDispatch.dispatchTriggerHandler');

        if(activeTriggerHandler != null){
            activeTriggerHandler.InProgressEntry(tc);
            return;
        } else {
            if(!String.isEmpty(tc.handler)){
                Type handlerClass = Type.forName(tc.handler);
//system.debug('tc.handler:'+tc.handler);
                activeTriggerHandler = (ITriggerClass)handlerClass.newInstance();
                activeTriggerHandler.MainEntry(tc);
                if(dispatchCounter.containsKey(tc.handler)){
                    dispatchCounter.put(tc.handler, dispatchCounter.get(tc.handler) +1);
                } else {
                    dispatchCounter.put(tc.handler, 1);
                }
            }           
        }
    }

    public static void forwardTrigger(TriggerContext tc, ITriggerClass currentTriggerHandler){
//system.debug('***TriggerDispatch.forwardTrigger');
        TriggerDispatch.activeTriggerHandler = null;
        TriggerDispatch.dispatchTriggerHandler(tc);
        TriggerDispatch.activeTriggerHandler = currentTriggerHandler;            
    }

}