/**
 * Interface - Hook provided to implement Strategy-1000
 * 
 * 
 * @author - Nikhil Chawra
 * **/

Global interface DM_ComputeStrategy_Interface {
    List<DM_Repayment_Schedule_Summary__c> computeRSS(Id ParentId);
    List<dm_Loan_Payment_Transaction__c> computeLPT(Id ParentId);
    List<dm_Loan_Disbursal_Transaction__c> computeLDT(Id ParentId);
    List<DM_Bill__c> computeBill(Id ParentId);
    List<DM_Charge__c> computeCharge(Id ParentId);
    List<DM_Automated_Payment_Setup__c> computeAPS(Id ParentId);
    List<DM_Repayment_Schedule__c> computeRS(Id ParentId); 
    List<DM_Accrual_Entry__c> computeAccrual(Id ParentId);
    List<DM_Interest_Posting_Transaction__c> computeIPT(Id ParentId);
    List<DM_Investment_Order__c> computeInvestorLoan(Id ParentId); 
    
    // added by NehaDM
    List<DM_Disbursal_Transaction_Distribution__c> computeDDI(Id ParentId);
    List<DM_Multi_Step_Loan_Setup__c> computeMSLS(Id ParentId);
    //List<DM_Investor_Loan_Transaction__c> computeInvLT(Id ParentId); 
    /*pallavi*/
    List<DM_Due_Payment__c> computeDPT(Id ParentId);
    /*pallavi*/
    /*pallavi*/
    List<DM_Repayment_Transaction_Reversal__c> computetxnRev(Id ParentId);
    List<DM_Repayment_Plan__c> computerepPlan(Id ParentId);
    /*pallavi*/
}