/* ****************Modification History******************
 * Created By        Date          JIRA number
 *1. Pallavi        2020/10/05     CRM-928(Previous Investor Current Weight number decreased when re-allocating applications)
 *2. Pallavi        2020/11/19     CRM-1022 Status 500 responses causing missing data in CLS - CLS Case #02456279
 ******************Modification History******************/

Public class CustomTriggerOnApplicationHandler{
    public static boolean isAppTrgExecuting=true;

    public CustomTriggerOnApplicationHandler(){

    }
    public CustomTriggerOnApplicationHandler(boolean isExecuting){
        isAppTrgExecuting = isExecuting;
    }


    public boolean runInvestorAllocationFieldsUpdate(List<genesis__Applications__c> oldList,List<genesis__Applications__c> newList,Map<id,genesis__Applications__c> oldMap){
        System.debug('Before isAppTrgExecuting ....'+ isAppTrgExecuting );
        Boolean invAllocated = false;
        if(isAppTrgExecuting){
             isAppTrgExecuting = false;
             System.debug('After isAppTrgExecuting ....'+ isAppTrgExecuting );
             invAllocated = investorAllocationFieldsUpdate(oldList, newList, oldMap);
        }
        return invAllocated;
    }
    public static Boolean investorAllocationFieldsUpdate(List<genesis__Applications__c> oldList,List<genesis__Applications__c> newList,Map<id,genesis__Applications__c> oldMap){

        Boolean retValue = false;
        Map<ID,ID> appOldInvestorIdMap = new Map<ID,ID>();
        for(genesis__Applications__c app : oldList){
            if(app.Investor__c != null){
                system.debug('Old Investor__c :...' + app.Investor__c);
                system.debug('ApplicationId :...' + app.Id);
                appOldInvestorIdMap.put(app.Investor__c,app.id);
            }
        }
        Set<ID> newInvestorId = new Set<ID>();
        for(genesis__Applications__c app : newList){
            if(app.Investor__c != null){
                system.debug('New Investor__c :...' + app.Investor__c);
                newInvestorId.add(app.Investor__c);
            }

        }
        Map<id,genesis__Applications__c> newAppQueryMap = new Map<id,genesis__Applications__c>([Select Id,
                                                                genesis__Status__c,
                                                                Investor__r.Name,
                                                                (Select id,name,
                                                                    Box_URl__c,
                                                                    genesis__Parent_Application_Document_Category__r.name
                                                                    from genesis__Application_Document_Category__r
                                                                    Where name like '%TIL%'
                                                                    or name like '%Credit Score Notice%'
                                                                    or genesis__Parent_Application_Document_Category__r.name like '%Origination Documents%'
                                                                    or name like '%ESign%'
                                                                    or genesis__Parent_Application_Document_Category__r.name like '%ESign%')
                                                                from genesis__applications__c
                                                                Where Id in: newList]);
        Map<id,Account> oldInvestorMap = new Map<id,Account>([Select id,name,
                                                                Amount_Invested__c,
                                                                Last_Application_assigned_on__c,
                                                                Number_Of_Applications_Invested__c,
                                                                Remaining_Amount__c,
                                                                Remaining_Applications__c,
                                                                Total_Investment_Limit__c,
                                                                Total_No_of_Application_Limit__c,
                                                                Investor_Current_Weight__c,
                                                                Total_Funded_Till_date__c,
                                                                Total_Funded_YTD__c,
                                                                Total_Funded_MTD__c,
                                                                Total_Allocations_MTD__c,
                                                                (Select id,name,
                                                                     Invested_Amount__c,
                                                                     Last_Investor_Assigned_On__c
                                                                     from Applications__r
                                                                     Order By Last_Investor_Assigned_On__c Desc
                                                                     Limit 2
                                                                )
                                                                From Account where id in: appOldInvestorIdMap.keySet()]);

        Map<id,Account> newInvestorMap = new Map<id,Account>([Select id,name,
                                                                Amount_Invested__c,
                                                                Last_Application_assigned_on__c,
                                                                Number_Of_Applications_Invested__c,
                                                                Remaining_Amount__c,
                                                                Remaining_Applications__c,
                                                                Total_Investment_Limit__c,
                                                                Total_No_of_Application_Limit__c,
                                                                Investor_Current_Weight__c,
                                                                Total_Funded_Till_date__c,
                                                                Total_Funded_YTD__c,
                                                                Total_Funded_MTD__c,
                                                                Total_Allocations_MTD__c,
                                                                (Select id,name,
                                                                     Invested_Amount__c,
                                                                     Last_Investor_Assigned_On__c
                                                                     from Applications__r
                                                                     Order By Last_Investor_Assigned_On__c Desc
                                                                     Limit 2
                                                                )
                                                                From Account where id in: newInvestorId]);

        List<Account> investorsToBeUpdate = new List<Account>();
        List<Application_Tags__c> appTagToBeInserted = new List<Application_Tags__c>();
        List<genesis__Application_Document_Category__c>  adcToBeUpdated = new List<genesis__Application_Document_Category__c>();
        List<genesis__Application_Document_Category__c>  adcToBeDeleted = new List<genesis__Application_Document_Category__c>();
        for(genesis__Applications__c appl : newList){


            genesis__Applications__c oldApp = oldMap.get(appl.id);
            if(appl.Investor__c != null){
                Account newInv = newInvestorMap.get(appl.Investor__c);
                if(oldApp.Investor__c == null){
                   appl.Last_Investor_Assigned_On__c = system.now();
                    appl.Invested_Amount__c = appl.genesis__loan_amount__c;
                    newInv.Amount_Invested__c = newInv.Amount_Invested__c + appl.Invested_Amount__c;
                    newInv.Number_Of_Applications_Invested__c = newInv.Number_Of_Applications_Invested__c + 1;
                    newInv.Last_Application_assigned_on__c = appl.Last_Investor_Assigned_On__c;

                    ///////////////////////////Reporiting Purpose///////////////////////////////////////
                    newInv.Total_Funded_Till_date__c = (newInv.Total_Funded_Till_date__c==null ?appl.genesis__loan_amount__c:newInv.Total_Funded_Till_date__c + appl.genesis__loan_amount__c);
                    newInv.Total_Funded_YTD__c = (newInv.Total_Funded_YTD__c==null ?appl.genesis__loan_amount__c:newInv.Total_Funded_YTD__c + appl.genesis__loan_amount__c);
                    newInv.Total_Funded_MTD__c = (newInv.Total_Funded_MTD__c==null ?appl.genesis__loan_amount__c:newInv.Total_Funded_MTD__c + appl.genesis__loan_amount__c);
                    newInv.Total_Allocations_MTD__c = (newInv.Total_Allocations_MTD__c==null ?1:newInv.Total_Allocations_MTD__c + 1);
                    ////////////////////////////////////////////////////////////////////////////////////
                    investorsToBeUpdate.add(newInv);
                }
                else if(appl.Investor__c != oldApp.Investor__c && oldApp.Investor__c != NULL){
                    Account oldInv = oldInvestorMap.get(oldApp.Investor__c);
                    List<genesis__Applications__c> oldAppList = oldInv.Applications__r;
                    oldInv.Amount_Invested__c = oldInv.Amount_Invested__c - oldApp.Invested_Amount__c;
                    oldInv.Number_Of_Applications_Invested__c = oldInv.Number_Of_Applications_Invested__c - 1;
                    if(oldInv.Investor_Current_Weight__c == null) {
                        oldInv.Investor_Current_Weight__c = 0;
                    }
                    //oldInv.Investor_Current_Weight__c = oldInv.Investor_Current_Weight__c-1;  //CRM-928 (moving to InvestorAllocation)
                    oldInv.Last_Application_assigned_on__c = oldAppList.size() <= 1?null:oldAppList[1].Last_Investor_Assigned_On__c;

                    appl.Last_Investor_Assigned_On__c = system.now();
                    appl.Invested_Amount__c = appl.genesis__loan_amount__c;
                    newInv.Amount_Invested__c = newInv.Amount_Invested__c + appl.Invested_Amount__c;
                    newInv.Number_Of_Applications_Invested__c = newInv.Number_Of_Applications_Invested__c + 1;
                    newInv.Last_Application_assigned_on__c = appl.Last_Investor_Assigned_On__c;
                    if(newInv.Investor_Current_Weight__c == null) {
                        newInv.Investor_Current_Weight__c = 0;
                    }
                    //newInv.Investor_Current_Weight__c = newInv.Investor_Current_Weight__c+1;

                    ///////////////////////////Reporiting Purpose///////////////////////////////////////
                    newInv.Total_Funded_Till_date__c = (newInv.Total_Funded_Till_date__c==null ?appl.genesis__loan_amount__c:newInv.Total_Funded_Till_date__c + appl.genesis__loan_amount__c);
                    newInv.Total_Funded_YTD__c = (newInv.Total_Funded_YTD__c==null ?appl.genesis__loan_amount__c:newInv.Total_Funded_YTD__c + appl.genesis__loan_amount__c);
                    newInv.Total_Funded_MTD__c = (newInv.Total_Funded_MTD__c==null ?appl.genesis__loan_amount__c:newInv.Total_Funded_MTD__c + appl.genesis__loan_amount__c);
                    newInv.Total_Allocations_MTD__c = (newInv.Total_Allocations_MTD__c==null ?1:newInv.Total_Allocations_MTD__c + 1);

                    //System.debug('checkstart here'+oldInv.Total_Funded_Till_date__c+' '+oldInv.Total_Funded_YTD__c+' '+oldInv.Total_Funded_MTD__c+' '+oldInv.Total_Allocations_MTD__c);
                    oldInv.Total_Funded_Till_date__c = (oldInv.Total_Funded_Till_date__c==null || oldInv.Total_Funded_Till_date__c==0?0:oldInv.Total_Funded_Till_date__c - oldApp.Invested_Amount__c);
                    oldInv.Total_Funded_YTD__c = (oldInv.Total_Funded_YTD__c==null || oldInv.Total_Funded_YTD__c==0 ?0:oldInv.Total_Funded_YTD__c - oldApp.Invested_Amount__c);
                    oldInv.Total_Funded_MTD__c = (oldInv.Total_Funded_MTD__c==null || oldInv.Total_Funded_MTD__c==0 ?0:oldInv.Total_Funded_MTD__c - oldApp.Invested_Amount__c);
                    oldInv.Total_Allocations_MTD__c = (oldInv.Total_Allocations_MTD__c==null || oldInv.Total_Allocations_MTD__c==0 ?0:oldInv.Total_Allocations_MTD__c - 1);

                    ////////////////////////////////////////////////////////////////////////////////////


                    investorsToBeUpdate.add(newInv);
                    investorsToBeUpdate.add(oldInv);

                    //Start Re allocation Logic

                    if(appl.genesis__Status__c != 'Default Documents' && appl.genesis__Status__c != 'offer_accepted' && appl.genesis__Status__c != 'offer_shown'){
                        genesis__Applications__c appRe = newAppQueryMap.get(appl.id);
                        ApplicationAttachmentHandler.attachmentHandler(appRe.id,appRe.Investor__r.Name,'Reallocation');
                        Application_Tags__c at = new Application_Tags__c();
                        at.Application__c = appl.id;
                        at.Application_Tag__c = 'Re allocation';
                        appTagToBeInserted.add(at);
                        if(appRe.genesis__Application_Document_Category__r != null && appRe.genesis__Application_Document_Category__r.size() > 0){
                            for(genesis__Application_Document_Category__c adc : appRe.genesis__Application_Document_Category__r){
                                if(adc.name == 'ESign Documents' || adc.genesis__Parent_Application_Document_Category__r.name == 'ESign Documents'){
                                    adcToBeDeleted.add(adc);
                                }
                                else {
                                    adc.Box_URl__c = null;
                                    adcToBeUpdated.add(adc);
                                    }
                            }
                        }

                    }
                    //// End Re allocation Logic
                }
                /*pallavi(PS-3695/LOS-132)*/ //CRM-1022
                 else if(appl.Investor__c == oldApp.Investor__c && oldApp.Investor__c != NULL && appl.genesis__loan_amount__c != oldApp.genesis__loan_amount__c){
                    System.debug('same investor');
                    appl.Last_Investor_Assigned_On__c = system.now();
                    appl.Invested_Amount__c = appl.genesis__loan_amount__c;
                    if(oldApp.Invested_Amount__c!= null)
                      newInv.Amount_Invested__c = newInv.Amount_Invested__c + appl.Invested_Amount__c - oldApp.Invested_Amount__c;
                    else
                        newInv.Amount_Invested__c = newInv.Amount_Invested__c + appl.Invested_Amount__c;
                    newInv.Last_Application_assigned_on__c = appl.Last_Investor_Assigned_On__c;
                    newInv.Total_Funded_Till_date__c = (newInv.Total_Funded_Till_date__c==null ?appl.genesis__loan_amount__c:newInv.Total_Funded_Till_date__c + appl.genesis__loan_amount__c-oldApp.genesis__loan_amount__c);
                    newInv.Total_Funded_YTD__c = (newInv.Total_Funded_YTD__c==null ?appl.genesis__loan_amount__c:newInv.Total_Funded_YTD__c + appl.genesis__loan_amount__c-oldApp.genesis__loan_amount__c);
                    newInv.Total_Funded_MTD__c = (newInv.Total_Funded_MTD__c==null ?appl.genesis__loan_amount__c:newInv.Total_Funded_MTD__c + appl.genesis__loan_amount__c-oldApp.genesis__loan_amount__c);
                    investorsToBeUpdate.add(newInv);
                }
                /*pallavi*/
            }

        }
        if(adcToBeDeleted != null && adcToBeDeleted.size() > 0){
            Delete adcToBeDeleted;
        }
        if(adcToBeUpdated != null && adcToBeUpdated.size() > 0){
            update adcToBeUpdated;

        }
        if(investorsToBeUpdate != null && investorsToBeUpdate.size() > 0){
            update investorsToBeUpdate;
            retValue = true;
        }
        System.debug('....runInvestorRule completed...');
        return retValue;
    }
    public Date addWorkingDaysToDate(Date date1,Integer adDays){

               List<Holiday> holidays=[Select StartTimeInMinutes,
                                                Name,
                                                ActivityDate
                                            From Holiday];
                Date resultDate;
                for(Integer k = 1;k <= adDays;k++ ){
                    if(checkifItisWorkingDay(date1.addDays(k),holidays)){
                        resultDate = date1.addDays(k);
                    }
                    else{
                        adDays++;
                    }
                }
                return resultDate;

    }
    public  boolean checkifItisWorkingDay(Date currentDate,List<Holiday> holidays){
                 Date weekStart  = currentDate.toStartofWeek();
                for(Holiday hDay:holidays){
                        if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                                 return false;
                        }
                }
               if(weekStart.daysBetween(currentDate) ==0 || weekStart.daysBetween(currentDate) == 6){
                       return false;
                } else
                       return true;
  }
    //CRM-531 - start
    public static Boolean dcpEligibleFieldForUpdate(List<genesis__Applications__c> newList){
      Boolean isDCPUpdated = false;
        List<genesis__applications__c> appListToUpdate = new List<genesis__applications__c>();
        try{
            for(genesis__Applications__c app : newList){
              app.dcp_eligible__c = 'No - Application Changed';
              appListToUpdate.add(app);
            }
            //update appListToUpdate;
            isDCPUpdated = true;
        }catch(Exception e){
            System.debug('Error updating dcp_eligible__c '+ e.getMessage());
            return false;
        }
        return isDCPUpdated;
    }

    public static Boolean payAtFundingForUpdate(Id appId){
        try{
            List<dcp_arcus_transactions__c> arcusTransactions = [select id, name, pay_at_funding__c from dcp_arcus_transactions__c
                                                                      where Application__r.id = :appId and pay_at_funding__c = true];
            List<dcp_arcus_transactions__c> arcusTransactionsToUpdate = new List<dcp_arcus_transactions__c>();
                      for(dcp_arcus_transactions__c txn:arcusTransactions){
                         txn.pay_at_funding__c = false;
                         arcusTransactionsToUpdate.add(txn);
                         System.debug('txn.pay_at_funding__c: '+ txn.pay_at_funding__c);
                       }
            if (arcusTransactionsToUpdate.size() > 0)
                update arcusTransactionsToUpdate;
            System.debug('Updated all DCP transactions..');
            return true;
      }catch(Exception e){
            System.debug('Error updating dcp_eligible__c '+ e.getMessage());
            return false;
        }
    }//CRM-531 - end
    
    //CRM-762
    public static void updateBankAccountTab(Id appId){
        try{
            System.debug('updateBankAccountTab--');
            String currentUser = UserInfo.getName();
          User profile =   [SELECT profile.name from user where name =: currentUser];
            List<ProfilesForBankAccTab__c> profileName = ProfilesForBankAccTab__c.getAll().values();
          Set<String> profName = new Set<String>();
          for(ProfilesForBankAccTab__c name : profileName){
              profName.add(name.profile_name__c);
          }
            System.debug('profile.name--' + profile.profile.name);
            if(profName.contains(String.valueOf(profile.profile.name))){
                System.debug('inside profile');
                List<Identity_Verification__c> bankAccTab = [select id,Bank_Verification_Flag__c from Identity_Verification__c
                                                             where Application__c =: appId];
                if(bankAccTab.size()>0){
                    bankAccTab[0].Bank_Verification_Flag__c = 'PASS';
                    update bankAccTab;
                }
            }
        }
        catch(Exception e){
            System.debug('Error updating bank accoun tab '+ e.getMessage());
        }
    }
    //CRM-762

    public static void updateBankStatement(Id appId, String status) {
        if (status == 'Accept' || status == 'Reject') {
            List<genesis__Application_Document_Category__c> toBeUpdated = new List<genesis__Application_Document_Category__c>();
            List<genesis__Application_Document_Category__c> docCats = [SELECT Id, Name, Cleared_Reason__c, genesis__Status__c, genesis__Application__c
                FROM genesis__Application_Document_Category__c
                WHERE genesis__Application__c =: appId AND ((Name like 'Bank Statement %' AND genesis__Required__c = true) OR (Name = 'Plaid Asset Report' AND Doc_URL__c != NULL))];
            for(genesis__Application_Document_Category__c docCat: docCats) {
                if (status == 'Accept') {
                    docCat.genesis__Status__c = 'CLEARED';
                    docCat.Cleared_Reason__c = 'Satisfied by PLAID transactions';
                }
                else {
                    docCat.genesis__Status__c = 'REJECTED';
                    docCat.Rejection_Reasons__c = 'Linked Account: Too few transactions';
                }
                toBeUpdated.add(docCat);
            }

            if (toBeUpdated.size() > 0) {
                update toBeUpdated;
            }
        }
    }
    /** If Requested Loan amount OR Annual Individual Income OR Monthly Housing Payment is changed on Application, call the redecision logic */
    public static void callRedecisionLogic(genesis__Applications__c app, genesis__Applications__c oldApp,Map<Id,genesis__applications__c> oldAppMap,Map<Id,genesis__applications__c> newAppMap){

        if((app.Requested_loan_amount__c != null && oldApp.Requested_loan_amount__c != null && app.Requested_loan_amount__c != oldApp.Requested_loan_amount__c) || 
            (app.Annual_Individual_Income_App__c != null && oldApp.Annual_Individual_Income_App__c != null && oldApp.Annual_Individual_Income_App__c != app.Annual_Individual_Income_App__c) || 
            (app.Monthly_Housing_Payment_App__c != null && oldApp.Monthly_Housing_Payment_App__c != null && oldApp.Monthly_Housing_Payment_App__c != app.Monthly_Housing_Payment_App__c))
        {
                RedecisionCntrl.appRedecisionTrigger(oldAppMap,newAppMap);
        }
    }
}