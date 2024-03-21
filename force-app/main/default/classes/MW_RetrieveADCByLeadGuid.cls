@RestResource(urlMapping='/application-document-category/lead-guid/*')
//MW_RetrieveApplicationDocumentCategoryByLeadGuid
global with sharing class MW_RetrieveADCByLeadGuid {
    @HttpGet
    global static void MW_RetrieveADCByLeadGuid() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            String leadGuid = req.params.get('lead-guid');
            if (String.isBlank(leadGuid)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('guid is required');
                return;
            }
            List<genesis__Application_Document_Category__c> docs = [
                SELECT    
                Id,
                OwnerId,
                Name,
                CreatedDate,
                CreatedById,
                LastModifiedDate,
                LastModifiedById,
                genesis__Active__c,
                genesis__Application__c,
                genesis__Description__c,
                genesis__Document_Category__c,
                genesis__Email__c,
                genesis__Id__c,
                genesis__Parent_Application_Document_Category__c,
                genesis__Parent_Id__c,
                genesis__Party_Type__c,
                genesis__Party__c,
                genesis__Priority__c,
                genesis__Required__c,
                genesis__Review_Assigned_To__c,
                genesis__Review_Comments__c,
                genesis__Reviewed_By__c,
                genesis__Send_Notification__c,
                genesis__Status__c,
                Action_Reason__c,
                Application_Email__c,
                Borrower_s_Email__c,
                Borrower_s_First_Name__c,
                Box_URl__c,
                Cleared_Reason__c,
                Deliver_Status__c,
                Doc_Code_FF__c,
                Doc_Upload_Notification__c,
                Member_Email__c,
                Rejection_Reason__c,
                Rejection_Reasons__c,
                Doc_Code_as_for_Investors__c,
                Investor_Code__c,
                ShareBoxLink__c,
                Last2characters_forSorting__c,
                DataArchiva_Read_Only_Data__c,
                DataArchiva_Old_Id__c,
                Lead_Id__c
                FROM genesis__Application_Document_Category__c
                WHERE Lead_Id__c = :leadGuid
            ];

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(docs));
        }
        catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
    }
}