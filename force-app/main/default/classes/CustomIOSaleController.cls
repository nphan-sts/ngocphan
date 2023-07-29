public class CustomIOSaleController {

    public loan__Investor_Loan__c ioForSale {get; set;}
    public loan__Investor_Loan__c newIO {get; set;}
    
    public loan__Investor_Loan_Account_Txns__c txn {get; set;}
    
    public Date sysDate {get; set;}
    
    public boolean success {get; set;}
    public Decimal salePrice {get; set;}
    public boolean isPreview {get; set;}
    public Decimal numberOfSharesSold;

    public CustomIOSaleController(ApexPages.StandardController controller) {
        ioForSale = (loan__Investor_Loan__c) controller.getRecord();
        ioForSale = [SELECT Id, 
                            Name,
                            loan__Certificate_Rate__c,
                            loan__Service_Rate__c,
                            loan__Account__c,
                            loan__Loan__c,
                            loan__Share__c,
                            loan__Status__c,
                            peer__Number_Of_Shares__c,
                            loan__Enabled_Flag__c,
                            loan__Inv_Accrued_Interest_Amt__c, 
                            loan__Remaining_Investment_Amount__c
                            FROM loan__Investor_Loan__c WHERE Id = :ioForSale.Id LIMIT 1];
        sysDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        
        newIO = new loan__Investor_Loan__c();
        txn = new loan__Investor_Loan_Account_Txns__c();
        txn.loan__Transaction_Date__c = sysDate;
        isPreview = false;
    }

    public PageReference preview() {
        
        try {
            
            //txn.peer__Sale_Price_Per_Share__c = salePrice/ioForSale.peer__Number_Of_Shares__c;          
            numberOfSharesSold = ioForSale.peer__Number_Of_Shares__c *(salePrice/100);
            system.debug(logginglevel.error,'numberOfSharesSold '+numberOfSharesSold );
            
            // harcoded the Proce per share = 1.
            txn.peer__Sale_Price_Per_Share__c = 1;
            isPreview = True;
            Account  buyer = [Select id,
                                name,
                                loan__Undeployed_Funds__c
                                from Account where id =:newIO.loan__Account__c];
            
            if (buyer.loan__Undeployed_Funds__c < (ioForSale.loan__Inv_Accrued_Interest_Amt__c + ioForSale.loan__Remaining_Investment_Amount__c)){
                isPreview = false;
                success = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Sorry !! Insufficient funds'));
            }
                         
        } catch (Exception e) {
            success = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Unexcepted error occured - ' + e.getMessage() + ' - ' + e.getLineNumber()));
        }
        
        return null;
    }
    
    public PageReference executeSale() {
        
        if(isPreview){
            
            peer.InvestorAPI7 api = peer.FractionalizationAPIFactory.getInvestorAPI7();  
            
            try {
                
                List<peer__Investment_Order_Sale_Transaction__c> invSaleTxnList = new List<peer__Investment_Order_Sale_Transaction__c>();
                                   
                peer__Investment_Order_Sale_Transaction__c saleTxn = new peer__Investment_Order_Sale_Transaction__c();
                saleTxn.peer__Buyer__c = newIO.loan__Account__c;
                saleTxn.peer__Number_Of_Shares__c = numberOfSharesSold;
                saleTxn.peer__Price_Per_Share__c = 1;
                saleTxn.peer__Transfer_Income__c = true;
                saleTxn.peer__Add_Income_in_Price__c = true;
                invSaleTxnList.add(saleTxn);
                                    
                api.sellInvestmentOrder(ioForSale.Id,invSaleTxnList, true);
                success = true;
                                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Transaction Successful.'));
                
                
            } catch (Exception e) {
                success = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Unexcepted error occured - ' + e.getMessage() + ' - ' + e.getLineNumber()));
            }
            
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Preview sale details before executing sale.'));
        }
        
        return null;
    }
    

}