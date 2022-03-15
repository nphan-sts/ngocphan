/** CLS-1121,1216,1095,1331
* Change Requirement :
* Pre-allocation of investors to be run at offer_accepted
* Final allocation to be run at ADVP
* if an application has eligible DCP transactions, a DCP enables investor should get allocated and DCP_Investor_Eligibility__c should
* be set to true
*If no investor is allocated, application should move to Review Queue **/
/* ****************Modification History*****************************************************************
*
* Modified by      Date        JIRA number
* 1.   Pallavi      2020/01/20  LOS-135/CRM-135 Generate TIL at docusign_loan_doc_sent status
* 2.   Anusha       2020/05/22 CRM -531 (SCHEMA changed)DCPM - CLS Requires an Offer Change Update DCP
* 3.   Anusha       2020/07/16 CRM-543 (Schema changes)Display link to 3rd party data portal
* 4.   Pallavi      2020/08/27 CRM-815 Automatic PASS of Credit Summary (T1-3 & Housing >= 500)
* 5.   Pallavi      2020/11/19 CRM-1022 Status 500 responses causing missing data in CLS - CLS Case #02456279
******************Modification History*****************************************************************/
trigger CustomTriggerOnApplication on genesis__Applications__c (before update, after update,before insert, after insert) {

    public Boolean isInvestorAllocated = false;
    public Boolean isDcpEligibleFieldUpdated = false;
    System.debug('CustomTriggerOnApplication');
    
    if (!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c ) {
        MW_Settings__c mwsetting = MW_Settings__c.getOrgDefaults();
        
        if(trigger.isBefore){
            if(trigger.isInsert){
                for(genesis__Applications__c app: trigger.new){
                    if(app.genesis__Expected_Start_Date__c != null){
                        app.genesis__Expected_Start_Date__c = date.today();
                    }
                    if(app.genesis__Expected_First_Payment_Date__c != null){
                        app.genesis__Expected_First_Payment_Date__c = app.genesis__Expected_Start_Date__c.addMonths(1);
                    }
                    if(app.Application_Start_DateV2__c == null){
                        app.Application_Start_DateV2__c = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
                    }
                }
            }
            if(trigger.isUpdate) {
                Map<id,genesis__Applications__c> oldAppMap = trigger.oldMap;
                Map<Id, genesis__Applications__c> newAppMap = null;
                for(genesis__Applications__c app : trigger.new){
                    
                    genesis__Applications__c oldApp = oldAppMap.get(app.id);
                    
                    if(app.Bureau_SSN__c != null && app.Bureau_SSN__c != oldApp.Bureau_SSN__c){
                        app.Bureau_SSN_Masked__c= '*******' + app.Bureau_SSN__c.right(4);
                    }
                    if(app.Loan_Doc_Signed_On__c != null && app.Loan_Doc_Signed_On__c != oldApp.Loan_Doc_Signed_On__c){
                        CustomTriggerOnApplicationHandler ctah = new CustomTriggerOnApplicationHandler();
                        app.Loan_Origination_Date__c = ctah.addWorkingDaysToDate(app.Loan_Doc_Signed_On__c,3);
                        if (newAppMap == null) {
                            newAppMap = new Map<Id, genesis__Applications__c>([
                                SELECT Id, Investor__r.Investor_Code__c
                                FROM genesis__Applications__c
                                WHERE Id IN : Trigger.new
                            ]);
                        }
                        String investorCode = newAppMap.get(app.Id).Investor__r.Investor_Code__c;
                        if (investorCode == 'CRB_THRM_MAIN' || investorCode == 'CRB_THRM_PRIME') {
                            app.Estimated_Purchase_Date__c = LoanBusinessCalculator.calculatePurchaseDate(app.Loan_Origination_Date__c,
                                                                                                          mwsetting.CRB_THRM_Loan_Transfer_Days__c.intValue());
                        }
                    }
                    if((app.Investor__c  != null && app.Investor__c != oldApp.Investor__c && !InvestorAllocation.allocationForADVPcalled)
                       ||(app.Investor__c  != null && app.Investor__c == oldApp.Investor__c && !InvestorAllocation.allocationForADVPcalled
                          && app.genesis__status__c == 'offer_accepted' && app.genesis__status__c != oldApp.genesis__status__c)){    //pallavi(PS-3695/LOS-132) //CRM-1022
                              isInvestorAllocated = CustomTriggerOnApplicationHandler.investorAllocationFieldsUpdate(trigger.old,trigger.new,trigger.oldMap);
                          }
                    //CRM-531 - start
                    if(app.DCP_Remainder_to_Member_Account__c != null && app.DCP_Remainder_to_Member_Account__c < 0){
                        isDcpEligibleFieldUpdated = CustomTriggerOnApplicationHandler.dcpEligibleFieldForUpdate(trigger.new);
                    }//CRM-531 - end
                }
            }
        }
        
        // CRM-543 - start
        if(!Test.isRunningTest()){
            if(trigger.isAfter && trigger.isInsert){
                
                for(genesis__Applications__c app : trigger.new){
                    TLOLinkConfig createTLOlink = new TLOLinkConfig();
                    List<genesis__applications__c> appsList = new List<genesis__applications__c>();
                    appsList.add(app);
                    createTLOlink.updateLinkonApps(appsList);
                }
            }
        }
        // CRM-543 - end
        
        List<String> deactivateStatus = System.Label.BankDeactivateStatus.split(',');
        //Added trigger.isUpdate on 03.08.2017
        if(trigger.isAfter && trigger.isUpdate){

            List<Id> plaidAppIds = new List<Id>();
            Map<id,genesis__Applications__c> oldAppMap = trigger.oldMap;

            for(genesis__Applications__c app : trigger.new){
                genesis__Applications__c oldApp = oldAppMap.get(app.id);
                /** Call to redecision logic */
                CustomTriggerOnApplicationHandler.callRedecisionLogic(app, oldApp,trigger.oldMap,trigger.newMap);
                
                //CRM-762
                if(app.GIACT_Status__c != null){
                    if((app.GIACT_Status__c.equals('Accept')) && (app.GIACT_Status__c != oldApp.GIACT_Status__c)){
                        CustomTriggerOnApplicationHandler.updateBankAccountTab(app.id);
                    }
                }
                // LOP-182
                if(app.Plaid_Status__c != oldApp.Plaid_Status__c){
                    CustomTriggerOnApplicationHandler.updateBankStatement(app.id, app.Plaid_Status__c);
                }
                if(app.is_Plaid_Asset_Available__c && app.is_Plaid_Asset_Available__c != oldApp.is_Plaid_Asset_Available__c) {
                    plaidAppIds.add(app.Id);
                }
                //CRM-762
                //CRM-531 - start
                if(app.dcp_eligible__c == 'No - Application Changed'){
                    Boolean isUpdated = CustomTriggerOnApplicationHandler.payAtFundingForUpdate(app.Id);
                }
                //CRM-531 - end
                //CRM-815
                if(app.OwnerId != oldApp.OwnerId){
                    QueueSobject Queues = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject
                                           WHERE SobjectType = 'genesis__Applications__c'
                                           AND queue.DeveloperName = 'Final_Verification' ];
                    if(app.OwnerId == Queues.Queue.Id){
                        OrgWideEmailAddress emailid = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'PayOff' LIMIT 1];
                        List<Credit_Policy__c> creditPolicy = [SELECT id,Credit_Card_Total_Count__c,Unsecured_Installment_Loans_Count__c
                                                               FROM Credit_Policy__c WHERE Application__c =: app.id
                                                               ORDER BY createddate DESC LIMIT 1];
                        
                        
                        if(creditPolicy.size() != 0){
                            if((creditPolicy[0].Credit_Card_Total_Count__c <=0) && (creditPolicy[0].Unsecured_Installment_Loans_Count__c <=0)){
                                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                List<String> sendTo = Label.CreditSummaryEmpty_mail.split(';');
                                mail.setToAddresses(sendTo);
                                mail.setOrgWideEmailAddressId(emailid.id);
                                mail.setSubject( app.name + ' Credit Summary tab is empty.');
                                mail.setHtmlBody(app.Lead_ID__c + ', ' + app.Name + ', Credit Summary tab is empty.');
                                mails.add(mail);
                                if (!Test.isRunningTest()) {
                                    Messaging.sendEmail(mails);
                                }
                            }
                        }
                    }
                }

                //CRM-815
                if(app.genesis__Status__c == 'Default Documents' && app.genesis__Status__c != oldApp.genesis__Status__c) {
                    TalxIntegration.CallTalxResponse(app.Id, app.genesis__account__c);
                } else if(app.genesis__Status__c == 'offer_accepted' && app.genesis__Status__c != oldApp.genesis__Status__c ) {

                } else if(deactivateStatus.contains(app.genesis__Status__c) && app.genesis__Status__c != oldApp.genesis__Status__c ) {
                    DeactivateBankAccountsforApplications.deactivateBankAccount(app.id);
                } else if (
                        (!InvestorAllocation.allocationForADVPcalled &&
                                app.genesis__Status__c == 'agent_document_verification_pending' &&
                                app.genesis__Status__c != oldApp.genesis__Status__c) ||
                        (!InvestorAllocation.allocationForPricingTierCalled &&
                                app.genesis__Status__c == 'agent_document_verification_pending' &&
                                app.genesis__Status__c == oldApp.genesis__Status__c &&
                                app.Pricing_Tier__c != oldApp.Pricing_Tier__c)) {  //CLS-1121,1216,1095,LOP-441

                    List<Credit_Policy__c> creditPolicies = [SELECT Id FROM Credit_Policy__c  WHERE Application__c= : app.Id];
                    System.debug('creditPolicies size check: ' + creditPolicies.size());

                    if (creditPolicies.size() > 0) {

                        String res = genesis.ScorecardAPI.generateScorecard(app.id);
                        Boolean result = true;
                        if (MW_AllocationEngineHandler.isRulesApiEnabled()) {
                            result = InvestorAllocation.runInvestorAllocationBasedOnWeighting(app.Id);
                        }

                        if (MW_AllocationEngineHandler.isAllocationEngineServiceEnabled()) {
                            MW_AllocationEngineHandler.handleAdvp(new List<Id> {app.Id});
                            InvestorAllocation.allocationForADVPcalled = true;
                        }

                        if (app.genesis__Status__c == 'agent_document_verification_pending' &&
                                app.genesis__Status__c == oldApp.genesis__Status__c &&
                                app.Pricing_Tier__c != oldApp.Pricing_Tier__c) { //LOP-441
                            InvestorAllocation.allocationForPricingTierCalled = true;
                        }

                    } else {
                                
                        Map<String, Object> msg = new Map<String, Object>();
                        msg.put('app.Id', app.Id);
                        msg.put('app.Lead_ID__c', app.Lead_ID__c);
                        msg.put('app.genesis__Status__c.', app.genesis__Status__c);
                        msg.put('app.msg', 'No application credit policy record found.  Ignoring allocation request in CustomTriggerOnApplication');

                        System.debug('sending datadog creditPolicies error');
                        MW_LogUtility.errorMessage('CustomTriggerOnApplication', 'Ignore Investor Allocation', msg);
                    }

                } else if (app.genesis__status__c == 'docusign_loan_docs_sent' && app.genesis__status__c != oldapp.genesis__Status__c){ /*(LOS-135)*/
                    if(app.Investor__c!=null){
                        if(app.Total_Arcus_Transactions__c >0){
                            TilGeneration__e til = new TilGeneration__e(RecordId__c = app.Id,
                                                                        Investor__c = app.Investor__r.Name,
                                                                        appStatus__c = 'TIL');
                            Database.SaveResult sr = EventBus.publish(til);
                        }
                        else{                            
                            TilGeneration__e til = new TilGeneration__e(RecordId__c = app.Id,
                                                                        Investor__c = app.Investor__r.Name,
                                                                        appStatus__c = 'TILDocument_forDCP');
                            Database.SaveResult sr = EventBus.publish(til);
                            
                            if (sr.isSuccess()) {                                
                                System.debug('Successfully published event.');                                
                            } else {
                                for(Database.Error err : sr.getErrors()) {                                    
                                    System.debug('Error returned: ' + err.getStatusCode() +' - ' + err.getMessage());                                    
                                }                                
                            }
                        }
                    }
                } else if ((mwsetting.OLN_Stacker_Threshold__c != null) &&
                                (app.OLN_Stacker_Status__c >= mwsetting.OLN_Stacker_Threshold__c &&
                                        app.OLN_Stacker_Status__c != oldApp.OLN_Stacker_Status__c) &&
                                app.genesis__status__c!='Declined') { /*(LOS-135)*/
                    system.debug('olnstatus--->'+app.OLN_Stacker_Status__c);
                    
                    PayoffUtilities.AssignToDeclinedQueueStatus(app.id,'Declined');
                } else if(app.genesis__Status__c != null && app.Investor__c  != null) {
                    if(app.genesis__Status__c == 'agent_verified' && app.DocuSignFlag__c && app.genesis__Status__c != oldApp.genesis__Status__c){
                           SendEnvDocuSignAPI.sendDocuSignEnvelope(app.Id);
                    }
                    /*pallavi(LOS-158)*/
                    List<Attachment> toattachCSN = new List<Attachment>();
                    Set<Id> CSNattId = new Set<Id>();
                    if(app.genesis__Status__c == 'Stacker_Check_Passed' && app.genesis__status__c != oldApp.genesis__Status__c){
                        
                        toattachCSN = [SELECT id FROM attachment WHERE parentId = :app.Id AND Name LIKE '%Credit Score Notice%'];
                        if(toattachCSN.size() == 0){
                            ApplicationAttachmentHandler.attachmentHandler(app.Id, app.Investor__r.Name, 'CSN');
                        }
                        else{
                            for(Attachment att : toattachCSN){
                                CSNattId.add(att.Id);
                            }
                            Integer countCSN = [SELECT COUNT() FROM genesis__AppDocCatAttachmentJunction__c WHERE genesis__AttachmentId__c IN :CSNattId AND isDeleted = FALSE];
                            if(countCSN == 0){
                                ApplicationAttachmentHandler.attachmentHandler(app.Id, app.Investor__r.Name, 'CSN');
                            }
                        }
                    }
                    /*pallavi(LOS-158)*/
                }

                if (MW_AllocationEngineHandler.statusListContains(
                        MW_Settings__c.getOrgDefaults().Allocation_Engine_Cancel_Statuses__c, app.genesis__Status__c) &&
                        oldApp.genesis__Status__c != app.genesis__Status__c &&
                        MW_AllocationEngineHandler.isAllocationEngineServiceEnabled()) {
                    MW_AllocationEngineHandler.handleCancelled(new List<Id> {app.Id});
                }

            }
            if (plaidAppIds.size() > 0) {
                MW_ADCServicehandler.refreshADCStructure(plaidAppIds);
            }
        }
    }
}