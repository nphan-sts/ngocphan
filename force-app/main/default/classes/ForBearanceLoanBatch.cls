/********************************************************************************************************************************
 * author Anusha
 * 
 * This batch is to skip a month's payment for a set of loan ids as borrowers have issues making payment due to COVID-19 pandemic
 * and reschedule those loans to start repayment later after a month
 * 
 * @params : set of loan ids for which skip-a-pay is requested
 * results - 1. given loans are rescheduled
 *        	 2. loan maturity date is moved accordingly
 * 
 *****************Modification History*****************************************************************
 * Modified by      Date            JIRA number
 *    Pallavi       2020/01/14    CRM-952 (Completely automate the SAP processing for LoanOps/Produce errors/logs for failures.)
 * 	  Anusha		2021/02/18	  LSP-3 (Completely automate the SAP processing for LoanOps)
 * 	  Anusha		2021/04/08	  LSP-3 Changes to include bad loans in the mail   
 ******************Modification History*****************************************************************/

global class ForBearanceLoanBatch implements Database.batchable<sObject>,Database.stateful {	//CRM-952
    
    String query;
    Set<Id> loanAccountIdSet = new Set<Id>();
    Set<String> loanAccountNameSet = new Set<String>();
    Map<String,String> loanAccountNameMap = new Map<String,String>();
    List<loan__Loan_Account__c> UnprocessedLoans = new List<loan__Loan_Account__c>();
    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
    loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
    Date systemDate = util.getCurrentSystemDate();
    DateTime systemDateTime = util.getCurrentSystemDateTime();	//CRM-952
    Integer numberOfSkips = 1;
    Map<String,String> contractSAPerror = new Map<String,String>();	//CRM-952
    
    global ForBearanceLoanBatch (Set<Id> LoanIDs){     
        
        loanAccountIdSet = LoanIDs;
        System.debug(logginglevel.DEBUG,'loanAccountIdSet +++'+loanAccountIdSet);
        
        query = 'Select id,name,lead_Guid__c,loan__First_Installment_Date__c, '+
                         'Application__r.genesis__Monthly_Debt_Payments__c,'+
                         'loan__Payment_Amount__c,'+
                         'loan__Loan_Status__c,'+
                         'loan__Accrual_Start_Date__c,'+
                         'Application__r.Loan_Origination_Date__c,'+
                         'loan__Last_Installment_Date__c,'+
                         'loan__Interest_Rate__c,'+
                         'loan__Frequency_of_Loan_Payment__c,'+
                         'loan__Pmt_Amt_Cur__c,'+
                         'loan__Next_Installment_Date__c,'+
                         'loan__Previous_Installment_Date__c,'+
                         'loan__Maturity_Date_Current__c,'+
                         'loan__Disbursal_Date__c,'+
                         'loan__Term_Cur__c,'+
                   		 'Skipped_a_pay_Date__c,'+
                         'Skipped_a_Pay__c,'+
                         '(Select id,name,'+
                         'loan__Is_Archived__c,'+
                         'loan__Due_Date__c'+
                         ' from loan__Repayment_Schedule__r),'+
                         '(select id,name from loan__Repayment_Plan__r),'+
                         'CPD_Reason__c,'+
                         'CPD_Expire_Date__c,'+
            	/*LSP-3 start */
            			 'U_LoanModTermExt__c,'+
            			 'loan__Oldest_Due_Date__c,'+
            			 'U_LoanModForbearance__c,'+
            			 'Hardship_New_Maturity_Date__c,'+
            			 'U_LoanModForbearDt__c,'+
            			 'Hardship_Request_Date__c'+
                /*LSP-3 end */
                         ' from loan__Loan_Account__c'+
                         ' where Id in : loanAccountIdSet';            
    }
    
    global ForBearanceLoanBatch (Set<String> LoanNames){     
        
        loanAccountNameSet = LoanNames;
        System.debug(logginglevel.DEBUG,'loanAccountIdSet +++'+loanAccountIdSet);
        
        query = 'Select id,name,lead_Guid__c,loan__First_Installment_Date__c, '+
                         'Application__r.genesis__Monthly_Debt_Payments__c,'+
                         'loan__Payment_Amount__c,'+
                         'loan__Loan_Status__c,'+
                         'loan__Accrual_Start_Date__c,'+
                         'Application__r.Loan_Origination_Date__c,'+
                         'loan__Last_Installment_Date__c,'+
                         'loan__Interest_Rate__c,'+
                         'loan__Frequency_of_Loan_Payment__c,'+
                         'loan__Pmt_Amt_Cur__c,'+
                         'loan__Next_Installment_Date__c,'+
                         'loan__Previous_Installment_Date__c,'+
                         'loan__Maturity_Date_Current__c,'+
                         'loan__Disbursal_Date__c,'+
                         'loan__Term_Cur__c,'+
                   		 'Skipped_a_pay_Date__c,'+
                         'Skipped_a_Pay__c,'+
                         '(Select id,name,'+
                         'loan__Is_Archived__c,'+
                         'loan__Due_Date__c'+
                         ' from loan__Repayment_Schedule__r),'+
                         '(select id,name from loan__Repayment_Plan__r),'+
                         'CPD_Reason__c,'+
                         'CPD_Expire_Date__c,'+
            /*LSP-3 start */
            			 'U_LoanModTermExt__c,'+
            			 'loan__Oldest_Due_Date__c,'+
            			 'U_LoanModForbearance__c,'+
            			 'Hardship_New_Maturity_Date__c,'+
            			 'U_LoanModForbearDt__c,'+
            			 'Hardship_Request_Date__c'+
            /*LSP-3 end */
                         ' from loan__Loan_Account__c'+
                         ' where Name in : loanAccountNameSet';            
    }
    
    global ForBearanceLoanBatch (Map<String,String> LoanNames, Map<String,String> badLoansMap){//LSP-3 Changes to include bad loans in mail
        loanAccountNameSet = LoanNames.keySet();
        loanAccountNameMap = LoanNames;        
        System.debug(logginglevel.DEBUG,'loanAccountNameMap +++'+loanAccountNameMap);       
        contractSAPerror.putAll(badLoansMap);//LSP-3 Changes to include bad loans in mail
        
        query = 'Select id,name,lead_Guid__c,loan__First_Installment_Date__c, '+
                         'Application__r.genesis__Monthly_Debt_Payments__c,'+
                         'loan__Payment_Amount__c,'+
                         'loan__Loan_Status__c,'+
                         'loan__Accrual_Start_Date__c,'+
                         'Application__r.Loan_Origination_Date__c,'+
                         'loan__Last_Installment_Date__c,'+
                         'loan__Interest_Rate__c,'+
                         'loan__Frequency_of_Loan_Payment__c,'+
                         'loan__Pmt_Amt_Cur__c,'+
                         'loan__Next_Installment_Date__c,'+
                         'loan__Previous_Installment_Date__c,'+
                         'loan__Maturity_Date_Current__c,'+
                         'loan__Disbursal_Date__c,'+
                         'loan__Term_Cur__c,'+
                   		 'Skipped_a_pay_Date__c,'+
                         'Skipped_a_Pay__c,'+
                         '(Select id,name,'+
                         'loan__Is_Archived__c,'+
                         'loan__Due_Date__c'+
                         ' from loan__Repayment_Schedule__r),'+
                         '(select id,name from loan__Repayment_Plan__r),'+
                         'CPD_Reason__c,'+
                         'CPD_Expire_Date__c,'+
            /*LSP-3 start */
            			 'U_LoanModTermExt__c,'+
            			 'loan__Oldest_Due_Date__c,'+
            			 'U_LoanModForbearance__c,'+
            			 'Hardship_New_Maturity_Date__c,'+
            			 'U_LoanModForbearDt__c,'+
            			 'Hardship_Request_Date__c'+
            /*LSP-3 end */
                         ' from loan__Loan_Account__c'+
                         ' where Name in : loanAccountNameSet';            
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){                           
        System.debug('In Database.QueryLocator : '+query);    
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug(logginglevel.DEBUG,'*** Method execute(+)scope *** '+ scope);
        List<loan__loan_account__c> listOfLoans = (List<loan__loan_account__c>)scope;                   
        for(loan__loan_account__c loan : listOfLoans ){
            if(loanAccountNameMap != null && loanAccountNameMap.size()>0){
              numberOfSkips = Integer.valueOf((loanAccountNameMap.get(loan.Name)).trim());
          }else numberOfSkips = 1;
            System.debug(logginglevel.DEBUG, 'Processing Loan :: '+loan.name);
            try{                                                                     
                 ForBearanceLoanHelper helper = new ForBearanceLoanHelper(loan,numberOfSkips);
                 helper.rescheduleLoan(contractSAPerror);  //CRM-952             
            }catch(Exception e){
                 System.debug(logginglevel.DEBUG,'Failed to reschedule loan : '+loan.Name);
                 batch.loan__Log_Level__c = 'ERROR';
                 batch.loan__Message__c = ' Reschedule failed for ::'+ loan.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
                 batch.loan__Batch_Id__c = 'ForBearanceLoanBatch';
                 insert batch;
                 contractSAPerror.put(loan.Name,batch.loan__Message__c);	//CRM-952
            }
        }
    } 
    /*CRM-952*/
    public void finish(Database.BatchableContext BC){
        String emailBody = 'Skip a Pay Ran by ' + UserInfo.getName() + ' at ' + systemDateTime;	//CRM-952
        emailBody += ' \n\n Please find below the list of unprocessed loans in skip a pay';
        /*CRM-952*/
        Set<String> contractName = new Set<String>();
        contractName = contractSAPerror.keySet();
        if(contractName.size()==0)
            emailBody += '\n\n All the loans are processed for skip a pay.';
        for(String contract : contractName){
            emailBody += '\n'+contract + ' '+ contractSAPerror.get(contract).trim();
        }
        
        emailBody += '\n\n Please find below the list of processed loans in skip a pay';
        
        List<loan__Loan_Account__c> processedLoans = [Select Id,Name from loan__Loan_Account__c
                                                     where (Name IN : loanAccountNameSet OR ID IN : loanAccountIdSet)
                                                     and name not in: contractName];
        if(processedLoans.size()==0)
            emailBody += '\n\n No contract was processed successfully for skip a pay.';
        for(loan__Loan_Account__c loansNotSkipped : processedLoans){
            emailBody += '\n'+loansNotSkipped.name;                                             
        }                                                 
        /*CRM-952*/
        emailBody += '\n\n ** This is a system generated email.';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<string> toAddresses = Label.MW_SkipAPayEmailRecipients.split(';');
        toAddresses.add(Userinfo.getUserEmail());
        mail.setToAddresses(toAddresses);
        mail.setSubject('Skip a pay - Processed/Unprocessed loans ');	//CRM-952
        mail.setPlainTextBody(emailBody);	//CRM-952
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    /*CRM-952*/
}