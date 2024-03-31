/* ****************Modification History******************
 * Modified by      Date            JIRA number
 *     Pallavi      2019/12/13    LOS-185/186 auto sale in bulk
 ******************Modification History******************/
global class AutoSale implements Database.batchable<sObject>,Schedulable{
            
    String query;
    String Status = 'Active';
    
    public loan__Investor_Loan__c ioForSale;
    Date CurrentSystemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
    loan__Investor_Loan__c newIO = new loan__Investor_Loan__c();
    loan__Investor_Loan_Account_Txns__c txn = new loan__Investor_Loan_Account_Txns__c();

    global AutoSale (){
        query = 'select id,name,loan__Certificate_Rate__c,Buyer__c,loan__Account__r.no_of_shares_to_be_Sold__c,loan__Service_Rate__c,loan__Account__c,loan__Loan__c,loan__Loan__r.Investor_Account__c,loan__Share__c,loan__Status__c, '+
                ' peer__Number_Of_Shares__c,loan__Enabled_Flag__c,loan__Inv_Accrued_Interest_Amt__c, loan__Remaining_Investment_Amount__c from loan__Investor_Loan__c where Buyer__c != null and loan__Loan__r.Effective_Date_for_AutoSale__c =: CurrentSystemDate '+   //(LOS-185/186)                   
                ' and loan__Status__c =\''+String.escapeSingleQuotes(Status)+'\'';
        
        System.debug(logginglevel.error,'query+++'+query);      //(Auto_Sale_Date__c =: CurrentSystemDate) HM does not use this anymore
                
    }
    
    global AutoSale (String query){
        
        this.query = query; 
    }
    
    global void execute(SchedulableContext sc) {
        
        AutoSale b = new AutoSale ();
        Database.executeBatch(b,1);
    
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
                              
        System.debug('Query'+query);    
        return Database.getQueryLocator(query);
    
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        System.debug('----Method execute(+)scope----'+ scope);
        List<loan__Investor_Loan__c> listOfIOs = (List<loan__Investor_Loan__c>)scope;
        ioForSale = listOfIOs[0];
        
        /* LOS-185/186*/
        Set<id> contractID = new Set<id>();
        for(loan__Investor_Loan__c IO : listOfIOs)
            contractID.add(IO.loan__Loan__c);
        
        List<loan__loan_account__c> loan = [Select id,Investor_Account__c from loan__loan_account__c where id in: contractID];
        Map<id,loan__loan_account__c> maploan = new Map<id,loan__loan_account__c>();
        for(loan__loan_account__c loans : loan)
            maploan.put(loans.id,loans);
        
        
        
        Map<id,loan__loan_account__c> MaptoUpdate = new Map<id,loan__loan_account__c>();
        List<loan__loan_account__c> toUpdate = new List<loan__loan_account__c>();
        
        Set<Id> apsID = new Set<Id>();
        
        loan__Automated_Payment_Configuration__c apc = [Select id,loan__Payment_Mode__c FROM loan__Automated_Payment_Configuration__c where
                                                       loan__Bank_Account__r.loan__Account__c =: ioForSale.Buyer__c LIMIT 1];
        
        Id paymentMode = apc.loan__Payment_Mode__c;
        
        /* LOS-185/186*/
        
        List<peer__Investment_Order_Sale_Transaction__c> invSaleTxnList = new List<peer__Investment_Order_Sale_Transaction__c>();
        txn.loan__Transaction_Date__c = CurrentSystemDate ;
                
        for(loan__Investor_Loan__c IOs : listOfIOs){
            
            peer.InvestorAPI7 api = peer.FractionalizationAPIFactory.getInvestorAPI7();                                          
            peer__Investment_Order_Sale_Transaction__c saleTxn = new peer__Investment_Order_Sale_Transaction__c();
            saleTxn.peer__Buyer__c = ioForSale.Buyer__c;
            saleTxn.peer__Number_Of_Shares__c = ioForSale.peer__Number_Of_Shares__c *(ioForSale.loan__Account__r.no_of_shares_to_be_Sold__c/100);
            saleTxn.peer__Price_Per_Share__c = 1;
            saleTxn.peer__Transfer_Income__c = True;
            saleTxn.peer__Add_Income_in_Price__c = False;
            invSaleTxnList.add(saleTxn);
            
            try{
            if(!test.isRunningTest())                    
            api.sellInvestmentOrder(ioForSale.Id,invSaleTxnList, true); 
            }
            catch(Exception ex){    // LOS-185/186
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'AutoSale' ;
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
            
            //throw ex;
            }   
            
            /* LOS-185/186*/
            loan__loan_account__c contract = maploan.get(IOs.loan__Loan__c);
            loan__loan_account__c updatedContract = new loan__loan_account__c();
            updatedContract = contract;
            updatedContract.Investor_Account__c = ioForSale.Buyer__c;
            
            toUpdate.add(updatedContract);
            apsID.add(updatedContract.id);
            
        }
        List<loan__Automated_Payment_Setup__c> aps = [select id,loan__Payment_Mode__c from loan__Automated_Payment_Setup__c where
                                                     loan__CL_Contract__c in: apsId];
        
        List<loan__Automated_Payment_Setup__c> toUpdateAPS = new List<loan__Automated_Payment_Setup__c>();
        
        for(loan__Automated_Payment_Setup__c aps1 :aps){
            aps1.loan__Payment_Mode__c = paymentMode;
            toUpdateAPS.add(aps1);
        }
        if(toUpdate.size()>0 && !toUpdate.isEmpty())
            Database.update(toUpdate);
        if(toUpdateAPS.size()>0 && !toUpdateAPS.isEmpty())
            update toUpdateAPS;
        /* LOS-185/186*/
        
    } 
    
    public void finish(Database.BatchableContext BC){

    }
    
}