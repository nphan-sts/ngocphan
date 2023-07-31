@isTest
private class MW_BoxAuthRefreshTokensSchedulerTest {

    @isTest static void getNewBoxAccessTokenTest(){
        Test.startTest();

        //setting up data
        ints__OAuth_Settings__c oAuthName = new ints__OAuth_Settings__c();
        oAuthName.ints__Consumer_Key__c     = 'd998c67720u9bf2zg34ll4ogesxppsh7';
        oAuthName.ints__Consumer_Secret__c  = 'fSmCcCTwBxYHFpxElbYcJJywiw4CelFd';
        oAuthName.ints__Access_Token_URL__c = 'https://api.box.com/oauth2/token';
        oAuthName.ints__Service_Name__c     = 'BoxSB.com';
        insert oAuthName;

        ints__OAuth_Token__c authToken = new ints__OAuth_Token__c();
        authToken.ints__Token__c = 'yBE4Ci4BP9wa8D00AXH4rm9t9Y6blKrL';
        authToken.ints__Refresh_Token__c = 'NqDQcTONAkM0U1NJKVBeTi3bNmNHoDwS88TkSquSK1RVn4tQKlWFBzDkxXy9woPq';
        authToken.ints__OAuth_Settings__c = oAuthName.id;
        authToken.ints__Is_Valid__c = true;
        insert authToken;

        String scheduleStartTime = '0 0 0 3 9 ? 2099';
        String jobId = System.schedule('getNewBoxAccessTokenTest', scheduleStartTime, new MW_BoxAuthRefreshTokensScheduler());

        // Get the information from the CronTrigger API object
    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                    FROM CronTrigger WHERE id = :jobId];

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
    System.assertEquals('2099-09-03 00:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();

        //Schedule Job will run right after stopTest
        //Since SF Test class don't support web service call therefore it'll falls to exception.
        loan__Batch_Process_Log__c bplog = [SELECT Id, loan__Type__c, loan__Origin__c
                                                                                FROM loan__Batch_Process_Log__c limit 1];

        System.assertEquals('BoX_Integ.getNewAccessToken', bplog.loan__Origin__c);
    }
}