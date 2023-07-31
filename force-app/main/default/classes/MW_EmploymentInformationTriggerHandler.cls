public class MW_EmploymentInformationTriggerHandler {

    final List<genesis__Employment_Information__c> newRecords;
    final Map<Id, genesis__Employment_Information__c> oldMap;
    final Map<Id, genesis__Employment_Information__c> newMap;

    public static boolean avoidrecursive = true;

    public MW_EmploymentInformationTriggerHandler(List< genesis__Employment_Information__c> pNewRecords, Map<Id, genesis__Employment_Information__c> pNewMap, Map<Id, genesis__Employment_Information__c> pOldMap) {
        this.newRecords = pNewRecords;
        this.oldMap = pOldMap;
        this.newMap = pNewMap;
    }

    /*
    public void beforeInsert() {
    }

    public void beforeUpdate() {
    }

    public void afterUpdate() {

    }
    */

    public void afterInsert() {
        MW_KbaDetailsTriggerHandler.UpdateApplications(null, null, null, newRecords, newMap, oldMap);
    }
}