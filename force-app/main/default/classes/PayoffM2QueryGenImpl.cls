global class PayoffM2QueryGenImpl implements loan.M2QueryGen {

    public String getAccountQuery() {
        return 'loan__Account__c, ' +
               'loan__Account__r.Name, ' +
               'loan__Account__r.peer__First_Name__c, ' +
               'loan__Account__r.peer__Last_Name__c, ' +
               'loan__Account__r.loan__SOCIAL_SECURITY_NUMBER__c, ' +
               'loan__Account__r.peer__Date_of_Birth__c, ' +                             
              //'loan__Account__r.BillingStreet, ' +
               'loan__Account__r.Address_1__c, ' +
               'loan__Account__r.Address_2__c, ' +
               'loan__Account__r.City__c, ' +
               'loan__Account__r.State__c, ' +
               'loan__Account__r.Phone, ' +
               'loan__Account__r.ZIP_Code__c, ' +
               'loan__Account__r.BillingCountry ';
    }
    
    public String getContactQuery() {
        return 'loan__Contact__c, ' +
               'loan__Contact__r.lastName, ' +
               'loan__Contact__r.firstName, ' +
               'loan__Contact__r.ints__Social_Security_Number__c, ' +
               'loan__Contact__r.Birthdate, ' +
               'loan__Contact__r.Phone, ' +
               'loan__Contact__r.MailingStreet, ' +
               'loan__Contact__r.MailingCity, ' +
               'loan__Contact__r.MailingState, ' +
               'loan__Contact__r.MailingPostalCode, ' +
               'loan__Contact__r.MailingCountry ';
    }
    
    private String getCoborrowerQuery() {
        String query = '(SELECT ';
        query += getAccountQuery() + ', ';
        query += getContactQuery();
        query += ' FROM loan__Coborrowers__r)';
        return query;
    }
    
    public virtual String getLoanQuery() {
    
        Date SystemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        Date lastDayOfMonth = SystemDate.toStartOfMonth().addDays(Date.daysInMonth(SystemDate.toStartOfMonth().year(), SystemDate.toStartOfMonth().month()) - 1);
        if (SystemDate < lastDayOfMonth){
            SystemDate = lastDayOfMonth.toStartOfMonth().addDays(-1); 
        }    
        String dateStr =String.valueOf(SystemDate); 
        String reportingClosedDateStr =String.valueOf(SystemDate.addMonths(-2)); //= String.valueOf(iDate);
        String reportingWrittenOffDateStr =String.valueOf(SystemDate.addMonths(-6)); //= String.valueOf(iDate);
        
        
     //   String loanId = '\'LAI-00001412\'' ;   
        /*list<loan__month_end_loan_snapshot__c> ml = [select id, loan__Loan_Account_Id__c 
                                                     from loan__Month_End_Loan_Snapshot__c 
                                                    where loan__previous_installment_date__c = null
                                                      and loan__Snapshot_Date__c = :SystemDate];

    //    String loanId = '\''+''+'\',';
        for (loan__month_end_loan_snapshot__c m : ml) {
           loanId = loanId +'\''+ m.loan__Loan_Account_Id__c +'\',';
        }
        loanId = '('+loanId.substring(0,loanId.length()-1)+')';
        */


                
        //String dateStr =String.valueOf(new loan.GlobalLoanUtilFacade().getCurrentSystemDate()); //= String.valueOf(iDate);
        String allowabledLoanStatuses = '\'Active - Good Standing\'' + ',' + 
                                        '\'Active - Bad Standing\'' + ',' + 
                                        '\'Closed - Obligations Met\'' + ',' + 
                                        '\'Closed - Rescheduled\'' + ',' + 
                                        '\'Closed- Written Off\'' + ',' + 
                                        '\'Active - Matured\'';
        
        String allowabledActiveLoanStatuses ='\'Active - Good Standing\'' + ',' + 
                                        '\'Active - Bad Standing\'' + ',' +                                                                      
                                        '\'Active - Matured\'';

        String allowabledClosedLoanStatuses = '\'Closed - Rescheduled\'' + ',' + 
                                              '\'Closed - Obligations met\'';    
        String allowabledWrittenOffLoanStatuses = '\'Closed- Written Off\''; 
                                          
        String allowabledConditions ='\'Open Compliance Condition(METRO2)\'' + ',' + 
                                        '\'Open Consumer Information(METRO2)\'' + ',' +    
                                        '\'Open Special Condition(METRO2)\'' + ',' +                                                                      
                                        '\'Stop Credit Bureau\'';   
                                                
        return 'SELECT ID, ' +
                'Name, ' +
                'loan__Loan_Account_External_Id__c, ' +
                'loan__Frequency_of_Loan_Payment__c, ' +
                'loan__Term_Cur__c, ' +
                'loan__Delinquency_Grace_Days__c,' +
                'loan__Pmt_Amt_Cur__c, ' +
                'loan__Metro2_Account_Status_Code__c, ' +
                'loan__Metro2_CIIC_Date__c, ' +
                'loan__Metro2_CCCD_Date__c, ' +
                'loan__Metro2_Compliance_Condition_Code__c, ' +
                'loan__Metro2_Consumer_Information_Code__c, ' +
                'loan__Metro2_Account_Type_Code__c, ' +
                'loan__Metro2_Payment_Rating__c, ' +
                'loan__Metro2_Portfolio_Type__c, ' +
                'loan__Last_Payment_Amount__c, '+
                'loan__Interest_Rate__c, '+
                'loan__Principal_Remaining__c, '+
                'loan__Metro2_Payment_History__c, ' +
                'loan__Metro2_Special_Comment__c, ' +
                'loan__Metro2_Account_highest_bal_amount__c, ' +
                'loan__Metro2_Account_pmt_history_date__c, '+
                'loan__Metro2_First_Delinquency_Date__c , '+
                'loan__Loan_Amount__c, ' +
                'loan__closed_date__c, '+                
                'loan__Pay_Off_Amount_As_Of_Today__c, ' +
                'loan__Charged_Off_Fees__c, '+
                'loan__Charged_Off_Interest__c, '+
                'loan__Charged_Off_Principal__c, '+
                'loan__Last_Payment_Date__c , '+
                'loan__Amount_to_Current__c, ' +
                'loan__Charged_Off_Date__c, '+
                'loan__Time_Counting_Method__c, '+                
                'loan__Write_off_Tolerance_Amount__c, ' +
                'loan__Loan_Status__c,loan__Product_Type__c, ' +
                'loan__Previous_Installment_Date__c, ' +
                'loan__Disbursal_Date__c, ' +
                'loan__Loan_Effective_Date__c, ' +
                'loan__Payment_Frequency_Cycle__c, ' +
                'loan__Delinquent_Amount__c, ' +
                'loan__Oldest_Due_Date__c, '+
                'SystemModStamp, ' +
                '(select Id,Name, ' +
                            ' loan__Fees__c, ' +
                            ' loan__Interest__c, ' +
                            ' loan__Principal__c, ' +
                            ' loan__Excess__c, ' +
                            ' loan__Cleared__c, ' +
                            ' loan__Reversed__c, ' +
                            ' loan__Transaction_Amount__c, ' +
                            ' loan__Transaction_Date__c, ' +
                            ' loan__Payment_Mode__c, ' +
                            ' loan__payment_mode__r.name, ' +
                            ' loan__Rejected__c, ' +
                            ' CreatedDate ' +
                        ' from loan__Loan_Payment_Transactions__r '+
                        ' where loan__Cleared__c=true '+
                        ' and loan__Reversed__c = false '+  
                        ' order by loan__Transaction_Date__c desc), '+   
             '(select Id, name,' +
                         'loan__Balance_Amount__c, ' +
                         'loan__Fees_Billed__c,'+
                         'loan__Fees_Paid__c, '+
                         'loan__Due_Amt__c, ' +
                         'loan__Due_Date__c, ' +
                         'loan__Due_Type_Description__c, ' +
                         'loan__Due_Type__c, ' +
                         'loan__Payment_Amt__c, ' +
                         'loan__DD_Primary_Flag__c , '+
                         'loan__Payment_Date__c, ' +
                         'loan__Payment_Satisfied__c, ' +
                         'loan__Tolerance__c, ' +
                         'loan__Transaction_Date__c ' +                            
                    'from loan__Dues_Details__r ' +
                   'where loan__DD_Primary_Flag__c = true ' +
                   'order by loan__Due_Date__c desc), ' +                        
                 '(select Id,Name, ' +
                            ' loan__Action__c, ' +
                            ' loan__End_Date__c, ' +
                            ' loan__Reason_Code__c, ' +
                            ' loan__Start_Date__c, ' +
                            ' loan__Result__c, ' +
                            ' loan__Reason_Code__r.id '+
                        ' from loan__Loan_Account_Conditions__r '+
                        ' where loan__Result__c in (' +allowabledConditions +') '+
                        ' and loan__start_Date__c <= ' + dateStr +   
                        ' and (loan__end_Date__c = null OR loan__end_Date__c > ' + dateStr + ') '+             
                        ' and loan__Enabled_Flag__c = true '+   
                        ' order by loan__Result__c,loan__Start_Date__c), '+                                           
                getAccountQuery() + ' , ' +
                getContactQuery() + ' , ' +
                getCoborrowerQuery() + ' ' +
                'FROM loan__Loan_Account__c '+
                'WHERE ((loan__Loan_Status__c  IN (' + allowabledActiveLoanStatuses + ') ) '+ 
                '    OR (loan__Loan_Status__c IN ('+allowabledClosedLoanStatuses+') AND loan__closed_date__c >'+reportingClosedDateStr+')'+
                '    OR (loan__Loan_Status__c IN ('+allowabledWrittenOffLoanStatuses+') AND ((loan__Last_Payment_Date__c!= null AND loan__Last_Payment_Date__c  >'+reportingWrittenOffDateStr+') OR (loan__Charged_Off_Date__c!= null AND loan__Charged_Off_Date__c  >'+reportingWrittenOffDateStr+')) ))'+
                ' AND loan__Include_In_Metro2_File__c=true ' +  
                ' and loan__Metro2_Account_pmt_history_date__c < ' + dateStr + 
                //' and loan__First_Installment_Date__c  <= ' + dateStr + 
                ' AND loan__disbursal_Date__c <= ' + dateStr + 
               // ' and name IN ('+ loanId + ') '+
                ' ORDER BY loan__Contact__r.lastName';
    }
    
}