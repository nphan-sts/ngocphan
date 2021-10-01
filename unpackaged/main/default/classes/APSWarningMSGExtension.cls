public class APSWarningMSGExtension {
    private final loan__Automated_Payment_Setup__c autoPayment;
    private final String WEEK_SATURDAY = 'SAT';
    private final String WEEK_SUNDAY = 'SUN';
    @TestVisible
    private final String WARNING_MESSAGE = 'WARNING: APS debit date must be on the NEXT ELIGIBLE BUSINESS Day.';
    public APSWarningMSGExtension(ApexPages.StandardController stdController) {
        this.autoPayment = (loan__Automated_Payment_Setup__c)stdController.getRecord();
    }
    public String getErrorMessage() {
        loan__Automated_Payment_Setup__c paymentSetUp = [SELECT CreatedDate, loan__Debit_Date__c, Next_Business_Debit_Date__c FROM loan__Automated_Payment_Setup__c WHERE Id=:this.autoPayment.Id];
        Date dtCreateDate = Date.newInstance(paymentSetUp.CreatedDate.year(), paymentSetUp.CreatedDate.month(), paymentSetUp.CreatedDate.day());
        Date weekStart = dtCreateDate.toStartOfWeek();
        Date weekStartDebit = paymentSetUp.loan__Debit_Date__c.toStartOfWeek();
        Boolean blnFlag = false;
      
        blnFlag = IsHoliday(paymentSetUp.loan__Debit_Date__c);
        if(blnFlag) {
            return WARNING_MESSAGE;
        }
        Time timeExpected = Time.newInstance(16,0,0,0);
        DateTime expectedDateTime = DateTime.newInstance(dtCreateDate, timeExpected);
        Long expected = expectedDateTime.getTime();
        Long actual = paymentSetUp.CreatedDate.getTime();
        Long timeavailable = (actual - expected);
        if((IsWeekEnd(weekStart,dtCreateDate)
           || IsWeekEnd(weekStartDebit, paymentSetUp.loan__Debit_Date__c))  
           || (weekStart.daysBetween(dtCreateDate) == 5 && timeavailable > 0         
           && (isWeekEnd(weekStartDebit, paymentSetUp.loan__Debit_Date__c) 
               || (IsHoliday(paymentSetUp.loan__Debit_Date__c) || IsHoliday(paymentSetUp.loan__Debit_Date__c.addDays(-1)))))    
           ) {
           return WARNING_MESSAGE;
        } 
        
        return '';
   
       }
    
    public Boolean IsHoliday(Date dtDate) {
        Boolean isHoliday = false;
        List<Holiday> holidayList = [SELECT Name, ActivityDate FROM Holiday WHERE ActivityDate =:dtDate];
         if(holidayList != null && holidayList.size() > 0) {
            for(Holiday hDay : holidayList) {
                if(dtDate.daysBetween(hday.ActivityDate) == 0) {
                    isHoliday = true;
                }
            }  
        }
        return isHoliday;
    }
    
    public String WeekendName(Date dtWeekStartDate, Date dtDebitDate) {
        String weekName = '';
        if(dtWeekStartDate.daysBetween(dtDebitDate) == 6) {
            weekName = WEEK_SATURDAY;
        }
        if(dtWeekStartDate.daysBetween(dtDebitDate) == 0) {
            weekName = WEEK_SUNDAY;
        }
        return weekName;
    }
    
    public Boolean IsWeekend(Date dtWeekStartDate, Date dtDebitDate) {
       Boolean blnFlag = false;
        if(dtWeekStartDate.daysBetween(dtDebitDate) == 6 || dtWeekStartDate.daysBetween(dtDebitDate) == 0) {
            blnFlag = true;
        }
        return blnFlag;
    }
}