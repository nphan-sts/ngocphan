global class schedulelptclearjob implements Schedulable
{

    global void execute(SchedulableContext sc)

    {


        loan.LoanPaymentTxnClearingJob b = new loan.LoanPaymentTxnClearingJob(false);
        database.executebatch(b,100);

    }

}