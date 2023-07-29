public class MW_ApplicationTagsTriggerHandler {

    final List<Application_Tags__c> newRecords;
    final Map<Id, Application_Tags__c> oldMap;
    final Map<Id, Application_Tags__c> newMap;

    public static boolean avoidrecursive = true;

    public MW_ApplicationTagsTriggerHandler(List< Application_Tags__c> pNewRecords, Map<Id, Application_Tags__c> pNewMap, Map<Id, Application_Tags__c> pOldMap) {
        this.newRecords = pNewRecords;
        this.oldMap = pOldMap;
        this.newMap = pNewMap;
    }

    
    public void beforeInsert() {
        checkAddTagsPermissions();
    }

    public void beforeUpdate() {
        checkDeleteTagsPermissions();
    }
    /*
    public void afterUpdate() {
            
    }

    public void afterInsert() {
        
    }
    */
    
    public void checkAddTagsPermissions(){        
        List<MW_ApplicationTagSetup__mdt> tagSetup = [SELECT Id, Profile_Name__c,Add_Tags__c, Profile_Id__c,Active__c FROM MW_ApplicationTagSetup__mdt WHERE Profile_Id__c =: UserInfo.getProfileId() AND Active__c = true ];
        If(tagSetup.isEmpty() || (!tagSetup.isEmpty() && tagSetup[0].Add_Tags__c == null)) {
            return;
        }else{
            List<string> addTags = tagSetup[0].Add_Tags__c.split(',');
            for (Application_Tags__c ac : newRecords) {
                if(!addTags.contains(ac.Application_Tag__c)){
                    ac.addError('You do not have access to add this record!');
                }
            }   
        } 
    }
    
    public void checkDeleteTagsPermissions(){
        List<MW_ApplicationTagSetup__mdt> tagSetup = [SELECT Id, Profile_Name__c,Delete_Tags__c, Profile_Id__c,Active__c FROM MW_ApplicationTagSetup__mdt WHERE Profile_Id__c =: UserInfo.getProfileId() AND Active__c = true ];
        If(tagSetup.isEmpty()) {
            return;
        }else{
            List<string> deleteTags = tagSetup[0].Delete_Tags__c != null ? tagSetup[0].Delete_Tags__c.split(',') : new List<string>();
            for (Application_Tags__c ac : newRecords) {
                if(tagSetup[0].Delete_Tags__c == null || (!deleteTags.contains(ac.Application_Tag__c))){
                    ac.addError('You do not have access to delete this record!');
                }
            }     
        } 
    }
}