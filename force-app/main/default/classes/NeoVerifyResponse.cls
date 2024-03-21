global class NeoVerifyResponse {
    global String requestBody;
    global String responseBody;
    global String integrationErrorStatus;
    global String integrationErrorStatusCode;
    global String errorMessage;
    global String report_id {get;set;} 
    global String application_date {get;set;} 
    global String report_start_date {get;set;} 
    global String report_end_date {get;set;} 
    global Integer report_duration {get;set;} 
    global Averages averages {get;set;} 
    global Living_expenses living_expenses {get;set;} 
    global Discretionary_expenses discretionary_expenses {get;set;} 
    global List<Accounts> accounts {get;set;} 
    global List<Period_summaries> period_summaries {get;set;} 
    global List<Employments> employments {get;set;} 
    global List<Other_income> other_income {get;set;} 
    global Payday_loans payday_loans {get;set;} 
    global Payday_loans bounced_checks {get;set;} 
    global Nsfs_by_month nsfs_by_month {get;set;} 
    global Overdrafts overdrafts {get;set;} 
    global Nsfs_by_month ods_by_month {get;set;} 
    global Neo_Verify__c neo;
    global class Other_income {
        global String description {get;set;} 
        global String amount {get;set;} 
        global String date1 {get;set;} 
    }
    
    global class Employments {
        global String employer {get;set;} 
        global String first_pay_date1 {get;set;} 
        global String last_pay_date1 {get;set;} 
        global Integer paychecks {get;set;} 
        global String avg_paycheck {get;set;} 
        global String pay_cycle {get;set;} 
        global String next_day_date1 {get;set;} 
        global String total_earnings {get;set;} 
        
    }
    
    global class Discretionary_expenses {
        global String restaurant {get;set;} 
        global String auto {get;set;} 
        global String clothing {get;set;} 
        global String entertainment {get;set;} 
        global String home_improvement {get;set;} 
        global String household {get;set;} 
        global String cash {get;set;} 
        global String other {get;set;}  
    }
    
    global class Nsfs_by_month {
        global Integer first {get;set;} 
        global Integer second {get;set;} 
        global Integer third {get;set;}     
    }
    
    global class Living_expenses {
        global String utility {get;set;} 
        global String insurance {get;set;} 
        global String gasoline {get;set;} 
        global String telecom {get;set;} 
        global String other {get;set;}  
    }
    
    global class Period_summaries {
        global String month {get;set;} 
        global String cash_flow_total_income {get;set;} 
        global String cash_flow_net_income {get;set;} 
        global String payroll_income {get;set;} 
        global String other_income {get;set;} 
        global String total_income {get;set;} 
        global String living_expense {get;set;} 
        global String discretionary_expense {get;set;} 
        global String total_expense {get;set;}  
    }
    
    global class Items {
        global String date1 {get;set;} 
        global String amount {get;set;}     
    }
    
    global class Payday_loans {
        global Integer count {get;set;} 
        global String fees {get;set;} 
        global List<Other_income> items {get;set;}  
    }
    
    global class Overdrafts {
        global Integer count {get;set;} 
        global String fees {get;set;} 
        global List<Items> items {get;set;}     
    }
    
    global class Accounts {
        global Object type_Z {get;set;} // in json: type
        global String number_Z {get;set;} // in json: number
        global String name {get;set;} 
        global String balance {get;set;} 
        global String FI {get;set;}     
    }
    
    global class Averages {
        global String total_income {get;set;} 
        global String payroll_income {get;set;} 
        global String other_income {get;set;} 
        global String total_expenses {get;set;} 
        global String living_expenses {get;set;} 
        global String discretionary_expenses {get;set;}     
    }
    
    
    global NeoVerifyResponse parse(String json,String accId, String appId) {
        json=json.replace('date', 'date1');
        
        
        NeoVerifyResponse NeoVerifyResponseData = (NeoVerifyResponse) System.JSON.deserialize(json, NeoVerifyResponse.class);
        System.debug('**********'+NeoVerifyResponseData);
       
        try{
            NeoVerifyResponseData.neo = mappingOfFields(NeoVerifyResponseData,accId,appId);
            
        }catch(Exception e){
            System.debug('Exception stack: '+e.getStackTraceString());
            throw new ints.IntegrationException(' API call failure Message: '+e.getMessage());
        }
        
        
        
        return NeoVerifyResponseData;
    }
    global Neo_Verify__c mappingOfFields(NeoVerifyResponse NeoVerifyResponseData,String accId,String appId){
        Neo_Verify__c  obj= new Neo_Verify__c();
        Integer moncredep;
        Decimal sumtransfer=0.0;
        Decimal sumdeposit=0.0;
        Decimal suminterest=0.0;
        Decimal sumnsf=0.0;
        Decimal sumuncategorizable=0.0;
        Decimal other=0.0;
        // obj.Account__c=accId;
        obj.Application__c=appId;
        if(NeoVerifyResponseData !=null){
            if(NeoVerifyResponseData.Averages!=null){
                if(NeoVerifyResponseData.Averages.total_income!=null){
                    obj.Average_Credits_Deposits__c= (Decimal.ValueOf(NeoVerifyResponseData.Averages.total_income) ) + '/Month';
                    if(NeoVerifyResponseData.Averages.total_expenses!=null){
                        obj.Average_Savings__c= String.ValueOf((Decimal.ValueOf(NeoVerifyResponseData.Averages.total_income) - Decimal.ValueOf(NeoVerifyResponseData.Averages.total_expenses)) ) + '/Month';
                        obj.Based_on_Total_Credits_Deposits__c= (Decimal.ValueOf(NeoVerifyResponseData.averages.total_income) - Decimal.ValueOf(NeoVerifyResponseData.averages.total_expenses));
                    }
                }
                if(NeoVerifyResponseData.averages.payroll_income!=null){
                    
                    
                    obj.Monthly_Net_Credits_Deposits__c= Decimal.ValueOf(NeoVerifyResponseData.averages.payroll_income);
                    if(NeoVerifyResponseData.averages.total_expenses!=null)
                        obj.Based_on_Net_Credits_Deposits__c=(Decimal.ValueOf(NeoVerifyResponseData.averages.payroll_income) - Decimal.ValueOf(NeoVerifyResponseData.averages.total_expenses ));
                    
                }
                if(NeoVerifyResponseData.averages.other_income!=null)
                    obj.Mothnly_Other_Credits_Deposits__c=Decimal.ValueOf(NeoVerifyResponseData.averages.other_income);
                
            }
            obj.Chk_Svg_Acct_Balances__c= 0;
            if(NeoVerifyResponseData.accounts!=null){
                for(Accounts acc: NeoVerifyResponseData.accounts){
                    if(acc.balance!=null)
                        obj.Chk_Svg_Acct_Balances__c=(obj.Chk_Svg_Acct_Balances__c+Decimal.valueOf(acc.balance));
                }
            }
            if(NeoVerifyResponseData.nsfs_by_month!=null && NeoVerifyResponseData.nsfs_by_month.first!=null 
               && NeoVerifyResponseData.nsfs_by_month.second!=null && NeoVerifyResponseData.nsfs_by_month.third !=null &&
               NeoVerifyResponseData.bounced_checks!=null && NeoVerifyResponseData.bounced_checks.count!=null && 
               NeoVerifyResponseData.overdrafts!=null && NeoVerifyResponseData.overdrafts.count!=null ){
                   obj.NSF_OD__c= String.Valueof((NeoVerifyResponseData.nsfs_by_month.first + NeoVerifyResponseData.nsfs_by_month.second 
                                                  + NeoVerifyResponseData.nsfs_by_month.third 
                                                  + NeoVerifyResponseData.bounced_checks.count + NeoVerifyResponseData.overdrafts.count));
                   
               }
            if(NeoVerifyResponseData.payday_loans!=null && NeoVerifyResponseData.payday_loans.count!=null)
                obj.Payday_Loans__c=String.valueOf(NeoVerifyResponseData.payday_loans.count);
            //obj.Pay_Frequency__c
            // obj.Payroll_Dates__c
            //obj.Payroll_Source_Company__c
            //obj.Total_Earnings__c
            // obj.Next_Paydate_estimate__c=
            //obj.No_of_Paychecks__c
            //obj.Avg_Paycheck__c=
            Integer count =0;
            Integer count1=0;
            if(NeoVerifyResponseData.Period_summaries!=null){
                For(Period_summaries periodsum:NeoVerifyResponseData.period_summaries){
                    if(Decimal.valueof(periodsum.total_income)<=1400.00)
                        count++;
                    count1++;
                }
                
                if((count+count1)==count)
                    obj.Monthly_Credits_Deposits__c='Below $1,400 every month';
                if((count+count1)==count1)
                    obj.Monthly_Credits_Deposits__c='Above $1,400 every month';
                if((count+count1)>count && count==1)
                    obj.Monthly_Credits_Deposits__c='Was below $1,400 in 1 month';
                if((count+count1)>count && count>1)
                    obj.Monthly_Credits_Deposits__c='Was below $1,400 in'+ count+' months';
                
                
            }
        }
        
        
        if(NeoVerifyResponseData!=null && NeoVerifyResponseData.Other_income!=null){
            for(Other_income oinc:NeoVerifyResponseData.other_income){
                if(oinc.description!=null && oinc.amount!=null){
                    if(oinc.description =='mTransfer' || oinc.description == null)
                        sumtransfer=sumtransfer+Decimal.valueOf(oinc.amount);
                    else if(oinc.description=='Deposit')
                        sumdeposit=sumdeposit+Decimal.valueOf(oinc.amount);
                    else if(oinc.description=='Interest') 
                        suminterest=suminterest+Decimal.valueOf(oinc.amount);
                    else if(oinc.description=='NSF')
                        sumnsf=sumnsf+Decimal.valueOf(oinc.amount);
                    else if(oinc.description=='Uncategorizable')
                        sumuncategorizable=sumuncategorizable+Decimal.valueOf(oinc.amount);
                    else
                        other=other+Decimal.valueOf(oinc.amount);
                }
            }
            obj.Transfer__c = String.valueOf(((sumtransfer*30)/NeoVerifyResponseData.report_duration));
            obj.Unrecognizable__c=String.valueOf(((sumuncategorizable*30)/NeoVerifyResponseData.report_duration));
            obj.Deposit__c=((sumdeposit*30)/NeoVerifyResponseData.report_duration);
            obj.Interest__c=((suminterest*30)/NeoVerifyResponseData.report_duration);
            obj.NSF__c=String.valueOf(((sumnsf*30)/NeoVerifyResponseData.report_duration));
            obj.Other_Credits_Deposiits__c=((other*30)/NeoVerifyResponseData.report_duration);
        }
        return obj;
    }
}