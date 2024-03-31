global with sharing class MW_SynchronizeHandler {
    public static boolean avoidrecursiveFuture = false;
    public static boolean preventIsAfterRecursionOnApplication = false;
    public static final Integer NUMBER_OF_MASKED_FIELD_EMAIL = 4;
    public static final Integer NUMBER_OF_MASKED_NOT_FIELD_EMAIL = 3;
    public static final Integer START_INDEX = 1;

    static List<String> maskedFields = Label.Masked_fields.split(',');

    global static void Sync_application_OnEnvId(Set<String> apList, String requestType) {
        sync_application syncApp = new sync_application(requestType, getApplicaitonInfo(apList));

        String str = JSON.serialize(syncApp, true);
        MW_WebhookHandler.CallWebHookIntegration(str, '' + apList, '');
    }

    public static list<ApplicationInformation> getApplicaitonInfo(Set<String> apList) {
        list<ApplicationInformation> listAppInfo = new List<ApplicationInformation>();

        Map<Id, Pricing_Offer__c> selectedOfferMap = selectedOfferQuery(apList);

        for (genesis__Applications__c applist : Database.query(applicationQuery(apList))) {
            applicationinformation appinfo = new ApplicationInformation();
            appinfo.member_id = applist.Member_ID__c;
            appinfo.id = applist.id;
            appinfo.account = applist.genesis__Account__r.name;
            appinfo.application_start_date = applist.Application_Start_Date__c;
            appinfo.application_work_email = applist.Application_Work_Email__c;
            appinfo.apr = applist.genesis__APR__c;
            appinfo.bank_account = applist.Bank_Account__c;
            appinfo.bank_account_number = applist.genesis__Bank_Account_Number__c;
            appinfo.bank_account_type = applist.genesis__Bank_Account_Type__c;
            appinfo.bank_name = applist.genesis__Bank_Name__c;
            appinfo.bank_verification_flag = applist.Bank_Verification_Flag__c;
            appinfo.borrower_s_email = applist.Borrower_s_Email__c;
            appinfo.borrower_s_first_name = applist.Borrower_s_First_Name__c;
            appinfo.borrower_s_lastname = applist.Borrower_s_LastName__c;
            appinfo.borrowers_work_email = applist.Borrowers_Work_Email__c;
            appinfo.cl_product_name = applist.genesis__CL_Product_Name__c;
            appinfo.credit_policy_verification_flag = applist.Credit_Policy_Verification_Flag__c;
            appinfo.description = applist.genesis__Description__c;
            appinfo.disbursement_date = applist.genesis__Disbursement_Date__c;
            appinfo.discount_rate = applist.genesis__Discount_Rate__c;
            appinfo.docusign_envelope_id = applist.DocuSign_Envelope_ID__c;
            appinfo.docusign_envelope_status = applist.DocuSign_Envelope_Status__c;
            appinfo.docusignflag = applist.DocuSignFlag__c;
            appinfo.docusign_sign_date = applist.DocuSign_Sign_Date__c;
            appinfo.employee_loan = applist.genesis__Employee_Loan__c;
            appinfo.employer = applist.Employer__c;
            appinfo.employment_status = applist.Employment_Status__c;
            appinfo.expected_start_date = applist.genesis__Expected_Start_Date__c;
            appinfo.financed_amount = applist.genesis__Financed_Amount__c;
            appinfo.income_verification_flag = applist.Income_Verification_Flag__c;
            appinfo.interest_rate = applist.genesis__Interest_Rate__c;
            appinfo.invested_amount = applist.Invested_Amount__c;
            appinfo.investor_name = applist.Investor__r.Investor_Code__c;
            appinfo.lending_partner = applist.Investor__r.Lending_Partner__c;
            appinfo.investoraddress = applist.InvestorAddress__c;
            appinfo.isredecision = applist.isRedecision__c;
            appinfo.kba_verification = applist.KBA_Verification__c;
            appinfo.last_investor_assigned_on = applist.Last_Investor_Assigned_On__c;
            appinfo.last_payment_amount = applist.Last_Payment_Amount__c;
            appinfo.lead_guid = applist.Lead_ID__c;
            appinfo.lead_id = applist.LEAD_ID_ExtKey__c;
            appinfo.lead_source = applist.Lead_Source__c;
            appinfo.lending_product = applist.genesis__Lending_Product__c;
            appinfo.loan_amount = applist.genesis__Loan_Amount__c;
            appinfo.maturity_date = applist.Loan_Maturity_Date__c;
            appinfo.maximum_loan_amount_dti = applist.genesis__Maximum_Loan_Amount_DTI__c;
            appinfo.notifycheck = applist.NotifyCheck__c;
            appinfo.origination_fee = applist.Origination_fee__c;
            appinfo.other_financed_fees = applist.genesis__Other_Financed_fees__c;
            appinfo.parent_application = applist.genesis__Parent_Application__c;
            appinfo.payment_amount = applist.genesis__Payment_Amount__c;
            appinfo.payment_frequency = applist.genesis__Payment_Frequency__c;
            appinfo.payment_mode = applist.Payment_Mode__c;
            appinfo.payoff_uid = applist.Payoff_UID__c;
            appinfo.portfolio = applist.genesis__Portfolio__c;
            appinfo.pricing_method = applist.genesis__Pricing_Method__c;
            appinfo.rejected = applist.Rejected__c;
            appinfo.routing_number = applist.genesis__Routing_Number__c;
            appinfo.sift_status = applist.Sift_Status__c;
            appinfo.overall_status = applist.genesis__Overall_Status__c;
            appinfo.status = applist.genesis__Status__c;
            appinfo.submitted = applist.Submitted__c;
            appinfo.term = applist.genesis__Term__c;
            appinfo.terms_selected = applist.genesis__Terms_Selected__c;
            appinfo.total_calculated_income = applist.Total_Calculated_Income__c;
            appinfo.total_of_payments = applist.Total_of_Payments__c;
            appinfo.total_stated_income = applist.Total_Stated_Income__c;
            appinfo.total_upfront_payments = applist.genesis__Total_Upfront_Payments__c;
            appinfo.variance = applist.Variance__c;
            appinfo.work_email = applist.Work_Email__c;
            appinfo.expiry_date = applist.Expiry_Date__c;
            appinfo.owner_name = applist.owner.Name;
            appinfo.esign_consent_withdrawn = applist.Esign_consent_withdrawn__c;
            appinfo.dcp_investor_available = applist.DCP_Investor_Eligibility__c;
            appinfo.kba_manual_passed = applist.Manual_KBA__c;
            appinfo.expiration_date = applist.Expiration_Date__c;
            appinfo.annual_individual_income_app = applist.Annual_Individual_Income_App__c;
            appinfo.monthly_housing_payment_app = applist.Monthly_Housing_Payment_App__c;

            /*
                  CLS-738
             */
            if (selectedOfferMap.size() > 0 && selectedOfferMap.get(applist.id) != null) {
                appinfo.selected_loan_amount = String.valueOf(selectedOfferMap.get(applist.id).Amount__c);
                appinfo.selected_term = String.valueOf(selectedOfferMap.get(applist.id).Term__c);
                appinfo.selected_monthly_payment = String.valueOf(selectedOfferMap.get(applist.id).Monthly_Payment__c);
                appinfo.selected_interest_rate = String.valueOf(selectedOfferMap.get(applist.id).Interest_Rate__c);
                appinfo.selected_apr = String.valueOf(selectedOfferMap.get(applist.id).APR__c);
                appinfo.selected_origination_fee = String.valueOf(selectedOfferMap.get(applist.id).Origination_fee__c);
                appinfo.selected_origination_fee_rate = String.valueOf(
                    selectedOfferMap.get(applist.id).Origination_fee_rate__c
                );
                appinfo.selected_offer_key = String.valueOf(selectedOfferMap.get(applist.id).Key__c);
            }

            /*
                  CLS-656
             */

            if (applist.genesis__Status__c == 'Decline_Manual_Review' && applist.owner.Name == 'Declined') {
                appinfo.is_declined = true;

                adverse_actions aa = new adverse_actions();
                if (applist.Manual_Adverse_Action_Decline__r.Decline_Name__c != null)
                    aa.name = applist.Manual_Adverse_Action_Decline__r.Decline_Name__c;
                if (applist.Manual_Adverse_Action_Decline__r.Description__c != null)
                    aa.reason = applist.Manual_Adverse_Action_Decline__r.Description__c;
                if (applist.Manual_Adverse_Action_Decline__r.Reason__c != null)
                    aa.description = applist.Manual_Adverse_Action_Decline__r.Reason__c;

                appinfo.adverse_actions.add(aa);
            }

            /*
               CLS-690  , LOP-342 - Expired-Withdrawn
             */

            if (applist.genesis__Status__c == 'Expired' || applist.genesis__Status__c == 'Expired-Withdrawn') {
                appinfo.is_expired = true;
            }

            if (applist.genesis__Status__c == 'Declined' && applist.owner.Name == 'Declined') {
                Map<Id, Credit_Policy__c> cpMap = MW_WebhookHelper.selectedCreditPolicyDetails(
                    new Set<String>{ applist.id }
                );
                if (
                    cpMap.size() > 0 &&
                    cpMap.get(applist.id) != null &&
                    cpMap.get(applist.id).Loan_amount_counteroffer__c != null
                ) {
                    appinfo.is_expired = true;
                }
            }

            /*
               CLS-657
             */

            if (applist.owner.Name == 'Review Queue') {
                appinfo.is_manual_review = true;
            } else {
                appinfo.is_manual_review = false;
            }

            /*CLS-913 - Withdrawn */

            if (applist.genesis__Status__c == 'Withdrawn') {
                appinfo.is_withdrawn = true;
            }

            listAppInfo.add(appInfo);
        }
        System.debug('listAppInfo: ' + JSON.serialize(listAppInfo));
        return listAppInfo;
    }

    @Future(callout=true)
    global static void Sync_application(Set<String> apList, String requestType) {
        sync_application syncApp = new sync_application(requestType, getApplicaitonInfo(apList));

        String str = JSON.serialize(syncApp, true);
        MW_WebhookHandler.CallWebHookIntegration(str, '' + apList, '');
    }

    @Future(callout=true)
    global static void Sync_account(List<String> accountList) {
        list<AccountInformation> listaccInfo = new List<AccountInformation>();

        for (Account acclist : accountQuery(accountList)) {
            AccountInformation accInfo = new AccountInformation();
            accinfo.peer_last_name = acclist.peer__Last_Name__c;
            accinfo.peer_date_of_birth = acclist.peer__Date_of_Birth__c;
            accinfo.peer_first_name = acclist.peer__First_Name__c;
            accinfo.billingstreet = acclist.billingstreet;
            accinfo.city = acclist.city__c;
            accinfo.state = acclist.state__c;
            accinfo.zip_code = acclist.zip_code__c;
            accinfo.suffix = acclist.Suffix__c;
            accinfo.phone = acclist.phone;
            accinfo.housing_status = acclist.housing_status__c;
            accinfo.annual_individual_income = acclist.annual_individual_income__c;
            accinfo.monthly_housing_payment = acclist.monthly_housing_payment__c;
            accinfo.peer_email = acclist.peer__Email__c;
            accinfo.member_id = acclist.Member_ID__c;
            accinfo.id = acclist.Id;
            accInfo.Address_1 = acclist.Address_1__c;
            accInfo.Address_2 = acclist.Address_2__c;
            accInfo.cnotify_Email = acclist.cnotify__Email__c;
            accInfo.loan_SOCIAL_SECURITY_NUMBER = acclist.loan__SOCIAL_SECURITY_NUMBER__c;
            System.debug('accInfo: ' + accInfo);
            listaccInfo.add(accInfo);
        }
        System.debug('listaccInfo: ' + listaccInfo);
        Sync_account syncAcc = new Sync_account('sync_account', listaccInfo);
        String str = JSON.serialize(syncAcc, true);
        MW_WebhookHandler.CallWebHookIntegration(str, '' + accountList, '');
    }

    class Sync_account {
        String type;
        AccountInformation[] data;
        public Sync_account(String type, AccountInformation[] accInfo) {
            this.type = type;
            this.data = accInfo;
        }
    }

    public class sync_application {
        String type;
        ApplicationInformation[] data;
        public sync_application(String type, ApplicationInformation[] appInfo) {
            this.type = type;
            this.data = appInfo;
        }
    }

    class AccountInformation {
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

    class ApplicationInformation {
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

        public decimal annual_individual_income_app;
        public decimal monthly_housing_payment_app;

        ApplicationInformation() {
            this.adverse_actions = new List<adverse_actions>();
        }
    }

    class adverse_actions {
        public String name;
        public String reason;
        public String description;
    }

    public static String applicationQuery(Set<String> appList) {
        string firstelement = (new List<string>(appList)[0]);

        String soqlQuery =
            'SELECT id,' +
            'genesis__No_Of_Payments_Required_Upfront__c,' +
            'X14day_s_Before_Expiration_Date__c,' +
            'Member_ID__c,' +
            'LEAD_ID_ExtKey__c,' +
            'Esign_consent_withdrawn__c,' +
            'Accepted__c,' +
            'genesis__Account__r.name,' +
            'genesis__Action__c,' +
            'genesis__Additional_Cash_Required__c,' +
            'ALertFlag__c,' +
            'Alerts_No_Of_Days_Before_Expiration__c,' +
            'genesis__Amortization_Term__c,' +
            'Estimated_Amount_needed__c,' +
            'Applicant_Name__c,' +
            'Application_Email__c,' +
            'Application_external_id__c,' +
            'Application_Graph__c,' +
            'Application_SessionId__c,' +
            'Application_Start_Date__c,' +
            'ApplicationTemplate__c,' +
            'Application_Work_Email__c,' +
            'genesis__APR__c,' +
            'genesis__Arrears__c,' +
            'genesis__Asset_Liability_Info__c,' +
            'genesis__Asset_Class__c,' +
            'genesis__Assigned_To__c,' +
            'genesis__Auto_Decisioning__c,' +
            'genesis__Balloon_Payment__c,' +
            'Bank_Account__c,' +
            'genesis__Bank_Account_Number__c,' +
            'genesis__Bank_Account_Type__c,' +
            'genesis__Bank_Name__c,' +
            'genesis__Bank_Transactions_Fetched__c,' +
            'Bank_Verification_Flag__c,' +
            'Borrower_s_Email__c,' +
            'Borrower_s_First_Name__c,' +
            'Borrower_s_LastName__c,' +
            'Borrowers_Work_Email__c,' +
            'genesis__Call_Code__c,' +
            'genesis__Cap_Reduction__c,' +
            'genesis__Cash_Collected_By_Dealer__c,' +
            'genesis__Charge_offs__c,' +
            'CheckEmailAlertValue__c,' +
            'genesis__Class_Code__c,' +
            'CL_Contract__c,' +
            'genesis__CL_Product__c,' +
            'genesis__CL_Product_Name__c,' +
            'genesis__CL_Purpose__c,' +
            'genesis__Collateral_Value__c,' +
            'genesis__CL_Company__c,' +
            'genesis__Company__c,' +
            'Conga_Solution_Template_Inv_Harsh__c,' +
            'genesis__Contact__c,' +
            'Estimated_credit_card_balances__c,' +
            'genesis__Credit_Limit__c,' +
            'Credit_Policy_Verification_Flag__c,' +
            'genesis__Credit_Rating__c,' +
            'CreditScore_Notice__c,' +
            'Credit_Summary_Verification__c,' +
            'genesis__Customer_Cash_Available__c,' +
            'genesis__Customer_Cash_Used_For__c,' +
            'genesis__Days_Convention__c,' +
            'genesis__Dealer_Payment_Date__c,' +
            'Decline_Reason__c,' +
            'genesis__Description__c,' +
            'Differenc_Between_Today_and_Expiry_Date__c,' +
            'genesis__Disbursement_Date__c,' +
            'genesis__Discount_Rate__c,' +
            'genesis__Discount_Rate_Based_On__c,' +
            'genesis__Documentation_Charges__c,' +
            'DocuSign_Envelope_ID__c,' +
            'DocuSign_Envelope_Status__c,' +
            'DocuSignFlag__c,' +
            'DocuSign_Sign_Date__c,' +
            'genesis__Down_Payment__c,' +
            'genesis__Draw_Period_End_Date__c,' +
            'genesis__Draw_Term__c,' +
            'genesis__Due_Day__c,' +
            'genesis__Employee_Loan__c,' +
            'Employer__c,' +
            'Employment_Status__c,' +
            'genesis__Estimated_Selling_Price__c,' +
            'genesis__Expected_Close_Date__c,' +
            'genesis__Expected_First_Payment_Date__c,' +
            'genesis__Expected_Second_Pay_Day_Date__c,' +
            'genesis__Expected_Start_Date__c,' +
            'Expiration_Date__c,' +
            'Expiration_Date_for_Email_trigger__c,' +
            'Expiry_Date__c,' +
            'genesis__Fees_Amount__c,' +
            'File_cleared_Image__c,' +
            'OpenImage__c,' +
            'File_rejected_image__c,' +
            'File_submitted_image__c,' +
            'File_total_image__c,' +
            'genesis__Financed_Amount__c,' +
            'First_time_offer_select__c,' +
            'genesis__Funding_in_Tranches__c,' +
            'GIACT_Date__c,' +
            'GIACTPerformed_By__c,' +
            'GIACT_Status__c,' +
            'genesis__Gross_Annual_Income__c,' +
            'genesis__Healthcare_Procedure__c,' +
            'Identity_Counter__c,' +
            'genesis__ID_Number__c,' +
            'genesis__ID_State__c,' +
            'genesis__ID_Type__c,' +
            'Income_Verification_Flag__c,' +
            'genesis__Initial_Advance__c,' +
            'Initial_Term_Payment_Amt__c,' +
            'genesis__Interest_Calculation_Method__c,' +
            'genesis__Interest_Compounding_Frequency__c,' +
            'genesis__Interest_Only_Period__c,' +
            'genesis__Interest_Rate__c,' +
            'Invested_Amount__c,' +
            'Investor__c,' +
            'Investor__r.Name,' +
            'Investor__r.Investor_Code__c,' +
            'Investor__r.Lending_Partner__c,' +
            'InvestorAddress__c,' +
            'Investor_Selected__c,' +
            'Iovation_Status__c,' +
            'genesis__Is_Get_Yield_Enabled__c,' +
            'genesis__Is_over_21__c,' +
            'is_PB_running__c,' +
            'isRedecision__c,' +
            'IV_Performed_By__c,' +
            'IV_Performed_Date__c,' +
            'KBA_Verification__c,' +
            'KBAV_Performed_BY__c,' +
            'KBAV_Performed_Date__c,' +
            'genesis__Landing_Sequence__c,' +
            'Last_Investor_Assigned_On__c,' +
            'Last_Payment_Amount__c,' +
            'Lead_ID__c,' +
            'Lead_Source__c,' +
            'genesis__Lending_Product__c,' +
            'Loading__c,' +
            'genesis__Loan_Amount__c,' +
            'Estimated_loan_balances__c,' +
            'genesis__Loan_Number__c,' +
            'Loan_Term_sub_1__c,' +
            'genesis__LTV_Pledged_Collateral__c,' +
            'genesis__Margin__c,' +
            'Loan_Maturity_Date__c,' +
            'genesis__Maximum_Loan_Amount_DTI__c,' +
            'Memberaddress__c,' +
            'genesis__Minimum_Cash_Required__c,' +
            'genesis__Monthly_Debt_Payments__c,' +
            'genesis__Monthly_Income_Expense_Info__c,' +
            'Neo_Verification__c,' +
            'Neo_Verify__c,' +
            'NeoV_Performed_By__c,' +
            'NeoV_Performed_Date__c,' +
            'Net_Difference__c,' +
            'Net_Difference_Net_Income__c,' +
            'genesis__Net_Present_Value__c,' +
            'Net_Total_Calculated_Income__c,' +
            'Net_Total_Stated_Income__c,' +
            'Net_Variance__c,' +
            'Neustart__c,' +
            'NotifyCheck__c,' +
            'genesis__Number_of_Pieces_of_Equipment__c,' +
            'Open__c,' +
            'Estimated_origination_fee__c,' +
            'Origination_fee__c,' +
            'genesis__Other_Financed_fees__c,' +
            'genesis__Parent_Application__c,' +
            'genesis__Participation_Date__c,' +
            'genesis__Payable_To_Dealer__c,' +
            'genesis__Total_Dealer_Payable__c,' +
            'genesis__Payment_Amount__c,' +
            'genesis__Payment_Amount_Step_Up_Type__c,' +
            'genesis__Payment_Due_Date__c,' +
            'genesis__Payment_Frequency__c,' +
            'genesis__Payment_Frequency_Multiplier__c,' +
            'Payment_Mode__c,' +
            'Payoff_UID__c,' +
            'genesis__Portfolio__c,' +
            'genesis__Prepaid_Interest_Option__c,' +
            'genesis__Prepayment_Penalty__c,' +
            'genesis__Prepayment_Penalty_Description__c,' +
            'genesis__Pricing_Method__c,' +
            'genesis__Collateral_Type__c,' +
            'genesis__Primary_Collateral_Code__c,' +
            'genesis__Primary_Property_Address__c,' +
            'genesis__Primary_Source_of_Repayment__c,' +
            'genesis__Probability__c,' +
            'genesis__Product_Sub_Type__c,' +
            'genesis__Product_Type__c,' +
            'genesis__Quick_Quote__c,' +
            'genesis__Rate_Ceiling__c,' +
            'genesis__Rate_Discount__c,' +
            'genesis__Rate_Floor__c,' +
            'genesis__Regulation_O__c,' +
            'Rejected__c,' +
            'genesis__Required_Customer_Cash__c,' +
            'genesis__Residual_Amount__c,' +
            'genesis__Retained_Amount__c,' +
            'genesis__Routing_Number__c,' +
            'genesis__Sales_Division__c,' +
            'genesis__Secondary_Source_of_Repayment__c,' +
            'Send_Offer_expiry_notification__c,' +
            'Sift_Status__c,' +
            'genesis__Spread__c,' +
            'genesis__Overall_Status__c,' +
            'genesis__Status__c,' +
            'genesis__SubLimit_Total__c,' +
            'genesis__Sublimit_Variance__c,' +
            'Submitted__c,' +
            'Summary_of_Revolving_Balances__c,' +
            'genesis__Tax_Amount__c,' +
            'genesis__Term__c,' +
            'genesis__Terms_Selected__c,' +
            'Today_s_Date__c,' +
            'Total__c,' +
            'Total_Calculated_Income__c,' +
            'genesis__Total_Cash_Due_from_Customer__c,' +
            'genesis__Total_Dealer_Price__c,' +
            'genesis__Total_Estimated_Interest__c,' +
            'genesis__Total_Facilities__c,' +
            'genesis__Total_Facility_Amount__c,' +
            'genesis__Total_Facility_Variance__c,' +
            'genesis__Total_Fee_Amount__c,' +
            'Total_of_Payments__c,' +
            'genesis__Total_Pledged_Collateral_Amount__c,' +
            'Total_required__c,' +
            'genesis__Total_Score__c,' +
            'Total_Stated_Income__c,' +
            'genesis__Total_Upfront_Payments__c,' +
            'Total_Uploaded__c,' +
            'genesis__Valid_Pricing_Flag__c,' +
            'Variance__c,' +
            'genesis__Warranty_Amount__c,' +
            'What_you_get_Total_Amount_Offered__c,' +
            'Work_Email__c,' +
            'genesis__Yield__c,' +
            'Manual_Adverse_Action_Decline__r.Decline_Name__c,' +
            'Manual_Adverse_Action_Decline__r.Description__c,' +
            'Manual_Adverse_Action_Decline__r.Reason__c,' +
            'owner.Name,' +
            'DCP_Investor_Eligibility__c,' +
            'Yodlee_Transaction__c,' +
            'Manual_KBA__c,' +
            'Annual_Individual_Income_App__c,' +
            'Monthly_Housing_Payment_App__c ' +
            'FROM genesis__Applications__c where Id =\'' +
            firstelement +
            '\' limit 1';

        System.debug('Query ' + soqlQuery);
        return soqlQuery;
    }

    public static List<Account> accountQuery(List<String> accList) {
        string firstelement = accList[0];

        List<Account> sobjList = Database.query(
            'SELECT id,' +
                'peer__Last_Name__c,' +
                'peer__Date_of_Birth__c,' +
                'peer__First_Name__c,' +
                'billingstreet,' +
                'city__c,' +
                'state__c,' +
                'zip_code__c,' +
                'Suffix__c,' +
                'phone,' +
                'Housing_Status__c,' +
                'annual_individual_income__c,' +
                'monthly_housing_payment__c,' +
                'peer__Email__c,' +
                'Address_1__c,' +
                'Address_2__c,' +
                'cnotify__Email__c,' +
                'loan__SOCIAL_SECURITY_NUMBER__c,' +
                'Member_ID__c FROM Account Where Id =\'' +
                firstelement +
                '\' limit 1'
        );

        return sobjList;
    }

    public static Boolean isAppDocCatFirstTime = true;

    //Filter out FE user changes
    public static Boolean userFilterFE() {
        //Skip this chechking when running the test.
        if (Test.isRunningTest()) {
            return true;
        } else {
            List<String> userFilter = MW_Settings__c.getInstance().API_User_Filter__c.split(',');
            return !userFilter.contains(UserInfo.getUserName());
        }
    }

    public static void postAccountDetailsOnWebHook(Map<id, Account> oldAccMap, Map<id, Account> newAccMap) {
        if (userFilterFE()) {
            set<String> fieldSet = new Set<String>();
            //dynamically get the fields from the field set and then use the same for comparison in the trigger.
            for (
                Schema.FieldSetMember fields : Schema.SObjectType.Account.fieldSets.getMap()
                    .get('Webhook_Fields')
                    .getFields()
            ) {
                fieldSet.add(fields.getFieldPath());
            }

            List<String> acclist = new List<String>();

            for (Account a : newAccMap.values()) {
                if (!a.loan__Investor__c) {
                    // exclude the investor records.
                    for (string s : fieldSet) {
                        if (a.get(s) != Trigger.oldMap.get(a.Id).get(s)) {
                            accList.add(a.Id);
                            break;
                        }
                    }
                }
            }

            if (acclist.size() > 0) {
                Sync_account(acclist);
            }
        }
    }

    public static void postAppDetailsOnWebHook(
        Map<id, genesis__Applications__c> oldAppMap,
        Map<id, genesis__Applications__c> newAppMap
    ) {
        if (userFilterFE()) {
            set<String> fieldSet = new Set<String>();
            //dynamically get the fields from the field set and then use the same for comparison in the trigger.
            for (
                Schema.FieldSetMember fields : Schema.SObjectType.genesis__Applications__c.fieldSets.getMap()
                    .get('Webhook_Fields')
                    .getFields()
            ) {
                fieldSet.add(fields.getFieldPath());
            }

            Set<String> appSet = new Set<String>();

            for (genesis__Applications__c app : newAppMap.values()) {
                for (string s : fieldSet) {
                    if (app.get(s) != Trigger.oldMap.get(app.Id).get(s) && !System.isBatch()) {
                        appSet.add(app.Id);
                        break;
                    }
                }
            }

            if (appSet.size() > 0) {
                Boolean ebpEnabled = false;
                Boolean mxChangedTheOffer = false;
                string firstelement = new List<string>(appSet)[0];
                genesis__Applications__c oldApp = oldAppMap.get(firstelement);
                genesis__Applications__c newApp = newAppMap.get(firstelement);

                if (
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

                List<Pricing_Offer__c> availablePricingOffers = [
                    SELECT EBP_Offer_Code__c
                    FROM Pricing_Offer__c
                    WHERE Application__c = :firstelement
                ];

                for (Pricing_Offer__c offer : availablePricingOffers) {
                    if (offer.EBP_Offer_Code__c != null && offer.EBP_Offer_Code__c.length() != 0) {
                        ebpEnabled = true;
                    }
                }

                if (ebpEnabled && mxChangedTheOffer) {
                    Sync_application(appSet, 'offer_reselect');
                } else {
                    Sync_application(appSet, 'sync_application');
                }
            }
        }
    }

    public static void postReallocationChangeOnWebHook(
        List<genesis__Applications__c> newList,
        Map<Id, genesis__Applications__c> oldMap
    ) {
        set<String> fieldSet = new Set<String>();

        for (genesis__Applications__c app : newList) {
            if (oldMap.get(app.Id).Investor__c != null && oldMap.get(app.Id).investor__c != app.Investor__c) {
            }
        }
    }

    public static void createOrgniationRecords(List<genesis__Applications__c> newList) {
        List<String> applist = new List<String>();

        for (genesis__Applications__c app : newList) {
            if (app.No_Of_Origination_Docs__c == 0) {
                applist.add(app.id);
            }
        }

        List<Origination_Documents__c> listOrgDocs = new List<Origination_Documents__c>();
        list<String> docList = getPickListValuesIntoList();

        for (String s : applist) {
            for (Integer i = 0; i < docList.size(); i++) {
                Origination_Documents__c od = new Origination_Documents__c();
                od.Application__c = s;
                od.Type__c = docList[i];
                if (od.Type__c == 'cbr')
                    od.Code_FF__c = 'bureau_report';
                else
                    od.Code_FF__c = od.Type__c;
                listOrgDocs.add(od);
            }
        }

        if (listOrgDocs.size() > 0)
            insert listOrgDocs;
    }

    public static List<String> getPickListValuesIntoList() {
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Origination_Documents__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }

    /*
   CLS-738
 */
    public static Map<Id, Pricing_Offer__c> selectedOfferQuery(Set<String> appList) {
        Map<Id, Pricing_Offer__c> selctedOfferMap = new Map<Id, Pricing_Offer__c>();

        for (Pricing_Offer__c priceOffer : [
            SELECT
                Id,
                Above_prime_max__c,
                Active__c,
                Amount__c,
                APR__c,
                Interest_Rate__c,
                Is_Offer_Selected__c,
                Key__c,
                Loan_Premium_Amount__c,
                Loan_Premium_Price__c,
                Monthly_Payment__c,
                Origination_fee__c,
                Origination_fee_rate__c,
                Pricing_Tier__c,
                Segment__c,
                Term__c,
                Type__c,
                Application__c
            FROM Pricing_Offer__c
            WHERE Application__c IN :appList AND Is_Offer_Selected__c = TRUE
            LIMIT 199
        ]) {
            selctedOfferMap.put(priceOffer.Application__c, priceOffer);
        }
        return selctedOfferMap;
    }
    public static void postBankAccountDetailsOnWebHook(
        Map<Id, loan__Bank_Account__c> oldMap,
        Map<Id, loan__Bank_Account__c> newMap
    ) {
        if (userFilterFE()) {
            MW_BankAccountUpdateSync.sendUpdatesToMatcha(newMap, oldMap);
        }
    }

    public static String maskingFields(String serializedData) {
        Map<String, Object> deserializedData = (Map<String, Object>) JSON.deserializeUntyped(serializedData);

        try {
            List<Object> dataList = (List<Object>) deserializedData.get('data');

            List<Map<String, Object>> dataMap = new List<Map<String, Object>>();

            for (Object obj : dataList) {
                System.debug(obj);
                dataMap.add((Map<String, Object>) obj);
            }

            for (Map<String, Object> data : dataMap) {
                for (String fieldToMask : maskedFields) {
                    // Check if the field exists in the ApplicationInformation object
                    Object fieldValue = data.get(fieldToMask);
                    if (fieldValue != null && !(fieldValue instanceof Boolean)) {
                        if (fieldToMask.contains('email')) {
                            data.put(
                                fieldToMask,
                                MW_SynchronizeHandler.maskingEmail(
                                    String.valueOf(fieldValue),
                                    String.valueOf(fieldValue)
                                        .subString(1, String.valueOf(fieldValue).indexOf('@'))
                                        .length()
                                )
                            );
                        } else {
                            data.put(
                                fieldToMask,
                                MW_SynchronizeHandler.maskingField(
                                    String.valueOf(fieldValue),
                                    START_INDEX,
                                    String.valueOf(fieldValue).length() - 2
                                )
                            );
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        return JSON.serialize(deserializedData, true);
    }

    public static String maskingEmail(String field, Integer numberOfChar) {
        return maskingField(field, field.indexOf('@') - numberOfChar, numberOfChar);
    }

    public static String maskingField(String field, Integer start, Integer numberOfChar) {
        try {
            if (field != null && field.length() >= start + numberOfChar) {
                String valueToMask = field.substring(start, start + numberOfChar);
                String mask = '*'.repeat(numberOfChar);
                String masked = field.replaceFirst(valueToMask, mask);

                return masked;
            } else {
                return field;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return field;
    }
}