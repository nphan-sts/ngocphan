public with sharing class CreditPolicyController {

    public List<Credit_Policy__c> creditPolicyRec { get; set; }
    public Decimal fico {get;set;}
    public CreditPolicyController(){   
        Id appId = ApexPages.currentPage().getParameters().get('Id'); 
        if(appId != null){  
            creditPolicyRec = [select FICO__C from Credit_Policy__c  where Application__c= : appId 
                and request_intent__c = 'application' 
                order by lastmodifieddate desc Limit 1];      
            
            if(creditPolicyRec!=null && !creditPolicyRec.isEmpty() && creditPolicyRec[0].FICO__C!=null) {               
                creditPolicyRec[0].FICO__C = creditPolicyRec[0].FICO__C.setScale(0);
                fico = creditPolicyRec[0].FICO__C.setScale(0);
            } else {
                fico = null;
            }
            
        }                
    }
}