@isTest
public with sharing class SlackCallTest {
    @isTest
    static void testSlackQueueable() {
        SlackCall slackQueue = new SlackCall(
            new Map<String, String>{
                'lsp_team_slack_channel_webhook__c' => 'testing'
            }
        );
        Test.startTest();
        String jobID = System.enqueueJob(slackQueue);
        Test.stopTest();
        Assert.isTrue(jobID != null, 'job runs');
    }
}