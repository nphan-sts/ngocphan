public class APSWarningMSGExtension {
    private final loan__Automated_Payment_Setup__c autoPayment;
    @TestVisible
    private final String WARNING_MESSAGE = 'WARNING: APS debit date must be on the NEXT ELIGIBLE BUSINESS Day.';
    public APSWarningMSGExtension(ApexPages.StandardController stdController) {
        this.autoPayment = (loan__Automated_Payment_Setup__c)stdController.getRecord();
    }
    public String getErrorMessage() {
        loan__Automated_Payment_Setup__c paymentSetUp = [SELECT CreatedDate,loan__Debit_Date__c FROM loan__Automated_Payment_Setup__c WHERE Id=:this.autoPayment.Id];
        List<Holiday> holidayList = [SELECT Name, ActivityDate FROM Holiday LIMIT 5000];
        Date dtCreateDate = Date.newInstance(paymentSetUp.CreatedDate.year(), paymentSetUp.CreatedDate.month(), paymentSetUp.CreatedDate.day());
        Date weekStart = dtCreateDate.toStartOfWeek();
        Date weekStartDebit = paymentSetUp.loan__Debit_Date__c.toStartOfWeek();
        if(holidayList != null && holidayList.size() > 0) {
            for(Holiday hDay : holidayList) {
                if(dtCreateDate.daysBetween(hDay.ActivityDate) == 0 || paymentSetUp.loan__Debit_Date__c.daysBetween(hDay.ActivityDate) == 0) {
                    return WARNING_MESSAGE;
                }
            }
        }
        Time timeExpected = Time.newInstance(15,0,0,0);
        DateTime expectedDateTime = DateTime.newInstance(dtCreateDate, timeExpected);
        Long expected = expectedDateTime.getTime();
        Long actual = paymentSetUp.CreatedDate.getTime();
        Long timeavailable = (actual - expected);
        if(weekStart.daysBetween(dtCreateDate) == 0 
           || weekStart.daysBetween(dtCreateDate) == 6
           || weekStartDebit.daysBetween(paymentSetUp.loan__Debit_Date__c) == 0 
           || weekStartDebit.daysBetween(paymentSetUp.loan__Debit_Date__c) == 6) {
               return WARNING_MESSAGE;
           } else if(weekStart.daysBetween(dtCreateDate) == 5 && (timeavailable > 0)) {
                return WARNING_MESSAGE;
           }
        return '';
    }
}
