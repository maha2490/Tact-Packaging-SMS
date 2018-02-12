public without sharing class BasePackageInstallHandler implements InstallHandler {
    //This InstallHandler class cannot run in user context due to the need to clean up any data post install/upgrade


    /////////////////////////////////////////////////////////////////////////
    //Method: onInstall
    //
    //Description:
    /////////////////////////////////////////////////////////////////////////
	public void onInstall (InstallContext context) {
        if (context.previousVersion() == null) {
            //This is a new install
            ApplicationSettings__c appSetting = new ApplicationSettings__c(Name='Default',
            																Active_Form_Instance_Status__c = 'Active',
            																AttachmentTrigger__c = true,
            																Complete_Form_Instance_Status__c = 'Complete',
            																ContactMergeFields__c = 'Name, Title',
            																ContactTrigger__c = true,
            																Create_Anonymous_Leads__c = true,
            																Debug__c = false,
            																FormTrigger__c = true,
            																LeadMergeFields__c = 'Name, Title',
            																LeadTrigger__c = true,
            																PossibleAnswerDelimiter__c = ':::',
            																SMSTrigger__c = true);
            insert appSetting;
            
            delete [SELECT id from PushTopic where Name = 'SMSCreated'];
            PushTopic pt = new PushTopic();
            pt.Name = 'SMSCreated';
            pt.Query = 'SELECT Id, Name, Mogli_SMS__Phone_Number__c, Mogli_SMS__Contact__c, Mogli_SMS__Lead__c FROM Mogli_SMS__SMS__c WHERE Mogli_SMS__Direction__c = \'Incoming\'';
            pt.IsActive = true;
            pt.NotifyForFields = 'Referenced';
            pt.NotifyForOperationCreate = true;
            pt.NotifyforOperationUpdate = false;
            pt.NotifyForOperationDelete = false;
            pt.NotifyForOperationUndelete = false;
            pt.ApiVersion = 40.0;
            try{
                insert pt;                          
            } catch (Exception e){
                
            }
            
            
            
            
            

        }
        else if(context.previousVersion().compareTo(new Version(1,0)) == 0){
        	//this is an upgrade from version 1.0

        }
        if (context.isUpgrade()){
            //this is an upgrade
            //Make sure the install package accounts for any new required fields
        	List<ApplicationSettings__c> appSettings = [Select id from ApplicationSettings__c where Name = 'Default'];
        	if(appSettings.size()==0){
	            ApplicationSettings__c appSetting = new ApplicationSettings__c(Name='Default',
	            																Active_Form_Instance_Status__c = 'Active',
	            																AttachmentTrigger__c = true,
	            																Complete_Form_Instance_Status__c = 'Complete',
	            																ContactMergeFields__c = 'Name, Title',
	            																ContactTrigger__c = true,
	            																Create_Anonymous_Leads__c = true,
	            																Debug__c = false,
	            																FormTrigger__c = true,
	            																LeadMergeFields__c = 'Name, Title',
	            																LeadTrigger__c = true,
	            																PossibleAnswerDelimiter__c = ':::',
	            																SMSTrigger__c = true);
	            insert appSetting;
                
                
                List<PushTopic> pushTopics = [SELECT id from PushTopic where Name = 'SMSCreated'];
                if(pushTopics.size()==0){
                    PushTopic pt = new PushTopic();
                    pt.Name = 'SMSCreated';
                    pt.Query = 'SELECT Id, Name, Mogli_SMS__Phone_Number__c, Mogli_SMS__Contact__c, Mogli_SMS__Lead__c FROM Mogli_SMS__SMS__c WHERE Mogli_SMS__Direction__c = \'Incoming\'';
                    pt.IsActive = true;
                    pt.NotifyForFields = 'Referenced';
                    pt.NotifyForOperationCreate = true;
                    pt.NotifyforOperationUpdate = false;
                    pt.NotifyForOperationDelete = false;
                    pt.NotifyForOperationUndelete = false;
                    pt.ApiVersion = 40.0;
                    try{
                    	insert pt;                          
                    } catch (Exception e){
                        
                    }
                  
                }
        	}
        }
        if (context.isPush()){
        	//this is a push
        }

    }


    public class BasePackageInstallHandlerException extends Exception {}
}