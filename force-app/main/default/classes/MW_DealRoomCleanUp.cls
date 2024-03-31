global class MW_DealRoomCleanUp implements Database.Batchable<sObject>, Schedulable {

    //Schedulable Process
    global void execute(SchedulableContext sc) {
        MW_DealRoomCleanUp cleanDR = new MW_DealRoomCleanUp();

        cleanDR.query = 'Select id, genesis__Status__c From genesis__Applications__c Where (genesis__Status__c = \'Declined\' OR genesis__Status__c = \'Expired\') AND id IN (Select genesis__Application__c From genesis__Application_Status_History__c Where genesis__New_Value__c = \'Declined\' AND genesis__Old_value__c = \'Default Documents\' AND IsADCDeleted__c = false)';
        Database.executeBatch(cleanDR, 50);
    }

    //Batchable Process
    public String query;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<genesis__Applications__c> scope) {
        //filter out application that is not auto declined
        List<genesis__Application_Status_History__c> historiesOfApps = [Select id, genesis__Application__r.Id, genesis__New_Value__c, genesis__Old_value__c, IsADCDeleted__c From genesis__Application_Status_History__c Where genesis__Application__c IN: scope];
        //Build Apps Status History Map
        Map<Id, List<genesis__Application_Status_History__c>> appHistoryMap = new Map<Id, List<genesis__Application_Status_History__c>>();

        //Update IsADCDeleted__c Value in app status history object
        List<genesis__Application_Status_History__c> ashUpdateList = new List<genesis__Application_Status_History__c>();
        for(genesis__Application_Status_History__c eachHistory : historiesOfApps) {
            if(appHistoryMap.containsKey(eachHistory.genesis__Application__r.Id)) {
                List<genesis__Application_Status_History__c> appHistories = appHistoryMap.get(eachHistory.genesis__Application__r.Id);
                appHistories.add(eachHistory);
                appHistoryMap.put(eachHistory.genesis__Application__r.Id, appHistories);
            }
            else{
                List<genesis__Application_Status_History__c> appHistories = new List<genesis__Application_Status_History__c>();
                appHistories.add(eachHistory);
                appHistoryMap.put(eachHistory.genesis__Application__r.Id, appHistories);
            }
            eachHistory.IsADCDeleted__c = true;
            ashUpdateList.add(eachHistory);
        }

        //Filter by History Status
        List<id> appIds = new List<id>();
        if(!appHistoryMap.isEmpty()){
            for(genesis__Applications__c app : scope) {
                Set<String> oldStatus = new Set<String>();
                Set<String> newStatus = new Set<String>();
                for(genesis__Application_Status_History__c appHistory : appHistoryMap.get(app.Id)) {
                    if(appHistory.genesis__Old_value__c != null) {
                        oldStatus.add(appHistory.genesis__Old_value__c);
                    }
                    newStatus.add(appHistory.genesis__New_Value__c);
                }
                if(autoDeclinedApp(oldStatus, newStatus)) {
                    appIds.add(app.id);
                }
            }
        }
        
        //Find Doc Tree with these applications
        List<genesis__Application_Document_Category__c> deleteADCList = new List<genesis__Application_Document_Category__c>();
        List<genesis__Application_Document_Category__c> parentTree = [Select id, name, genesis__Application__c, genesis__Parent_Application_Document_Category__c From genesis__Application_Document_Category__c Where genesis__Application__c IN: appIds AND name = 'Verification Documents'];
        //Traversing each Verification Documents
        deleteADCList.addAll(parentTree);
        while(parentTree!= null && parentTree.size() > 0) {
            List<genesis__Application_Document_Category__c> childLevel = [Select id, name, genesis__Application__c, genesis__Parent_Application_Document_Category__c From genesis__Application_Document_Category__c Where genesis__Application__c IN: appIds AND genesis__Parent_Application_Document_Category__c IN: parentTree];
            deleteADCList.addAll(childLevel);
            parentTree = childLevel;
        }

        //Update Application Status History
        if(ashUpdateList.size() > 0) {
            update ashUpdateList;
        }

        //Delete Verification Documents
        if(deleteADCList.size() > 0) {
            delete deleteADCList;
            //DataBase.emptyRecycleBin(deleteADCList);
        }
    }

    public static Boolean autoDeclinedApp(Set<String> oldStatus, Set<string> newStatus){
        //Auto Declined Status History NEW-ENTERED to Default Documents to Declined
        if(oldStatus.size() == 1 && oldStatus.containsAll(new List<String>{'Default Documents'}) &&
           newStatus.size() == 2 && newStatus.containsAll(new List<String>{'Default Documents', 'Declined'})) {
            return true;
        }
        //Auto Declined Status History NEW-ENTERED to Default Documents to Declined to Expired
        else if(oldStatus.size() == 2 && oldStatus.containsAll(new List<String>{'Default Documents', 'Declined'}) &&
                newStatus.size() == 3 && newStatus.containsAll(new List<String>{'Default Documents', 'Declined', 'Expired'})){
            return true;
        }
        return false;
    }

    global void finish(Database.BatchableContext BC) {

    }

}