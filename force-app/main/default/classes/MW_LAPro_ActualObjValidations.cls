public class MW_LAPro_ActualObjValidations {

    public static List<DM_Error_On_Staging__c> getActualObjValidationErrors(List<dm_Loan_Account__c> contractList){
        set<Id> appIdSet = new set<Id>();
        for(DM_Loan_Account__c contractLoans : contractList){
            appIdSet.add(contractLoans.DM_Application__c);
        }
        List<DM_Error_On_Staging__c> error = new List<DM_Error_On_Staging__c>();
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        
        for(genesis__Applications__c app : [ SELECT Id, Lead_ID__c, genesis__Account__c, Investor__c, genesis__Loan_Amount__c,Application_external_id__c,custom_APR_for_not_rounding__c,
                                            (SELECT Id,LoanPremiumPrice__c,Pricing_Tier__c,Loan_Premium_Amount__c,Is_Offer_Selected__c,DM_External_Id__c FROM Pricing_Offer__r WHERE Is_Offer_Selected__c = true),
                                            (SELECT Id,DM_External_Id__c FROM Credit_Policy__r)
                                            FROM genesis__Applications__c WHERE Id IN : appIdSet]){
        
            if(String.isBlank(app.Lead_ID__c)){
                DM_Error_On_Staging__c err = new DM_Error_On_Staging__c();
                err.DM_object_name__c = 'genesis__Applications__c';
                err.DM_obj_and_Field_Name__c = 'Lead_ID__c';
                error.add(err);
            }
            if(app.genesis__Account__c == null){
                DM_Error_On_Staging__c err = new DM_Error_On_Staging__c();
                err.DM_object_name__c = 'genesis__Applications__c';
                err.DM_obj_and_Field_Name__c = 'genesis__Account__c';
                error.add(err);
            }
            if(app.Investor__c == null){
                DM_Error_On_Staging__c err = new DM_Error_On_Staging__c();
                err.DM_object_name__c = 'genesis__Applications__c';
                err.DM_obj_and_Field_Name__c = 'Investor__c';
                error.add(err);
            }
            if(app.genesis__Loan_Amount__c == null){
                DM_Error_On_Staging__c err = new DM_Error_On_Staging__c();
                err.DM_object_name__c = 'genesis__Applications__c';
                err.DM_obj_and_Field_Name__c = 'genesis__Loan_Amount__c';
                error.add(err);
            }
            if(String.isBlank(app.Application_external_id__c)){
                DM_Error_On_Staging__c err = new DM_Error_On_Staging__c();
                err.DM_object_name__c = 'genesis__Applications__c';
                err.DM_obj_and_Field_Name__c = 'Application_external_id__c';
                error.add(err);
            }
            if(app.custom_APR_for_not_rounding__c == null || app.custom_APR_for_not_rounding__c == 0){
                DM_Error_On_Staging__c err = new DM_Error_On_Staging__c();
                err.DM_object_name__c = 'genesis__Applications__c';
                err.DM_obj_and_Field_Name__c = 'custom_APR_for_not_rounding__c';
                error.add(err);
            }
            if(app.Pricing_Offer__r.size() == 0){
                DM_Error_On_Staging__c err = new DM_Error_On_Staging__c();
                err.DM_object_name__c = 'genesis__Applications__c';
                err.DM_obj_and_Field_Name__c = 'Pricing_Offer__r';
                error.add(err);
            }
            else if(app.Pricing_Offer__r.size() > 0){
                if(app.Pricing_Offer__r[0].Loan_Premium_Amount__c == null){
                    DM_Error_On_Staging__c err = new DM_Error_On_Staging__c();
                    err.DM_object_name__c = 'Pricing_Offer__c';
                    err.DM_obj_and_Field_Name__c = 'Loan_Premium_Amount__c';
                    error.add(err);
                }
                if(String.isBlank(app.Pricing_Offer__r[0].Pricing_Tier__c)){
                    DM_Error_On_Staging__c err = new DM_Error_On_Staging__c();
                    err.DM_object_name__c = 'Pricing_Offer__c';
                    err.DM_obj_and_Field_Name__c = 'Pricing_Tier__c';
                    error.add(err);
                }
                if(app.Pricing_Offer__r[0].LoanPremiumPrice__c == null){
                    DM_Error_On_Staging__c err = new DM_Error_On_Staging__c();
                    err.DM_object_name__c = 'Pricing_Offer__c';
                    err.DM_obj_and_Field_Name__c = 'LoanPremiumPrice__c';
                    error.add(err);
                }
                if(String.isBlank(app.Pricing_Offer__r[0].DM_External_Id__c)){
                    DM_Error_On_Staging__c err = new DM_Error_On_Staging__c();
                    err.DM_object_name__c = 'Pricing_Offer__c';
                    err.DM_obj_and_Field_Name__c = 'DM_External_Id__c';
                    error.add(err);
                }
            }
            if(app.Credit_Policy__r.size() == 0){
                DM_Error_On_Staging__c err = new DM_Error_On_Staging__c();
                err.DM_object_name__c = 'genesis__Applications__c';
                err.DM_obj_and_Field_Name__c = 'Credit_Policy__r';
                error.add(err);
            }else if(app.Credit_Policy__r.size() > 0){
                if(String.isBlank(app.Credit_Policy__r[0].DM_External_Id__c)){
                    DM_Error_On_Staging__c err = new DM_Error_On_Staging__c();
                    err.DM_object_name__c = 'Credit_Policy__c';
                    err.DM_obj_and_Field_Name__c = 'DM_External_Id__c';
                    error.add(err);
                }
            }
        }
        system.debug('error=========>>>'+error);
        return error;
    }
}