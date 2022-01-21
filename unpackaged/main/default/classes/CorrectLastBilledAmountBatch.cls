/*
 * author: Anusha
 * This batch is to correct last billed amount on loans(for LSP-284)
 * 
 *****************Modification History*****************************************************************
 * 
 ******************Modification History*****************************************************************/
global class CorrectLastBilledAmountBatch implements Database.Batchable<sObject>, Database.Stateful{
    private String fromDate;
    private String toDate;
    private String query;
    loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
    Date systemDate = util.getCurrentSystemDate();
    Set<String> lastPaymentDue = new Set<String>();
    Set<String> neitherFirstNorLastPaymentDue = new Set<String>();
    Set<String> firstPaymentDue = new Set<String>();
    
    global CorrectLastBilledAmountBatch(Date fromDate, Date toDate){
        this.fromDate = String.valueOf(fromDate);
        this.toDate = String.valueOf(toDate);
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        query = 'Select id, name, loan__Pmt_Amt_Cur__c,loan__Disbursal_Date__c,loan__next_due_generation_date__c,loan__Payment_Amount__c,'
                                              + 'loan__next_installment_date__c, loan__Maturity_Date_Current__c, loan__Last_Installment_Date__c, loan__Last_Billed_Amount__c '
                                              + 'from loan__loan_account__c '
            								  + 'where loan__next_installment_date__c  >= '+ fromDate
                                              + ' and loan__next_installment_date__c <= '+ toDate
                                              + ' and loan__Loan_Status__c IN ('
            								  + '\''+ 'Active - Good Standing'+'\''+','+'\''+'Active - Bad standing'+'\''+')'
                                              + ' and loan__Pre_Bill_Days__c = 3';
        System.debug('query: '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        List<loan__loan_account__c> listOfLoans = (List<loan__loan_account__c>)scope;
        try{
            CorrectLastBilledAmountHandler handler = new CorrectLastBilledAmountHandler(fromDate,toDate);
        	handler.process(listOfLoans,lastPaymentDue,neitherFirstNorLastPaymentDue,firstPaymentDue);
        }catch(Exception e){
            System.debug(logginglevel.DEBUG,'CorrectLastBilledAmountBatch failed with error: '+e.getMessage());
            loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
                 batch.loan__Log_Level__c = 'ERROR';
                 batch.loan__Message__c = 'Unprocessed loans:: '+listOfLoans+' ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString();
                 batch.loan__Batch_Id__c = 'CorrectLastBilledAmountBatch';
                 insert batch;
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        //Send out an e-mail after the processing is over
        String emailBody = 'Last billed amount correction ran by ' + UserInfo.getName() + ' at ' + systemDate;
        emailBody += '\nPlease find the list of processed loans below: ';
        emailBody += '\n\nLoans where last payment was due: ';
        if(lastPaymentDue.size()==0) emailBody += 'None';
        else{
            for(String pmt : lastPaymentDue){
                emailBody += '\n'+pmt.trim();
            }
        }
        
        emailBody += '\n\nLoans where first payment was due: ';
        if(firstPaymentDue.size()==0) emailBody += ' None';
        else{
            for(String pmt : firstPaymentDue){
                emailBody += '\n'+pmt.trim();
            }
        }
        
        emailBody += '\n\nLoans where neither first nor last payment was due: ';
        if(neitherFirstNorLastPaymentDue.size()==0) emailBody += ' None';
        else{
            for(String pmt : neitherFirstNorLastPaymentDue){
                emailBody += '\n'+pmt.trim();
            }
        }
        emailBody += '\n\n ** This is a system generated email. Please do not reply';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<string> toAddresses = Label.LastBilledAmountemailRecepients.split(';');
        toAddresses.add(Userinfo.getUserEmail());
        mail.setToAddresses(toAddresses);
        mail.setSubject('Last Billed Amount correction batch run');
        mail.setPlainTextBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}