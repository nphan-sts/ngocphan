/**
 * Created by ilazarte on 9/1/21.
 */

trigger MW_TriggerOnCreditPolicy on Credit_Policy__c (after insert, after update, after delete, after undelete ) {
    List<Credit_Policy__c> creditPolicies = Trigger.isDelete ? Trigger.old : Trigger.new;
    MW_TriggerOnCreditPolicyHandler.setLastCreditPolicy(creditPolicies);
}