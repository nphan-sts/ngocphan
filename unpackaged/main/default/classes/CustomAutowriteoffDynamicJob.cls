global class CustomAutowriteoffDynamicJob extends clcommon.DynamicJob {
    /**
     * Automates Write-off loans and capture write-off reason
     * This Job automates the process to write-off loans (status in 'Active good standing', 'Active Bad standing' or 'Active Matured') daily
     * Write off reason is captured as 'Auto'
     */
    
     private Date sodDate;
     private static final String JOB_NAME = 'Auto Write-Off Job';
     private static final Integer DEFAULT_BATCH_SIZE = 150;
     //global List<loan__loan_Account__c> LoanAccount = new List<loan__loan_Account__c>();
     loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
    
     global CustomAutowriteoffDynamicJob() {
         this(null);
     }
     
     public CustomAutowriteoffDynamicJob(String query) {
         super(JOB_NAME, query);
       
     }
    
     /** 
       * execute(jobId)
       * This method gets invoked when the batch job executed and operates on one batch of records
       * @param  jobId     Database.BatchableContext
     */
     
     
    
     global override void doInitialize() {} // do nothing

     global override String getRuntimeQuery() {
         //Add run time query when query passed in the constructor is null.
         //String query = ProcessJobQueryUtil.getAutoWriteOffJobQuery(null);
         //return query;
        Loan__Org_Parameters__c orgPAram = loan.CustomSettingsUtil.getOrgParameters();
        decimal numberofdaysoverdue = orgPAram.WriteOffSuggestion__c ;
        List<String> allowableLoanStatuses = new List<String>();
        allowableLoanStatuses.add('Active - Good Standing');
        allowableLoanStatuses.add('Active - Bad Standing');
        allowableLoanStatuses.add('Active - Matured');
        loan__Loan_Account__c loanAccount;

        mfiflexUtil.ExecutionContext ec = mfiflexUtil.ExecutionContext.getExecContext();
        mfiflexUtil.ObjectCache loanOC = ec.getObject('LoanAccount');
        if(loanOC != null) {
            ec.deleteObject('LoanAccount');
        }
        loanOC = ec.createObject('LoanAccount', 'loan__Loan_Account__c', '');
         
        loanOC.addFields('id,name,loan__Interest_Remaining__c,Skip_AutoWriteOff__c,loan__Principal_Remaining__c,loan__Invalid_Data__c,loan__Loan_Balance__c,loan__Number_of_Days_Overdue__c ');
        loanOC.addNamedParameter('allowableLoanStatuses', allowableLoanStatuses); 
        loanOC.addNamedParameter('numberofdaysoverdue', numberofdaysoverdue);
        loanOC.setWhereClause('loan__Number_of_Days_Overdue__c >=:numberofdaysoverdue AND loan__Number_of_Days_Overdue__c != null AND loan__loan_status__c IN :allowableLoanStatuses AND loan__Invalid_Data__c=false AND Skip_AutoWriteOff__c=false ');
        loanOC.buildQuery();
        return loanOC.getQuery();
     }  
         
         

     /*global override String getRuntimeQueryForPipelinedExecution(Set<Id> records) {
         return null;
     }*/

     global override void doStart(Database.BatchableContext bc) {}
     
     /** 
         * doExecute(jobId,recordList)
         * This method calls writeOffImpl class to implement logic to write-off loans
         * @param  jobId         Database.BatchableContext 
         * @param  recordList    List<sObject> 
     */
    global override void doexecute(SchedulableContext sc) {
        
        CustomAutowriteoffDynamicJob job = new CustomAutowriteoffDynamicJob();
             Database.executebatch(job,1);
                 
         } 
    
    global override void doExecute(Database.BatchableContext BC, List<sObject> scope) {
        
         /*set<ID> loanIdsToWriteOff = new set<ID>();
         for(sObject sObj : scope){
            loanIdsToWriteOff.add(sObj.Id);
         }

         //loan.WriteOffImpl writeoffaloanset = new loan.WriteOffImpl();
        // loan.writeoffaloanset.writeOffLoans(loanIdsToWriteOff);

         //LogUtil.pop();*/
     }

     global override void doFinish(Database.BatchableContext bc) {
         
         
         /* try{
             
        // Get Org Params
        loan__Org_Parameters__c orgPAram = loan.CustomSettingsUtil.getOrgParameters();
        
        
        List<String> allowableLoanStatuses = new List<String>();
        allowableLoanStatuses.add('\'' + 'Active - Good Standing' + '\'');
        allowableLoanStatuses.add('\'' + 'Active - Bad Standing' + '\'');
        allowableLoanStatuses.add('\'' + 'Active - Matured' + '\'');

        //get custom query
        String query = 'SELECT Id, ' +
                                'Name, ' +
                                'Interest_Remaining__c, ' +
                                'Principal_Remaining__c, ' +
                                'Loan_Balance__c, ' +
                                'Fees_Remaining__c, ' +
                                'Capitalized_Interest__c, ' +
                                'Capitalized_Fee__c, ' +
                                'Interest_Posted__c, ' +
                                'Loan_Status__c, ' +
                                'Total_Overdue_Fees__c, ' +
                                'Total_Amount_Overdue__c, ' +
                                'Loan_Product_Name__c, ' +
                                'Delinquent_Amount__c, ' +
                                'Branch__c, ' +
                                'Uncleared_Written_Off_Amount__c, ' +
                                'ACH_On__c, ' +
                                'OT_ACH_Payment_Amount__c, ' +
                                'OT_ACH_Fee_Amount__c, ' +
                                'Number_of_Days_Overdue__c ' +
                            'FROM Loan_Account__c ' +    
                            'WHERE Number_of_Days_Overdue__c  >= ' + orgPAram.WriteOffSuggestion__c +
                            ' AND Number_of_Days_Overdue__c != null ' +
                            ' AND Loan_Status__c in ' + allowableLoanStatuses +
                            ' AND Invalid_Data__c = false' +
                            ' AND Skip_AutoWriteOff__c = false';
        
              loan.AutoWriteOffJob a = new loan.AutoWriteOffJob(query);
        
               //CustomAutoWriteOff j = new CustomAutoWriteOff();
               if(!test.isRunningTest()){  
               Database.executeBatch(a,50);
                }
                if(test.isRunningTest()){  //to increase test coverage
                    integer x = 2;
                    x = x/0;
                }    
       }
       catch(exception e)

       {
         
                batch.loan__Log_Level__c = 'ERROR';
                batch.loan__Message__c = 'ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
                batch.loan__Batch_Id__c = 'CustomAutowriteoffDynamicJob';
                insert batch;
            }*/
           
     }
   
}