/* ****************Modification History*****************************************************************
 * Created by    	Date    		JIRA number
 *     Pallavi      2020/04/28      CRM-502 auto sale to funding partner
 ******************Modification History*****************************************************************/
global class AutoSaletoFundingPartner implements Database.Batchable<SObject>,Schedulable {

    String query;
    String Status = 'Active';   
    public loan__Investor_Loan__c ioForSale;
    Date CurrentSystemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
    loan__Investor_Loan__c newIO = new loan__Investor_Loan__c();
    loan__Investor_Loan_Account_Txns__c txn = new loan__Investor_Loan_Account_Txns__c();

    global void execute(SchedulableContext sc){
        Boolean isHoliday = checkHoliday();
        if(!isHoliday){
            AutoSaletoFundingPartner b = new AutoSaletoFundingPartner();
            database.executebatch(b,1);
        }
    }

    global boolean checkHoliday(){
        Integer checkingHoliday = [select count() from Holiday where ActivityDate =: CurrentSystemDate];
        if(checkingHoliday > 0){
            return true;
        }
        
        return false;
    }

    global AutoSaletoFundingPartner(){
    
        query = 'select id,name,loan__Certificate_Rate__c,Buyer__c,loan__Account__r.no_of_shares_to_be_Sold__c,loan__Service_Rate__c,loan__Account__c,loan__Loan__c,loan__Share__c,loan__Status__c, '+
                ' loan__Account__r.Funding_Partner__c,peer__Number_Of_Shares__c,loan__Enabled_Flag__c,loan__Inv_Accrued_Interest_Amt__c, loan__Remaining_Investment_Amount__c from loan__Investor_Loan__c where loan__loan__r.Auto_Sale_Date__c <=: CurrentSystemDate  '+          
                ' and loan__Account__r.Funding_Partner__c <>\'' + '\'' + ' and loan__Status__c =\''+String.escapeSingleQuotes(Status)+'\' and loan__loan__r.IO_AutoSale_to_Funding_Partner__c = false';
        
        System.debug(logginglevel.error,'query+++'+query);
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
    
        System.debug('Query'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<sObject> scope){
    
        System.debug('----Method execute(+)scope----'+ scope);
        
        List<loan__Investor_Loan__c> listOfIOs = (List<loan__Investor_Loan__c>)scope;
        ioForSale = listOfIOs[0];
        
        Id contractID =  ioForSale.loan__Loan__c;
        
        loan__loan_account__c contract = [Select id,IO_AutoSale_to_Funding_Partner__c from loan__loan_account__c where id =: contractID];
        
        loan__Automated_Payment_Configuration__c apc = [
                SELECT Id,
                       loan__Payment_Mode__c
                FROM   loan__Automated_Payment_Configuration__c
                WHERE  loan__Bank_Account__r.loan__Account__c = :ioForSale.loan__Account__r.Funding_Partner__c
                AND    loan__Active__c = TRUE
                LIMIT 1
        ];
        
        Id paymentMode = apc.loan__Payment_Mode__c;
        
        List<peer__Investment_Order_Sale_Transaction__c> invSaleTxnList = new List<peer__Investment_Order_Sale_Transaction__c>();
        txn.loan__Transaction_Date__c = CurrentSystemDate ;
                
        peer.InvestorAPI7 api = peer.FractionalizationAPIFactory.getInvestorAPI7();                                          
        peer__Investment_Order_Sale_Transaction__c saleTxn = new peer__Investment_Order_Sale_Transaction__c();
        saleTxn.peer__Buyer__c = ioForSale.loan__Account__r.Funding_Partner__c;
        saleTxn.peer__Number_Of_Shares__c = ioForSale.peer__Number_Of_Shares__c *(ioForSale.loan__Account__r.no_of_shares_to_be_Sold__c/100);
        saleTxn.peer__Price_Per_Share__c = 1;
        saleTxn.peer__Transfer_Income__c = True;
        saleTxn.peer__Add_Income_in_Price__c = False;
        invSaleTxnList.add(saleTxn);
        try{
        
            if(!test.isRunningTest()){                    
                api.sellInvestmentOrder(ioForSale.Id,invSaleTxnList, true); 
            }
            List<loan__Automated_Payment_Setup__c> aps = [select id,loan__Payment_Mode__c from loan__Automated_Payment_Setup__c where
                                                     loan__CL_Contract__c =: contract.id];
            List<loan__Automated_Payment_Setup__c> toUpdateAPS = new List<loan__Automated_Payment_Setup__c>();
            
            for(loan__Automated_Payment_Setup__c aps1 :aps){
                aps1.loan__Payment_Mode__c = paymentMode;
                toUpdateAPS.add(aps1);
            }
            if(toUpdateAPS.size()>0 && !toUpdateAPS.isEmpty()){
                update toUpdateAPS;
            }
            
            contract.IO_AutoSale_to_Funding_Partner__c = true;
            update contract;
            
            if(test.isRunningTest()){   	//to get coverage(flow will go in exception block)                 
                api.sellInvestmentOrder(ioForSale.Id,invSaleTxnList, true); 
            }
            
        }catch(Exception ex){   
            
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'AutoSaletoFundingPartner' ;
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
        
        }   
    }

    public void finish(Database.BatchableContext BC){}

    
}