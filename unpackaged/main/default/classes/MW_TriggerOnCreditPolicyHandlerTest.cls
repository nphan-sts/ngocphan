/**
 * Created by ilazarte on 9/1/21.
 */

@IsTest
public class MW_TriggerOnCreditPolicyHandlerTest {

    @TestSetup static void setup() {
        CL_Document__c clDocument = MW_GlobalTestUtility.getCLDocumentRecord();
        insert clDocument;
    }

    /**
     * Inserting multiple credit policies in two runs, first a single, and then a list
     * should result in a single last credit policy being created and then updated in both scenarios.
     * The second scenario adds another app to the batch.
     */
    @IsTest static void test_setLastCreditPolicy_insert() {

        genesis__Applications__c app1 = MW_GlobalTestUtility.GetApplication();
        insert app1;

        /*
         Assert the first credit policy insertion creates a record.
         The LCP entry should be created, and its fields should match the inserting CP.
         The CP has to be queried again in order to get the evaluation for the formula field, NDI_num
         */
        Credit_Policy__c creditPolicy = CreditPolicy(app1, 640.0, 1200.0, 35, 7);
        insert creditPolicy;
        assertCurrentLastCreditPolicy(app1, creditPolicy, 640.0, 1200.0, 35, 7);

        /*
         Assert a list of credit policies following only updates the single entry.
         The LCP should equal the last CP in the list.
         Intersperse another applications credit policies.
         */
        genesis__Applications__c app2 = MW_GlobalTestUtility.GetApplication();
        insert app2;

        List<Credit_Policy__c> policies = new List<Credit_Policy__c>();
        policies.add(CreditPolicy(app1, 641.01, 1201.01, 36, 8));
        policies.add(CreditPolicy(app2, 541.01, 1101.01, 26, 4));
        policies.add(CreditPolicy(app1, 642.02, 1202.02, 37, 9));
        policies.add(CreditPolicy(app2, 542.02, 1102.02, 27, 5));

        /* attempt to trick up insertion, only application credit policies are considered */
        Credit_Policy__c nonApplicationCreditPolicy = CreditPolicy(app1, 643.03, 1303.03, 38, 10);
        nonApplicationCreditPolicy.request_intent__c = 'verification';

        policies.add(nonApplicationCreditPolicy);
        insert policies;

        assertCurrentLastCreditPolicy(app1, policies.get(2), 642.02, 1202.02, 37, 9);
        assertCurrentLastCreditPolicy(app2, policies.get(3), 542.02, 1102.02, 27, 5);
    }

    /**
     * Test various updating scenarios of credit policy records.
     * These shouldn't happen, but handling them just in case.
     * As far as I know, no credit policy record is updated through manual entry.
     */
    @IsTest static void test_setLastCreditPolicy_update() {

        genesis__Applications__c app1 = MW_GlobalTestUtility.GetApplication();
        insert app1;

        Credit_Policy__c firstCp = CreditPolicy(app1, 641.01, 1201.01, 36, 8);
        Credit_Policy__c secondCp = CreditPolicy(app1, 541.01, 1101.01, 26, 4);

        List<Credit_Policy__c> policies = new List<Credit_Policy__c>();
        policies.add(firstCp);
        policies.add(secondCp);
        insert policies;

        /* first confirm we have the right original order */
        assertCurrentLastCreditPolicy(app1, secondCp, 541.01, 1101.01, 26, 4);


        /* update the older record (should never happen in prod but just in case)
        *  demonstrate that the LCP is unchanged */
        firstCp.FICO__c = 642.02;
        update firstCp;
        assertCurrentLastCreditPolicy(app1, secondCp, 541.01, 1101.01, 26, 4);

        /* update the latest record (should never happen in prod but just in case)
         * demonstrate the LCP is updated accordingly using its NDI num formula field and other fields
         */
        secondCp.FICO__c = 542.02;
        secondCp.Net_Disposable_Income_NDI__c = '1202.02';
        secondCp.Monthly_DTI__c = 27;
        secondCp.Num_Trades_Opened_Past_24mo__c = 5;
        update secondCp;
        Last_Credit_Policy__c thirdResult = assertCurrentLastCreditPolicy(app1, secondCp, 542.02, 1202.02, 27, 5);

        /*
         * delete LCP from sf, shoudn't happen just in case
         * On update of older CP, assert most recent CP is used for LCP restoration
         */
        delete thirdResult;
        firstCp.FICO__c = 643.03;
        firstCp.Net_Disposable_Income_NDI__c = '1203.03';
        firstCp.Monthly_DTI__c = 37.01;
        firstCp.Num_Trades_Opened_Past_24mo__c = 9;
        update firstCp;
        Last_Credit_Policy__c fourthResult = assertCurrentLastCreditPolicy(app1, secondCp, 542.02, 1202.02, 27, 5);

        /*
         * delete LCP from sf, shoudn't happen just in case
         * On update of latest CP, assert most recent CP is used for LCP restoration
         */
        delete fourthResult;

        secondCp.FICO__c = 544.04;
        secondCp.Net_Disposable_Income_NDI__c = '1204.04';
        secondCp.Monthly_DTI__c = 28;
        secondCp.Num_Trades_Opened_Past_24mo__c = 6;
        update secondCp;
        assertCurrentLastCreditPolicy(app1, secondCp, 544.04, 1204.04, 28, 6);

        /*
         * finally change update with a verification credit policy (wont ever happen)
         * but if it does, it should recreate the lcp as the previous cp
         */
        secondCp.FICO__c = 545.05;
        secondCp.Net_Disposable_Income_NDI__c = '1205.05';
        secondCp.Monthly_DTI__c = 29;
        secondCp.Num_Trades_Opened_Past_24mo__c = 7;
        secondCp.request_intent__c = 'verification';
        update secondCp;
        assertCurrentLastCreditPolicy(app1, firstCp, 643.03, 1203.03, 37.01, 9);
    }

    /**
     * Again, a series of tests that should never occur.
     * Just in case, if the parent credit policy is deleted, clear out the lcp
     */
    @IsTest static void test_setLastCreditPolicy_delete() {

        genesis__Applications__c app1 = MW_GlobalTestUtility.GetApplication();
        insert app1;
        genesis__Applications__c app2 = MW_GlobalTestUtility.GetApplication();
        insert app2;

        Credit_Policy__c creditPolicy1 = CreditPolicy(app1, 640.0, 1200.0, 35, 7);
        insert creditPolicy1;
        Credit_Policy__c creditPolicy2 = CreditPolicy(app1, 641.0, 1201.0, 36, 8);
        insert creditPolicy2;
        Credit_Policy__c creditPolicy3 = CreditPolicy(app1, 642.0, 1202.0, 37, 9);
        insert creditPolicy3;

        /* Re assert insertion works fine*/
        assertCurrentLastCreditPolicy(app1, creditPolicy3, 642.0, 1202.0, 37, 9);

        /* assert return to 2 */
        delete creditPolicy3;
        assertCurrentLastCreditPolicy(app1, creditPolicy2, 641.0, 1201.0, 36, 8);

        /* assert return to 1 */
        delete creditPolicy2;
        assertCurrentLastCreditPolicy(app1, creditPolicy1, 640.0, 1200.0, 35, 7);

        /* assert return to none */
        delete creditPolicy1;
        assertNoLastCreditPolicy(app1);

        List<Credit_Policy__c> policies = new List<Credit_Policy__c>();
        policies.add(CreditPolicy(app1, 641.01, 1201.01, 36, 8));
        policies.add(CreditPolicy(app2, 541.01, 1101.01, 26, 4));
        policies.add(CreditPolicy(app1, 642.02, 1202.02, 37, 9));
        Credit_Policy__c app2Last = CreditPolicy(app2, 542.02, 1102.02, 27, 5);
        policies.add(app2Last);
        insert policies;

        /* delete a batch from app1*/
        delete [SELECT Id FROM Credit_Policy__c WHERE Application__c = : app1.Id];
        assertNoLastCreditPolicy(app1);

        /* out of paranoia, delete the lcp and make sure the credit policy record survives */
        delete [SELECT Id
                FROM   Last_Credit_Policy__c
                WHERE  Application__c = : app2.Id
                AND    Credit_Policy__c =: app2Last.Id];
        assertNoLastCreditPolicy(app2);

        List<Credit_Policy__c> creditPolicies = [SELECT Id FROM Credit_Policy__c WHERE Application__c = : app2.Id];
        System.assert(creditPolicies != null);
        System.assertEquals(2, creditPolicies.size());
    }

    /**
     * Assert the current LCP against the app comparing values to the Credit Policy hardcoded and retrieved.
     * @param app application
     * @param cp credit policy
     * @param fico score
     * @param ndi value
     * @param monthlyDti value
     * @param numTrades in last 24 mos
     * @return Last_Credit_Policy__c
     */
    private static Last_Credit_Policy__c assertCurrentLastCreditPolicy(genesis__Applications__c app,
                                                      Credit_Policy__c cp,
                                                        Decimal fico,
                                                        Decimal ndi,
                                                        Decimal monthlyDti,
                                                        Decimal numTrades) {
        Last_Credit_Policy__c lcp = assertSingleEntryForApp(app);
        assertValuesCopied(cp.Id, app, lcp);
        assertValuesHard(app, cp, fico, ndi, monthlyDti, numTrades, lcp);
        return lcp;
    }

    /**
     * @param expectedApp The app last credit entry to search for
     *
     * @return The single entry after assertion
     */
    private static Last_Credit_Policy__c assertSingleEntryForApp(genesis__Applications__c expectedApp) {
        List<Last_Credit_Policy__c> lastCreditPolicies = selectLastCreditPolicies(expectedApp.Id);
        System.assertEquals(1, lastCreditPolicies.size());
        Last_Credit_Policy__c lastCreditPolicy = lastCreditPolicies.get(0);
        return lastCreditPolicy;
    }

    private static void assertNoLastCreditPolicy(genesis__Applications__c expectedApp) {
        List<Last_Credit_Policy__c> lastCreditPolicies = selectLastCreditPolicies(expectedApp.Id);
        System.assertEquals(0, lastCreditPolicies.size());
    }

    /**
     * Assert values returned from a sf select
     * @param expectedCreditPolicyId Expected values from sf
     * @param expectedApp Expected application
     * @param actual Actual
     */
    private static void assertValuesCopied(Id expectedCreditPolicyId,
                                    genesis__Applications__c expectedApp,
                                    Last_Credit_Policy__c actual) {

        Credit_Policy__c expectedCreditPolicy = selectSingleCreditPolicy(expectedCreditPolicyId);

        System.assert(actual.Credit_Policy__c != null);
        System.assertEquals(expectedCreditPolicy.Id, actual.Credit_Policy__c);

        System.assert(actual.FICO__c != null);
        System.assertEquals(expectedCreditPolicy.FICO__c, actual.FICO__c);

        System.assert(actual.Net_Disposable_Income_NDI_Num__c != null);
        System.assertEquals(expectedCreditPolicy.Net_Disposable_Income_NDI_Num__c, actual.Net_Disposable_Income_NDI_Num__c);

        System.assert(actual.Monthly_DTI__c != null);
        System.assertEquals(expectedCreditPolicy.Monthly_DTI__c, actual.Monthly_DTI__c);

        System.assert(actual.Num_Trades_Opened_Past_24mo__c != null);
        System.assertEquals(expectedCreditPolicy.Num_Trades_Opened_Past_24mo__c, actual.Num_Trades_Opened_Past_24mo__c);

        System.assert(actual.Application__c != null);
        System.assertEquals(expectedApp.Id, actual.Application__c);
    }

    /*
     Sanity check assertion against hard coded values.
     Should always pass in accordance with assertValuesCopied
     */
    private static void assertValuesHard(genesis__Applications__c expectedApp,
            Credit_Policy__c creditPolicy,
            Decimal fico,
            Decimal ndi,
            Decimal monthlyDti,
            Decimal numTrades,
            Last_Credit_Policy__c actual) {

        System.assertEquals(creditPolicy.Id, actual.Credit_Policy__c);
        System.assertEquals(fico, actual.FICO__c);
        System.assertEquals(ndi, actual.Net_Disposable_Income_NDI_Num__c);
        System.assertEquals(monthlyDti, actual.Monthly_DTI__c);
        System.assertEquals(numTrades, actual.Num_Trades_Opened_Past_24mo__c);
        System.assertEquals(expectedApp.Id, actual.Application__c);
    }

    /*
     Create object only, no insert
     */
    private static Credit_Policy__c CreditPolicy(genesis__Applications__c app,
            Decimal fico,
            Decimal ndi,
            Decimal monthlyDti,
            Decimal numTrades) {

        Credit_Policy__c creditPolicy = new Credit_Policy__c();
        creditPolicy.FICO__c = fico;
        creditPolicy.request_intent__c = 'application';
        creditPolicy.Net_Disposable_Income_NDI__c = String.valueOf(ndi);
        creditPolicy.Monthly_DTI__c = monthlyDti;
        creditPolicy.Num_Trades_Opened_Past_24mo__c = numTrades;
        creditPolicy.Application__c = app.Id;
        return creditPolicy;
    }

    /**
     * @param appId The last credit policies to select, by app id
     *
     * @return A list un ordered
     */
    private static List<Last_Credit_Policy__c> selectLastCreditPolicies(Id appId) {
        return [
                SELECT Id,
                       FICO__c,
                       Net_Disposable_Income_NDI_Num__c,
                       Monthly_DTI__c,
                       Num_Trades_Opened_Past_24mo__c,
                       Application__c,
                       Credit_Policy__c
                FROM   Last_Credit_Policy__c
                WHERE  Application__c =: appId
            ];
    }

    /**
     * @param creditPolicyId The id of the credit policy to retrieve
     *
     * @return A credit policy with evaluated field ndi num and other fields to assert
     */
    private static Credit_Policy__c selectSingleCreditPolicy(Id creditPolicyId) {
        List<Credit_Policy__c> creditPolicy = [
                SELECT Id,
                        request_intent__c,
                        FICO__c,
                        Net_Disposable_Income_NDI_Num__c,
                        Monthly_DTI__c,
                        Num_Trades_Opened_Past_24mo__c,
                        Application__c
                FROM Credit_Policy__c
                WHERE Id = :creditPolicyId
        ];
        return creditPolicy.get(0);
    }
}