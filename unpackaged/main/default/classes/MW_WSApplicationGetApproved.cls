@RestResource(urlMapping='/Application/getFundingApprovedApplications')
global with sharing class MW_WSApplicationGetApproved {

    public class ApprovedApplications {
        public String lead_guid;
        public String firstName;
        public String lastName;
        public String email;
        public String state;
        public Date loan_doc_signed_date;
    }

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
            //List<String> leadIds = new List<String>();
            List<ApprovedApplications> listApprovedApps = new List<ApprovedApplications>();
            if(reqType == 'prelim_origination_package')
            {
                applications = [Select Lead_ID__c, Loan_Doc_Signed_On__c, genesis__Account__r.peer__Last_Name__c, genesis__Account__r.peer__First_Name__c, genesis__Account__r.cnotify__Email__c, genesis__Account__r.State__c
                                From genesis__Applications__c
                                Where Loan_Origination_Date__c = :disbursementDate and genesis__Status__c = 'pre_funding' and Investor__r.loan__Investor__c = TRUE and Investor__r.Investor_Code__c = :investorId];
            }
            else
            {
                applications = [Select Lead_ID__c, Loan_Doc_Signed_On__c, genesis__Account__r.peer__Last_Name__c, genesis__Account__r.peer__First_Name__c, genesis__Account__r.cnotify__Email__c, genesis__Account__r.State__c
                                From genesis__Applications__c
                                Where Loan_Origination_Date__c = :disbursementDate and genesis__Status__c = 'Approved for funding' and Investor__r.loan__Investor__c = TRUE and Investor__r.Investor_Code__c = :investorId];
            }
            for (genesis__Applications__c application : applications) {
                ApprovedApplications newApprovedApp = new ApprovedApplications();
                newApprovedApp.lead_guid = application.Lead_ID__c;
                newApprovedApp.firstName = application.genesis__Account__r.peer__First_Name__c;
                newApprovedApp.lastName = application.genesis__Account__r.peer__Last_Name__c;
                newApprovedApp.email = application.genesis__Account__r.cnotify__Email__c;
                newApprovedApp.state = application.genesis__Account__r.State__c;
                newApprovedApp.loan_doc_signed_date = application.Loan_Doc_Signed_On__c;
                listApprovedApps.add(newApprovedApp);
            }

            System.debug(Blob.valueOf(JSON.serialize(listApprovedApps)));

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(listApprovedApps));
        }
        catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
    }
}