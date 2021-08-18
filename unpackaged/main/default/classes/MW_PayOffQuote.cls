/* ****************Modification History*****************************************************************
* Modified by      Date         JIRA number  Description
* Mohan Kiran   2021/08/11       LSP-327 	  This class is used by CL_WebhookControlHandler to get Payoff parameters and pass the payoff quote back and save it in salesforce

******************Modification History*****************************************************************/

public with sharing class MW_PayOffQuote {
    class PayoffQuoteWrapper {
        public loan__Payoff_Quote__c payoffQuote { get; set; }
        public String Status { get; set; }
        public String ErrorMessage { get; set; }
    }
    
    public Static String Save(String pLoanName, String pPayOffDate){
        
        //Calling the getPayOffQuote to get the generated quote record  
        
        PayoffQuoteWrapper quoteRecord =  MW_PayOffQuote.Get(pLoanName,pPayOffDate);
        
        
        if(quoteRecord != null && quoteRecord.status == 'Success' && quoteRecord.payoffQuote != null){
          
            try{
                
                
                //Quote record is inserted in salesforce here.
				quoteRecord.payoffQuote.Name = 'MPR' + ' - ' + quoteRecord.payOffQuote.loan__Loan_Account__c + ' - '+pPayOffDate;
                insert quoteRecord.payoffQuote;
                
            }
            catch (Exception e) {
               
                system.debug('There is an error in inserting record in salesforce. The error is --'+e);
                string errorMessage = e.getStackTraceString();
                MW_LogUtility.error('MW_PayOffQuote', null , quoteRecord.payOffQuote.loan__Loan_Account__c , 'Save', e);
                return errorMessage;
            }
        }        
        
        //Serializing and sending the response back
        
        return GetJsonPayoffQuoteWrapper(quoteRecord);
    }
    
    //Here pLoanName = should be valid Loan Id like 'LAI-00000151' and PayOffDate is in yyyy-mm-dd format like '2020-09-14'
    Public Static PayoffQuoteWrapper Get(String pLoanName, String pPayOffDate) {
        
        PayoffQuoteWrapper pqWrapper = new PayoffQuoteWrapper();
        Date payOffDate;
        
        try {
            payOffDate = Date.valueOf(pPayOffDate);
        } catch (TypeException e) {
            pqWrapper.Status = 'Error';
            pqWrapper.ErrorMessage = e.getMessage();
            
            return pqWrapper;
        }
        
        loan__Loan_Account__c[] loanAccts = [SELECT Id, Name FROM loan__Loan_Account__c WHERE Name = :pLoanName LIMIT 1];
        If (loanAccts.size() == 0) {
            pqWrapper.Status = 'Error';
            pqWrapper.ErrorMessage = 'Loan Id not exist';
            
            return pqWrapper;
        }
        
        try {
            // here we need to assing the loan ID for which we want to get the payoff amount.
            Id loanAccId = loanAccts[0].Id;
            
            loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
            Date systemdate = util.getcurrentsystemdate();
            loan__Loan_Account__c loanAccount;
            
            mfiflexUtil.ExecutionContext ec = mfiflexUtil.ExecutionContext.getExecContext();
            mfiflexUtil.ObjectCache loanOC = ec.getObject('LoanAccount');
            if (loanOC != null) {
                ec.deleteObject('LoanAccount');
            }
            
            loanOC = ec.createObject('LoanAccount', 'Loan_Account__c', 'loan');
            loanOC.addFields(loan.ObjectCacheQueryUtil.getLoanSnapshotFields());
            loanOC.addNamedParameter('loanAccId', loanAccId);
            loanOC.setWhereClause('ID = :loanAccId');
            loanOC.setLimitClause('1');
            
            mfiflexUtil.ObjectCache repaymentSchedule = ec.createRelationship('Repayment_Schedule__r')
                .addFields(loan.ObjectCacheQueryUtil.getScheduleFields())
                .setWhereClause('Is_Archived__c = false')
                .setOrderClause('Due_Date__c DESC');
            loanOC.addRelationship(repaymentSchedule);
            
            mfiflexUtil.ObjectCache lpts = ec.createRelationship('Loan_Payment_Transactions__r')
                .addFields(loan.ObjectCacheQueryUtil.getLoanPaymentTxnFields())
                .setWhereClause('Rejected__c = false');
            loanOC.addRelationship(lpts);
            
            mfiflexUtil.ObjectCache charges = ec.createRelationship('Charges__r')
                .addFields(loan.ObjectCacheQueryUtil.getchargesFields());
            loanOC.addRelationship(charges);
            
            mfiflexUtil.ObjectCache bills = ec.createRelationship('Dues_Details__r')
                .addFields(loan.ObjectCacheQueryUtil.getDueDetailsFields())
                .addNamedParameter('systemDate', systemDate)
                .setWhereClause('DD_Primary_Flag__c = true AND Due_Date__c >= :systemDate')
                .setOrderClause('Due_Date__c ASC ');
            loanOC.addRelationship(bills);
            loanOC.buildQuery();
            loanOC.executeQuery();
            
            
            if (loanOC.getRecords().size() > 0) {
                loanAccount = (loan__Loan_Account__c) loanOC.getRecords().get(0);
            }
            
            
            
            loan__Payoff_Quote__c payOffQuote = new loan__Payoff_Quote__c();
            
            
            
            loan__Other_Transaction__c txn = new loan__Other_Transaction__c();
            txn.loan__Pay_Off_Date__c = payOffDate;
            
            // method to get the Payoff quote Txn. You can read the field values from payOffQuote.
            loan.PayoffQuote payoff = new loan.PayoffQuote();
            payOffQuote = payoff.postPayoffquote(loanAccount, txn);
            
            System.debug(logginglevel.error, 'payOffQuote :: ' + payOffQuote);
            
            
            pqWrapper.payoffQuote = payOffQuote;
            pqWrapper.Status = 'Success';
            
            //return GetJsonPayoffQuoteWrapper(pqWrapper);
            
            return pqWrapper;
            
        } catch (TypeException e) {
            pqWrapper.Status = 'Error';
            pqWrapper.ErrorMessage = e.getMessage();
            
            return pqWrapper;
        }
    }
    
    
    
    Static String GetJsonPayoffQuoteWrapper(PayoffQuoteWrapper pqWrapper)
    {
        System.debug('pqWrapper=' + pqWrapper);
        String jsonPayoffQuoteWrapper = JSON.serialize(pqWrapper);
        System.debug('jsonPayoffQuoteWrapper=' + jsonPayoffQuoteWrapper);
        return jsonPayoffQuoteWrapper;
    }
}