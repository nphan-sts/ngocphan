@RestResource(urlMapping='/application-document-category/target-date/*')
global with sharing class MW_RetriveACDIdsbydate {
    @HttpGet
    global static void MW_RetriveACDIdsbydate() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            String modifiedDate = req.params.get('target-date');
            if (String.isBlank(modifiedDate)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('date is required');
                return;
            }
            Date formatted = Date.valueOf(modifiedDate);

            List<genesis__Application_Document_Category__c> docs = [
                SELECT    
                Id
                FROM genesis__Application_Document_Category__c
                WHERE LastModifiedDate >= :formatted
                AND LastModifiedDate < :formatted.addDays(1)
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
