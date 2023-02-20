/* ****************Modification History******************
* Modified By       Date                    JIRA Number
*   Shakul        09/02/2023     LPC-239(Custom Batch Job created to calculate interest accrual in advance for Feb Month for loan tape reporting purpose)  
******************Modification History******************/
public class InterestAccrualFebMonthBatch implements Database.Batchable<SObject>,Schedulable{
    String query;
    List<String> statusSet = System.Label.ActiveStatus.split(',');
    Date currentSystemDate = (new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        query = 'SELECT id FROM loan__Loan_Account__c WHERE loan__Product_Type__c = \''+loan.LoanConstants.FLEXIBLE_AMZ+'\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<loan__loan_account__c> scope){
        List<loan__loan_account__c> newLoanAccs = new List<loan__loan_account__c>();
        List<loan__loan_account__c> filteredLoanAccs = [SELECT Id,loan__Interest_Rate__c,loan__Loan_Status__c,loan__Interest_Accrued_Not_Due__c,loan__Principal_Remaining__c,loan__Last_Accrual_Date__c,
                                                        (SELECT id, loan__Balance__c FROM loan__Dues_Details__r WHERE loan__DD_Primary_Flag__c = true AND loan__Due_Date__c <=: currentSystemDate order by loan__Due_Date__c desc LIMIT 1) 
                                                        FROM loan__Loan_Account__c
                                                        WHERE Id IN:scope];
        Integer month = currentSystemDate.month();
        Integer day = currentSystemDate.day();
        Integer daysInterestToAdd=day==Integer.valueOf(System.Label.DaysFebMonthNonLeapYear)?2:1;
        Decimal accuredInterest = 0;
        if(!filteredLoanAccs.isEmpty()){
            for(loan__Loan_Account__c eachLoan : filteredLoanAccs){
                System.debug('eachLoan.loan__Last_Accrual_Date__c--'+eachLoan.loan__Last_Accrual_Date__c);
                if(eachLoan.loan__Last_Accrual_Date__c <= currentSystemDate && statusSet.contains(eachLoan.loan__Loan_Status__c)){
                    if(month == 2){
                          if(eachLoan.loan__Dues_Details__r.size() > 0){
                                accuredInterest = (eachLoan.loan__Dues_Details__r.get(0).loan__Balance__c*eachLoan.loan__Interest_Rate__c *daysInterestToAdd)/36000.00;
                            }
                            else if(eachLoan.loan__Dues_Details__r.size() == 0){
                                accuredInterest = (eachLoan.loan__Principal_Remaining__c*eachLoan.loan__Interest_Rate__c *daysInterestToAdd)/36000.00;
                            }
                    }
                    eachLoan.Interest_Accrued_Feb30__c = eachLoan.loan__Interest_Accrued_Not_Due__c + accuredInterest;
                }
                else{
                    eachLoan.Interest_Accrued_Feb30__c = 0;
                }
                accuredInterest = 0;
                newLoanAccs.add(eachLoan);
            }
        }
        if(!newLoanAccs.isEmpty()){
            update newLoanAccs;
        }
    }
    
    public void execute(SchedulableContext sc){
        InterestAccrualFebMonthBatch iaFebMnth = new InterestAccrualFebMonthBatch();
        Database.executeBatch(iaFebMnth, Integer.valueOf(System.Label.InterestAccrualFebMonthBatchSize));
    }
    
    public void finish(Database.BatchableContext bc){}
}