/* ****************Modification History******************
 * Last Modified by        Date          JIRA number
 *      1. Pallavi        2020/01/27     LOS-28(Remove references to InvestorAccount field on CL contract)
 *      2. Pallavi        2020/05/19     CRM-557/LOP-56(DCP - additional fields on Disbursal transaction)
 ******************Modification History******************/
global class ApplicationToContractConverter implements ints.IProcessContract{
    
    public genesis__Applications__c application;
    public loan__Loan_Account__c loanAccount;
    private Date systemDate;
    public loan__Org_Parameters__c orgParam;
    String autopayLpName;
    String manualpayLpName;
        
    global virtual void setContracts(Map<SObject,SObject> objectMap){
        
        Set<SObject> applicationSet = objectMap.keySet();
        
        for(SObject obj:applicationSet){
            application = (genesis__Applications__c)obj;
        }
        
        this.loanAccount = (loan__Loan_Account__c)objectMap.get(application);
        this.loanAccount.loan__Contract_Type__c = 'New';
        systemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        
    }
    
    global virtual String processContract(){
        
        System.debug(logginglevel.error, 'In ApplicationToContractConverter' );
        intialize();
        
        application = getApplicationDetails(application.id);        
        
        loan__Bank_Account__c bankAcc = getBankAccDetails(application.genesis__Account__r.id);       
        String validateResult = validate();
        
        if(!validateResult.equalsIgnoreCase('SUCCESS')){
            return validateResult;
        }
        
        Savepoint spDML = Database.setSavepoint();
        
        try{
            
            String retMsg = '';
            //Integer monthFPD = application.Anniversary_Date__c.addMonth(1).month();
            /*   Date firstPaymentDate = application.Anniversary_Date__c.addMonths(1);
            Integer numberOfDays = Date.daysInMonth(application.Anniversary_Date__c.year(), application.Anniversary_Date__c.month());
            Date lastDayOfMonth = Date.newInstance(application.Anniversary_Date__c.year(), application.Anniversary_Date__c.month(), numberOfDays);
            Integer dueDay = firstPaymentDate.day();
            if(application.Anniversary_Date__c == lastDayOfMonth){
            
            Integer numOfDays = Date.daysInMonth(firstPaymentDate.year(), firstPaymentDate.month());
            System.Debug('numOfDays ' + numOfDays);
            firstPaymentDate = Date.newInstance(firstPaymentDate.year(), firstPaymentDate.month(), numOfDays);
            System.Debug('firstPaymentDate  ' + firstPaymentDate);
            dueDay = 31;
            
            }  */
            
            QueueSobject fundedQue;
            
            try{
            
                fundedQue = [Select queue.id,queue.name,QueueID 
                             from QueueSobject 
                             where SobjectType ='genesis__Applications__c'                                   
                             AND queue.DeveloperName =: 'Funding_Queue'];
                             
            }catch(Exception e){
                loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in TRY Block :: :  '+e.getlinenumber()+'Error: '+e.getMessage() + application.name);
                insert logs;
                throw new ints.IntegrationException('Funded Queue is not setup');
            }
            
            date customLastAccrualDate = (application.Loan_Origination_Date__c.month() == 12 ? date.newinstance((systemDate.year()+1), 01, 01) : date.newinstance(systemDate.year(), (systemDate.month() + 1), 01));
            
            loan__Loan_Account__c la = new loan__Loan_Account__c(loan__Loan_Amount__c = application.genesis__Loan_Amount__c,
                                                                 Application__c = application.Id,
                                                                 loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_APPROVED,
                                                                 peer__Note_Type__c = [select id,name from peer__Note_Type__c limit 1][0].id,
                                                                 loan__Is_Interest_Posting_Enabled__c = True,
                                                                 loan__Interest_Posting_Frequency__c = application.genesis__Payment_Frequency__c,
                                                                 //loan__Interest_Rate_on_Due_Principal__c = application.genesis__Interest_Rate__c ,
                                                                 loan__account__c = application.genesis__Account__c,
                                                                 peer__Origination_Fee__c =application.Origination_fee__c,
                                                                 loan__Number_of_Installments__c = application.genesis__Term__c,
                                                                 loan__interest_rate__c = application.genesis__Interest_Rate__c,
                                                                 loan__Loan_Product_Name__c = application.genesis__CL_Product__r.loan__Lending_Product__c, 
                                                                 loan__First_Installment_Date__c = application.Anniversary_Date__c,
                                                                 loan__Contractual_Due_Day__c = application.Anniversary_Date__c.day(),
                                                                 //Investor_Account__c = application.Investor__c, commented(LOS-28)
                                                                 // commented by Neha. CLS-1375 /*Rashmi*/
                                                                 //loan__Accrual_Start_Date__c = (application.Loan_Origination_Date__c.day() == 29 || application.Loan_Origination_Date__c.day() == 30 || application.Loan_Origination_Date__c.day() == 31 ? customLastAccrualDate : systemDate),
                                                                 loan__Accrual_Start_Days__c = ((application.Loan_Origination_Date__c.day() == 29 || application.Loan_Origination_Date__c.day() == 30 || application.Loan_Origination_Date__c.day() == 31) ? math.abs(customLastAccrualDate.daysBetween(systemDate)):(systemDate.daysBetween(application.Loan_Origination_Date__c))),/*Rashmi*/
                                                                 //loan__Accrual_Start_Days__c = systemDate.daysBetween(application.Loan_Origination_Date__c),
                                                                 //loan__Contractual_Due_Day__c = dueDay,
                                                                 loan__Expected_Repayment_Start_Date__c = application.Anniversary_Date__c,
                                                                 Anniversary_Date__c = application.Anniversary_Date__c,
                                                                 lead_Guid__c = application.Lead_Id__c,
                                                                 loan__Payment_Amount__c = application.genesis__Monthly_Debt_Payments__c,
                                                                 loan__Include_In_Metro2_File__c = true,
                                                                 RecordTypeId = [select Id,
                                                                                 Name,
                                                                                 SobjectType
                                                                                 from RecordType
                                                                                 where Name =: application.genesis__CL_Product__r.loan__Lending_Product__r.loan__Loan_Product_Type__c 
                                                                                 and SObjectType =: 'loan__Loan_Account__c'].Id);  
            //pallavi PS-3723/LOS-115
             if(systemDate.daysBetween(application.Loan_Origination_Date__c) < 0){
                la.loan__Accrual_Start_Days__c = 0; 
             }
            //pallavi PS-3723/LOS-115
            
            List<DCp_Arcus_Transactions__c> dcpTrans = [select id,name,Credit_Card_Name__c,
                                                        Paid_Amount__c,Status__c,Transaction_Id__c,Requested_Amount__c
                                                        from DCp_Arcus_Transactions__c
                                                        where Transaction_Id__c!=null and Pay_at_Funding__c=true 
                                                        and application__c=:application.id];                                                                                                             
                                                        
            //Rate schedule
            //System.debug('Investor_Account__c' + ' ' + la.Investor_Account__c);
            List<loan__Multi_Step_Loan_Setup__c> rtsch = new List<loan__Multi_Step_Loan_Setup__c>();
            loan__Multi_Step_Loan_Setup__c multi= new loan__Multi_Step_Loan_Setup__c();
            multi.loan__Interest_Rate__c = application.genesis__Interest_Rate__c;
            multi.loan__Sequence__c = 1;
            multi.loan__Start_Date__c =systemDate;
            rtsch.add(multi);       
                        
            loan.BorrowerAPI2 bAPI = loan.APIFactory.getBorrowerAPI2();
            loan__Loan_Account__c lAccount = bAPI.createContract(la, 
                                                                 null, 
                                                                 rtsch,
                                                                 null,
                                                                 null, 
                                                                 null);
            loan__Automated_Payment_Configuration__c apc;
            
            try{
            
                apc = [Select id,name,
                       loan__Payment_Mode__c,
                       loan__Bank_Account__c,
                       loan__Bank_Account__r.loan__Account__c
                       From loan__Automated_Payment_Configuration__c
                       Where loan__Bank_Account__r.loan__Account__c =: application.Investor__c
                       limit 1];
                       
            }catch(exception ex){
                loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToUnderwriterQueue:  '+ex.getlinenumber()+'Error: '+ex.getMessage() + application.name);
                insert logs;
                throw new ints.IntegrationException('NO APC FOUND FOR THIS INVESTOR');
                
            }
            
            System.debug(autopayLpName+ '  '+ application.genesis__CL_Product__r.loan__Lending_Product__r.Name );  
            
            if(application.genesis__CL_Product__r.loan__Lending_Product__r.Name == autopayLpName) {
                
                loan__Automated_Payment_Setup__c aps = new loan__Automated_Payment_Setup__c();
                aps.loan__Type__c = 'RECURRING';
                aps.loan__Amount_Type__c= loan.LoanConstants.CURRENT_PAYMENT_AMOUNT;
                //aps.loan__Transaction_Amount__c=loanApplication.genesis__Payment_Amount__c; No need to set transaction because 
                aps.loan__CL_Contract__c=lAccount.Id;
                aps.loan__Payment_Mode__c = apc.loan__Payment_Mode__c;
                aps.loan__Active__c = true;                
                aps.loan__Bank_Account__c = bankAcc.ID;
                aps.loan__Debit_Date__c = application.Anniversary_Date__c;
                aps.loan__Frequency__c = application.genesis__Payment_Frequency__c;
                aps.loan__Setup_Date__c=systemDate;
                aps.loan__Installment_Payment__c = false; // making it false as the payment will clear either on the transaction date or later
                aps.loan__Recurring_ACH_Start_Date__c = aps.loan__Debit_Date__c;
                //aps.loan__Recurring_ACH_End_Date__c = lAccount.loan__Maturity_Date_Current__c;    //Do not set End date as they want to keep trying for APS if Loan is not paid completely.
                aps.loan__Retry__c = 'Disabled'; 
                
                insert aps; 
            }          
            
            loan__Loan_Disbursal_Transaction__c disbursal =  new loan__Loan_Disbursal_Transaction__c();
            disbursal.loan__Disbursal_Date__c = systemDate; 
            disbursal.loan__Disbursed_Amt__c = lAccount.loan__Loan_Amount__c ;
            disbursal.loan__Loan_Account__c = lAccount.id;
            disbursal.loan__Mode_of_Payment__c = apc.loan__Payment_Mode__c;
            disbursal.loan__Bank_Account__c = bankAcc.ID;
            
            if(application.Total_Arcus_Transactions__c >0) {
            
                List<loan__payment_mode__c> paymentMode = [select id,name from loan__payment_mode__c where name='DCP Arcus'];
                
                if(paymentMode==null) {
                    throw new ints.IntegrationException('NO Payment Mode available for DCP');
                }
                
                disbursal.loan__Mode_of_Payment__c = paymentMode[0].id;
            }
            
            loan.LoanDisbursalActionAPI action = new loan.LoanDisbursalActionAPI(disbursal);
            lAccount = action.disburseLoanAccount();
            
            List<loan__Disbursal_Txn_Distribution__c> distributionTxn = new List<loan__Disbursal_Txn_Distribution__c>();
               
            if(application.Total_Arcus_Transactions__c >0) {
                            
                for(DCp_Arcus_Transactions__c dcpTransaction : dcpTrans) {
                                            
                    loan__Disbursal_Txn_Distribution__c disbursalDistribution = new loan__Disbursal_Txn_Distribution__c();
                    disbursalDistribution.loan__Distribution_Amount__c = dcpTransaction.Requested_Amount__c;
                    disbursalDistribution.loan__Distribution_Type__c ='Disbursement';
                    disbursalDistribution.loan__Loan_Disbursal_Transaction__c = disbursal.Id;
                    disbursalDistribution.Arcus_Transaction_Id__c = dcpTransaction.Transaction_Id__c; //CLS-1083
                    disbursalDistribution.Arcus_Transaction_Status__c = 'Initialized';  //CRM-557
                    disbursalDistribution.DCP_Arcus_Transaction__c = dcpTransaction.id;    //CRM-557
                    distributionTxn.add(disbursalDistribution);
                }
                
            }else{
                disbursal.loan__Mode_of_Payment__c = apc.loan__Payment_Mode__c;
            }
            
            if(application.Total_Arcus_Transactions__c >0) {
                List<loan__Disbursal_Txn_Distribution__c> distribution = [Select id,name
                                                                          from loan__Disbursal_Txn_Distribution__c
                                                                          where loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__c=:lAccount.id];
                //delete  distribution;                                                       
                insert distributionTxn;
            }
            
            application.CL_Contract__c = lAccount.Id;
            application.genesis__Status__c=PayoffConstants.FUNDED;
            lAccount.Application__c = application.id;
            application.OwnerId = fundedQue.Queue.Id;
            update application;
            update lAccount;
            
            
            //Create Investment order.
            Account investor=[SELECT id,loan__Collect_Service_Fees_on__c,Funding_Partner__c,loan__Service_Rate_On_Investment__c 
                              FROM Account 
                              WHERE id = :application.Investor__c];
            
            loan__Investor_Loan__c inv = new loan__Investor_Loan__c(loan__Loan__c = lAccount.Id, loan__Account__c = investor.id,
                                                                    loan__Investment_Amount__c = lAccount.loan__Loan_Amount__c ,
                                                                    loan__Collect_Service_Fees_On__c =investor.loan__Collect_Service_Fees_on__c,
                                                                    loan__Certificate_Rate__c = lAccount.loan__interest_rate__c,
                                                                    loan__Service_Rate__c = investor.loan__Service_Rate_On_Investment__c ,
                                                                    loan__Investor_Start_Date__c = systemDate,
                                                                    Buyer__c = investor.Funding_Partner__c);
            List<loan__Investor_Loan__c> ios = new List<loan__Investor_Loan__c>();
            ios.add(inv); 
            loan.InvestorAPI api = loan.APIFactory.getInvestorAPI();
            api.createInvestmentOrders(ios);
            
            return 'Application converted to Loan successfully!!';        
            
        }catch(Exception e){
            system.debug('e.getLineNumber()'+e.getLineNumber()+'msg'+e.getMessage()+'stack'+e.getStackTraceString());
            Database.rollback(spDML);
            return 'message:'+e.getMessage() +',line number:'+e.getLineNumber(); 
        }
        
    }
    
    
    public static genesis__Applications__c getApplicationDetails(String appId){
        genesis__Applications__c application = [select id,RecordTypeId,CreatedDate,
                                                name,
                                                genesis__Status__c,
                                                Origination_fee__c,
                                                Investor__c,
                                                genesis__Monthly_Debt_Payments__c,
                                                genesis__Account__r.id,
                                                genesis__Payment_Frequency_Multiplier__c,
                                                genesis__Total_Fee_Amount__c,
                                                genesis__CL_Purpose__r.loan__Lending_Purpose__c,
                                                genesis__Lending_Product__r.Name,
                                                genesis__Company__r.Name,genesis__Loan_Amount__c,
                                                genesis__Account__c,genesis__Contact__c,
                                                genesis__Term__c,
                                                genesis__Expected_Second_Pay_Day_Date__c,
                                                genesis__Payment_Frequency__c,genesis__Draw_Term__c,
                                                genesis__Interest_Rate__c,genesis__Product_Type__c,
                                                genesis__Lending_Product__c,genesis__Days_Convention__c,
                                                genesis__Expected_First_Payment_Date__c  ,
                                                genesis__Expected_Start_Date__c,
                                                genesis__Expected_Close_Date__c,
                                                genesis__Balloon_Payment__c,
                                                genesis__Interest_Only_Period__c,
                                                genesis__Bank_Account_Number__c,
                                                genesis__Bank_Account_Type__c,
                                                genesis__Bank_Name__c,
                                                genesis__CL_Product__c, 
                                                genesis__CL_Product__r.loan__Lending_Product__c,
                                                genesis__CL_Product__r.loan__Lending_Product__r.loan__Loan_Product_Type__c,
                                                genesis__CL_Product__r.loan__Lending_Product__r.Name,
                                                Payment_Mode__c,
                                                CL_Contract__c,
                                                Bank_Account__c,
                                                genesis__Routing_Number__c,
                                                genesis__Payment_Amount__c,
                                                genesis__Financed_Amount__c,
                                                Anniversary_Date__c,
                                                Lead_Id__c,
                                                Loan_Doc_Signed_On__c,
                                                Loan_Origination_Date__c,
                                                Total_Arcus_Transactions__c
                                                from genesis__Applications__c where Id=:appId];
        
        
        return application;
    }
    
    public static loan__Bank_Account__c getBankAccDetails(ID accId){
        
        loan__Bank_Account__c bankAcc;
        
        try{
            bankAcc = [Select id,name,
                       loan__Account__c,
                       loan__Active__c
                       From loan__Bank_Account__c 
                       Where loan__Account__c =: accId 
                       And loan__Active__c = True
                       Limit 1];
                       
        }catch(Exception e){
            System.Debug('<<Exception>> ' + e.getMessage() + e.getStackTraceString());
            throw new ints.IntegrationException('Bank Account is Missing');
            
        }
        return bankAcc;
    }
    
    private String validate() {
        /* Checking if App is Auto pay or not */
        //****
        orgParam = loan.CustomSettingsUtil.getOrgParameters();
        autopayLpName = orgParam.Auto_Payer_Lending_Product_Name__c;
        manualpayLpName = orgParam.Manual_Payer_Lending_product_name__c;
        
        //***
        String retVal = 'SUCCESS';
        if(this.application.CL_Contract__c!=null){
            return 'Application already been converted into Contract';
        }
        /* if(application.Payment_Mode__c ==null){
        return 'Please provide payment mode !!';
        } */
        
        if(!application.genesis__Status__c.equalsIgnoreCase('Approved for Funding')){
            return 'Status of application should be "Approved for Funding" to convert into Contract';
        }
        
        if(application.Investor__c == null){
            return 'Investor is not allocated to this application';
        }
        return retVal;
    }  
              
    private void intialize() {
        
        orgParam = loan.CustomSettingsUtil.getOrgParameters();
        autopayLpName = orgParam.Auto_Payer_Lending_Product_Name__c;
        manualpayLpName = orgParam.Manual_Payer_Lending_product_name__c;
        
        
        
    }   
    
    public static void callDCPIntegration(Id applicationId){
    List<DCp_Arcus_Transactions__c> dcpTrans = [select id,name,Credit_Card_Name__c,
                                                        Paid_Amount__c,Status__c,Transaction_Id__c,DCP_Callout_done__c,
                                                        Arcus_Failure_Response__c   //pallavi
                                                        from DCp_Arcus_Transactions__c
                                                        where Transaction_Id__c!=null and Pay_at_Funding__c=true 
                                                        and application__c=:applicationId and DCP_Callout_done__c = false];
        
    List<DCp_Arcus_Transactions__c> updatedcpTrans = new List<DCp_Arcus_Transactions__c>(); //pallavi
                                                        
     for(DCp_Arcus_Transactions__c dcpTransaction : dcpTrans) {
                
               // DCPResponse res = DCPIntegration.patchTransactions(dcpTransaction.Transaction_Id__c);                   
                HTTPResponse res = DCPIntegration.patchTransactions(dcpTransaction.Transaction_Id__c);
                System.debug(logginglevel.error, 'AFTER CALLING DCPIntegration :: RES ::' +res );
                dcpTransaction.DCP_Callout_done__c = true;  //pallavi
                if(res.getStatusCode()==200 || res.getStatusCode() == 202)
                    dcpTransaction.DCP_Callout_successful__c = true;
                if(res.getStatusCode()>=400){   //pallavi
                    String failureResposne = 'Status:'+ String.valueOf(res.getStatusCode()) + ' ' + 'Title:'+ res.getStatus() + ' '
                                              + 'Response Body:'+ res.getBody();
                    if(failureResposne.length() <= 255)
                        dcpTransaction.Arcus_Failure_Response__c = failureResposne;
                    else
                        dcpTransaction.Arcus_Failure_Response__c = res.getStatus();
                }
                updatedcpTrans.add(dcpTransaction); //pallavi
            }
            if(updatedcpTrans.size()>0)
                update updatedcpTrans;  //pallavi
    
    }   
    
    
}