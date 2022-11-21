/* ****************Modification History******************
* Modified By       Date                    JIRA Number
*   Shakul        18/11/2022     LSP-1047(Custom Query Class to override the default query in LoanPaymentFilegenDynamicJob DAG)  
******************Modification History******************/

global class CustomQueryLoanPaymentFilegen implements clcommon.IBatchJobQuery{
    static final String Payment_Const = 'Loan Payments Clearing for all Modes';
    public static List<loan__Automated_Payment_Configuration__c> aPCs;
    global String getCustomQuery(String jobClassName){
        if(jobClassName == 'loan.LoanPaymentFilegenDynamicJob'){
            Set<String> paymentModes = new Set<String>();
            if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true){
                if(aPCs == null || aPCs.size() == 0) {
                    aPCs = [SELECT Id,loan__Payment_Mode__r.Name FROM loan__Automated_Payment_Configuration__c WHERE loan__Active__c = TRUE];
                }
                if (aPCs.size() > 0){
                    for(loan__Automated_Payment_Configuration__c aPC : aPCs){
                        paymentModes.add(aPC.loan__Payment_Mode__r.Name);
                    }
                }
            }
            paymentModes.add('ACH');
            Date iDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
            Integer daysInAdvanceToCreateFile = (Integer) loan.CustomSettingsUtil.getACHParameters().loan__Days_In_Advance_To_Create_File__c;
            if (daysInAdvanceToCreateFile == null) {
                daysInAdvanceToCreateFile = 0;
            }
            iDate = loan.CustomSettingsUtil.getACHParameters().loan__Debit_Payment_on_Previous_Working_Day__c ? loan.HolidayUtil.INSTANCE.getNextWorkingDate(iDate.addDays(daysInAdvanceToCreateFile)) : iDate.addDays(daysInAdvanceToCreateFile);
            Date startDate = iDate.addDays(-Integer.valueOf(System.Label.LPTNachaGenDaysConsideration));
            String ns = loan.CustomSettingsUtil.getOrgParameters().loan__Namespace_Prefix__c;
            mfiflexUtil.ExecutionContext ec = mfiflexUtil.ExecutionContext.getExecContext();
            mfiflexUtil.ObjectCache loanPmtOC = ec.getObject(Payment_Const);
            if(loanPmtOC != null) {
                ec.deleteObject(Payment_Const);
            }
            loanPmtOC = ec.createObject(Payment_Const,
                                        'Loan_Payment_Transaction__c',
                                        ns);
            loanPmtOC.addNamedParameter('pDate', startDate);
            loanPmtOC.addNamedParameter('csd', iDate);
            loanPmtOC.addNamedParameter('pModes', paymentModes);
            loanPmtOC.addFields('Cleared__c,'+
                                'Clearing_Date__c,'+
                                'Loan_Account__c,'+
                                'Automated_Payment_Setup__c,'+
                                'Transaction_Amount__c,'+
                                'Transaction_Date__c,'+
                                'Payment_Type__c,'+
                                'Payment_Mode__c,Payment_Mode__r.Name');
            loanPmtOC.setWhereClause( 'Transaction_Date__c >= :pDate'
                                     + ' AND Transaction_Date__c <= :csd'
                                     + ' AND Loan_Account__r.Invalid_Data__c = false'
                                     + ' AND Payment_Mode__r.Name IN :pModes '
                                     + ' AND Sent_To_ACH__c = false'
                                     + ' AND Sent_To_ACH_On__c = null'
                                     + ' AND Closure_Tolerance_Payment__c = false'
                                     + ' AND Rebate_Payment__c = false'
                                     + ' AND ACH_Filename__c = null'
                                    );
            loanPmtOC.setOrderClause('Payment_Mode__r.Name,Name');
            loanPmtOC.buildQuery();
            return loanPmtOC.getQuery();
        }
        return null;
    }
}