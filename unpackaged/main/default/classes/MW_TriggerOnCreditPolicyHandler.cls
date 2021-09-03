/**
 * Created by ilazarte on 9/1/21.
 * All operations are designed to handle bulk.
 * Must execute after insert to insert id
 * Can execute before update since id exists
 */

public class MW_TriggerOnCreditPolicyHandler {


    public static void setLastCreditPolicy(List<Credit_Policy__c> sources) {

        /* collect app ids and clear out any last credit policies found */
        Set<Id> appIds = new Set<Id>();
        for (Credit_Policy__c cp : sources) {
            appIds.add(cp.Application__c);
        }

        delete [SELECT Id
                FROM   Last_Credit_Policy__c
                WHERE  Application__c IN : appIds];

        /* get all 'application' credit policies associated with these apps sort ascending */
        List<Credit_Policy__c> existingPolicies = [SELECT Id,
                                                            request_intent__c,
                                                            Application__c,
                                                            Net_Disposable_Income_NDI_Num__c,
                                                            FICO__c,
                                                            Monthly_DTI__c,
                                                            Num_Trades_Opened_Past_24mo__c
                                                    FROM   Credit_Policy__c
                                                    WHERE  Application__c IN : appIds
                                                    AND    request_intent__c = 'application'
                                                    ORDER BY Id ASC];

        List<Last_Credit_Policy__c> inserts = new List<Last_Credit_Policy__c>();
        Map<Id, Credit_Policy__c> appIdToLatestPolicy = makeAppIdToLatestCreditPolicy(existingPolicies);
        for (Credit_Policy__c existingPolicy : existingPolicies) {
            Credit_Policy__c latest = appIdToLatestPolicy.get(existingPolicy.Application__c);
            /* null check of latest covers scenarios beyond insert */
            if (latest != null && existingPolicy.Id == latest.Id) {
                Last_Credit_Policy__c target = copy(latest, new Last_Credit_Policy__c());
                inserts.add(target);
            }
        }

        insert inserts;
    }

    /**
     * @param creditPolicies A list of credit policy instances in order of creation.
     * @return Map of App Id to Credit_Policy__c
     */
    public static Map<Id, Credit_Policy__c> makeAppIdToLatestCreditPolicy(List<Credit_Policy__c> creditPolicies) {

        Map<Id, Credit_Policy__c> appIdToCp = new Map<Id, Credit_Policy__c>();
        for (Credit_Policy__c cp : creditPolicies) {
            Credit_Policy__c existing = appIdToCp.get(cp.Application__c);
            if (existing == null || cp.Id > existing.Id) {
                appIdToCp.put(cp.Application__c, cp);
            }
        }
        return appIdToCp;
    }

    /**
     * If any new credit policy fields are needed for the rules api,
     * it would be added here, after adding to the LCP custom object.
     * @param source A source Credit Policy object
     * @param dest A target Last Credit Policy object
     *
     * @return the updated last credit policy object
     */
    public static Last_Credit_Policy__c copy(Credit_Policy__c source, Last_Credit_Policy__c dest) {
        dest.Application__c = source.Application__c;
        dest.Net_Disposable_Income_NDI_Num__c = source.Net_Disposable_Income_NDI_Num__c;
        dest.FICO__c = source.FICO__c;
        dest.Monthly_DTI__c = source.Monthly_DTI__c;
        dest.Num_Trades_Opened_Past_24mo__c = source.Num_Trades_Opened_Past_24mo__c;
        dest.Credit_Policy__c = source.Id;
        return dest;
    }
}