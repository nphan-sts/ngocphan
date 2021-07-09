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
                System.debug('>>> 1'+jobID);
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
            /* CLS-676 -- Moved to process builder as a part of CLS-1302
            if(app.Employment_Status__c!= null && oldMap.get(app.Id).genesis__Status__c!=app.Employment_Status__c  && app.Employment_Status__c =='Self Employed' && !app.isSelfEmployed__c) {
                app.genesis__Status__c ='Self Employed Documents';
                app.isSelfEmployed__c = true;
            }*/

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

    //LOP-220, LOP-221, LOP-222, LOP-257
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
        List<loan__Loan_Account__c> updateExistingLoanAccts = new List<loan__Loan_Account__c>();

        For(genesis__Applications__c app : apps) {
            If(
                (app.genesis__Status__c != oldMap.get(app.Id).genesis__Status__c && app.genesis__Status__c == 'kba_fail')
                ||
                (app.genesis__Status__c != oldMap.get(app.Id).genesis__Status__c && app.genesis__Status__c == 'kba_success') 
            )
            {
                    mapCurrentApps.put(app.genesis__Account__c, app);
                    setCurrentAcctIds.add(app.genesis__Account__c);
                    setDuplicateSsn.Add(app.Bureau_SSN__c);
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

                List<Account> listDuplicateAccts = [
                    SELECT Id, Name, social_security_number_uniqueness_field__c
                    FROM Account 
                    WHERE social_security_number_uniqueness_field__c IN :setDuplicateSsn
                ];
                
                For (Account acct : listDuplicateAccts) {
                        mapExistingDuplicateAccts.put(acct.social_security_number_uniqueness_field__c, acct);
                        setPreExistAcctIds.Add(acct.Id);
                }

                //
                List<loan__Loan_Account__c> listExistingLoanAcct = [
                    SELECT Id, loan__Account__c, loan__Loan_Status__c
                    FROM loan__Loan_Account__c 
                    WHERE loan__Account__c IN :setPreExistAcctIds AND loan__Loan_Status__c = 'Closed - Obligations met'
                ];
                For (loan__Loan_Account__c loanAcct : listExistingLoanAcct) {
                    mapExistingLoanAccts.put(loanAcct.loan__Account__c, loanAcct);
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

                For (Id acctId : mapCurrentAccts.keySet()) {
                    genesis__Applications__c app = mapCurrentApps.get(acctId);
                    Account currentAcct = mapCurrentAccts.get(acctId);
                    Account existingDuplAcct = mapExistingDuplicateAccts.get(app.Bureau_SSN__c);
                    loan__Loan_Account__c existingLoanAcct = mapExistingLoanAccts.get(existingDuplAcct.Id);
                    Boolean IsPreExistAcctActiveAppThere = mapPreExistAcctsActiveApps.get(existingDuplAcct.Id) != null? true: false;

                    If( IsPreExistAcctActiveAppThere == false 
                            && 
                            (existingLoanAcct == null || existingLoanAcct.loan__Loan_Status__c == 'Closed - Obligations met')
                        )
                    {
                        existingDuplAcct.loan__SOCIAL_SECURITY_NUMBER__c = NULL; //by workflow, it would update to social_security_number_uniqueness_field__c
                        existingDuplAcct.Encrypted_SSN__c = NULL;
                        existingDuplAcct.ints__SSN__c = NULL;
                        currentAcct.loan__SOCIAL_SECURITY_NUMBER__c = app.Bureau_SSN__c;
                        updatePreExistAccts.Add(existingDuplAcct);
                        updateCurrentAccts.Add(currentAcct);

                        //Adding account post
                        FeedItem acctPost = new FeedItem();
                        acctPost.ParentId = existingDuplAcct.Id;
                        acctPost.Body = 'SSN was moved to ';
                        acctPost.Title = currentAcct.Id;
                        acctPost.LinkUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + currentAcct.Id;
                        
                        preExistAcctsPost.Add(acctPost);
                    
                        If(existingLoanAcct != null)
                        {
                            existingLoanAcct.loan__Account__c = currentAcct.Id;
                            updateExistingLoanAccts.Add(existingLoanAcct);
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
                
            } //If(mapCurrentAccts.size() > 0)
        } //If(mapCurrentApps.size() > 0)
    }

}