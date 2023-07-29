global class InvestorlimitsReset implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        // ResetInvestorLimits.CallResetInvestorLimits();
        date mydate = date.today();
        system.debug(mydate.dayOfYear());    
        integer DayofYr = mydate.dayOfYear();
        List<Account> listinvestors =new List<Account>();
        for(Account acc:[select id,Total_Investment_Limit__c,Amount_Invested__c,Total_No_of_Application_Limit__c,Number_Of_Applications_Invested__c, loan__Undeployed_Funds__c,Total_Allocations_MTD__c,Total_Funded_MTD__c,Previous_Month_Total_Allocations__c, Previous_Month_Total_Funded__c,Previous_year_Total_Funded__c, Total_Funded_YTD__c from Account where loan__Investor__c=true Or recordtype.name='Investor' limit 50000 ]){
             acc.Previous_Month_Total_Funded__c = acc.Total_Funded_MTD__c;
             acc.Previous_Month_Total_Allocations__c = acc.Total_Allocations_MTD__c;
             acc.Total_Allocations_MTD__c=0;
             acc.Total_Funded_MTD__c=0;
             acc.Amount_Invested__c=0;
             acc.Number_Of_Applications_Invested__c =0 ;
             if(DayofYr==1){
                 acc.Previous_year_Total_Funded__c = acc.Total_Funded_YTD__c;
                 acc.Total_Funded_YTD__c =0;
                 }
             listinvestors.add(acc);
    }
    if(listinvestors.size()>0)
     Database.update(listinvestors);
    
    }
}