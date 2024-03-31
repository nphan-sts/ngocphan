@RestResource(urlMapping='/Application/getApproved')
global with sharing class WSApplicationGetApproved {

    @HttpGet
    global static void getApproved() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            String reqType = req.params.get('request_type');

            String originationDate = req.params.get('origination_date');
            system.debug('////'+originationDate);
            if (String.isBlank(originationDate)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('origination_date is required');
                return;
            }
            String investorId = req.params.get('investor_id');
            if (String.isBlank(investorId)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('investor_id is required');
                return;
            }
            investorId = investorId.toUpperCase();
            Date disbursementDate = Date.valueOf(originationDate);
            List<genesis__Applications__c> applications = new List<genesis__Applications__c>();
            List<String> leadIds = new List<String>();
            
            if(reqType == 'prelim_origination_package')
            {
                    applications = [select Lead_ID__c from genesis__Applications__c where
                    Loan_Origination_Date__c = :disbursementDate and genesis__Status__c = 'pre_funding'
                    and Investor__r.loan__Investor__c = TRUE and Investor__r.Investor_Code__c = :investorId];
            }
            else
            {
                    applications = [select Lead_ID__c from genesis__Applications__c where
                    Loan_Origination_Date__c = :disbursementDate and genesis__Status__c = 'Approved for funding'
                    and Investor__r.loan__Investor__c = TRUE and Investor__r.Investor_Code__c = :investorId];
            }
            for (genesis__Applications__c application : applications)
               leadIds.add(application.Lead_ID__c);

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(leadIds));

        }
        catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
    }
}