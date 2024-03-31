public Class TestHelper{
    private static loan__Office_Name__c rootBranch = null;    
    private static ID rootBranchRecordTypeId = null;
    public static loan__Office_Name__c getRootBranch() {
        if(rootBranch == null)    
            rootBranch = [SELECT Name, Id,
                           loan__Days_in_advance_to_create_Collection_Rep__c,
                           loan__Loan_Schedule_tied_to_Meeting_Schedule__c,
                           loan__Mark_Suspended_After_Days__c,
                           loan__Write_Off_Suggestion_Days__c,
                           loan__Parent_Office__c,
                           loan__Cash_Account__c,
                           loan__Check_Account__c,
                           loan__Cash_Account__r.Name,
                           loan__Check_Account__r.Name,
                           loan__Current_System_Date__c
                           FROM loan__Office_Name__c
                           WHERE RecordTypeID=:getRootBranchRecordTypeId() LIMIT 1];
        return rootBranch;
    }
    
    public static Date getCurrentSystemDate() {
        return getRootBranch().loan__Current_System_Date__c;
    }
    
    public static ID getRootBranchRecordTypeID() {
        if (rootBranchRecordTypeId != null) {
            return rootBranchRecordTypeId;
        }
        System.debug(LoggingLevel.ERROR, 'BranchName:' + 'loan__Office_Name__c');
        rootBranchRecordTypeId = [SELECT ID FROM RecordType WHERE Name='Root Branch'
                                    AND DeveloperName='Root_Branch' and SObjectType = :'loan__Office_Name__c' LIMIT 1].Id;
        System.debug('BranchUtilRootRecordtype:' + rootBranchRecordTypeId);
        return rootBranchRecordTypeId;
    }
    
    
}