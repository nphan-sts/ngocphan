@RestResource(urlMapping='/employment-information/application-id/*')
global with sharing class MW_RetrieveEmpInfobyAppId {
    @HttpGet
    global static void MW_RetrieveEmpInfobyAppId() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            String contractId = req.params.get('application-id');
            if (String.isBlank(contractId)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('application id is required');
                return;
            }
            List<genesis__Employment_Information__c> empInfos = [
                SELECT
                Id,
                OwnerId,
                Name,
                CreatedDate,
                CreatedById,
                LastModifiedDate,
                LastModifiedById,
                genesis__Application__c,
                genesis__Contact__c,
                genesis__Employer_City__c,
                genesis__Employer_Country__c,
                genesis__Employer_State__c,
                genesis__Employer_Street__c,
                genesis__Employer_Zipcode__c,
                genesis__Name_of_employer__c,
                genesis__Number_of_years_on_job__c,
                genesis__Phone__c,
                genesis__Position__c,
                genesis__Self_Employed__c,
                genesis__Type_of_business__c,
                Avg_Paycheck__c,
                Income_Include_Bonuses_or_Commissions__c,
                Neo_Verify__c,
                Next_Paydate_estimate__c,
                No_of_Paychecks__c,
                Pay_Frequency__c,
                Payroll_Dates__c,
                Payroll_Source_Company__c,
                Previous_occupation__c,
                Send_work_email_verification_Email__c,
                Total_Earnings__c,
                Work_Email__c,
                Work_email_verified_check_box__c,
                WorkEmailKeyCode__c,
                WorkEmailKeyCodeResponse__c,
                DataArchiva_Old_Id__c,
                DataArchiva_Read_Only_Data__c
                FROM genesis__Employment_Information__c
                WHERE genesis__Application__c = :contractId
            ];
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(empInfos));
        }
        catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
         
    }
}
