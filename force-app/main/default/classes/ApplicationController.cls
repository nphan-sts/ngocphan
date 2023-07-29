public class ApplicationController{
    public genesis__Applications__c applicationRec{get;set;}
    public genesis__Amortization_Schedule__c AmzRec{get;set;}
    public genesis__Amortization_Schedule__c AmzRec1{get;set;}
    public Decimal apr_strInt{get;set;}
    public List<DCp_Arcus_Transactions__c> dcpArcusTransaction{get;set;}    //CLS-1189   
    public applicationController(){
        
        Id appId = ApexPages.currentPage().getParameters().get('Id');
      
        if(null != appId)
        {
            applicationRec = [SELECT genesis__Interest_Rate__c,genesis__Payment_Amount__c,genesis__APR__c,Investor__c, 
                            genesis__Total_Estimated_Interest__c,genesis__Loan_Amount__c,
                            Total_of_Payments__c,genesis__Account__c,//genesis__Account__r.Borrower_s_First_Name__c,
                            //genesis__Account__r.Borrower_s_Last_Name__c,
                            genesis__Account__r.Name,
                            genesis__Account__r.City__c,
                            genesis__Account__r.State__c,genesis__Account__r.ZIP_Code__c, genesis__Account__r.Address_1__c,genesis__Account__r.Address_2__c,
                            Investor__r.Name,Investor__r.City__c,Investor__r.ZIP_Code__c, Investor__r.Address_1__c, Investor__r.State__c,
                            Loan_Term_sub_1__c, Last_Payment_Amount__c,genesis__Financed_Amount__c,
                            genesis__Term__c, Origination_fee__c, Initial_Term_Payment_Amt__c, DCP_total_amount__c,
                                (select Monthly_Payment__c,Total_of_Payments_TIL__c from Pricing_Offer__r where Is_Offer_Selected__c=true)//pallavi
                            FROM genesis__Applications__c where Id =: appId];
            AmzRec1 = [SELECT id,genesis__Due_Date__c, genesis__Total_Due_Amount__c 
                      FROM genesis__Amortization_Schedule__c WHERE genesis__Application__c =: appId ORDER BY genesis__Due_Date__c LIMIT 1];
            AmzRec = [SELECT id,genesis__Due_Date__c, genesis__Total_Due_Amount__c 
                      FROM genesis__Amortization_Schedule__c WHERE genesis__Application__c =: appId ORDER BY genesis__Due_Date__c DESC LIMIT 1];
            dcpArcusTransaction = [SELECT id,Bank_Name__c, Paid_Amount__c,Requested_Amount__c
                                  FROM DCp_Arcus_Transactions__c WHERE Application__c =: appId and Pay_at_Funding__c = true];       //CLS-1189

            String apr_str = String.valueOF(applicationRec.genesis__APR__c);
             if(apr_str.length() > 5 ) apr_str = apr_str.substring(0, 5);      
              apr_strInt = Decimal.valueOF(apr_str )  ;   
            
                      
           //if(applicationRec.genesis__APR__c != null)
               //applicationRec.genesis__APR__c = applicationRec.genesis__APR__c.setScale(3);
            //if(applicationRec.Pricing_offer__r.Monthly_Payment__c != null)
               //offer.Monthly_Payment__c = offer.Monthly_Payment__c.setScale(2);
           //if(applicationRec.Initial_Term_Payment_Amt__c!= null)
           //    applicationRec.Initial_Term_Payment_Amt__c= applicationRec.Initial_Term_Payment_Amt__c.setScale(2); 
           //if(applicationRec.Last_Payment_Amount__c!= null)
           //    applicationRec.Last_Payment_Amount__c= applicationRec.Last_Payment_Amount__c.setScale(2); 
           
             if(applicationRec.Origination_fee__c!= null)
               applicationRec.Origination_fee__c= applicationRec.Origination_fee__c.setScale(2);
             
        }
    }
}