@isTest
public with sharing class SlackCallTest {
    @isTest
    static void testSlackQueueable() {

        SlackCall slackQueue = new SlackCall('testing');
        Test.startTest();        
        String jobID = System.enqueueJob(slackQueue);
        Test.stopTest();
        Assert.isTrue(jobID != null, 'job runs');
        
    }
}