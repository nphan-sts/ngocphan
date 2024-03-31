global class InvestorReportingJob implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable{
    String query;
    Date systemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
    global InvestorReportingJob() {
        
        query  = 'Select id,name,loan__Investor__c,Last_Application_assigned_on__c,Amount_Invested__c,Previous_year_Total_Funded__c,'+
                 'Number_Of_Applications_Invested__c,Investor_Alloted_Weight__c,Investor_Current_Weight__c,Previous_Month_Total_Funded__c,'+
                 'Total_Funded_Till_date__c, Total_Funded_YTD__c,Total_Funded_MTD__c,Total_Allocations_MTD__c,Previous_Month_Total_Allocations__c '+
                 'FROM Account WHERE loan__Investor__c = true AND loan__Active__c = \'Yes\'';

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
       System.debug(query);
       return Database.getQueryLocator(query);
    }
	global void execute(SchedulableContext sc) {
       InvestorReportingJob j =new InvestorReportingJob();
       Database.executebatch(j,200);
   	}
   	global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug(scope.size());
        try {
            Date lastDayofMonth = systemDate.addMonths(1).toStartofMonth().addDays(-1);
            List<Account> accLst = new List<Account>();
            for(Account acc:scope) {
                if(systemDate.day()==1 && systemDate.month()==1) {
                    acc.Previous_year_Total_Funded__c = acc.Total_Funded_YTD__c;
                    acc.Total_Funded_YTD__c = 0;
                    acc.Previous_Month_Total_Funded__c = acc.Total_Funded_MTD__c;
                    acc.Total_Funded_MTD__c = 0;
                    acc.Previous_Month_Total_Allocations__c = acc.Total_Allocations_MTD__c;
                    acc.Total_Allocations_MTD__c = 0;
                    accLst.add(acc);
                }
                else if(systemDate.day()==1) {
                    acc.Previous_Month_Total_Funded__c = acc.Total_Funded_MTD__c;
                    acc.Total_Funded_MTD__c = 0;
                    acc.Previous_Month_Total_Allocations__c = acc.Total_Allocations_MTD__c;
                    acc.Total_Allocations_MTD__c = 0;
                    accLst.add(acc);
                }
            }
            if(accLst!=null && accLst.size()>0) {
                update accLst;
            }
        } catch(Exception e) {
            loan__batch_process_Log__c bpl = new loan__batch_process_Log__c();
            bpl.loan__message__c = e.getStackTraceString()+'\n'+e.getMessage()+' at line number:'+e.getLineNumber();
            bpl.loan__Origin__c = 'InvestorReportingJob';
            bpl.loan__Log_Level__c = 'Exception';
            insert bpl;
        }
        
        
        
    }
    
    global void finish(Database.BatchableContext BC) {
        // update job's last run time in custom         
	} 

}