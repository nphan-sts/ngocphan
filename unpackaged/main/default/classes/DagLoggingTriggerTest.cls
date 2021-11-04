@istest

public class DagLoggingTriggerTest {
    
    @isTest public static void checkDag(){
        //Create a dag schedule record.
        
        clcommon__DAG_Schedule__c dag = new clcommon__DAG_Schedule__c();
        dag.clcommon__DAG_Name__c    = 'Consolidated Dag';
        insert dag;
      
        // Create a job record 
        List<clcommon__Job__c > dagJobList = new List<clcommon__Job__c >();
        clcommon__Job__c dagJob = new clcommon__Job__c();
        dagJob.clcommon__DAG__c = dag.id;
        dagjob.clcommon__Batch_Size__c = 200;
        dagjob.clcommon__Fail_Type__c = 'Logging';
        dagjob.clcommon__Label__c = 'LoanPayoffPaymentTxnClearingDynamicJob';
        dagjob.clcommon__Number_Of_Instances__c = 1;
        // dagJob.name = 'J-12345';
        dagJob.clcommon__Class__c =  'loan.LoanPayoffPaymentTxnClearingDynamicJob';
        //dagJob.isJobComplete__c = true;
        dagJob.clcommon__Last_Used_Query__c = 'select id, name, loan__excess__c, loan__auto_create_excess_transaction__c, loan__eligible_for_payoff__c, (SELECT id, name FROM loan__loan_payment_transactions__r WHERE loan__cleared__c = false LIMIT 1) FROM loan__loan_account__c WHERE loan__excess__c > 0 and (loan__product_type__c = \'Amz Based Loan\' or loan__product_type__c = \'Flexible Amz Loan\') and loan__auto_create_excess_transaction__c = true and loan__invalid_data__c = false and id in (select loan__loan_account__c from loan__loan_account_due_details__c where loan__dd_primary_flag__c = true and loan__payment_satisfied__c = false and loan__due_date__c <= 2021-07-10) LIMIT 0';
        dagJobList.add(dagJob);
        insert dagJobList;
       
        clcommon__DAG_Logging__c dagLogging = new clcommon__DAG_Logging__c();
        
        dagLogging.clcommon__Status__c = 'Success';
        dagLogging.clcommon__DAG__c = dag.id;
        
        test.startTest();
        insert dagLogging;
        System.assertEquals('Consolidated Dag',dag.clcommon__DAG_Name__c);
        System.assertEquals(dag.id,dagJob.clcommon__DAG__c);
        System.assertEquals('Success',dagLogging.clcommon__Status__c);
        test.stopTest();
        
    }
    
    @isTest public static void checkFileGen(){
             //Create a dag schedule record.
             //
         clcommon__DAG_Schedule__c dagFileGen = new clcommon__DAG_Schedule__c();
        dagFileGen.clcommon__DAG_Name__c    = 'Payment - Filegen - Upload to Box';
        insert dagFileGen;
        
         // Create a job record 
       
         List<clcommon__Job__c > dagJobListFileGen = new List<clcommon__Job__c >();
        clcommon__Job__c dagJobFileGen = new clcommon__Job__c();
        dagJobFileGen.clcommon__DAG__c = dagFileGen.id;
        dagJobFileGen.clcommon__Batch_Size__c = 200;
        dagJobFileGen.clcommon__Fail_Type__c = 'Logging';
        dagJobFileGen.clcommon__Label__c = 'LoanPayoffPaymentTxnClearingDynamicJob';
        dagJobFileGen.clcommon__Number_Of_Instances__c = 1;
        dagJobFileGen.clcommon__Class__c =  'loan.LoanPayoffPaymentTxnClearingDynamicJob';
        dagJobFileGen.clcommon__Last_Used_Query__c = 'select id, name, loan__excess__c, loan__auto_create_excess_transaction__c, loan__eligible_for_payoff__c, (SELECT id, name FROM loan__loan_payment_transactions__r WHERE loan__cleared__c = false LIMIT 1) FROM loan__loan_account__c WHERE loan__excess__c > 0 and (loan__product_type__c = \'Amz Based Loan\' or loan__product_type__c = \'Flexible Amz Loan\') and loan__auto_create_excess_transaction__c = true and loan__invalid_data__c = false and id in (select loan__loan_account__c from loan__loan_account_due_details__c where loan__dd_primary_flag__c = true and loan__payment_satisfied__c = false and loan__due_date__c <= 2021-07-10) LIMIT 0';
        dagJobListFileGen.add(dagJobFileGen);
        insert dagJobListFileGen;
        
         clcommon__DAG_Logging__c dagLoggingFileGen = new clcommon__DAG_Logging__c();
        
        dagLoggingFileGen.clcommon__Status__c = 'Success';
        dagLoggingFileGen.clcommon__DAG__c = dagFileGen.id;
        
        
         test.startTest();
       
        insert dagLoggingFileGen;
        
        System.assertEquals('Payment - Filegen - Upload to Box',dagFileGen.clcommon__DAG_Name__c);
        System.assertEquals(dagFileGen.id,dagJobFileGen.clcommon__DAG__c);
        System.assertEquals('Success',dagLoggingFileGen.clcommon__Status__c);
       
        test.stopTest();
    }
}