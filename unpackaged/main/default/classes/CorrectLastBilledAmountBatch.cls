/*
* author: Anusha
* This batch is to correct last billed amount on loans(for LSP-284)
* 
*****************Modification History*****************************************************************
*  Modified by      Date            JIRA number
*Bhavya Maliwal  2022/07/07    LSP-284 : To automate the process the Holiday list has been 
								picked up from custom setting and based on coming holiday from date and to date has been calculated.
******************Modification History*****************************************************************/
global class CorrectLastBilledAmountBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    private String fromDate;
    private String toDate;
    private String query;
    loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
    Date systemDate = util.getCurrentSystemDate();
    Set<String> lastPaymentDue = new Set<String>();
    Set<String> neitherFirstNorLastPaymentDue = new Set<String>();
    Set<String> firstPaymentDue = new Set<String>();
    // LSP-284 : Bhavya Maliwal : created the schedulable method 
    global void execute(SchedulableContext SC){
        CorrectLastBilledAmountBatch job = new CorrectLastBilledAmountBatch(); 
        Database.executeBatch(job,200);
    }
    //end
    global Database.QueryLocator start(Database.BatchableContext bc){
        //LSP-284 : Bhavya Maliwal : Updated the logic for Holiday date and have automated it via custom setting 
        HolidaySetup__c holiday=[Select Start_Date__c,End_Date__c from HolidaySetup__c 
                                 where Start_Date__c>=:systemDate order by Start_Date__c ASC limit 1];
        system.debug(holiday);
        if(holiday!=null){
            fromDate=String.valueof(holiday.Start_Date__c);
            toDate=String.valueof(holiday.End_Date__c);
        }
        //end Bhavya Maliwal
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
        system.debug(listOfLoans);
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