public with Sharing class DocumentReduction{
    public Static void payStubReduction(Id applicationId){
        Boolean reductionFlag = false;
        //added order by createdDate desc
        Credit_Policy__c creditPolicy = [Select Net_Disposable_Income_NDI__c from Credit_Policy__c 
                                         where Application__c = :applicationId order by createdDate desc Limit 1];
        if(null != creditPolicy){
            System.debug('... NDI: ...' + creditPolicy);
            if(creditPolicy.Net_Disposable_Income_NDI__c != null){
                Decimal NDIncome = decimal.valueOf(creditPolicy.Net_Disposable_Income_NDI__c);
                if(NDIncome <= 4000)
                    reductionFlag = true;
            }
        }
        
        System.debug('...reductionFlag...'+ reductionFlag);
    }
}