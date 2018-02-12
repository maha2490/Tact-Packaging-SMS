public with sharing class CompleteFormsAsync implements Queueable {
    private Set<ID> formsToComplete = new Set<ID>();
    public CompleteFormsAsync(Set<ID> formsToComplete) {
        this.formsToComplete = formsToComplete;
        
    }
    public void execute(QueueableContext context){
        //Rehydrate the data
        SystemContext sc = new SystemContext();
        Map<ID, Form__c> currentFormsByID = new Map<ID, Form__c>(sc.queryForms(this.formsToComplete));

        for(Form__c form : currentFormsByID.values()){
            form.Status__c = MogliSMSSettings.getAppSettings().Complete_Form_Instance_Status__c;    
        }

        if(MogliUtil.respectUserSecurityDML()){
            if(Form__c.sObjectType.getDescribe().isUpdateable()){
                Database.update(currentFormsByID.values(),true);            
            } else {
                throw new CompleteFormsAsyncException('CompleteFormsAsync - Insufficient Access to Update Form__c');
            }
        } else {
            Database.update(currentFormsByID.values(),true);            
        }
    }
    public without sharing class SystemContext{
        /*This query runs in without sharing mode so that the system user can see all forms in the system in order to complete the correct one*/
        public List<Form__c> queryForms(Set<ID> formsToComplete){
        if((Schema.sObjectType.Form__c.isAccessible()) &&
           (Schema.sObjectType.Form__c.fields.Status__c.isAccessible())){
            return [SELECT id, Status__c
                    FROM Form__c
                    WHERE Status__c = :MogliSMSSettings.getAppSettings().Active_Form_Instance_Status__c
                    and ID = :formsToComplete
                    LIMIT 50000];

        } else {
            return null;
        }

        }
    }
    public class CompleteFormsAsyncException extends Exception {}
}