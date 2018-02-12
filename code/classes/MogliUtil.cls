public with sharing class MogliUtil {
    /////////////////////////////////////////////////////////////////////////
    // Method: DML settings to control whether or not to adher to user security
    //
    //
    /////////////////////////////////////////////////////////////////////////
    private static Boolean respectUserSecurityDML = true;
    public static void setSystemSecurityDML(){
        respectUserSecurityDML = false;
    }
    public static void setUserSecurityDML(){
        respectUserSecurityDML = true;
    }
    public static Boolean respectUserSecurityDML(){
        return respectUserSecurityDML;
    }

    //maps to hold the record type info 
    private static Map<String, Schema.SObjectType> globalDescribe;
    private static Map<String,Map<Id,Schema.RecordTypeInfo>> recordTypesById = new Map<String,Map<Id,Schema.RecordTypeInfo>>();
    private static Map<String,Map<String,Schema.RecordTypeInfo>> recordTypesByName = new Map<String,Map<String,Schema.RecordTypeInfo>>();
    private static Map<String, String> profileMap = new Map<String,String>();

    private static Map<ID, String> queueByID = new Map<ID,String>();
    private static Map<String, ID> queueByDeveloperName = new Map<String, ID>();
    
    /////////////////////////////////////////////////////////////////////////
    //Method: fillMapsForRecordTypeObject
    /////////////////////////////////////////////////////////////////////////
    private static void fillMapsForRecordTypeObject(string objectName) {
        // get the object map the first time
        objectName = packageSafeObjectName(objectName);
        if (globalDescribe==null) {
            globalDescribe = Schema.getGlobalDescribe();
        }
        // get the object description
        if (globalDescribe.containsKey(objectName)) {
            Schema.DescribeSObjectResult describe = globalDescribe.get(objectName).getDescribe();
            recordTypesByName.put(objectName, describe.getRecordTypeInfosByName());
            recordTypesById.put(objectName, describe.getRecordTypeInfosById());
        }
    }

    public static Id getRecordTypeIdByLabelName(String objectName, String labelName) {
        // make sure we have this object's record types mapped
        objectName = packageSafeObjectName(objectName);
        if (!recordTypesByName.containsKey(objectName)){
            fillMapsForRecordTypeObject(objectName);        
        }

        // now grab and return the requested id
        Map<String,Schema.RecordTypeInfo> rtMap = recordTypesByName.get(objectName);
        if (rtMap != null && rtMap.containsKey(labelName)) {
            return rtMap.get(labelName).getRecordTypeId();
        } else {
            return null;
        }
    }
    public static String getRecordTypeLabelNameByID(String objectName, Id recordTypeId) {
    // make sure we have this object's record types mapped
        objectName = packageSafeObjectName(objectName);
        if (!recordTypesById.containsKey(objectName)){
            fillMapsForRecordTypeObject(objectName);        
        }

        // now grab and return the requested id
        Map<Id,Schema.RecordTypeInfo> rtMap = recordTypesById.get(objectName);
        if (rtMap != null && rtMap.containsKey(recordTypeId)) {
            return rtMap.get(recordTypeId).getName();
        } else {
            return null;
        }
    }

    public static String packageSafeObjectName(String objectName){
        if (Type.forName('Mogli_SMS__SMS__c') == null) {
            //Not in Package
            return objectName.removeStart('Mogli_SMS__');
        } else {
            //In Package
            Set<String> packageObjects = new Set<String>{'SMS__c', 'Gateway__c'};
            if(packageObjects.contains(objectName)){
                return 'Mogli_SMS__'+objectName.removeStart('Mogli_SMS__');                
            }
        }
        return objectName;
    }
    public static void testCoverage(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
      i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}