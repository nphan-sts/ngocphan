global class HardCreditPullResponse {
    
    global String requestBody;
    global String responseBody;
    global String integrationErrorStatus;
    global String integrationErrorStatusCode;
    global String errorMessage;
    global Decimal fico_score;
    global List<Hard_Credit_Pull__c> cpData = new List<Hard_Credit_Pull__c>();
    
    global class Account {
        global String type_Z {get;set;} // in json: type
        global String amount {get;set;} 
        
    }
    
    global class All_attributes {
        global String bureau_request_uid {get;set;} 
        
        global Bureau_report bureau_report {get;set;} 
        global Boolean no_hit {get;set;} 
        global Boolean frozen {get;set;} 
        //  global Find_my_balance find_my_balance {get;set;} 
        global String bureau_report_uid {get;set;} 
        
        
    }
    
    
    global All_attributes all_attributes {get;set;} 
    global metadata metadata {get;set;} 
    
    
    
    
    
    
    global class Most_recent_payment {
        global String amount {get;set;} 
        global String date1 {get;set;} 
        
        
    }
    
    global class Name {
        global String source {get;set;} 
        global String qualifier {get;set;} 
        global String unparsed {get;set;} 
        
        
    }
    
    
    global class Subscriber {
        global String industry_code {get;set;} 
        global String member_code {get;set;} 
        global Name name {get;set;} 
        
        
    }
    
    global class Remarks {
        global String code;
        global String type1;
    }
    
    global class Payment_pattern {
        global String start_date1 {get;set;} 
        global String text {get;set;} 
        
        
    }
    
    global class metadata {
        global Integer status {get;set;} 
        
        
    }
    
    global class Bureau_report {
        global Integer fico_score {get;set;} 
        global List<String> fico_score_factors {get;set;} 
        global Boolean file_inquiries_impacted_score {get;set;} 
        global String consumer_id {get;set;} 
        global Boolean no_hit {get;set;} 
        global Boolean frozen {get;set;} 
        // global List<Trades> trades {get;set;} 
        global List<String> bureau_social_security_number {get;set;} 
        global List<String> bureau_date1_of_birth {get;set;} 
        global String bureau_inquiry_date1 {get;set;} 
        global Integer months_since_oldest_trade {get;set;} 
        global Integer inquiries_last_6_months {get;set;} 
        global Integer number_of_open_trades {get;set;} 
        global Integer number_of_satisfactory_open_trades {get;set;} 
        global Integer number_of_delinquencies_last_2_years {get;set;} 
        global Integer number_of_current_delinquencies {get;set;} 
        global Integer number_of_tax_liens {get;set;} 
        global Integer number_of_90_day_delinquencies {get;set;} 
        global Integer number_of_trades_opened_in_last_12_months {get;set;} 
        global Integer global_records {get;set;} 
        global Integer revolving_balance {get;set;} 
        global String percent_high_card_utilization {get;set;} 
        global String months_since_derogatory_global_record {get;set;} 
        global Integer AGG901_non_mortgage_increases_last_3_mo {get;set;} 
        global Integer AGG909_mo_since_max_bankcard_balance {get;set;} 
        global String AGG911_max_bankcard_utilization {get;set;} 
        global Integer AGGS903_monthly_spend {get;set;} 
        global Integer AT02S_open_trades {get;set;} 
        global Integer AT03S_satisfactory_open_trades {get;set;} 
        global Integer AT103S_percent_satisfactory_trades_last_24_mo {get;set;} 
        global Integer AT104S_percent_trades_opened_last_24_mo {get;set;} 
        global Integer AT20S_mo_since_oldest_trade_opened {get;set;} 
        global Integer BC02S_open_credit_cards {get;set;} 
        global Integer BC20S_mo_since_oldest_credit_card_opened {get;set;} 
        global Integer BR109S_revolving_trades_with_past_due_over_50_days {get;set;} 
        global String EPAY01_ATTR06_student_loan_monthly_payment {get;set;} 
        global Integer EPAY01_ATTR10_payments_mortgage_trade_highest_high_credit {get;set;} 
        global String EPAY01_AUP1003_auto_trade_monthly_payment {get;set;} 
        global Integer FI02S_installment_trades {get;set;} 
        global Integer G058S_trades_30_days_past_due_last_6_mo {get;set;} 
        global Integer G061S_trades_30_days_past_due_last_24_mo {get;set;} 
        global Integer G069S_trades_90_days_past_due_last_12_mo {get;set;} 
        global Integer G095S_mo_since_global_record {get;set;} 
        global Integer G209S_mo_since_recent_charge_off_opened {get;set;} 
        global Integer G215B_non_medical_collections {get;set;} 
        global Integer HIAP01_home_equity_monthly_payment {get;set;} 
        global Integer IN33S_installment_trades_balance {get;set;} 
        global Integer IN34S_utilization_installment_trades_last_12_mo {get;set;} 
        global Integer INAP01_installment_trades_monthly_payment {get;set;} 
        global Integer MT101S_total_mortgage_balance {get;set;} 
        global Integer MT21S_mo_since_recent_mortgage_trade_opened {get;set;} 
        global String PAYMNT08_min_payment_revolving_ratio {get;set;} 
        global Integer RE101S_revolving_trades_balance {get;set;} 
        global Integer RE31S_percent_high_revolving_trade_utilization {get;set;} 
        global Integer RE33S_open_revolving_trades_balance {get;set;} 
        global Integer REAP01_revolving_trade_monthly_payment {get;set;} 
        global Integer RVLR04_retail_revolver_trade_balance {get;set;} 
        global String RVLR14_revolver_transactor_inactive_pattern {get;set;} 
        global Integer SCRG082_trades_past_due_last_2_mo {get;set;} 
        global Integer SCRG085_trades_90_days_past_due_last_2_mo {get;set;} 
        global Integer SCRG086_trades_120_days_past_due_last_2_mo {get;set;} 
        global Integer SCRG087_trades_150_days_past_due_last_2_mo {get;set;} 
        global Integer SCRIN07_installment_trades_opened_last_12_mo {get;set;} 
        global Integer S114S_inquiries_last_6_mo {get;set;} 
        global Integer ST06S_student_loan_trades_opened_last_6_mo {get;set;} 
        global Integer TRV01_mo_since_overlimit_on_bankcard {get;set;} 
        global Integer TRV02_mo_overlimit_on_bankcard {get;set;} 
        global Integer TRV12_revolving_high_credit_increases_last_3_mo {get;set;} 
        //global List<Inquiries> inquiries {get;set;} 
        global String AADM12_credit_vision_alternative_risk_score {get;set;} 
        global String raw_response {get;set;} 
        //global Transunion_response transunion_response {get;set;} 
        global List<Tradelines> tradelines {get;set;} 
        
        
    }
    
    global class Remarks_Z {
        global String code {get;set;} 
        global String type_Z {get;set;} // in json: type
        
        
    }
    global class Additional_trade_account{
        global Portfolio portfolio {get;set;}
        global Original original {get;set;}
    }
    
    global class Portfolio{
        global String sale_indicator{get;set;}
        global Name name{get;set;}
    }
    
    global class Original{
        global String charge_off{get;set;}
    }
    
    
    global class Trade_account {
        global String portfolio_type {get;set;} 
        global String account_number {get;set;} 
        global String ecoa_designator {get;set;} 
        global String date1_opened {get;set;} 
        global String date1_effective {get;set;} 
        global String date1_closed {get;set;} 
        global String closed_indicator {get;set;} 
        global String date1_paid_out {get;set;} 
        global String current_balance {get;set;} 
        global String high_credit {get;set;} 
        global String credit_limit {get;set;} 
        global String account_rating {get;set;} 
        global String past_due {get;set;} 
        global String update_method {get;set;} 
        global String miscellaneous {get;set;} 
        global Subscriber subscriber {get;set;} 
        global List<Remarks> remarks {get;set;} 
        global Account account {get;set;} 
        global Payment_history payment_history {get;set;} 
        global Most_recent_payment most_recent_payment {get;set;} 
        
        
    }
    
    global class Terms {
        global String payment_frequency {get;set;} 
        global String payment_schedule_month_count {get;set;} 
        global String scheduled_monthly_payment {get;set;} 
        global String prior_scheduled_monthly_payment {get;set;} 
        global String payment_schedule_month_number {get;set;} 
        
        
    }
    
    global class Balances {
        global Integer credit_cards {get;set;} 
        global Integer installment_loans {get;set;} 
        
        
    }
    
    global class Tradelines {
        global String portfolio_type {get;set;} 
        global String account_type {get;set;} 
        global String account_number {get;set;} 
        global String date1_effective;// {get;set;} 
        global String date1_opened ;//{get;set;}
        global String account_rating_code {get;set;} 
        global String  payment_frequency {get;set;} 
       
        global String subscriber_name_unparsed {get;set;} 
        global String subscriber_industry_code {get;set;} 
        global String subscriber_member_code {get;set;} 
        global Integer balance {get;set;} 
        global Integer credit_limit {get;set;} 
        global Integer high_credit {get;set;} 
        global String closed_indicator {get;set;} 
         
        global Trade_account trade_account {get;set;} 

        global Additional_trade_account additional_trade_account {get;set;}
       
        global Integer monthly_payment {get;set;} 
        global Integer monthly_payment_count {get;set;} 
        global String date1_closed {get;set;}
        
    }
    
    
    
    global class Historical_counters {
        global String months_reviewed_count {get;set;} 
        global String late_30_days_total {get;set;} 
        global String late_60_days_total {get;set;} 
        global String late_90_days_total {get;set;} 
        global String calculated {get;set;} 
        
        
    }
    
    global class Payment_history {
        global List<Remarks> max_delinquency {get;set;} 
        global Payment_pattern payment_pattern {get;set;} 
        global Historical_counters historical_counters {get;set;} 
        global String date1_first_delinquent {get;set;} 
        
        
    }
    
    global class Accounts {
        //    global List<Credit_cards> credit_cards {get;set;} 
        //  global List<Installment_loans> installment_loans {get;set;} 
        
        
    }
    
    
    global static HardCreditPullResponse parse(String json,String accId, String appId) {
        json=json.replace('date', 'date1');
        HardCreditPullResponse HardCreditPullResponseData = (HardCreditPullResponse) System.JSON.deserialize(json, HardCreditPullResponse.class);
        
        system.debug('Stage 1: ****** '+HardCreditPullResponseData );
        
        try{
            HardCreditPullResponseData.cpData = mappingOfFields(HardCreditPullResponseData,accId,appId);
            
            Hard_Credit_Pull__c hcp = new Hard_Credit_Pull__c();
            hcp.Account__c          = accId;
            hcp.Application__c      = appId;
            hcp.Name                = appId;
            insert hcp;
            
            Attachment creditReport = new Attachment();
            creditReport.parentId   = hcp.id;
            creditReport.name       = 'hard_pull_'+ DateTime.now().getTime() +'.pdf';
            creditReport.body       =  blob.toPDF(json);
            insert creditReport;
             
        }catch(Exception e){
            System.debug('Exception stack: '+e.getStackTraceString());
            throw new ints.IntegrationException(' API call failure Message: '+e.getMessage());
        }
        
        return HardCreditPullResponseData;
        
    }
    /*  global Bureau_report parseBRAPI(String json){
return (Bureau_report) System.JSON.deserialize(json, Bureau_report.class);
}*/
    global static List<Hard_Credit_Pull__c> mappingOfFields(HardCreditPullResponse HardCreditPullResponseData,String accId,String appId){
        
        List<Hard_Credit_Pull__c> objList=new List<Hard_Credit_Pull__c>();
        //system.debug('HardCreditPullResponseData'+HardCreditPullResponseData);
        if(HardCreditPullResponseData!=null){
            System.debug(' ** *** Trade Lins ** *** 1'+HardCreditPullResponseData.All_attributes );
            if(HardCreditPullResponseData.All_attributes !=null){
                if(HardCreditPullResponseData.All_attributes.Bureau_report!=null){
                    // String BureauResponse = String.valueof(HardCreditPullResponseData.All_attributes.Bureau_report);
                    /*if(HardCreditPullResponseData.All_attributes.Bureau_report.fico_score!=null){
                        System.debug('Stage 3 : ' + HardCreditPullResponseData.All_attributes.Bureau_report.fico_score);
                        HardCreditPullResponseData.fico_score   = HardCreditPullResponseData.All_attributes.Bureau_report.fico_score;
                        System.debug('Stage 4 : ' + HardCreditPullResponseData.fico_score);
                    }*/
                }
                
                if(HardCreditPullResponseData.all_attributes.bureau_report.tradelines!=null){
                   System.debug(' ** *** Trade Lins ** *** '+HardCreditPullResponseData.all_attributes.bureau_report.tradelines);
                    for(Tradelines inst:HardCreditPullResponseData.all_attributes.bureau_report.tradelines)
                    {
                        Hard_Credit_Pull__c  obj= new Hard_Credit_Pull__c();   
                        obj.Application__c=appId;
                        obj.Account__c=accId;
                        if(inst.account_number!=null)
                            obj.Account_Number__c=inst.account_number;
                        obj.Current_Balance__c=inst.balance;
                        if(inst.account_type!=null){
                            if((inst.portfolio_type != 'installment') && (inst.account_type == 'CC' || 
                                                                          inst.account_type =='FX'|| inst.account_type =='CH'||
                                                                          inst.account_type =='BC'|| inst.account_type == 'SC')) 
                            {
                                obj.Account_Type__c= 'credit card';}
                            
                            
                            else if(inst.portfolio_type != 'installment' && 
                                    inst.account_type == 'ST' ){
                                        obj.Account_Type__c= 'student loan';}
                            
                            else if((inst.portfolio_type != 'installment') && 
                                    (inst.account_type == 'CV'||inst.account_type == 'CY' ||inst.account_type == 'FL' 
                                     || inst.account_type =='FR' || inst.account_type =='RM' ||inst.account_type == 'SM' 
                                     || inst.account_type =='VM' || inst.account_type == 'MB' ))
                            {
                                obj.Account_Type__c= 'mortgage';}
                            
                            else if((inst.portfolio_type != 'installment') && 
                                    (inst.account_type == 'AU' || inst.account_type == 'AL' ))
                            {
                                obj.Account_Type__c= 'auto loan';}
                            
                            else if((inst.portfolio_type != 'installment') &&(inst.account_type == 'HE'))
                                obj.Account_Type__c= ' HELOC';
                            
                            
                            else if((inst.portfolio_type != 'installment') &&(inst.account_type == 'US')){
                                obj.Account_Type__c= ' unsecured IL';}
                            
                            else if((inst.portfolio_type != 'installment') &&(inst.account_type == 'LC' ||inst.account_type == 'CE')){
                                obj.Account_Type__c= 'line of credit';}
                            
                            
                            
                            else{
                                obj.Account_Type__c= 'other';
                                
                                if(inst.account_type =='AX' || inst.account_type =='CP' ||
                                   inst.account_type =='CU' ||inst.account_type =='DC' ||
                                   inst.account_type =='DR' ||inst.account_type =='FI' ||
                                   inst.account_type =='FM' ||inst.account_type =='GS' ||
                                   inst.account_type =='HI' ||inst.account_type =='LE' ||
                                   inst.account_type =='LS' ||inst.account_type =='RA' ||
                                   inst.account_type =='RC' ||inst.account_type =='RD' ||
                                   inst.account_type =='RE' ||inst.account_type =='SE' ||
                                   inst.account_type =='SH' ||inst.account_type =='SI' ||
                                   inst.account_type =='SO' ||inst.account_type =='UC'){
                                       obj.Account_Type__c= 'OTHER';}
                                else
                                    obj.Account_Type__c= ' unsecured IL';
                            }
                            
                        }
                        if(inst.account_rating_code !=null){
                            if(inst.account_rating_code == '01')
                                obj.Account_Rating__c='Good';
                            else
                                obj.Account_Rating__c='Bad';
                        }
                        if(inst.credit_limit!=null)
                            obj.Credit_Limit__c=Decimal.valueof(inst.credit_limit);
                            
                        if(inst.Additional_trade_account!=null && inst.Additional_trade_account.Portfolio!=null && inst.Additional_trade_account.Portfolio.sale_indicator!=null && inst.Additional_trade_account.Portfolio.name!=null && inst.Additional_trade_account.Portfolio.name.unparsed !=null )
                            obj.Additional_Trade_Account__c= 'Portfolio : sale_indicator : ' + inst.Additional_trade_account.Portfolio.sale_indicator + 'name : unparsed : '+ inst.Additional_trade_account.Portfolio.name.unparsed + 'original: charge_off : ';
                        
                        //system.debug('inst.date1_closed'+inst.date1_closed);                   
                        if(inst.date1_closed!=null)
                            obj.Date_Closed__c= inst.date1_closed;
                            
                        //system.debug('inst.date_effective'+inst.date1_effective);
                        if(inst.date1_effective!=null)
                            obj.Date_Effective__c=inst.date1_effective;
                        //system.debug('inst.date_opened'+inst.date1_opened);    
                        if(inst.date1_opened!=null)
                            obj.Date_Opened__c=inst.date1_opened;
                        if(inst.high_credit!=null)
                            obj.High_credit__c=Decimal.valueOf(inst.high_credit);
                        if(inst.credit_limit!=null)
                            obj.Max_Deliquency__c=String.valueOf(inst.credit_limit);
                        if(inst.portfolio_type!=null)
                            obj.Portfolio_Type__c=inst.portfolio_type;
                        if(inst.monthly_payment!=null)
                           obj.Scheduled_Monthly_Payment__c= inst.monthly_payment;
                        if(inst.trade_account.subscriber.name.unparsed !=null)
                            obj.Subscriber__c= inst.trade_account.subscriber.name.unparsed;
                        if(inst.subscriber_industry_code!=null)
                            obj.Subscriber_industry_code__c=inst.subscriber_industry_code;
                        if(inst.subscriber_member_code!=null)
                            obj.Subscriber_Member_Code__c=inst.subscriber_member_code;
                        obj.Payment_Pattern__c=inst.trade_account.Payment_history.payment_pattern.text;
                        if(inst.payment_frequency!=null)
                            obj.Payment_Frequency__c=inst.payment_frequency;
                        if(inst.trade_account.ecoa_designator!=null)
                        obj.Ecoa_Designator__c=inst.trade_account.ecoa_designator;
                        if(inst.trade_account.payment_history.historical_counters.months_reviewed_count!=null)
                        obj.Months_Reviewed_Count__c=Decimal.ValueOf(inst.trade_account.payment_history.historical_counters.months_reviewed_count);
                       // if(inst.trade_account.most_recent_payment.date1!=null)
                       // obj.Most_Recent_Payment_Date__c=inst.trade_account.most_recent_payment.date1;
                        if(inst.trade_account.payment_history.payment_pattern.start_date1!=null)
                        obj.Payment_Start__c=inst.trade_account.payment_history.payment_pattern.start_date1;
                        if(inst.trade_account.remarks!=null){
                            for(remarks rem: inst.trade_account.remarks){
                                if(rem.code!=null && rem.type1!=null)
                                    obj.Remarks__c= 'code'+rem.code + 'type:'+rem.type1; 
                            }
                        }
                        
                        objList.add(obj);
                        
                        System.debug('Insert Object ' +objList);
                        
                        insert objList;
                        //system.debug(objList);
                    }
                }
            }
            
        }
        if(objList != null && objList.size() > 0)
            HardCreditPullResponseData.cpData = objList;
        //system.debug(objList);
        return objList;
    }
}