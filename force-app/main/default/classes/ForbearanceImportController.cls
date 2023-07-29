/*
 * author: Anusha
 * Ths controller is to parse CSV file thats uploaded for skip-a-pay actio
 *
 *****************Modification History*****************************************************************
 * Modified by      Date            JIRA number
 *    Pallavi       2020/01/14    CRM-952 (Completely automate the SAP processing for LoanOps/Produce errors/logs for failures.)
 * 	  Anusha		2021/04/08	  LSP-3 (Completely automate the SAP processing for LoanOps) - Changes to include bad loans in the mail
 ******************Modification History*****************************************************************/

public class ForbearanceImportController {
    public Blob csvFileBody{get;set;}
    public String csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public Map<String,String> loanlist{get;set;}
    public Integer loanSize{get;set;}
    public Map<String,String> loanToProcessSkipAPay{get;set;}
    public boolean isSkipaPayButtonDisabled{get;set;}
    public Integer numberOfSkips{get;set;}
    loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
    Date systemDate = util.getCurrentSystemDate();
    public List<loan__Loan_Account__c> BadLoans{get;set;}
    public List<loan__Loan_Account__c> GoodLoans{get;set;}
    public List<loan__Loan_Account__c> UnprocessedLoans{get;set;}
    public Map<String, String> badLoansMap = null;//LSP-3
    
      public ForbearanceImportController(){
        csvFileLines = new String[]{};
        loanlist = new Map<String,String>();
        loanToProcessSkipAPay = new Map<String,String>(); 
        GoodLoans = new List<loan__Loan_Account__c>();
        BadLoans = new List<loan__Loan_Account__c>();
        badLoansMap = new Map<String, String>();//LSP-3
        numberOfSkips = 0;     
        loanSize = 0;
        isSkipaPayButtonDisabled = true;
        system.debug('systemDate: '+systemDate);
      }
      
    /*
     * Method to parse input csv file
     * 
     */ 
      public void importCSVFile(){
          isSkipaPayButtonDisabled = false;
           try{
               csvAsString = csvFileBody.toString();
               csvFileLines = csvAsString.split('\n');
               for(Integer i=1; i<csvFileLines.size(); i++){
                   string[] csvRecordData = csvFileLines[i].split(',');
                   loanlist.put(csvRecordData[0],csvRecordData[1]);//key=loan name and value = number of skips
                }
               loanSize = loanlist.size();
               
               MW_Settings__c mc = MW_Settings__c.getOrgDefaults();
               for(loan__Loan_Account__c loan : [Select Id,Name, loan__Loan_Status__c from loan__Loan_Account__c
                                                 where Name IN : loanlist.keyset()]){
                    if(mc.ExcludeLoansForSkipAPay__c != null &&
                      	mc.ExcludeLoansForSkipAPay__c.contains(loan.loan__Loan_Status__c)){
                        BadLoans.add(loan);
                        badLoansMap.put(loan.name,loan.loan__Loan_Status__c);//LSP-3
                    }else{
                        GoodLoans.add(loan);
                        loanToProcessSkipAPay.put(loan.Name,loanlist.get(loan.Name));
                    }                                      
               }
               system.debug('BadLoans--------: '+BadLoans);
               system.debug('GoodLoans--------: '+GoodLoans);
               system.debug('loanlist--------: '+loanlist);
               system.debug('loanToProcessSkipAPay--------: '+loanToProcessSkipAPay);
            }
            catch (Exception e)
            {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data. Please make sure input csv file is correct');
                ApexPages.addMessage(errorMessage);
            }
  }
    
    /*
     * Method to call batch file to perform skip a pay action
     * 
     */
    public void performSkipaPayLoan(){
        system.debug('loanToProcessSkipAPay: '+loanToProcessSkipAPay);   
        try{
            ForbearanceLoanBatch batch = new ForbearanceLoanBatch(loanToProcessSkipAPay,badLoansMap);//LSP-3
            Database.executeBatch(batch, 1);
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO,'Loans are queued up for processing. You will be notified with an email.');
            ApexPages.addMessage(errorMessage);
        }catch(Exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
            ApexPages.addMessage(errorMessage);
        }
                       
        isSkipaPayButtonDisabled = true;//once the action is complete, disable 'Skip a Pay' button to make sure there are no multiple submissions
        //upload the document once processing is complete
        Document uploadDoc = new Document();
        uploadDoc.Body = csvFileBody;
        if(!Test.isRunningTest()){
          uploadDoc.FolderId = [select id from folder where name = 'Skip a Pay'].Id;
            uploadDoc.Name = 'SkipaPay'+systemDate.format();
        }
        uploadDoc.Description = 'File uploaded for skip-a-pay action on '+systemDate.format();
        uploadDoc.IsPublic = true;
        uploadDoc.Type = 'csv';
        if(!Test.isRunningTest()){
            insert uploadDoc;
        }
    }
}