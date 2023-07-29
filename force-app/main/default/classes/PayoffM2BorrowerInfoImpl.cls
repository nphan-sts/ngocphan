Global class PayoffM2BorrowerInfoImpl implements loan.CRBorrowerInfoInterface2 {

    private Contact c;
    private Account a;
    
    public void setBorrower(SObject b){
        if (b instanceof Contact) {
            this.c = (Contact) b;
        } else if(b instanceof Account) {
            this.a = (Account) b;
        }
    }
    
    public loan.CRBorrowerInfo getBorrowerInfo(){
        return new loan.CRBorrowerInfo('Borrower',
                                c != null ? c.firstName : a.peer__First_Name__c,
                                c != null? c.LastName : a.peer__Last_Name__c,
                                '',
                                c != null ? c.ints__Social_Security_Number__c : a.loan__SOCIAL_SECURITY_NUMBER__c,
                                c != null ? (c.MailingStreet!=null?c.MailingStreet.replace('\n', ''):'') : sanitizeAddress(a.Address_1__c),
                                '',
                                c != null ? (c.MailingCity!=null?c.MailingCity.replace('\n', ''):'') : sanitizeAddress(a.City__c),
                                c != null ? (c.MailingState!=null ? c.MailingState.replace('\n', '').subString(0,2) : '') : (a.State__c != null ? sanitizeAddress(a.State__c) : 'TEST'),
                                c != null ? (c.MailingPostalCode!=null?c.MailingPostalCode.replace('\n', '').leftPad(5).replaceAll(' ', '0') :'')
                                                : (a.ZIP_Code__c != null ? a.ZIP_Code__c : 'TEST'),
                                c != null ? (c.MailingCountry!=null?c.MailingCountry.replace('\n', ''):'') : a.BillingCountry,
                                'US',
                                null,
                                c != null ? c.Birthdate : a.peer__Date_of_Birth__c,
                                c != null ? sanitizePhone(c.Phone) 
                                            : sanitizePhone(a.Phone),
                                '',
                                null,
                                null,
                                null
                                );                              
    }

    private String sanitizePhone(String s) { 
        return s != null ? s.replace('&', '').replace(',', '').replace('\'', '')
                            .replace('@', '').replace('^', '').replace('/', '').replace('%', '')
                                .replace('!', '').replace('$', '').replace('*', '').replace('(', '').replace(')', '')
                                    .replace('-', '').replace(' ', '').replace('+', '') : null;
    }
    
    private String sanitizeAddress(String s) {
        return s!= null ? s.replace('&', '').replace(',', ' ').replace('\'', '')
                            .replace('@', '').replace('^', '').replace('%', '').replace('\n', '').replace('\r', '')
                                .replace('!', '').replace('$', '').replace('*', '').replace('(', '').replace(')', '') : null;
    }

    public loan.CRBorrowerInfo getCoBorrowerInfo() {
        return null;                          
    }
   
   
   public String getLoanNumber(loan__Loan_Account__c loan){
       /*if (loan.External_Loan_Account_Number__c != null){
          return loan.External_Loan_Account_Number__c.replace('-', '');
       }*/
       return loan.name.replace('-', '');
       //return loan.loan__Loan_Account_External_Id__c.replace('-', '');
    }

    
    public String getLoanAccountType(loan__Loan_Account__c loan){
       
       String accTypeCode = (loan.loan__Metro2_Account_Type_Code__c != null ? loan.loan__Metro2_Account_Type_Code__c : '01');
       //return loan.loan__Metro2_Account_Type_Code__c ;
       return '01'; //returning 01 for Unsecured loans
       //return accTypeCode.substring(0,2) ;
    }
    
    global virtual String getLoanIdQuery() {
        
        
        //String loanId = '\'LAI-00001412\'' ; 

        loan.globalLoanUtilfacade util = new loan.globalLoanUtilfacade();
        Date SystemDate = util.getCurrentSystemDate();
        Date lastDayOfMonth = SystemDate.toStartOfMonth().addDays(Date.daysInMonth(SystemDate.toStartOfMonth().year(), SystemDate.toStartOfMonth().month()) - 1);
        if (SystemDate < lastDayOfMonth){
            SystemDate = lastDayOfMonth.toStartOfMonth().addDays(-1);
        }
        String dateStr =String.valueOf(SystemDate); //= String.valueOf(iDate);
        String reportingClosedDateStr =String.valueOf(SystemDate.addMonths(-2)); //= String.valueOf(iDate);
        String reportingWrittenOffDateStr =String.valueOf(SystemDate.addMonths(-6)); //= String.valueOf(iDate);

        //Date systemDate = SystemDateUtil.getCurrentSystemDate();
        //Integer systemDay = systemDate.day();
        String allowabledLoanStatuses = '\'' + loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING + '\'' + ',' +
                                        '\''+ loan.LoanConstants.LOAN_STATUSACTIVE_BAD_STANDING + '\'' + ',' +
                                        '\''+ loan.LoanConstants.LOAN_STATUS_CLOSED_WRITTEN_OFF + '\'' + ',' +
                                        '\''+ loan.LoanConstants.LOAN_STATUS_CLOSED_OBLIGATIONS_MET + '\'' + ',' +
                                        '\''+ loan.LoanConstants.LOAN_STATUS_ACTIVE_MATURED + '\'';

        String allowabledActiveLoanStatuses = '\'' + loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING + '\'' + ',' +
                                        '\''+ loan.LoanConstants.LOAN_STATUSACTIVE_BAD_STANDING + '\'' + ',' +
                                        '\''+ loan.LoanConstants.LOAN_STATUS_ACTIVE_MATURED + '\'';

        String allowabledClosedLoanStatuses = '\''+ loan.LoanConstants.LOAN_STATUS_CLOSED_OBLIGATIONS_MET + '\'';
        String allowabledWrittenOffLoanStatuses = '\''+ loan.LoanConstants.LOAN_STATUS_CLOSED_WRITTEN_OFF + '\'';


        String allowabledConditions = '\'' + Metro2Constants.CCCD + '\'' + ',' +
                                        '\''+ Metro2Constants.CIIC + '\'' + ',' +
                                        '\''+ Metro2Constants.SPCC + '\'' + ',' +
                                        '\''+ Metro2Constants.SCB + '\'';


        return 'SELECT ID ' +
                'FROM loan__Loan_Account__c ' +
                'WHERE ((loan__Loan_Status__c  IN (' + allowabledActiveLoanStatuses + ') ) '+
                '    OR (loan__Loan_Status__c IN ('+allowabledClosedLoanStatuses+') AND loan__closed_date__c >'+reportingClosedDateStr+') '+
                '    OR (loan__Loan_Status__c IN ('+allowabledWrittenOffLoanStatuses+') AND ((loan__Last_Payment_Date__c!= null AND loan__Last_Payment_Date__c  >'+reportingWrittenOffDateStr+') OR (loan__Charged_Off_Date__c!= null AND loan__Charged_Off_Date__c  >'+reportingWrittenOffDateStr+')) ))'+
                ' AND loan__Include_In_Metro2_File__c=true ' +
                ' and loan__disbursal_date__c  <= ' + dateStr +
                //' and name IN ( '+ loanID +') ' +
                ' and loan__Metro2_Account_pmt_history_date__c < ' + dateStr ;
    }
  


}