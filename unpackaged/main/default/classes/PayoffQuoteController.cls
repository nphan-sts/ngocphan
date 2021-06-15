/* ****************Modification History******************
 * Created By        Date          JIRA number
 *1. Pallavi        2020/01/29     LOS-242(Generate CL Loan Payoff Quote PDF Document)
 *2. Neha           2020/07/23     LOS-763(Unable to generate Pay off quote Document)
 ******************Modification History******************/
 
public class PayoffQuoteController {
    
    public loan__Payoff_Quote__c PayoffQuoteRec{get;set;}
    public loan__loan_account__c contractRec{get;set;}
    public loan__Investor_Loan__c investorDetails{get;set;}
    
    public PayoffQuoteController(){
        System.debug('------------PayoffQuoteController------------');
        
        Id payoffQuoteId = ApexPages.currentPage().getParameters().get('Id');
        System.debug('payoffQuoteId----' + payoffQuoteId);
        
        if(payoffQuoteId != null){
            PayoffQuoteRec = [Select id,name,loan__Loan_Account__r.lead_Guid__c,loan__Poq_Interest_Per_Diem__c,loan__Poq_Total_Payoff_Amount__c,loan__Poq_valid_till_Dt__c,
                              loan__Loan_Account__r.id,loan__Poq_Principal_Bal__c,loan__Poq_Unpaid_Interest__c,loan__Interest_Posted__c, loan__Loan_Account__r.Payoff_Loan_ID__c 
                              from loan__Payoff_Quote__c where id =: payoffQuoteId];
            
            contractRec = [Select id,name,loan__Account__r.name from loan__loan_account__c where id =: PayoffQuoteRec.loan__Loan_Account__r.id];
            
            //CRM-514 - Retrieving Investor Billing and Shipping address of the investor for the contract
            //CRM-763 added clause to filter only Active IO
            investorDetails = [select id,name,loan__Account__r.Billingstreet,loan__Account__r.BillingCity, loan__Account__r.BillingState,loan__Account__r.BillingPostalCode,loan__Account__r.BillingCountry,
                           loan__Account__r.Shippingstreet,loan__Account__r.ShippingCity, loan__Account__r.ShippingState,loan__Account__r.ShippingPostalCode,loan__Account__r.ShippingCountry from loan__Investor_Loan__c 
                           where loan__loan__r.id =: PayoffQuoteRec.loan__Loan_Account__r.id and loan__Status__c = 'Active'];
        }
    }

}