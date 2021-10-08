public class APSWarningMSGExtension {
    private final loan__Automated_Payment_Setup__c autoPayment;
    
    @TestVisible
    private final String WARNING_MESSAGE = 'WARNING: APS debit date must be on the NEXT ELIGIBLE BUSINESS Day.';
    public APSWarningMSGExtension(ApexPages.StandardController stdController) {
        this.autoPayment = (loan__Automated_Payment_Setup__c)stdController.getRecord();
    } //abc
    public String getErrorMessage() {
        loan__Automated_Payment_Setup__c paymentSetUp = [SELECT CreatedDate, loan__Debit_Date__c FROM loan__Automated_Payment_Setup__c WHERE Id=:this.autoPayment.Id];
        Date dtCreateDate = Date.newInstance(paymentSetUp.CreatedDate.year(), paymentSetUp.CreatedDate.month(), paymentSetUp.CreatedDate.day());
        Date weekStart = dtCreateDate.toStartOfWeek();
        Date weekStartDebit = paymentSetUp.loan__Debit_Date__c.toStartOfWeek();
        Boolean blnFlag = false;
      
        blnFlag = IsHoliday(paymentSetUp.loan__Debit_Date__c);
        if(blnFlag) {
            return WARNING_MESSAGE;
        }
        MW_Settings__c payOffSettings = MW_Settings__c.getOrgDefaults();
        String cutOffTime = payOffSettings?.APS_Cutofftime__c;   
        String[] timeSplit = cutOffTime.split(':');
        Time timeExpected = Time.newInstance(Integer.valueOf(timeSplit[0]),Integer.valueOf(timeSplit[1]),Integer.valueOf(timeSplit[2]),0);
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
            
                    isHoliday = true;
                }
             
        
        return isHoliday;
    }
    
    
    
    public Boolean IsWeekend(Date dtWeekStartDate, Date dtDebitDate) {
       Boolean blnFlag = false;
        if(dtWeekStartDate.daysBetween(dtDebitDate) == 6 || dtWeekStartDate.daysBetween(dtDebitDate) == 0) {
            blnFlag = true;
        }
        return blnFlag;
    }
}
