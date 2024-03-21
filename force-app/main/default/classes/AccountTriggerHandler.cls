public with sharing class AccountTriggerHandler {
    List<Account> newRecords;
    Map<Id, Account> oldMap;
    Map<Id, Account> newMap;

    public AccountTriggerHandler(List<Account> pNewRecords, Map<Id, Account> pNewMap, Map<Id, Account> pOldMap) {
        this.newRecords = pNewRecords;
        this.oldMap = pOldMap;
        this.newMap = pNewMap;
    }
    public void afterInsert() {
    }
    public void afterUpdate() {
    }

    public static void sendSlackNotification(List<Account> newRecords) {
        String message = '<!here> :alert: Environment: {0} \n Account *{1}* with Id {2} : Available Fund is lower than $1M \n {3}';

        for (Account acc : newRecords) {
            if (
                Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Investor').getRecordTypeId() ==
                acc.RecordTypeId &&
                acc.loan__Investor__c &&
                acc.loan__Undeployed_Funds__c <= 1000000
            ) {
                Map<String, Object> msgMap = new Map<String, Object>();
                try {
                    String output = String.format(
                        message,
                        new List<String>{
                            EnvironmentHelper.getSandbox(), //{0}
                            acc.Name, // {1}
                            acc.Id, // {2}
                            EnvironmentHelper.getPageDetailUrl(acc.Id) //{3}
                        }
                    );
                    msgMap.put('text', output);
                } catch (Exception e) {
                    msgMap.put('text', e.getMessage());
                } finally {
                    if (!Test.isRunningTest()) {
                        LogsCalloutBatchHelper.sendSlackCallouts(
                            new Map<String, String>{
                                MW_Settings__c.getOrgDefaults().lsp_team_slack_channel_webhook__c => JSON.serialize(
                                    msgMap
                                )
                            }
                        );
                    }
                }
            }
        }
    }
}