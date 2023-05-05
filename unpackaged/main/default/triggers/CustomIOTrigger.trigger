/* ****************Modification History******************
 * Last Modified by        Date          JIRA number
 *      1. Pallavi        2020/01/27     LOS-28(Remove references to InvestorAccount field on CL contract)
 *      2. Pallavi        2020/04/28     CRM-502
 *      3. Pallavi        2020/04/28     CRM-614
 ******************Modification History******************/
trigger CustomIOTrigger on loan__Investor_Loan__c (after insert, after update) {    

    System.debug(logginglevel.error, 'In IO Trigger');
    if (!loan.CustomSettingsUtil.getOrgParameters().loan__Disable_Triggers__c) {
        
        System.debug(logginglevel.error, 'In IO Trigger, In 1 IF');
        //if(trigger.isInsert && trigger.isBefore) { 
        
        System.debug(logginglevel.error, 'In IO Trigger, In 2 IF ');
        Set<Id> LASet = new Set<Id>();
        //DateTime CurrentSystemDateTime = new loan.GlobalLoanUtilFacade().getCurrentSystemDateTime(); //CRM-502
        DateTime originationDatetime;
        Set<Id> InvestorsSet = new Set<Id>();
        
        List<loan__loan_account__c> LAList = new List<loan__loan_account__c>();
        Map<id,id> MapLoanToInvestor = new Map<id,id>();
        Map<id,id> MapInvestorToPaymentmode = new Map<id,id>();
         
            for(loan__Investor_Loan__c IO : trigger.new){
                
                System.debug(logginglevel.error, 'In FOR Is_Funding_Partner__c'+IO.Is_Funding_Partner__c);
               
                //if(IO.Is_Funding_Partner__c == False){(not needed)
                    
                    System.debug(logginglevel.error, 'In FOR-  IF ');
                    System.debug(logginglevel.error, 'LOAN' + IO.loan__Loan__c);                              
                    LASet.add(IO.loan__Loan__c);
                    InvestorsSet.add(IO.loan__Account__c);
                    MapLoanToInvestor.put(IO.loan__Loan__c,IO.loan__Account__c);
                    System.debug(logginglevel.error, 'LASet: ' + LASet);
                
                //}
            }
            
            LAList = [select id,loan__Payment_Mode__c,Auto_Sale_Date__c,IO_AutoSale_to_Funding_Partner__c,Application__r.Loan_Origination_Date__c/*,Investor_Account__c*/,(select id,name from loan__Automated_Payment_Setup__r where loan__Active__c = True) from loan__loan_account__c where id in : LASet];  //CRM-614	//COMMENTED FOR LOS-28  //pallavi(added autosale for CRM-502)
            List <loan__Automated_Payment_Setup__c> APSList = new List <loan__Automated_Payment_Setup__c>();
            List <loan__Automated_Payment_Configuration__c> apcs = [
                    SELECT Id,
                           Name,
                           loan__Payment_Mode__c,
                           loan__Bank_Account__c,
                           loan__Bank_Account__r.loan__Account__c
                    FROM   loan__Automated_Payment_Configuration__c
                    WHERE  loan__Bank_Account__r.loan__Account__c IN : InvestorsSet
                    AND    loan__Active__c = TRUE
            ];

            System.debug(logginglevel.error, 'LAList ' + LAList );
            
            for(loan__Automated_Payment_Configuration__c apc : apcs){
            
                MapInvestorToPaymentmode.put(apc.loan__Bank_Account__r.loan__Account__c,apc.loan__Payment_Mode__c);      
            
            }
            
            for(loan__loan_account__c Loan : LAList ){
            
                //Loan.Investor_Account__c = MapLoanToInvestor.get(Loan.Id);
                Loan.loan__Payment_Mode__c = MapInvestorToPaymentmode.get(MapLoanToInvestor.get(Loan.Id));

                /*CRM-502*/
                if(trigger.isInsert){
                    AddBusinessDays autoSaleDate = new AddBusinessDays();
                    Integer timeZoneDiff = autoSaleDate.getTimeZoneDiff();  //CRM-614
                    if(!test.isRunningTest())
                        originationDatetime = ((DateTime)Loan.application__r.Loan_Origination_Date__c).addHours(timeZoneDiff);    //CRM-614
                    else {
                        originationDatetime = ((DateTime)System.today()).addHours(timeZoneDiff);
                    }
                    Id investor = MapLoanToInvestor.get(Loan.Id);
                    Account invAccount = [Select id,Number_of_Days__c from account where id =: investor];
                    integer noOfdays = (integer) invAccount.Number_of_Days__c;
                    if(!loan.IO_AutoSale_to_Funding_Partner__c && noOfdays > 0){
                        loan.Auto_Sale_Date__c = autoSaleDate.calBusinesssDateiwthCalendarDays(noOfdays,originationDatetime);   //CRM-614
                    }
                 }
                /*CRM-502*/

                
                for(loan__Automated_Payment_Setup__c aps : loan.loan__Automated_Payment_Setup__r){
                
                    aps.loan__Payment_Mode__c = MapInvestorToPaymentmode.get(MapLoanToInvestor.get(Loan.Id));
                    APSList.add(aps);
                }
                
            }
            
            update APSList;
            update LAList;
            
            
            /*for (Integer i = 0; i < Trigger.new.size(); i++){
                System.debug(logginglevel.error, 'SIZE : ' + Trigger.new.size());          
                System.debug(logginglevel.error, 'MapLoanToIO : ' + MapLoanToIO);
                System.debug(logginglevel.error, 'MapLoanToIO.get(Trigger.new[i].loan__Loan__c) : ' + MapLoanToIO.get(Trigger.new[i].loan__Loan__c)); 
                //System.debug(logginglevel.error, 'LAList[i].Id : ' + LAList[i].Id);                               
                if(MapLoanToIO.containsKey(Trigger.new[i].loan__Loan__c)){}
                   Trigger.new[i]. = MapLoanToIO.get(Trigger.new[i].loan__Loan__c) ;
                
            }*/
            
        //}
    
    }

}