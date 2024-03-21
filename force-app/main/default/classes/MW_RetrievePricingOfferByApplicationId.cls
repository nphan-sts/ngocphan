@RestResource(urlMapping='/pricing-offer/application-id/*')

global with sharing class MW_RetrievePricingOfferByApplicationId {
    @HttpGet
    global static void MW_RetrievePricingOfferByApplicationId() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            
            String applicationId = req.params.get('application-id');
            if (String.isBlank(applicationId)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('application id is required');
                return;
            }
            List<Pricing_Offer__c> pricingOffers = [
                SELECT
                Id,
                Name,
                CreatedDate,
                CreatedById,
                LastModifiedDate,
                LastModifiedById,
                Application__c,
                APR__c,
                Above_prime_max__c,
                Active__c,
                Amount__c,
                Interest_Rate__c,
                IntRate_Words__c,
                Is_Offer_Selected__c,
                Key__c,
                Loan_Premium_Amount__c,
                Loan_Premium_Price__c,
                Monthly_Payment__c,
                Origination_fee__c,
                Origination_fee_rate__c,
                Pricing_Tier__c,
                Segment__c,
                Term__c,
                Type__c,
                InvestorCodeOnApp__c,
                LoanPremiumPrice__c,
                Loan_Premium_Price_ACU__c,
                Loan_Premium_Price_FTCU_TCU__c,
                OriginationDateOnApp__c,
                Total_of_Payments_TIL__c,
                Loan_Premium_Price_TFCU__c,
                DM_External_Id__c,
                Loan_Premium_Price_GSCU__c,
                Loan_Premium_Price_USAFCU__c,
                DataArchiva_Old_Id__c,
                DataArchiva_Read_Only_Data__c,
                EBP_Offer_Code__c,
                Loan_Premium_Price_BFCU__c,
                Loan_Premium_Price_CRB_Theorem_Main__c,
                Loan_Premium_Price_CRB_Theorem_Prime__c,
                Loan_Premium_Price_GSCU_PART__c,
                Loan_Premium_Price_ITB_CRB_Theorem_Main__c,
                Loan_Premium_Price_ITB_CRB_Theorem_Prime__c,
                Loan_Premium_Price_OTB_CRB_Theorem_Main__c,
                Loan_Premium_Price_OTB_CRB_Theorem_Prime__c,
                Loan_Premium_Price_VCU__c
                FROM Pricing_Offer__c 
                WHERE Application__c = :applicationId
            ];
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(pricingOffers));
        }
        catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
    }
}