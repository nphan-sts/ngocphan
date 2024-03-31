public class MW_ApplicationService {

    public static void postDealRoomStructure(List< genesis__Applications__c > apps, Map<Id, genesis__Applications__c> oldMap){

        List<String> appList                 = new List<String>();
        List<MCCallout__c> calloutsScheduled = new List<MCCallout__c>();

        for(genesis__Applications__c ls : apps) {
            if(ls.genesis__Status__c != oldMap.get(ls.Id).genesis__Status__c && ls.genesis__Status__c=='offer_shown') {
                appList.add(ls.Id);
            }
        }

        if(appList.size()>0) {
            Set<String> appListNoDups = new Set<String>();
            appListNoDups.addAll(appList);
            String app = '';
            if(!appListNoDups.isEmpty()) {app = new list<String>(appListNoDups)[0];}
            List<MCCallout__c> currentCallout = new List<MCCallout__c>([Select Id From MCCallout__c Where Application__c=: app limit 1]);

            if(currentCallout == null && currentCallout.size()<=0) {
                ID jobID = System.enqueueJob(new MWQueuebleJob(appList));
                calloutsScheduled.add(new MCCallout__c(Job_ID__c = jobID, Application__c=app, Status__c = 'Queued', Send_on__c=System.now()));
            }

            if(calloutsScheduled.size()>0) {
                insert calloutsScheduled;
            }
        }


    }


    public static void UpdateApplicationFlags(List<genesis__Applications__c> appslist, Map<Id, genesis__Applications__c> oldMap)
    {
        for(genesis__Applications__c app : appslist) {
           
            if(app.genesis__Status__c == 'Redecision_Required' && app.genesis__Status__c!=oldMap.get(app.Id).genesis__Status__c) {
                app.agentVerificationPendingFlag__c = false;
            }

            if(app.custom_APR_for_not_rounding__c == null || app.custom_APR_for_not_rounding__c == 0 || oldMap.get(app.Id).genesis__APR__c!=app.genesis__APR__c) {
                app.custom_APR_for_not_rounding__c = app.genesis__APR__c;
            }

            if(app.Required_Docs_Count__c==0 && app.genesis__Status__c !='agent_document_verification_pending' && !app.agentVerificationPendingFlag__c /*CLS-980-->*/
                    && app.genesis__Status__c !='Redecision_Required' /*CLS-994 --> */ && app.genesis__Status__c !='Stacker_Check_Passed' && app.genesis__Status__c !='agent_verified'
                    && app.genesis__Status__c !='docusign_loan_docs_sent' && app.genesis__Status__c !='docusign_loan_docs_complete' && app.genesis__Status__c !='pre_funding'
                    && app.genesis__Status__c !='Approved for funding' && app.genesis__Status__c !='funded' /*PS-1709-->*/ && app.genesis__Status__c !='offer_shown'
                    && app.genesis__Status__c !='Declined' && app.genesis__Status__c !='Expired' && app.genesis__Status__c !='Withdrawn'
                    && app.genesis__Status__c !='Decline_Manual_Review' && app.owner.Name != 'Review Queue') {

                app.genesis__Status__c ='agent_document_verification_pending';

                if(MW_WebhookHelper.appQueueDetails().size()>0 && /*CLS-1174 -->*/ !app.readyforverificationQueueFlag__c) {
                    app.ownerid = MW_WebhookHelper.appQueueDetails().get('Ready for Verification');
                    app.readyforverificationQueueFlag__c = true;/*CLS-1174 --*/
                }

                app.agentVerificationPendingFlag__c = true;
            }
        }
    }

    public static void updateBoxFolder(List<genesis__Applications__c> appslist){

        for(genesis__Applications__c app : appslist)
        {
            if(app.BoxFolderID__c==null) {
                app.BoxFolderID__c     = MW_Settings__c.getInstance().BOXRootFolder__c;
            }

            if(app.genesis__Status__c=='NEW - ENTERED') {
                app.genesis__Status__c ='Default Documents';
            }

            if(app.genesis__CL_Product__c==null) {
                List<clcommon__CL_Product__c> productlist  = new List<clcommon__CL_Product__c>([SELECT Id,Name from clcommon__CL_Product__c where clcommon__Product_Name__c='Auto Payer' limit 1]);
                if(productlist.size()>0) {
                    app.genesis__CL_Product__c =productlist[0].Id;
                }
            }
        }
    }

    //LOP-220, LOP-221, LOP-222, LOP-257,LOP-452
    public static void pifLoanUpdates(List< genesis__Applications__c > apps, Map<Id, genesis__Applications__c> newMap, Map<Id, genesis__Applications__c> oldMap){
        Map<Id, genesis__Applications__c> mapCurrentApps = new Map<Id, genesis__Applications__c>();
        Map<Id, genesis__Applications__c> mapPreExistAcctsActiveApps = new Map<Id, genesis__Applications__c>();
        Map<Id, Account> mapCurrentAccts = new Map<Id, Account>();
        Map<Id, loan__Loan_Account__c> mapExistingLoanAccts = new Map<Id, loan__Loan_Account__c>();
        Set<Id> setCurrentAcctIds = new Set<Id>();
        Set<Id> setPreExistAcctIds = new Set<Id>();
        Set<String> setDuplicateSsn = new Set<String>();
        List<Account> updateCurrentAccts = new List<Account>();
        List<Account> updatePreExistAccts = new List<Account>();
        List<Account> listDuplicateAccts = new List<Account>();
        List<loan__Loan_Account__c> updateExistingLoanAccts = new List<loan__Loan_Account__c>();
        //LOP-452
        Map<Id, genesis__Applications__c> mapPreExistAcctsApps = new Map<Id, genesis__Applications__c>(); 
        Map<Id, loan__Loan_Account__c> mapExistingAllLoanAccts = new Map<Id, loan__Loan_Account__c>(); //duplicate as mapExistingLoanAccts     
        Map<Id, genesis__Applications__c> mapPreExistAcctsAppsNotActive = new Map<Id, genesis__Applications__c>(); 
              

        For(genesis__Applications__c app : apps) {
            If(
                (app.genesis__Status__c != oldMap.get(app.Id).genesis__Status__c && app.genesis__Status__c == 'kba_fail')
                ||
                (app.genesis__Status__c != oldMap.get(app.Id).genesis__Status__c && app.genesis__Status__c == 'kba_success') 
            )
            {
                    mapCurrentApps.put(app.genesis__Account__c, app);
                    setCurrentAcctIds.add(app.genesis__Account__c);
                    if(app.Bureau_SSN__c != null && app.Bureau_SSN__c != ''){
                        setDuplicateSsn.Add(app.Bureau_SSN__c);
                    }
            }
        }
        If(mapCurrentApps.size() > 0)
        {
            List<Account> listCurrentAccts = [
                        SELECT Id, Name, social_security_number_uniqueness_field__c
                        FROM Account 
                        WHERE Id IN :setCurrentAcctIds AND social_security_number_uniqueness_field__c = NULL
                ];
                For (Account acct : listCurrentAccts) {
                    mapCurrentAccts.put(acct.Id, acct);
                }

            If(mapCurrentAccts.size() > 0)
            {
                Map<String, Account> mapExistingDuplicateAccts = new Map<String, Account>();
                List<FeedItem> preExistAcctsPost = new List<FeedItem>();
                if (setDuplicateSsn !=null && setDuplicateSsn.size() > 0){
                   listDuplicateAccts = [
                    SELECT Id, Name, social_security_number_uniqueness_field__c
                    FROM Account 
                    WHERE social_security_number_uniqueness_field__c IN :setDuplicateSsn ]; 
                }
                For (Account acct : listDuplicateAccts) {
                        mapExistingDuplicateAccts.put(acct.social_security_number_uniqueness_field__c, acct);
                        setPreExistAcctIds.Add(acct.Id);
                }  

                List<loan__Loan_Account__c> listExistingLoanAcct = [
                    SELECT Id, loan__Account__c, loan__Loan_Status__c
                    FROM loan__Loan_Account__c 
                    WHERE loan__Account__c IN :setPreExistAcctIds AND loan__Loan_Status__c = 'Closed - Obligations met'
                ];
                For (loan__Loan_Account__c loanAcct : listExistingLoanAcct) {
                    mapExistingLoanAccts.put(loanAcct.loan__Account__c, loanAcct);
                    system.debug('Inside For Loop- mapExistingLoanAccts==>'+mapExistingLoanAccts);
                }

                //if any existing active application
                For (genesis__Applications__c app : 
                        [
                            SELECT Id, Name, genesis__Status__c, genesis__Account__c 
                            FROM genesis__Applications__c 
                            WHERE 
                            genesis__Account__c IN :setPreExistAcctIds
                            AND genesis__Status__c IN
                            (
                                'agent_document_verification_pending', 'agent_verification_pending',
                                'agent_verified', 'docusign_loan_docs_sent', 'docusign_loan_docs_complete', 
                                'pre_funding', 'Approved for funding'
                            )
                        ]
                    ) 
                {
                   mapPreExistAcctsActiveApps.put(app.genesis__Account__c, app);
                }
                //LOP-452 
                For (genesis__Applications__c app :
                        [
                            SELECT Id, Name, genesis__Status__c, genesis__Account__c
                            FROM genesis__Applications__c
                            WHERE
                            genesis__Account__c IN :setPreExistAcctIds
                        ]
                    )
                {
                    mapPreExistAcctsApps.put(app.genesis__Account__c, app);
                }


//if any existing  Loan application 
                List<loan__Loan_Account__c> listExistingAllLoanAcct = [
                    SELECT Id, loan__Account__c, loan__Loan_Status__c
                    FROM loan__Loan_Account__c
                    WHERE loan__Account__c IN :setPreExistAcctIds
                ];  
                For (loan__Loan_Account__c loanAcct : listExistingAllLoanAcct) {
                    mapExistingAllLoanAccts.put(loanAcct.loan__Account__c, loanAcct);
                    system.debug('Inside For Loop- mapExistingAllLoanAccts==>'+mapExistingAllLoanAccts);
                }

//if any existing expired/withdrawn/declined app application
                For (genesis__Applications__c app :
                        [
                            SELECT Id, Name, genesis__Status__c, genesis__Account__c
                            FROM genesis__Applications__c
                            WHERE
                            genesis__Account__c IN :setPreExistAcctIds AND genesis__Status__c IN
                            (
                                'expired', 'withdrawn','Expired-Withdrawn','Decline_Manual_Review','declined', 'Rejected'
                            )
                        ]
                    )
                {
                    mapPreExistAcctsAppsNotActive.put(app.genesis__Account__c, app);
                }
                
                For (Id acctId : mapCurrentAccts.keySet()) {
                    genesis__Applications__c app = mapCurrentApps.get(acctId);
                    Account currentAcct = mapCurrentAccts.get(acctId);
                    Account existingDuplAcct = mapExistingDuplicateAccts.get(app.Bureau_SSN__c);
                    loan__Loan_Account__c existingClosedLoanAcct;
                    Boolean IsPreExistAcctActiveAppThere;
                    Boolean IsPreExistClosedLoanThere;
                    loan__Loan_Account__c existingAnyLoanAcct; 
                    Boolean IsPreExistAnyLoanThere; 
                    Boolean IsPreExistAcctAnyAppThere; 
                    Boolean IsPreExistAcctAppNotActiveThere; 
                    
                    if(existingDuplAcct!=null){
                        existingClosedLoanAcct = mapExistingLoanAccts.get(existingDuplAcct.Id);
                        IsPreExistAcctActiveAppThere = mapPreExistAcctsActiveApps.get(existingDuplAcct.Id) != null? true: false;
                        IsPreExistClosedLoanThere = existingClosedLoanAcct != null? true: false;
                        existingAnyLoanAcct = mapExistingAllLoanAccts.get(existingDuplAcct.Id);
                        IsPreExistAcctAnyAppThere = mapPreExistAcctsApps.get(existingDuplAcct.Id) != null? true: false;
                        IsPreExistAnyLoanThere = existingAnyLoanAcct != null? true: false;
                        IsPreExistAcctAppNotActiveThere = mapPreExistAcctsAppsNotActive.get(existingDuplAcct.Id) != null? true: false; 
                        
                       If( (IsPreExistAcctActiveAppThere == false && IsPreExistClosedLoanThere == true)||
                            ((IsPreExistAcctAnyAppThere== false || IsPreExistAcctAppNotActiveThere== true) && IsPreExistAnyLoanThere == false)){
                            existingDuplAcct.loan__SOCIAL_SECURITY_NUMBER__c = NULL; //by workflow, it would update to social_security_number_uniqueness_field__c
                            existingDuplAcct.Encrypted_SSN__c = NULL;
                            existingDuplAcct.ints__SSN__c = NULL;
                            currentAcct.loan__SOCIAL_SECURITY_NUMBER__c = app.Bureau_SSN__c;
                            updatePreExistAccts.Add(existingDuplAcct);
                            updateCurrentAccts.Add(currentAcct);
                            //Adding account post
                            FeedItem acctPost = PostAccounts(existingDuplAcct,currentAcct);
                            preExistAcctsPost.Add(acctPost);
                    
                            If(existingClosedLoanAcct != null && IsPreExistClosedLoanThere == true)
                            {
                                existingClosedLoanAcct.loan__Account__c = currentAcct.Id;
                                updateExistingLoanAccts.Add(existingClosedLoanAcct);
                            }
                        }
                        
                    }
                }

                If(updatePreExistAccts.Size() > 0)
                {
                    Update updatePreExistAccts;
                }

                If(updateCurrentAccts.Size() > 0)
                {
                    Update updateCurrentAccts;
                }

                If(updateExistingLoanAccts.Size() > 0)
                {
                    Update updateExistingLoanAccts;
                }

                If(preExistAcctsPost.Size() > 0)
                {
                    Insert preExistAcctsPost;
                }                
            }
        }
    }
    /** Update the accounts with latest Income and housing values from Application */
    public static void UpdateAccount(List<genesis__Applications__c> newApps, Map<Id, genesis__Applications__c> oldMap, String triggerEvent) {
        List<Account> updateAccountList = new List<Account>();
        try{
            for (genesis__Applications__c app : newApps) {
                genesis__Applications__c oldApp = (oldMap != null && oldMap.size() > 0) ? oldMap.get(app.Id) : null;
                Account acct = new Account();
                /** Update Annual_Individual_Income__c on Account if a new application is inserted OR the field is updated on Application */
                if (app.Annual_Individual_Income_App__c != null && app.Annual_Individual_Income_App__c > 0 && ((triggerEvent == 'afterUpate' && app.Annual_Individual_Income_App__c != oldApp.Annual_Individual_Income_App__c) || (triggerEvent == 'afterInsert'))) {
                    acct.Annual_Individual_Income__c = app.Annual_Individual_Income_App__c;
                    acct.Id = app.genesis__Account__c;
                }
                /** Update Monthly_Housing_Payment_App__c on Account if a new application is inserted OR the field is updated on Application */
                if (app.Monthly_Housing_Payment_App__c != null && app.Monthly_Housing_Payment_App__c > 0 &&  ((triggerEvent == 'afterUpate' && app.Monthly_Housing_Payment_App__c != oldApp.Monthly_Housing_Payment_App__c) || (triggerEvent == 'afterInsert'))) {
                    acct.Monthly_Housing_Payment__c = app.Monthly_Housing_Payment_App__c;
                    acct.Id = app.genesis__Account__c;
                } 
                /** Add the account to update list if any one of the above 2 fields is updated */           
                if(acct.Id == app.genesis__Account__c){
                    updateAccountList.add(acct);
                }
            }
            
            if(updateAccountList.size() > 0) {            
                update updateAccountList;
            }
        }catch(Exception ex){
            MW_LogUtility.ExceptionDO expRex = new MW_LogUtility.ExceptionDO(ex);
            MW_DataDogCallOut.futureSend(JSON.serialize(MW_LogUtility.getLogRecord('MW_ApplicationService', newApps[0].Id, newApps[0].Lead_Id__c, 'UpdateAccount',JSON.serialize(expRex),'Error',null)), new List<String>());
        }
    }
    Public static FeedItem PostAccounts(Account existingDuplAct,Account currentAct){
        FeedItem acctPost = new FeedItem();
                            acctPost.ParentId = existingDuplAct.Id;
                            acctPost.Body = 'SSN was moved to ';
                            acctPost.Title = currentAct.Id;
                            acctPost.LinkUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + currentAct.Id;
        return acctPost;
    }    
}