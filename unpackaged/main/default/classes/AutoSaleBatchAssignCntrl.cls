/* ****************Modification History******************
 * Created by    	Date    	JIRA number
 *     Pallavi      2019/12/13    LOS-185/186 auto sale in bulk
 ******************Modification History******************/
public with sharing class AutoSaleBatchAssignCntrl {
    
    public loan__Loan_Account__c contract {get;set;}
    public List<loan__Loan_Account__c> eligibleLoan{get;set;}
    public ApexPages.StandardSetController standardController;
    public List<loan__Investor_Loan__c> InvestmentOrder = new List<loan__Investor_Loan__c>();
    public List<loan__Loan_Account__c> SelectedContracts = new List<loan__Loan_Account__c>();
    public List<loan__Loan_Account__c> getSelectedContracts = new List<loan__Loan_Account__c>();
    public Boolean btnEnabled { get; set; }
    
    public AutoSaleBatchAssignCntrl(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
        eligibleLoan = new List<loan__Loan_Account__c>();
        contract = (loan__Loan_Account__c) standardController.getRecord();
    }
    public PageReference saveBuyerandDate(){
        btnEnabled = false;
        System.debug('saveBuyerandDate');
        getSelectedContracts = (List<loan__Loan_Account__c>) standardController.getSelected();
        SelectedContracts = [Select id,Buyer__c,Effective_Date_for_AutoSale__c
                                                         from loan__Loan_Account__c where id in: getSelectedContracts];
        
        /*try{
            for(loan__Loan_Account__c loan : SelectedContracts){
                
                loan.Buyer__c = contract.Buyer__c;
                loan.Effective_Date_for_AutoSale__c = contract.Effective_Date_for_AutoSale__c;
                eligibleLoan.add(loan);
            }
                    
        System.debug('-----IO-----' + IO);
        for(loan__Investor_Loan__c inv : IO){
            System.debug('-----IO is not empty-----');
            System.debug('----contract.Buyer__c----' + contract.Buyer__c);
            inv.buyer__c = contract.Buyer__c;
            System.debug('----- inv.buyer__c-----' + inv.buyer__c);
            InvestmentOrder.add(inv);
        }
        }

        catch(Exception e){
            System.debug('Exception'+ e.getMessage());
            throw new ints.IntegrationException('No input from user.');
        }*/
        return null;
        
    }
    public PageReference updateBuyerandDate(){
        
        if(eligibleLoan.size()>0 && !eligibleLoan.isEmpty()){
            update eligibleLoan;
        }
        
        List<loan__Investor_Loan__c> IO = [Select id,name,Buyer__c,loan__Loan__c from loan__Investor_Loan__c where loan__Loan__c in: getSelectedContracts];
        
        for(loan__Investor_Loan__c inv : IO){
            System.debug('-----IO is not empty-----');
            System.debug('----contract.Buyer__c----' + contract.Buyer__c);
            inv.buyer__c = contract.Buyer__c;
            System.debug('----- inv.buyer__c-----' + inv.buyer__c);
            InvestmentOrder.add(inv);
        }

        
        System.debug('---------InvestmentOrder---------' + InvestmentOrder);
        
        if(InvestmentOrder.size()>0 && !InvestmentOrder.isEmpty()){
            update InvestmentOrder;
        }
        
       	return standardController.save(); 
    }
    public PageReference validateBuyerandDate(){
        btnEnabled = false;
        if(contract.Buyer__c == null){
            ApexPages.Message test =  new ApexPages.Message(ApexPages.severity.ERROR,'Buyer is null');
            ApexPages.addMessage(test);
            return null;
        }
        else if(contract.Effective_Date_for_AutoSale__c == null){
            ApexPages.Message test =  new ApexPages.Message(ApexPages.severity.ERROR,'Effective Date is null');
            ApexPages.addMessage(test);
            return null;
        }
        
        Account investor = [Select id,loan__Investor__c from account where id =: contract.Buyer__c];
        if(!investor.loan__Investor__c){
            ApexPages.Message test =  new ApexPages.Message(ApexPages.severity.ERROR,'Buyer should be an Investor');
            ApexPages.addMessage(test);
            return null;
        }
        
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date systemDate = util.getCurrentSystemDate();
        
        if(contract.Effective_Date_for_AutoSale__c <= systemDate){
           ApexPages.Message test =  new ApexPages.Message(ApexPages.severity.ERROR,'Effective date should be a future date');
           ApexPages.addMessage(test);
           return null; 
        }
        ApexPages.Message test =  new ApexPages.Message(ApexPages.severity.INFO,'Validation Successful');
        ApexPages.addMessage(test);
        btnEnabled = true;
        return null;
    }
    public PageReference onChangeBuyer(){
       btnEnabled = false;
       return null; 
    }
}