global with sharing class MW_SynchronizeHandler {

    public static boolean avoidrecursiveFuture = false;
    public static boolean preventIsAfterRecursionOnApplication = false;

    global static void Sync_application_OnEnvId(Set<String> apList, String RequestType){
        sync_application syncApp = new sync_application(RequestType, getApplicaitonInfo(apList));
        String str = JSON.serialize(syncApp, true);
        MW_WebhookHandler.CallWebHookIntegration(str, ''+apList, '');
    }

    public static list<ApplicationInformation> getApplicaitonInfo(Set<String> apList){

        list<ApplicationInformation> listAppInfo  = new list<ApplicationInformation>();

        Map<Id,Pricing_Offer__c> selectedOfferMap   = selectedOfferQuery(apList);

        // Map<Id,Adverse_Actions__c> adverseFactorMap = adverseActionResults(apList);
        for(genesis__Applications__c applist: Database.query(applicationQuery(apList))) {
            applicationinformation appinfo             = new ApplicationInformation();
            appinfo.member_id                          = applist.Member_ID__c;
            appinfo.id                                 = applist.id;
            appinfo.account                            = applist.genesis__Account__r.name;
            appinfo.application_start_date             = applist.Application_Start_Date__c;
            appinfo.application_work_email             = applist.Application_Work_Email__c;
            appinfo.apr                                = applist.genesis__APR__c;
            appinfo.bank_account                       = applist.Bank_Account__c;
            appinfo.bank_account_number                = applist.genesis__Bank_Account_Number__c;
            appinfo.bank_account_type                  = applist.genesis__Bank_Account_Type__c;
            appinfo.bank_name                          = applist.genesis__Bank_Name__c;
            appinfo.bank_verification_flag             = applist.Bank_Verification_Flag__c;
            appinfo.borrower_s_email                   = applist.Borrower_s_Email__c;
            appinfo.borrower_s_first_name              = applist.Borrower_s_First_Name__c;
            appinfo.borrower_s_lastname                = applist.Borrower_s_LastName__c;
            appinfo.borrowers_work_email               = applist.Borrowers_Work_Email__c;
            appinfo.cl_product_name                    = applist.genesis__CL_Product_Name__c;
            appinfo.credit_policy_verification_flag    = applist.Credit_Policy_Verification_Flag__c;
            appinfo.description                        = applist.genesis__Description__c;
            appinfo.disbursement_date                  = applist.genesis__Disbursement_Date__c;
            appinfo.discount_rate                      = applist.genesis__Discount_Rate__c;
            appinfo.docusign_envelope_id               = applist.DocuSign_Envelope_ID__c;
            appinfo.docusign_envelope_status           = applist.DocuSign_Envelope_Status__c;
            appinfo.docusignflag                       = applist.DocuSignFlag__c;
            appinfo.docusign_sign_date                 = applist.DocuSign_Sign_Date__c;
            appinfo.employee_loan                      = applist.genesis__Employee_Loan__c;
            appinfo.employer                           = applist.Employer__c;
            appinfo.employment_status                  = applist.Employment_Status__c;
            appinfo.expected_start_date                = applist.genesis__Expected_Start_Date__c;
            appinfo.financed_amount                    = applist.genesis__Financed_Amount__c;
            appinfo.income_verification_flag           = applist.Income_Verification_Flag__c;
            appinfo.interest_rate                      = applist.genesis__Interest_Rate__c;
            appinfo.invested_amount                    = applist.Invested_Amount__c;
            appinfo.investor_name                      = applist.Investor__r.Investor_Code__c;
            appinfo.lending_partner                    = applist.Investor__r.Lending_Partner__c;
            appinfo.investoraddress                    = applist.InvestorAddress__c;
            appinfo.isredecision                       = applist.isRedecision__c;
            appinfo.kba_verification                   = applist.KBA_Verification__c;
            appinfo.last_investor_assigned_on          = applist.Last_Investor_Assigned_On__c;
            appinfo.last_payment_amount                = applist.Last_Payment_Amount__c;
            appinfo.lead_guid                          = applist.Lead_ID__c;
            appinfo.lead_id                            = applist.LEAD_ID_ExtKey__c;
            appinfo.lead_source                        = applist.Lead_Source__c;
            appinfo.lending_product                    = applist.genesis__Lending_Product__c;
            appinfo.loan_amount                        = applist.genesis__Loan_Amount__c;
            appinfo.maturity_date                      = applist.Loan_Maturity_Date__c;
            appinfo.maximum_loan_amount_dti            = applist.genesis__Maximum_Loan_Amount_DTI__c;
            appinfo.notifycheck                        = applist.NotifyCheck__c;
            appinfo.origination_fee                    = applist.Origination_fee__c;
            appinfo.other_financed_fees                = applist.genesis__Other_Financed_fees__c;
            appinfo.parent_application                 = applist.genesis__Parent_Application__c;
            appinfo.payment_amount                     = applist.genesis__Payment_Amount__c;
            appinfo.payment_frequency                  = applist.genesis__Payment_Frequency__c;
            appinfo.payment_mode                       = applist.Payment_Mode__c;
            appinfo.payoff_uid                         = applist.Payoff_UID__c;
            appinfo.portfolio                          = applist.genesis__Portfolio__c;
            appinfo.pricing_method                     = applist.genesis__Pricing_Method__c;
            appinfo.rejected                           = applist.Rejected__c;
            appinfo.routing_number                     = applist.genesis__Routing_Number__c;
            appinfo.sift_status                        = applist.Sift_Status__c;
            appinfo.overall_status                     = applist.genesis__Overall_Status__c;
            appinfo.status                             = applist.genesis__Status__c;
            appinfo.submitted                          = applist.Submitted__c;
            appinfo.term                               = applist.genesis__Term__c;
            appinfo.terms_selected                     = applist.genesis__Terms_Selected__c;
            appinfo.total_calculated_income            = applist.Total_Calculated_Income__c;
            appinfo.total_of_payments                  = applist.Total_of_Payments__c;
            appinfo.total_stated_income                = applist.Total_Stated_Income__c;
            appinfo.total_upfront_payments             = applist.genesis__Total_Upfront_Payments__c;
            appinfo.variance                           = applist.Variance__c;
            appinfo.work_email                         = applist.Work_Email__c;
            appinfo.expiry_date                        = applist.Expiry_Date__c;
            appinfo.owner_name                         = applist.owner.Name;
            appinfo.esign_consent_withdrawn            = applist.Esign_consent_withdrawn__c;
            appinfo.dcp_investor_available             = applist.DCP_Investor_Eligibility__c;
            appinfo.kba_manual_passed                  = applist.Manual_KBA__c;
            /*    appinfo.no_of_payments_required_upfront    = applist.genesis__No_Of_Payments_Required_Upfront__c;
                appinfo.x14day_s_before_expiration_date    = applist.X14day_s_Before_Expiration_Date__c;
                appinfo.accepted                           = applist.Accepted__c;
                appinfo.action                             = applist.genesis__Action__c;
                appinfo.additional_cash_required           = applist.genesis__Additional_Cash_Required__c;
                appinfo.alertflag                          = applist.ALertFlag__c;
                appinfo.alerts_no_of_days_before_expiration= applist.Alerts_No_Of_Days_Before_Expiration__c;
                appinfo.amortization_term                  = applist.genesis__Amortization_Term__c;
                appinfo.estimated_amount_needed            = applist.Estimated_Amount_needed__c;
                appinfo.applicant_name                     = applist.Applicant_Name__c;
                appinfo.application_email                  = applist.Application_Email__c;
                appinfo.application_external_id            = applist.Application_external_id__c;
                appinfo.application_graph                  = applist.Application_Graph__c;
                appinfo.arrears                            = applist.genesis__Arrears__c;
                appinfo.asset_liability_info               = applist.genesis__Asset_Liability_Info__c;
                appinfo.asset_class                        = applist.genesis__Asset_Class__c;
                appinfo.assigned_to                        = applist.genesis__Assigned_To__c;
                appinfo.auto_decisioning                   = applist.genesis__Auto_Decisioning__c;
                appinfo.balloon_payment                    = applist.genesis__Balloon_Payment__c;
                appinfo.bank_transactions_fetched          = applist.genesis__Bank_Transactions_Fetched__c;
                appinfo.call_code                          = applist.genesis__Call_Code__c;
                appinfo.cap_reduction                      = applist.genesis__Cap_Reduction__c;
                appinfo.cash_collected_by_dealer           = applist.genesis__Cash_Collected_By_Dealer__c;
                appinfo.charge_offs                        = applist.genesis__Charge_offs__c;
                appinfo.checkemailalertvalue               = applist.CheckEmailAlertValue__c;
                appinfo.class_code                         = applist.genesis__Class_Code__c;
                appinfo.cl_contract                        = applist.CL_Contract__c;
                appinfo.cl_purpose                         = applist.genesis__CL_Purpose__c;
                appinfo.collateral_value                   = applist.genesis__Collateral_Value__c;
                appinfo.cl_company                         = applist.genesis__CL_Company__c;
                appinfo.company                            = applist.genesis__Company__c;
                appinfo.iovation_status                    = applist.Iovation_Status__c;
                appinfo.contact                            = applist.genesis__Contact__c;
                appinfo.estimated_credit_card_balances     = applist.Estimated_credit_card_balances__c;
                appinfo.credit_limit                       = applist.genesis__Credit_Limit__c;
                appinfo.credit_rating                      = applist.genesis__Credit_Rating__c;
                appinfo.credit_summary_verification        = applist.Credit_Summary_Verification__c;
                appinfo.customer_cash_available            = applist.genesis__Customer_Cash_Available__c;
                appinfo.customer_cash_used_for             = applist.genesis__Customer_Cash_Used_For__c;
                appinfo.days_convention                    = applist.genesis__Days_Convention__c;
                appinfo.dealer_payment_date                = applist.genesis__Dealer_Payment_Date__c;
                appinfo.differenc_between_today_and_expiry_Date=    applist.Differenc_Between_Today_and_Expiry_Date__c;
                appinfo.discount_rate_based_on             = applist.genesis__Discount_Rate_Based_On__c;
                appinfo.documentation_charges              = applist.genesis__Documentation_Charges__c;
                appinfo.down_payment                       = applist.genesis__Down_Payment__c;
                appinfo.draw_period_end_date               = applist.genesis__Draw_Period_End_Date__c;
                appinfo.draw_term                          = applist.genesis__Draw_Term__c;
                appinfo.due_day                            = applist.genesis__Due_Day__c;
                appinfo.estimated_selling_price            = applist.genesis__Estimated_Selling_Price__c;
                appinfo.expected_close_date                = applist.genesis__Expected_Close_Date__c;
                appinfo.expected_first_payment_date        = applist.genesis__Expected_First_Payment_Date__c;
                appinfo.expected_second_pay_day_date       = applist.genesis__Expected_Second_Pay_Day_Date__c;
                appinfo.expiration_date_for_email_trigger  = applist.Expiration_Date_for_Email_trigger__c;
                appinfo.fees_amount                        = applist.genesis__Fees_Amount__c;
                appinfo.file_cleared_image                 = applist.File_cleared_Image__c;
                appinfo.openimage                          = applist.OpenImage__c;
                appinfo.file_rejected_image                = applist.File_rejected_image__c;
                appinfo.file_submitted_image               = applist.File_submitted_image__c;
                appinfo.file_total_image                   = applist.File_total_image__c;
                appinfo.first_time_offer_select            = applist.First_time_offer_select__c;
                appinfo.funding_in_tranches                = applist.genesis__Funding_in_Tranches__c;
                appinfo.giact_date                         = applist.GIACT_Date__c;
                appinfo.giactperformed_by                  = applist.GIACTPerformed_By__c;
                appinfo.giact_status                       = applist.GIACT_Status__c;
                appinfo.gross_annual_income                = applist.genesis__Gross_Annual_Income__c;
                appinfo.healthcare_procedure               = applist.genesis__Healthcare_Procedure__c;
                appinfo.identity_counter                   = applist.Identity_Counter__c;
                appinfo.id_number                          = applist.genesis__ID_Number__c;
                appinfo.id_state                           = applist.genesis__ID_State__c;
                appinfo.id_type                            = applist.genesis__ID_Type__c;
                appinfo.initial_advance                    = applist.genesis__Initial_Advance__c;
                appinfo.initial_term_payment_amt           = applist.Initial_Term_Payment_Amt__c;
                appinfo.interest_calculation_method        = applist.genesis__Interest_Calculation_Method__c;
                appinfo.interest_compounding_frequency     = applist.genesis__Interest_Compounding_Frequency__c;
                appinfo.interest_only_period               = applist.genesis__Interest_Only_Period__c;
                appinfo.investor_selected                  = applist.Investor_Selected__c;
                appinfo.is_get_yield_enabled               = applist.genesis__Is_Get_Yield_Enabled__c;
                appinfo.is_over_21                         = applist.genesis__Is_over_21__c;
                appinfo.is_pb_running                      = applist.is_PB_running__c;
                appinfo.iv_performed_by                    = applist.IV_Performed_By__c;
                appinfo.iv_performed_date                  = applist.IV_Performed_Date__c;
                appinfo.kbav_performed_by                  = applist.KBAV_Performed_BY__c;
                appinfo.kbav_performed_date                = applist.KBAV_Performed_Date__c;
                appinfo.landing_sequence                   = applist.genesis__Landing_Sequence__c;
                appinfo.estimated_loan_balances            = applist.Estimated_loan_balances__c;
                appinfo.loan_number                        = applist.genesis__Loan_Number__c;
                appinfo.loan_term_sub_1                    = applist.Loan_Term_sub_1__c;
                appinfo.ltv_pledged_collateral             = applist.genesis__LTV_Pledged_Collateral__c;
                appinfo.margin                             = applist.genesis__Margin__c;
                appinfo.minimum_cash_required              = applist.genesis__Minimum_Cash_Required__c;
                appinfo.monthly_debt_payments              = applist.genesis__Monthly_Debt_Payments__c;
                appinfo.monthly_income_expense_info        = applist.genesis__Monthly_Income_Expense_Info__c;
                appinfo.neo_verification                   = applist.Neo_Verification__c;
                appinfo.neo_verify                         = applist.Neo_Verify__c;
                appinfo.neov_performed_by                  = applist.NeoV_Performed_By__c;
                appinfo.neov_performed_date                = applist.NeoV_Performed_Date__c;
                appinfo.net_difference                     = applist.Net_Difference__c;
                appinfo.net_difference_net_income          = applist.Net_Difference_Net_Income__c;
                appinfo.net_present_value                  = applist.genesis__Net_Present_Value__c;
                appinfo.net_total_calculated_income        = applist.Net_Total_Calculated_Income__c;
                appinfo.net_total_stated_income            = applist.Net_Total_Stated_Income__c;
                appinfo.net_variance                       = applist.Net_Variance__c;
                appinfo.neustart                           = applist.Neustart__c;
                appinfo.number_of_pieces_of_equipment      = applist.genesis__Number_of_Pieces_of_Equipment__c;
                appinfo.open                               = applist.Open__c;
                appinfo.estimated_origination_fee          = applist.Estimated_origination_fee__c;
                appinfo.participation_date                 = applist.genesis__Participation_Date__c;
                appinfo.payable_to_dealer                  = applist.genesis__Payable_To_Dealer__c;
                appinfo.total_dealer_payable               = applist.genesis__Total_Dealer_Payable__c;
                appinfo.payment_amount_step_up_type        = applist.genesis__Payment_Amount_Step_Up_Type__c;
                appinfo.payment_due_date                   = applist.genesis__Payment_Due_Date__c;
                appinfo.payment_frequency_multiplier       = applist.genesis__Payment_Frequency_Multiplier__c;
                appinfo.prepaid_interest_option            = applist.genesis__Prepaid_Interest_Option__c;
                appinfo.prepayment_penalty                 = applist.genesis__Prepayment_Penalty__c;
                appinfo.prepayment_penalty_description     = applist.genesis__Prepayment_Penalty_Description__c;
                appinfo.collateral_type                    = applist.genesis__Collateral_Type__c;
                appinfo.primary_collateral_code            = applist.genesis__Primary_Collateral_Code__c;
                appinfo.primary_property_address           = applist.genesis__Primary_Property_Address__c;
                appinfo.primary_source_of_repayment        = applist.genesis__Primary_Source_of_Repayment__c;
                appinfo.probability                        = applist.genesis__Probability__c;
                appinfo.product_sub_type                   = applist.genesis__Product_Sub_Type__c;
                appinfo.product_type                       = applist.genesis__Product_Type__c;
                appinfo.quick_quote                        = applist.genesis__Quick_Quote__c;
                appinfo.rate_ceiling                       = applist.genesis__Rate_Ceiling__c;
                appinfo.rate_discount                      = applist.genesis__Rate_Discount__c;
                appinfo.rate_floor                         = applist.genesis__Rate_Floor__c;
                appinfo.regulation_o                       = applist.genesis__Regulation_O__c;
                appinfo.required_customer_cash             = applist.genesis__Required_Customer_Cash__c;
                appinfo.residual_amount                    = applist.genesis__Residual_Amount__c;
                appinfo.retained_amount                    = applist.genesis__Retained_Amount__c;
                appinfo.sales_division                     = applist.genesis__Sales_Division__c;
                appinfo.secondary_source_of_repayment      = applist.genesis__Secondary_Source_of_Repayment__c;
                appinfo.send_offer_expiry_notification     = applist.Send_Offer_expiry_notification__c;
                appinfo.spread                             = applist.genesis__Spread__c;
                appinfo.sublimit_total                     = applist.genesis__SubLimit_Total__c;
                appinfo.sublimit_variance                  = applist.genesis__Sublimit_Variance__c;
                appinfo.summary_of_revolving_balances      = applist.Summary_of_Revolving_Balances__c;
                appinfo.tax_amount                         = applist.genesis__Tax_Amount__c;
                appinfo.today_s_date                       = applist.Today_s_Date__c;
                appinfo.total                              = applist.Total__c;
                appinfo.total_cash_due_from_customer       = applist.genesis__Total_Cash_Due_from_Customer__c;
                appinfo.total_dealer_price                 = applist.genesis__Total_Dealer_Price__c;
                appinfo.total_estimated_interest           = applist.genesis__Total_Estimated_Interest__c;
                appinfo.total_facilities                   = applist.genesis__Total_Facilities__c;
                appinfo.total_facility_amount              = applist.genesis__Total_Facility_Amount__c;
                appinfo.total_facility_variance            = applist.genesis__Total_Facility_Variance__c;
                appinfo.total_fee_amount                   = applist.genesis__Total_Fee_Amount__c;
                appinfo.total_pledged_collateral_amount    = applist.genesis__Total_Pledged_Collateral_Amount__c;
                appinfo.total_required                     = applist.Total_required__c;
                appinfo.total_score                        = applist.genesis__Total_Score__c;
                appinfo.total_uploaded                     = applist.Total_Uploaded__c;
                appinfo.valid_pricing_flag                 = applist.genesis__Valid_Pricing_Flag__c;
                appinfo.warranty_amount                    = applist.genesis__Warranty_Amount__c;
                appinfo.what_you_get_total_amount_offered  = applist.What_you_get_Total_Amount_Offered__c;
                appinfo.yield                              = applist.genesis__Yield__c; */
            appinfo.expiration_date                    = applist.Expiration_Date__c;

            /*
                  CLS-738
             */
            if(selectedOfferMap.size()>0 && selectedOfferMap.get(applist.id)!=null) {
                appinfo.selected_loan_amount               = String.valueOf(selectedOfferMap.get(applist.id).Amount__c);
                appinfo.selected_term                      = String.valueOf(selectedOfferMap.get(applist.id).Term__c);
                appinfo.selected_monthly_payment           = String.valueOf(selectedOfferMap.get(applist.id).Monthly_Payment__c);
                appinfo.selected_interest_rate             = String.valueOf(selectedOfferMap.get(applist.id).Interest_Rate__c);
                appinfo.selected_apr                       = String.valueOf(selectedOfferMap.get(applist.id).APR__c);
                appinfo.selected_origination_fee           = String.valueOf(selectedOfferMap.get(applist.id).Origination_fee__c);
                appinfo.selected_origination_fee_rate      = String.valueOf(selectedOfferMap.get(applist.id).Origination_fee_rate__c);
                appinfo.selected_offer_key                 = String.valueOf(selectedOfferMap.get(applist.id).Key__c);
            }

            /*
                  CLS-656
             */


            if(applist.genesis__Status__c=='Decline_Manual_Review' && applist.owner.Name=='Declined') {
                appinfo.is_declined                         = true;

                adverse_actions aa = new adverse_actions();
                if(applist.Manual_Adverse_Action_Decline__r.Decline_Name__c!=null)
                    aa.name            = applist.Manual_Adverse_Action_Decline__r.Decline_Name__c;
                if(applist.Manual_Adverse_Action_Decline__r.Description__c!=null)
                    aa.reason          = applist.Manual_Adverse_Action_Decline__r.Description__c;
                if(applist.Manual_Adverse_Action_Decline__r.Reason__c!=null)
                    aa.description     = applist.Manual_Adverse_Action_Decline__r.Reason__c;

                appinfo.adverse_actions.add(aa);

            }

            /*
               CLS-690
             */

            if(applist.genesis__Status__c=='Expired') {
                appinfo.is_expired                         = true;
            }

            /*
               CLS- 690
             */
            
            /*LOP-342 - Expired-Withdrawn */
            if(applist.genesis__Status__c=='Expired-Withdrawn') {
                appinfo.is_expired                         = true;
            }
            
            
            if(applist.genesis__Status__c=='Declined' && applist.owner.Name=='Declined') {
                Map<Id,Credit_Policy__c>  cpMap = MW_WebhookHelper.selectedCreditPolicyDetails(new Set<String>{applist.id});
                if(cpMap.size()>0 && cpMap.get(applist.id)!=null && cpMap.get(applist.id).Loan_amount_counteroffer__c!=null) {
                    appinfo.is_expired                         = true;
                }
            }

            /*
               CLS-657
             */

            if(applist.owner.Name=='Review Queue') {
                appinfo.is_manual_review = true;
            }else{
                appinfo.is_manual_review = false;
            }

            /*CLS-913 - Withdrawn */

            if(applist.genesis__Status__c=='Withdrawn')
            {
                appinfo.is_withdrawn = true;
            }

            listAppInfo.add(appInfo);
        }

        return listAppInfo;
    }

    @Future(callout=true)
    global static void Sync_application(Set<String> apList, String RequestType)
    {
        sync_application syncApp = new sync_application(RequestType, getApplicaitonInfo(apList));
        String str = JSON.serialize(syncApp, true);
        MW_WebhookHandler.CallWebHookIntegration(str, ''+apList, '');
    }

    @Future(callout=true)
    global static void Sync_account(List<String> accountList)
    {
        list<AccountInformation> listaccInfo = new list<AccountInformation>();

        for(Account acclist:accountQuery(accountList)) {
            AccountInformation accInfo             = new AccountInformation();
            accinfo.peer_last_name                 = acclist.peer__Last_Name__c;
            accinfo.peer_date_of_birth             = acclist.peer__Date_of_Birth__c;
            accinfo.peer_first_name                = acclist.peer__First_Name__c;
            accinfo.billingstreet                  = acclist.billingstreet;
            accinfo.city                           = acclist.city__c;
            accinfo.state                          = acclist.state__c;
            accinfo.zip_code                       = acclist.zip_code__c;
            accinfo.suffix                         = acclist.Suffix__c;
            accinfo.phone                          = acclist.phone;
            accinfo.housing_status                 = acclist.housing_status__c;
            accinfo.annual_individual_income       = acclist.annual_individual_income__c;
            accinfo.monthly_housing_payment        = acclist.monthly_housing_payment__c;
            accinfo.peer_email                     = acclist.peer__Email__c;
            accinfo.member_id                      = acclist.Member_ID__c;
            accinfo.id                             = acclist.Id;
            accInfo.Address_1                      = acclist.Address_1__c;
            accInfo.Address_2                      = acclist.Address_2__c;
            accInfo.cnotify_Email                  = acclist.cnotify__Email__c;
            accInfo.loan_SOCIAL_SECURITY_NUMBER    = acclist.loan__SOCIAL_SECURITY_NUMBER__c;
            /*   accInfo.Alternate_Phone                = acclist.Alternate_Phone__c;
               accInfo.Amount_Invested                = acclist.Amount_Invested__c;
               accInfo.Annual_Individual_Income       = acclist.Annual_Individual_Income__c;
               accInfo.Authorized_User                = acclist.Authorized_User__c;
               accInfo.Avg_Daily_Balance              = acclist.Avg_Daily_Balance__c;
               accInfo.Balance_Difference             = acclist.Balance_Difference__c;
               accInfo.Bankrupt                       = acclist.Bankrupt__c;
               accInfo.Borrower_s_Email               = acclist.Borrower_s_Email__c;
               accInfo.Borrower_s_First_Name          = acclist.Borrower_s_First_Name__c;
               accInfo.Borrower_s_Last_Name           = acclist.Borrower_s_Last_Name__c;
               accInfo.Bureau_Date_of_Birth           = acclist.Bureau_Date_of_Birth__c;
               accInfo.Bureau_Social_Security         = acclist.Bureau_Social_Security__c;
               accInfo.City                           = acclist.City__c;
               accInfo.Contact                        = acclist.Contact__c;
               accInfo.Credits                        = acclist.Credits__c;
               accInfo.Debits                         = acclist.Debits__c;
               accInfo.cnotify_Email                  = acclist.cnotify__Email__c;
               accInfo.peer__Email                     = acclist.peer__Email__c;
               accInfo.clcommon_Email                 = acclist.clcommon__Email__c;
               accInfo.Employer                       = acclist.Employer__c;
               accInfo.collect_External_ID            = acclist.collect_External_ID__c;
               accInfo.peer_External_Id               = acclist.peer_External_Id__c;
               accInfo.peer_FB_Access_Token           = acclist.peer_FB_Access_Token__c;
               accInfo.peer_FB_Image                  = acclist.peer_FB_Image__c;
               accInfo.peer_First_Name                = acclist.peer_First_Name__c;
               accInfo.peer_Funds_In_Queue            = acclist.peer_Funds_In_Queue__c;
               accInfo.peer_Funds_Not_In_Queue        = acclist.peer_Funds_Not_In_Queue__c;
               accInfo.peer_Gender                    = acclist.peer_Gender__c;
               accInfo.loan_Group                     = acclist.loan_Group__c;
               accInfo.Housing_Status                 = acclist.Housing_Status__c;
               accInfo.Income                         = acclist.Income__c;
               accInfo.Income_Variance                = acclist.Income_Variance__c;
               accInfo.clcommon_Indirect_Exposure     = acclist.clcommon_Indirect_Exposure__c;
               accInfo.loan_Interest_Donated_Till_Date= acclist.loan_Interest_Donated_Till_Date__c;
               accInfo.collect_Invalid_Address        = acclist.collect_Invalid_Address__c;
               accInfo.collect_Invalid_Email          = acclist.collect_Invalid_Email__c;
               accInfo.collect_Invalid_Number         = acclist.collect_Invalid_Number__c;
               accInfo.Investment_Rules               = acclist.Investment_Rules__c;
               accInfo.loan_Investor                  = acclist.loan_Investor__c;
               accInfo.peer_Investor_Status           = acclist.peer_Investor_Status__c;
               accInfo.loan_Investor_Tax_Configuration= acclist.loan_Investor_Tax_Configuration__c;
               accInfo.loan_Investor_Type             = acclist.loan_Investor_Type__c;
               accInfo.peer_IsActiveBorrower          = acclist.peer_IsActiveBorrower__c;
               accInfo.peer_IsActiveInvestor          = acclist.peer_IsActiveInvestor__c;
               accInfo.Last_Application_assigned_on   = acclist.Last_Application_assigned_on__c;
               accInfo.peer_Last_Name                 = acclist.peer_Last_Name__c;
               accInfo.Last_Update_Date               = acclist.Last_Update_Date__c;
               accInfo.clcommon_Legal_Entity_Type     = acclist.clcommon_Legal_Entity_Type__c;
               accInfo.clcommon_Master_Archive_Object = acclist.clcommon_Master_Archive_Object__c;
               accInfo.peer_Maximum_Loan_Term         = acclist.peer_Maximum_Loan_Term__c;
               accInfo.Member_ID                      = acclist.Member_ID__c;
               accInfo.Monthly_Housing_Payment        = acclist.Monthly_Housing_Payment__c;
               accInfo.peer_National_Id               = acclist.peer_National_Id__c;
               accInfo.NeoVerify_Data                 = acclist.NeoVerify_Data__c;
               accInfo.Net_Difference                 = acclist.Net_Difference__c;
               accInfo.Net_Income_Variance            = acclist.Net_Income_Variance__c;
               accInfo.peer_Nickname                  = acclist.peer_Nickname__c;
               accInfo.Number_Of_Applications_Invested= acclist.Number_Of_Applications_Invested__c;
               accInfo.loan_NumberofLocations         = acclist.loan_NumberofLocations__c;
               accInfo.collect_NumberofLocations      = acclist.collect_NumberofLocations__c;
               accInfo.peer_Password                  = acclist.peer_Password__c;
               accInfo.Payoff_UID                     = acclist.Payoff_UID__c;
               accInfo.Payoff_User_Slug               = acclist.Payoff_User_Slug__c;
               accInfo.Person_UID                     = acclist.Person_UID__c;
               accInfo.peer_Portfolio_Amount          = acclist.peer_Portfolio_Amount__c;
               accInfo.Position                       = acclist.Position__c;
               accInfo.Primary_Sourcce_of_income      = acclist.Primary_Sourcce_of_income__c;
               accInfo.loan_Reinvest_Interest         = acclist.loan_Reinvest_Interest__c;
               accInfo.loan_Reinvest_Principal        = acclist.loan_Reinvest_Principal__c;
               accInfo.Remaining_Amount               = acclist.Remaining_Amount__c;
               accInfo.Remaining_Applications         = acclist.Remaining_Applications__c;
               accInfo.loan_Service_Rate_On_Investment= acclist.loan_Service_Rate_On_Investment__c;
               accInfo.peer_Sign_Agreement            = acclist.peer_Sign_Agreement__c;
               accInfo.collect_SLA                    = acclist.collect_SLA__c;
               accInfo.cnotify_SLA                    = acclist.cnotify_SLA__c;
               accInfo.loan_SLA                       = acclist.loan_SLA__c;
               accInfo.collect_SLAExpirationDate      = acclist.collect_SLAExpirationDate__c;
               accInfo.loan_SLAExpirationDate         = acclist.loan_SLAExpirationDate__c;
               accInfo.collect_SLASerialNumber        = acclist.collect_SLASerialNumber__c;
               accInfo.loan_SLASerialNumber           = acclist.loan_SLASerialNumber__c;
               accInfo.loan_SOCIAL_SECURITY_NUMBER    = acclist.loan_SOCIAL_SECURITY_NUMBER__c;
               accInfo.ints_SSN                       = acclist.ints_SSN__c;
               accInfo.State                          = acclist.State__c;
               accInfo.peer_Status                    = acclist.peer_Status__c;
               accInfo.Suffix                         = acclist.Suffix__c;
               accInfo.clcommon_Summary               = acclist.clcommon_Summary__c;
               accInfo.clcommon_Summary_Record_Id     = acclist.clcommon_Summary_Record_Id__c;
               accInfo.TALX_Date_Modified             = acclist.TALX_Date_Modified__c;
               accInfo.TALX_Employer                  = acclist.TALX_Employer__c;
               accInfo.TALX_Hire_Date                 = acclist.TALX_Hire_Date__c;
               accInfo.TALX_Length_of_Employment      = acclist.TALX_Length_of_Employment__c;
               accInfo.TALX_Performed_by              = acclist.TALX_Performed_by__c;
               accInfo.TALX_Position                  = acclist.TALX_Position__c;
               accInfo.TALX_Salary                    = acclist.TALX_Salary__c;
               accInfo.TALX_Term_Date                 = acclist.TALX_Term_Date__c;
               accInfo.Tenure                         = acclist.Tenure__c;
               accInfo.loan_Deployed_Funds            = acclist.loan_Deployed_Funds__c;
               accInfo.Total_Calculated_Income        = acclist.Total_Calculated_Income__c;
               accInfo.Total_Calculated_Net_Income    = acclist.Total_Calculated_Net_Income__c;
               accInfo.loan_Total_Invested_Amount     = acclist.loan_Total_Invested_Amount__c;
               accInfo.loan_Total_Principal_Remaining = acclist.loan_Total_Principal_Remaining__c;
               accInfo.Total_Investment_Limit         = acclist.Total_Investment_Limit__c;
               accInfo.Total_No_of_Application_Limit  = acclist.Total_No_of_Application_Limit__c;
               accInfo.loan_Total_Pay_Off_Amount      = acclist.loan_Total_Pay_Off_Amount__c;
               accInfo.peer_Total_remaining_Investment= acclist.peer_Total_remaining_Investment__c;
               accInfo.loan_Total_Returns             = acclist.loan_Total_Returns__c;
               accInfo.US_Citizen                     = acclist.US_Citizen__c;
               accInfo.loan_Uncleared_Deposits        = acclist.loan_Uncleared_Deposits__c;
               accInfo.loan_Uncleared_Withdrawals     = acclist.loan_Uncleared_Withdrawals__c;
               accInfo.collect_UpsellOpportunity      = acclist.collect_UpsellOpportunity__c;
               accInfo.loan_UpsellOpportunity         = acclist.loan_UpsellOpportunity__c;
               accInfo.User_Friendly_ID               = acclist.User_Friendly_ID__c;
               accInfo.peer_Verified                  = acclist.peer_Verified__c;
               accInfo.peer_Verified_img              = acclist.peer_Verified_img__c;
               accInfo.Work_Email                     = acclist.Work_Email__c;
               accInfo.Work_email_verified_check_box  = acclist.Work_email_verified_check_box__c;
               accInfo.Work_Phone                     = acclist.Work_Phone__c;
               accInfo.Work_Phone_Extension           = acclist.Work_Phone_Extension__c;
               accInfo.ints_Yodlee_Password           = acclist.ints_Yodlee_Password__c;
               accInfo.Yodlee_Account_Id              = acclist.Yodlee_Account_Id__c;
               accInfo.ints_Yodlee_Username           = acclist.ints_Yodlee_Username__c;
               accInfo.ZIP_Code                       = acclist.ZIP__Code__c*/
            listaccInfo.add(accInfo);
        }

        Sync_account syncAcc = new Sync_account('sync_account', listaccInfo);
        String str = JSON.serialize(syncAcc, true);
        MW_WebhookHandler.CallWebHookIntegration(str, ''+accountList, '');
    }

    class Sync_account {
        String type;
        AccountInformation[] data;
        public Sync_account(String type, AccountInformation[] accInfo){
            this.type = type;
            this.data = accInfo;
        }
    }

    class sync_application {
        String type;
        ApplicationInformation[] data;
        public sync_application(String type, ApplicationInformation[] appInfo){
            this.type = type;
            this.data = appInfo;
        }
    }

    class AccountInformation
    {
        public string peer_last_name;
        public Date peer_date_of_birth;
        public string peer_first_name;
        public string billingstreet;
        public string city;
        public string state;
        public string zip_code;
        public string suffix;
        public string phone;
        public string housing_status;
        public decimal annual_individual_income;
        public decimal monthly_housing_payment;
        public string peer_email;
        public String member_id;
        public string id;
        public string Address_1;
        public string Address_2;
        public String cnotify_Email;
        public String loan_SOCIAL_SECURITY_NUMBER;
    }

    class ApplicationInformation
    {
        public string id;
        public String member_id;
        public decimal no_of_payments_required_upfront;
        public boolean x14day_s_before_expiration_date;
        public decimal accepted;
        public string account;
        public string action;
        public decimal additional_cash_required;
        public boolean alertflag;
        public boolean esign_consent_withdrawn;
        public decimal alerts_no_of_days_before_expiration;
        public decimal amortization_term;
        public decimal estimated_amount_needed;
        public string applicant_name;
        public string application_email;
        public string application_external_id;
        public string application_graph;
        public string application_sessionid;
        public Date application_start_date;
        public string applicationtemplate;
        public string application_work_email;
        public decimal apr;
        public boolean arrears;
        public string asset_liability_info;
        public string asset_class;
        public string assigned_to;
        public boolean auto_decisioning;
        public decimal balloon_payment;
        public id bank_account;
        public string bank_account_number;
        public string bank_account_type;
        public string bank_name;
        public boolean bank_transactions_fetched;
        public string bank_verification_flag;
        public string borrower_s_email;
        public string borrower_s_first_name;
        public string borrower_s_lastname;
        public string borrowers_work_email;
        public string call_code;
        public decimal cap_reduction;
        public decimal cash_collected_by_dealer;
        public string charge_offs;
        public boolean checkemailalertvalue;
        public string class_code;
        public string cl_contract;
        public string cl_product;
        public string cl_product_name;
        public string cl_purpose;
        public decimal collateral_value;
        public string cl_company;
        public string company;
        public string conga_solution_template_inv_harsh;
        public string contact;
        public decimal estimated_credit_card_balances;
        public decimal credit_limit;
        public string credit_policy_verification_flag;
        public string credit_rating;
        public string creditscore_notice;
        public string credit_summary_verification;
        public decimal customer_cash_available;
        public string customer_cash_used_for;
        public string days_convention;
        public Date dealer_payment_date;
        public string reason; // decline_reason
        public string description;
        public decimal differenc_between_today_and_expiry_date;
        public Date disbursement_date;
        public decimal discount_rate;
        public string discount_rate_based_on;
        public decimal documentation_charges;
        public string docusign_envelope_id;
        public string docusign_envelope_status;
        public boolean docusignflag;
        public date docusign_sign_date;
        public decimal down_payment;
        public date draw_period_end_date;
        public decimal draw_term;
        public decimal due_day;
        public boolean employee_loan;
        public boolean employer;
        public string employment_status;
        public decimal estimated_selling_price;
        public date expected_close_date;
        public date expected_first_payment_date;
        public date expected_second_pay_day_date;
        public date expected_start_date;
        public date expiration_date;
        public date expiration_date_for_email_trigger;
        public date expiry_date;
        public decimal fees_amount;
        public string file_cleared_image;
        public string openimage;
        public string file_rejected_image;
        public string file_submitted_image;
        public string file_total_image;
        public decimal financed_amount;
        public decimal first_time_offer_select;
        public boolean funding_in_tranches;
        public Date giact_date;
        public string giactperformed_by;
        public string giact_status;
        public decimal gross_annual_income;
        public string healthcare_procedure;
        public decimal identity_counter;
        public string identity_verification_flag;
        public Date idma_date;
        public string idma_performed_by;
        public string idma_status;
        public Date idmv_date;
        public string idmv_performed_by;
        public string idmv_status;
        public string id_number;
        public string id_state;
        public string id_type;
        public string income_verification_flag;
        public decimal initial_advance;
        public decimal initial_term_payment_amt;
        public string interest_calculation_method;
        public string interest_compounding_frequency;
        public decimal interest_only_period;
        public decimal interest_rate;
        public decimal invested_amount;
        public string investor_name;
        public string investoraddress;
        public boolean investor_selected;
        public decimal iovation_status;
        public boolean is_get_yield_enabled;
        public boolean is_over_21;
        public boolean is_pb_running;
        public boolean isredecision;
        public string iv_performed_by;
        public Date iv_performed_date;
        public string kba_verification;
        public string kbav_performed_by;
        public Date kbav_performed_date;
        public Decimal landing_sequence;
        public Datetime last_investor_assigned_on;
        public decimal last_payment_amount;
        public string lead_guid;
        public string lead_id;
        public string lead_source;
        public string lending_product;
        public string loading;
        public decimal loan_amount;
        public decimal estimated_loan_balances;
        public string loan_number;
        public decimal loan_term_sub_1;
        public decimal ltv_pledged_collateral;
        public decimal margin;
        public date maturity_date;
        public decimal maximum_loan_amount_dti;
        public string memberaddress;
        public decimal minimum_cash_required;
        public decimal monthly_debt_payments;
        public string monthly_income_expense_info;
        public string neo_verification;
        public string neo_verify;
        public string neov_performed_by;
        public date neov_performed_date;
        public decimal net_difference;
        public decimal net_difference_net_income;
        public decimal net_present_value;
        public decimal net_total_calculated_income;
        public decimal net_total_stated_income;
        public decimal net_variance;
        public string neustart;
        public boolean notifycheck;
        public decimal number_of_pieces_of_equipment;
        public date ofac_date;
        public string ofac_performed_by;
        public string ofac_status;
        public decimal open;
        public decimal estimated_origination_fee;
        public decimal origination_fee;
        public decimal other_financed_fees;
        public string parent_application;
        public Date participation_date;
        public decimal payable_to_dealer;
        public decimal total_dealer_payable;
        public decimal payment_amount;
        public string payment_amount_step_up_type;
        public Date payment_due_date;
        public string payment_frequency;
        public decimal payment_frequency_multiplier;
        public string payment_mode;
        public string payoff_uid;
        public string portfolio;
        public Date precise_account_opening_date;
        public string precise_account_opening_performedby;
        public string precise_account_opening_status;
        public Date precise_identity_screening_date;
        public string precise_identity_screening_performedby;
        public string precise_identity_screening_status;
        public string prepaid_interest_option;
        public boolean prepayment_penalty; //203
        public string prepayment_penalty_description;
        public string pricing_method;
        public string collateral_type;
        public string primary_collateral_code;
        public string primary_property_address;
        public string primary_source_of_repayment;
        public decimal probability;
        public string product_sub_type;
        public string product_type;
        public string quick_quote;
        public decimal rate_ceiling;
        public boolean rate_discount;
        public decimal rate_floor; //216
        public string regulation_o;
        public decimal rejected;
        public decimal required_customer_cash;
        public decimal residual_amount;
        public decimal retained_amount;
        public string routing_number;
        public string sales_division;
        public string secondary_source_of_repayment;
        public boolean send_offer_expiry_notification;
        public decimal sift_status; //226
        public decimal spread;
        public string overall_status;
        public string status;
        public decimal sublimit_total;
        public decimal sublimit_variance;
        public decimal submitted;
        public decimal summary_of_revolving_balances;
        public decimal tax_amount; //234
        public decimal term;
        public string terms_selected;
        public string testemail;
        public string testemail1;
        public string til_solution_manager_document;
        public Date tlo_date;
        public string tlo_performed_by;
        public string tlo_status;
        public decimal today_s_date; //243
        public decimal total;
        public decimal total_calculated_income;
        public decimal total_cash_due_from_customer;
        public decimal total_dealer_price;
        public decimal total_estimated_interest;
        public decimal total_facilities;
        public decimal total_facility_amount;
        public decimal total_facility_variance;
        public decimal total_fee_amount;
        public decimal total_of_payments;
        public decimal total_pledged_collateral_amount;
        public decimal total_required;
        public decimal total_score;
        public decimal total_stated_income;
        public decimal total_upfront_payments;
        public decimal total_uploaded;
        public boolean valid_pricing_flag;
        public decimal variance;
        public decimal warranty_amount;
        public decimal what_you_get_total_amount_offered;
        public string work_email;
        public decimal yield;

        public String owner_name;
        /*
           CLS-738
         */
        public String selected_loan_amount;
        public String selected_term;
        public String selected_monthly_payment;
        public String selected_interest_rate;
        public String selected_apr;
        public String selected_origination_fee;
        public String selected_origination_fee_rate;
        public String lending_partner;
        public String selected_offer_key;
        /*
           CLS-656
         */
        public boolean is_declined;
        public adverse_actions[] adverse_actions;

        /*
           CLS-690
         */
        public boolean is_expired;

        /*
           CLS-657
         */
        public boolean is_manual_review;

        /*CLS-913 */
        public boolean is_withdrawn;

        //CLS-1138 DCP Investor Flag
        public boolean dcp_investor_available;
        
        //CRM-843 kba_manual_passed
        public boolean kba_manual_passed;

        ApplicationInformation(){
            this.adverse_actions = new List<adverse_actions>();
        }

    }

    class adverse_actions {
        public String name;
        public String reason;
        public String description;
    }

    public Static String applicationQuery(Set<String> appList){

        string firstelement = (new list<string>(appList)[0]);

        String soqlQuery = 'SELECT id,'+
                           'genesis__No_Of_Payments_Required_Upfront__c,'+
                           'X14day_s_Before_Expiration_Date__c,'+
                           'Member_ID__c,'+
                           'LEAD_ID_ExtKey__c,'+
                           'Esign_consent_withdrawn__c,'+
                           'Accepted__c,'+
                           'genesis__Account__r.name,'+
                           'genesis__Action__c,'+
                           'genesis__Additional_Cash_Required__c,'+
                           'ALertFlag__c,'+
                           'Alerts_No_Of_Days_Before_Expiration__c,'+
                           'genesis__Amortization_Term__c,'+
                           'Estimated_Amount_needed__c,'+
                           'Applicant_Name__c,'+
                           'Application_Email__c,'+
                           'Application_external_id__c,'+
                           'Application_Graph__c,'+
                           'Application_SessionId__c,'+
                           'Application_Start_Date__c,'+
                           'ApplicationTemplate__c,'+
                           'Application_Work_Email__c,'+
                           'genesis__APR__c,'+
                           'genesis__Arrears__c,'+
                           'genesis__Asset_Liability_Info__c,'+
                           'genesis__Asset_Class__c,'+
                           'genesis__Assigned_To__c,'+
                           'genesis__Auto_Decisioning__c,'+
                           'genesis__Balloon_Payment__c,'+
                           'Bank_Account__c,'+
                           'genesis__Bank_Account_Number__c,'+
                           'genesis__Bank_Account_Type__c,'+
                           'genesis__Bank_Name__c,'+
                           'genesis__Bank_Transactions_Fetched__c,'+
                           'Bank_Verification_Flag__c,'+
                           'Borrower_s_Email__c,'+
                           'Borrower_s_First_Name__c,'+
                           'Borrower_s_LastName__c,'+
                           'Borrowers_Work_Email__c,'+
                           'genesis__Call_Code__c,'+
                           'genesis__Cap_Reduction__c,'+
                           'genesis__Cash_Collected_By_Dealer__c,'+
                           'genesis__Charge_offs__c,'+
                           'CheckEmailAlertValue__c,'+
                           'genesis__Class_Code__c,'+
                           'CL_Contract__c,'+
                           'genesis__CL_Product__c,'+
                           'genesis__CL_Product_Name__c,'+
                           'genesis__CL_Purpose__c,'+
                           'genesis__Collateral_Value__c,'+
                           'genesis__CL_Company__c,'+
                           'genesis__Company__c,'+
                           'Conga_Solution_Template_Inv_Harsh__c,'+
                           'genesis__Contact__c,'+
                           'Estimated_credit_card_balances__c,'+
                           'genesis__Credit_Limit__c,'+
                           'Credit_Policy_Verification_Flag__c,'+
                           'genesis__Credit_Rating__c,'+
                           'CreditScore_Notice__c,'+
                           'Credit_Summary_Verification__c,'+
                           'genesis__Customer_Cash_Available__c,'+
                           'genesis__Customer_Cash_Used_For__c,'+
                           'genesis__Days_Convention__c,'+
                           'genesis__Dealer_Payment_Date__c,'+
                           'Decline_Reason__c,'+
                           'genesis__Description__c,'+
                           'Differenc_Between_Today_and_Expiry_Date__c,'+
                           'genesis__Disbursement_Date__c,'+
                           'genesis__Discount_Rate__c,'+
                           'genesis__Discount_Rate_Based_On__c,'+
                           'genesis__Documentation_Charges__c,'+
                           'DocuSign_Envelope_ID__c,'+
                           'DocuSign_Envelope_Status__c,'+
                           'DocuSignFlag__c,'+
                           'DocuSign_Sign_Date__c,'+
                           'genesis__Down_Payment__c,'+
                           'genesis__Draw_Period_End_Date__c,'+
                           'genesis__Draw_Term__c,'+
                           'genesis__Due_Day__c,'+
                           'genesis__Employee_Loan__c,'+
                           'Employer__c,'+
                           'Employment_Status__c,'+
                           'genesis__Estimated_Selling_Price__c,'+
                           'genesis__Expected_Close_Date__c,'+
                           'genesis__Expected_First_Payment_Date__c,'+
                           'genesis__Expected_Second_Pay_Day_Date__c,'+
                           'genesis__Expected_Start_Date__c,'+
                           'Expiration_Date__c,'+
                           'Expiration_Date_for_Email_trigger__c,'+
                           'Expiry_Date__c,'+
                           'genesis__Fees_Amount__c,'+
                           'File_cleared_Image__c,'+
                           'OpenImage__c,'+
                           'File_rejected_image__c,'+
                           'File_submitted_image__c,'+
                           'File_total_image__c,'+
                           'genesis__Financed_Amount__c,'+
                           'First_time_offer_select__c,'+
                           'genesis__Funding_in_Tranches__c,'+
                           'GIACT_Date__c,'+
                           'GIACTPerformed_By__c,'+
                           'GIACT_Status__c,'+
                           'genesis__Gross_Annual_Income__c,'+
                           'genesis__Healthcare_Procedure__c,'+
                           'Identity_Counter__c,'+
                           //'Identity_Verification_Flag__c,'+
                           //'IDMA_Date__c,'+
                           //'IDMA_Performed_By__c,'+
                           //'IDMA_Status__c,'+
                           //'IDMV_Date__c,'+
                           //'IDMV_Performed_By__c,'+
                           //'IDMV_Status__c,'+
                           'genesis__ID_Number__c,'+
                           'genesis__ID_State__c,'+
                           'genesis__ID_Type__c,'+
                           'Income_Verification_Flag__c,'+
                           'genesis__Initial_Advance__c,'+
                           'Initial_Term_Payment_Amt__c,'+
                           'genesis__Interest_Calculation_Method__c,'+
                           'genesis__Interest_Compounding_Frequency__c,'+
                           'genesis__Interest_Only_Period__c,'+
                           'genesis__Interest_Rate__c,'+
                           'Invested_Amount__c,'+
                           'Investor__c,'+
                           'Investor__r.Name,'+
                           'Investor__r.Investor_Code__c,'+
                           'Investor__r.Lending_Partner__c,'+
                           'InvestorAddress__c,'+
                           'Investor_Selected__c,'+
                           'Iovation_Status__c,'+
                           'genesis__Is_Get_Yield_Enabled__c,'+
                           'genesis__Is_over_21__c,'+
                           'is_PB_running__c,'+
                           'isRedecision__c,'+
                           'IV_Performed_By__c,'+
                           'IV_Performed_Date__c,'+
                           'KBA_Verification__c,'+
                           'KBAV_Performed_BY__c,'+
                           'KBAV_Performed_Date__c,'+
                           'genesis__Landing_Sequence__c,'+
                           'Last_Investor_Assigned_On__c,'+
                           'Last_Payment_Amount__c,'+
                           'Lead_ID__c,'+
                           'Lead_Source__c,'+
                           'genesis__Lending_Product__c,'+
                           'Loading__c,'+
                           'genesis__Loan_Amount__c,'+
                           'Estimated_loan_balances__c,'+
                           'genesis__Loan_Number__c,'+
                           'Loan_Term_sub_1__c,'+
                           'genesis__LTV_Pledged_Collateral__c,'+
                           'genesis__Margin__c,'+
                           'Loan_Maturity_Date__c,'+
                           'genesis__Maximum_Loan_Amount_DTI__c,'+
                           'Memberaddress__c,'+
                           'genesis__Minimum_Cash_Required__c,'+
                           'genesis__Monthly_Debt_Payments__c,'+
                           'genesis__Monthly_Income_Expense_Info__c,'+
                           'Neo_Verification__c,'+
                           'Neo_Verify__c,'+
                           'NeoV_Performed_By__c,'+
                           'NeoV_Performed_Date__c,'+
                           'Net_Difference__c,'+
                           'Net_Difference_Net_Income__c,'+
                           'genesis__Net_Present_Value__c,'+
                           'Net_Total_Calculated_Income__c,'+
                           'Net_Total_Stated_Income__c,'+
                           'Net_Variance__c,'+
                           'Neustart__c,'+
                           'NotifyCheck__c,'+
                           'genesis__Number_of_Pieces_of_Equipment__c,'+
                           //'OFAC_Date__c,'+
                           //'OFAC_Performed_By__c,'+
                           //'OFAC_Status__c,'+
                           'Open__c,'+
                           'Estimated_origination_fee__c,'+
                           'Origination_fee__c,'+
                           'genesis__Other_Financed_fees__c,'+
                           'genesis__Parent_Application__c,'+
                           'genesis__Participation_Date__c,'+
                           'genesis__Payable_To_Dealer__c,'+
                           'genesis__Total_Dealer_Payable__c,'+
                           'genesis__Payment_Amount__c,'+
                           'genesis__Payment_Amount_Step_Up_Type__c,'+
                           'genesis__Payment_Due_Date__c,'+
                           'genesis__Payment_Frequency__c,'+
                           'genesis__Payment_Frequency_Multiplier__c,'+
                           'Payment_Mode__c,'+
                           'Payoff_UID__c,'+
                           'genesis__Portfolio__c,'+
                           //'Precise_Account_Opening_Date__c,'+
                           //'Precise_Account_Opening_PerformedBy__c,'+
                           //'Precise_Account_Opening_Status__c,'+
                           //'Precise_Identity_Screening_Date__c,'+
                           //'Precise_Identity_Screening_PerformedBy__c,'+
                           //'Precise_Identity_Screening_Status__c,'+
                           'genesis__Prepaid_Interest_Option__c,'+
                           'genesis__Prepayment_Penalty__c,'+
                           'genesis__Prepayment_Penalty_Description__c,'+
                           'genesis__Pricing_Method__c,'+
                           'genesis__Collateral_Type__c,'+
                           'genesis__Primary_Collateral_Code__c,'+
                           'genesis__Primary_Property_Address__c,'+
                           'genesis__Primary_Source_of_Repayment__c,'+
                           'genesis__Probability__c,'+
                           'genesis__Product_Sub_Type__c,'+
                           'genesis__Product_Type__c,'+
                           'genesis__Quick_Quote__c,'+
                           'genesis__Rate_Ceiling__c,'+
                           'genesis__Rate_Discount__c,'+
                           'genesis__Rate_Floor__c,'+
                           'genesis__Regulation_O__c,'+
                           'Rejected__c,'+
                           'genesis__Required_Customer_Cash__c,'+
                           'genesis__Residual_Amount__c,'+
                           'genesis__Retained_Amount__c,'+
                           'genesis__Routing_Number__c,'+
                           'genesis__Sales_Division__c,'+
                           'genesis__Secondary_Source_of_Repayment__c,'+
                           'Send_Offer_expiry_notification__c,'+
                           'Sift_Status__c,'+
                           'genesis__Spread__c,'+
                           'genesis__Overall_Status__c,'+
                           'genesis__Status__c,'+
                           'genesis__SubLimit_Total__c,'+
                           'genesis__Sublimit_Variance__c,'+
                           'Submitted__c,'+
                           'Summary_of_Revolving_Balances__c,'+
                           'genesis__Tax_Amount__c,'+
                           'genesis__Term__c,'+
                           'genesis__Terms_Selected__c,'+
                           'Today_s_Date__c,'+
                           'Total__c,'+
                           'Total_Calculated_Income__c,'+
                           'genesis__Total_Cash_Due_from_Customer__c,'+
                           'genesis__Total_Dealer_Price__c,'+
                           'genesis__Total_Estimated_Interest__c,'+
                           'genesis__Total_Facilities__c,'+
                           'genesis__Total_Facility_Amount__c,'+
                           'genesis__Total_Facility_Variance__c,'+
                           'genesis__Total_Fee_Amount__c,'+
                           'Total_of_Payments__c,'+
                           'genesis__Total_Pledged_Collateral_Amount__c,'+
                           'Total_required__c,'+
                           'genesis__Total_Score__c,'+
                           'Total_Stated_Income__c,'+
                           'genesis__Total_Upfront_Payments__c,'+
                           'Total_Uploaded__c,'+
                           'genesis__Valid_Pricing_Flag__c,'+
                           'Variance__c,'+
                           'genesis__Warranty_Amount__c,'+
                           'What_you_get_Total_Amount_Offered__c,'+
                           'Work_Email__c,'+
                           'genesis__Yield__c,'+
                           'Manual_Adverse_Action_Decline__r.Decline_Name__c,'+
                           'Manual_Adverse_Action_Decline__r.Description__c,'+
                           'Manual_Adverse_Action_Decline__r.Reason__c,'+
                           'owner.Name,'+
                           'DCP_Investor_Eligibility__c,'+
                           'Yodlee_Transaction__c, Manual_KBA__c FROM genesis__Applications__c where Id =\'' + firstelement + '\' limit 1';

        System.debug('Query ' + soqlQuery);
        return soqlQuery;
    }

    public Static List<Account> accountQuery(List<String> accList){

        string firstelement = accList[0];

        List<Account> sobjList = Database.query('SELECT id,'+
                                                'peer__Last_Name__c,'+
                                                'peer__Date_of_Birth__c,'+
                                                'peer__First_Name__c,'+
                                                'billingstreet,'+
                                                'city__c,'+
                                                'state__c,'+
                                                'zip_code__c,'+
                                                'Suffix__c,'+
                                                'phone,'+
                                                'Housing_Status__c,'+
                                                'annual_individual_income__c,'+
                                                'monthly_housing_payment__c,'+
                                                'peer__Email__c,'+
                                                'Address_1__c,'+
                                                'Address_2__c,'+
                                                'cnotify__Email__c,'+
                                                'loan__SOCIAL_SECURITY_NUMBER__c,'+
                                                'Member_ID__c FROM Account Where Id =\'' + firstelement + '\' limit 1');
/*
                        'Account_External_ID__c,'+
                        'peer_last_lame__C,'+
                        'loan__Active__c,'+
                        'Address_1__c,'+
                        'Address_2__c,'+
                        'Alternate_Phone__c,'+
                        'peer__Amount_In_Funding__c,'+
                        'Amount_Invested__c,'+
                        'cnotify__Email__c,'+
                        'Annual_Individual_Income__c,'+
                        'clcommon__Archived__c,'+
                        'Authorized_User__c,'+
                        'peer__Auto_Invest__c,'+
                        'loan__Undeployed_Funds__c,'+
                        'Avg_Daily_Balance__c,'+
                        'Balance_Difference__c,'+
                        'Bankrupt__c,'+
                        'loan__Borrower__c,'+
                        'Borrower_s_Email__c,'+
                        'Borrower_s_First_Name__c,'+
                        'Borrower_s_Last_Name__c,'+
                        'peer__Borrower_Exposure_Limit_Amount__c,'+
                        'peer__Borrower_Exposure_Percentage__c,'+
                        'peer__Borrower_Information__c,'+
                        'loan__Branch__c,'+
                        'loan__Broker__c,'+
                        'Bureau_Date_of_Birth__c,'+
                        'Bureau_Social_Security__c,'+
                        'genesis__Business_Information__c,'+
                        'City__c,'+
                        'collect__Active__c,'+
                        'loan__Collect_Service_Fees_on__c,'+
                        'Contact__c,'+
                        'peer__Credit_Rating_Matrix__c,'+
                        'Credits__c,'+
                        'collect__CustomerPriority__c,'+
                        'loan__CustomerPriority__c,'+
                        'peer__Date_of_Birth__c,'+
                        'Debits__c,'+
                        'clcommon__Direct_Exposure__c,'+
                        'clcommon__Direct_Proposed_Exposure__c,'+
                        'collect__Disable_Collection_Activities__c,'+
                        'ints__Email__c,'+
                        'peer__Email__c,'+
                        'clcommon__Email__c,'+
                        'Employer__c,'+
                        'collect__External_ID__c,'+
                        'peer__External_Id__c,'+
                        'peer__FB_Access_Token__c,'+
                        'peer__FB_Image__c,'+
                        'peer__First_Name__c,'+
                        'peer__Funds_In_Queue__c,'+
                        'peer__Funds_Not_In_Queue__c,'+
                        'peer__Gender__c,'+
                        'loan__Group__c,'+
                        'Housing_Status__c,'+
                        'Income__c,'+
                        'Income_Include_Bonuses_or_Commissions__c,'+
                        'Income_Variance__c,'+
                        'clcommon__Indirect_Exposure__c,'+
                        'clcommon__Indirect_Proposed_Exposure__c,'+
                        'loan__Interest_Donated_Till_Date__c,'+
                        'loan__Interest_Got_Back_Till_Date__c,'+
                        'loan__Interest_Reinvested_Till_Date__c,'+
                        'collect__Invalid_Address__c,'+
                        'collect__Invalid_Email__c,'+
                        'collect__Invalid_Number__c,'+
                        'Investment_Rules__c,'+
                        'loan__Investor__c,'+
                        'peer__Investor_Status__c,'+
                        'loan__Investor_Tax_Configuration__c,'+
                        'loan__Investor_Type__c,'+
                        'peer__IsActiveBorrower__c,'+
                        'peer__IsActiveInvestor__c,'+
                        'Last_Application_assigned_on__c,'+
                        'clcommon__Last_Modified_Date_Exposure__c,'+
                        'peer__Last_Name__c,'+
                        'Last_Update_Date__c,'+
                        'clcommon__Legal_Entity_Type__c,'+
                        'clcommon__Master_Archive_Object__c,'+
                        'peer__Maximum_Loan_Term__c,'+
                        'Member_ID__c,'+
                        'Monthly_Housing_Payment__c,'+
                        'peer__National_Id__c,'+
                        'NeoVerify_Data__c,'+
                        'Net_Difference__c,'+
                        'Net_Income_Variance__c,'+
                        'peer__Nickname__c,'+
                        'Number_Of_Applications_Invested__c,'+
                        'loan__NumberofLocations__c,'+
                        'collect__NumberofLocations__c,'+
                        'peer__Password__c,'+
                        'Payoff_UID__c,'+
                        'Payoff_User_Slug__c,'+
                        'Person_UID__c,'+
                        'peer__Portfolio_Amount__c,'+
                        'peer__Portfolio_Generated_Per_Day__c,'+
                        'peer__Portfolio_Generated_Per_Hour__c,'+
                        'peer__Portfolio_Timestamp__c,'+
                        'Position__c,'+
                        'Primary_Sourcce_of_income__c,'+
                        'loan__Reinvest_Interest__c,'+
                        'loan__Reinvest_Principal__c,'+
                        'Remaining_Amount__c,'+
                        'Remaining_Applications__c,'+
                        'loan__Service_Rate_On_Investment__c,'+
                        'peer__Sign_Agreement__c,'+
                        'collect__SLA__c,'+
                        'cnotify__SLA__c,'+
                        'loan__SLA__c,'+
                        'collect__SLAExpirationDate__c,'+
                        'loan__SLAExpirationDate__c,'+
                        'collect__SLASerialNumber__c,'+
                        'loan__SLASerialNumber__c,'+
                        'loan__SOCIAL_SECURITY_NUMBER__c,'+
                        'ints__SSN__c,'+
                        'State__c,'+
                        'peer__Status__c,'+
                        'Suffix__c,'+
                        'clcommon__Summary__c,'+
                        'clcommon__Summary_Record_Id__c,'+
                        'TALX_Date_Modified__c,'+
                        'TALX_Employer__c,'+
                        'TALX_Hire_Date__c,'+
                        'TALX_Length_of_Employment__c,'+
                        'TALX_Performed_by__c,'+
                        'TALX_Position__c,'+
                        'TALX_Salary__c,'+
                        'TALX_Term_Date__c,'+
                        'Tenure__c,'+
                        'loan__Deployed_Funds__c,'+
                        'Total_Calculated_Income__c,'+
                        'Total_Calculated_Net_Income__c,'+
                        'loan__Total_Invested_Amount__c,'+
                        'loan__Total_Principal_Remaining__c,'+
                        'Total_Investment_Limit__c,'+
                        'Total_No_of_Application_Limit__c,'+
                        'loan__Total_Pay_Off_Amount__c,'+
                        'peer__Total_remaining_Investment__c,'+
                        'loan__Total_Returns__c,'+
                        'US_Citizen__c,'+
                        'loan__Uncleared_Deposits__c,'+
                        'loan__Uncleared_Withdrawals__c,'+
                        'peer__Funds_Available_For_Investment__c,'+
                        'collect__UpsellOpportunity__c,'+
                        'loan__UpsellOpportunity__c,'+
                        'User_Friendly_ID__c,'+
                        'peer__Verified__c,'+
                        'peer__Verified_img__c,'+
                        'Work_Email__c,'+
                        'Work_email_verified_check_box__c,'+
                        'Work_Phone__c,'+
                        'Work_Phone_Extension__c,'+
                        'ints__Yodlee_Password__c,'+
                        'Yodlee_Account_Id__c,'+
                        'ints__Yodlee_Username__c,'+
 */

        return sobjList;
    }

    /*
       public static boolean SyncApplicationTrigger(Map<id,Account> oldAccMap,Map<id,Account> newAccMap){

        List<genesis__applications__c> applicationList;
                       applicationList = [SELECT id, Name,
                                              genesis__account__c ,
                                              genesis__account__r.Member_ID__c,
                                              Lead_ID__c,
                                              Bureau_SSN__c
                                              FROM genesis__applications__c
                                              WHERE genesis__account__c = :newAccMap.keyset()];

          for(genesis__applications__c app : applicationList)
          {
              Account accOld = oldAccMap.get(app.genesis__account__c);
              Account accNew = newAccMap.get(app.genesis__account__c);
              FERequest fe = new FERequest();
              fe.data = new Map<String,String>();

              Boolean redecisionRequired = false;
              if(accOld.loan__SOCIAL_SECURITY_NUMBER__c != null && accOld.loan__SOCIAL_SECURITY_NUMBER__c != accNew.loan__SOCIAL_SECURITY_NUMBER__c){
                  fe.data.put('loan__SOCIAL_SECURITY_NUMBER__c',String.valueOf(accNew.loan__SOCIAL_SECURITY_NUMBER__c));
                  redecisionRequired = true;
              }
              if(accOld.peer__Date_of_Birth__c != null && accOld.peer__Date_of_Birth__c != accNew.peer__Date_of_Birth__c){
                  fe.data.put('peer__Date_of_Birth__c',String.valueOf(accNew.peer__Date_of_Birth__c));
                  redecisionRequired = true;
              }
              if(accOld.peer__First_Name__c != null && accOld.peer__First_Name__c != accNew.peer__First_Name__c){
                  fe.data.put('peer__First_Name__c',String.valueOf(accNew.peer__First_Name__c));
                  redecisionRequired = true;
              }
              if(accOld.peer__Last_Name__c != null && accOld.peer__Last_Name__c != accNew.peer__Last_Name__c){
                  fe.data.put('peer__Last_Name__c',String.valueOf(accNew.peer__Last_Name__c));
                  redecisionRequired = true;
              }
              if(accOld.Address_1__c != null && accOld.Address_1__c != accNew.Address_1__c){
                  fe.data.put('Address_1__c',String.valueOf(accNew.Address_1__c));
                  redecisionRequired = true;
              }
              if(accOld.Address_2__c != null && accOld.Address_2__c != accNew.Address_2__c){
                  fe.data.put('Address_2__c',String.valueOf(accNew.Address_2__c));
                  redecisionRequired = true;
              }
              if(accOld.Income__c != null && accOld.Income__c != accNew.Income__c){
                  fe.data.put('Income__c',String.valueOf(accNew.Income__c));
                  redecisionRequired = true;
              }
              if(accOld.Monthly_Housing_Payment__c != null && accOld.Monthly_Housing_Payment__c != accNew.Monthly_Housing_Payment__c){
                  fe.data.put('Monthly_Housing_Payment__c',String.valueOf(accNew.Monthly_Housing_Payment__c));
                  redecisionRequired = true;
              }
              if(app.Bureau_SSN__c != accNew.loan__SOCIAL_SECURITY_NUMBER__c){
                  fe.data.put('Is_Stated_SSN_Equal_to_Bureau_SSN','FALSE');
              }
              else{
                  fe.data.put('Is_Stated_SSN_Equal_to_Bureau_SSN','True');
              }

              if(redecisionRequired == true){
              fe.data.put('Lead_ID__c',String.valueOf(app.Lead_ID__c));
                  String JSONString = JSON.serialize(fe);
                  Redecision_Request__c rr = new Redecision_Request__c();
                  rr.Application__c = app.id;
                  rr.Body__c = JSONString;
                  rr.Triggered_From__c = 'Account';
                  rrToBeInseted.add(rr);
              }
          }
          if(rrToBeInseted.size() > 0 && rrToBeInseted != null){
              insert rrToBeInseted;
          }
       }
     */

    public static Boolean isAppDocCatFirstTime = true;

    // private static boolean run = true;
    //
    // public static boolean runOnce(){
    //
    //      if(run) {
    //              run=false;
    //              return true;
    //      }else{
    //              return run;
    //      }
    // }

//Filter out FE user changes
    public static Boolean userFilterFE(){
        //Skip this chechking when running the test.
        if(Test.isRunningTest()) {
            return true;
        }
        else{
            List<String> userFilter = MW_Settings__c.getInstance().API_User_Filter__c.split(',');
            return !userFilter.contains(UserInfo.getUserName());
        }
    }

    public static void postAccountDetailsOnWebHook(Map<id,Account> oldAccMap,Map<id,Account> newAccMap){
        if(userFilterFE()) {
            set<String> fieldSet = new Set<String>();
            //dynamically get the fields from the field set and then use the same for comparison in the trigger.
            for(Schema.FieldSetMember fields :Schema.SObjectType.Account.fieldSets.getMap().get('Webhook_Fields').getFields()) {
                fieldSet.add(fields.getFieldPath());
            }

            List<String> acclist = new List<String>();

            for(Account a: newAccMap.values()) {
                if(!a.loan__Investor__c) { // exclude the investor records.
                    for(string s: fieldSet) {
                        if(a.get(s) != trigger.oldMap.get(a.Id).get(s)) {
                            accList.add(a.Id);
                            break;
                        }
                    }
                }
            }

            if(acclist.size()>0) {
                Sync_account(acclist);
            }
        }
    }


    public static void postAppDetailsOnWebHook(Map<id,genesis__Applications__c> oldAppMap,Map<id,genesis__Applications__c> newAppMap){
        if(userFilterFE()) {
            set<String> fieldSet = new Set<String>();
            //dynamically get the fields from the field set and then use the same for comparison in the trigger.
            for(Schema.FieldSetMember fields :Schema.SObjectType.genesis__Applications__c.fieldSets.getMap().get('Webhook_Fields').getFields()) {
                fieldSet.add(fields.getFieldPath());
            }

            Set<String> appSet = new Set<String>();

            for(genesis__Applications__c app: newAppMap.values()) {
                for(string s: fieldSet) {
                    if(app.get(s) != trigger.oldMap.get(app.Id).get(s) && !System.isBatch()) {
                        appSet.add(app.Id);
                        break;
                   }
                }
            }

            if(appSet.size()>0) {
                Boolean ebpEnabled = false;
                Boolean mxChangedTheOffer = false;
                string firstelement = new list<string>(appSet)[0];
                genesis__Applications__c oldApp = oldAppMap.get(firstelement);
                genesis__Applications__c newApp = newAppMap.get(firstelement);

                if(
                    (oldApp.genesis__Loan_Amount__c != newApp.genesis__Loan_Amount__c ||
                    oldApp.genesis__APR__c != newApp.genesis__APR__c ||
                    oldApp.genesis__Term__c != newApp.genesis__Term__c ||
                    oldApp.Origination_fee__c != newApp.Origination_fee__c ||
                    oldApp.genesis__Monthly_Debt_Payments__c != newApp.genesis__Monthly_Debt_Payments__c ||
                    oldApp.genesis__Interest_Rate__c != newApp.genesis__Interest_Rate__c) &&
                    newApp.genesis__Status__c == 'offer_shown'
                ) {
                    mxChangedTheOffer = true;
                }

                List<Pricing_Offer__c> availablePricingOffers = [SELECT EBP_Offer_Code__c from Pricing_Offer__c WHERE Application__c = :firstelement];
                

                for(Pricing_Offer__c offer: availablePricingOffers) {
                    if(offer.EBP_Offer_Code__c != null && offer.EBP_Offer_Code__c.length() != 0) {
                        ebpEnabled = true;
                    }
                }

                if(ebpEnabled && mxChangedTheOffer) {
                    Sync_application(appSet, 'offer_reselect');
                }
                else {
                    Sync_application(appSet, 'sync_application');
                }
            }
        }
    }


    public static void postReallocationChangeOnWebHook(List<genesis__Applications__c> newList, Map<Id, genesis__Applications__c> oldMap){
        set<String> fieldSet = new Set<String>();

        for(genesis__Applications__c app: newList) {
            if(oldMap.get(app.Id).Investor__c !=null && oldMap.get(app.Id).investor__c!=app.Investor__c) {

            }
        }
    }


    public static void createOrgniationRecords(List<genesis__Applications__c> newList){
        List<String> applist = new List<String>();

        for(genesis__Applications__c app:newList) {
            if(app.No_Of_Origination_Docs__c==0) {
                applist.add(app.id);
            }
        }

        List<Origination_Documents__c> listOrgDocs = new List<Origination_Documents__c>();
        list<String> docList = getPickListValuesIntoList();

        for(String s:applist)
        {
            for(Integer i=0; i<docList.size(); i++) {
                Origination_Documents__c od = new Origination_Documents__c();
                od.Application__c = s;
                od.Type__c = docList[i];
                if(od.Type__c=='cbr')
                    od.Code_FF__c = 'bureau_report';
                else
                    od.Code_FF__c = od.Type__c;
                listOrgDocs.add(od);
            }
        }

        if(listOrgDocs.size()>0)
            insert listOrgDocs;
    }

    public static List<String> getPickListValuesIntoList(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Origination_Documents__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }


/*
   CLS-738
 */
    public Static Map<Id,Pricing_Offer__c> selectedOfferQuery(Set<String> appList){

        Map<Id,Pricing_Offer__c> selctedOfferMap = new Map<Id,Pricing_Offer__c>();

        for(Pricing_Offer__c priceOffer : [Select Id, Above_prime_max__c, Active__c, Amount__c, APR__c, Interest_Rate__c, Is_Offer_Selected__c, Key__c,
                                           Loan_Premium_Amount__c, Loan_Premium_Price__c, Monthly_Payment__c, Origination_fee__c, Origination_fee_rate__c,
                                           Pricing_Tier__c, Segment__c,
                                           Term__c,Type__c,Application__c from Pricing_Offer__c
                                           where Application__c IN:appList and Is_Offer_Selected__c=true limit 199]) {
            selctedOfferMap.put(priceOffer.Application__c, priceOffer);
        }
        return selctedOfferMap;
    }
    public static void postBankAccountDetailsOnWebHook(Map<Id,loan__Bank_Account__c> oldMap,Map<Id,loan__Bank_Account__c> newMap){
        if(userFilterFE()) {
            MW_BankAccountUpdateSync.sendUpdatesToMatcha(newMap,oldMap);
        }
    }
}