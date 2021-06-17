//Database.executeBatch(new MW_Alerts(), 1);
global class MW_Alerts implements Database.AllowsCallouts, Database.batchable<sObject> {
    private String baseUrl = getSalesforceInstanceUrl();

    private final String SalesforceLimitsUrl = MW_Settings__c.getInstance().SalesforceLimitsUrl__c; //'/services/data/v45.0/limits';//(pending take from custom setting)
    private final Decimal thresholdApiAndStorage = MW_Settings__c.getInstance().thresholdApiAndStorage__c; //70;//(pending take from custom setting)
    private final Decimal thresholdFundingCaps = MW_Settings__c.getInstance().thresholdFundingCaps__c; //80;//(pending take from custom setting)
    //Batchable Process
    private String query = 'SELECT Id, Name, Annual_Funded_Cap__c, Total_Funded_YTD__c, Annual_Available_Balance__c,' +
            'Monthly_Allocation_Cap__c, Total_Allocations_MTD__c, Current_Month_s_Available_Allocation__c,' +
            'Monthly_Funded_Cap__c, Total_Funded_MTD__c, Current_Month_s_Available_Funded_Balance__c' +
            ' FROM Account WHERE RecordType.Name = \'Investor\' AND loan__Investor__c = true';


    global Database.QueryLocator start(Database.BatchableContext BC) {

        LimitsJson limitApi = getLimitsJson();
        System.debug('limit=' + limitApi);
        System.debug('thresholdApiAndStorage=' + thresholdApiAndStorage);

        //API Daily Limit Alert
        if (limitApi.DailyApiRequests.Remaining < (limitApi.DailyApiRequests.Max * (100 - thresholdApiAndStorage) / 100)) {
            Map<String, Object> msg = new Map<String, Object>();
            msg.put('code', 'SFDC_API_THRESHOLD_EXCEEDED');
            msg.put('percentDailyThresholdCrossed', thresholdApiAndStorage);
            msg.put('maxDailyLimit', limitApi.DailyApiRequests.Max);
            msg.put('remainingDailyLimit', limitApi.DailyApiRequests.Remaining);

            MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
        }

        //API Data Storage Alert
        if (limitApi.DataStorageMB.Remaining < (limitApi.DataStorageMB.Max * (100 - thresholdApiAndStorage) / 100)) {
            Map<String, Object> msg = new Map<String, Object>();
            msg.put('code', 'SFDC_DATA_STORAGE_THRESHOLD_EXCEEDED');
            msg.put('percentFileStorageCrossed', thresholdApiAndStorage);
            msg.put('maxLimitMB', limitApi.DataStorageMB.Max);
            msg.put('remainingLimit', limitApi.DataStorageMB.Remaining);

            MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
        }

        //API File Storage Alert
        if (limitApi.FileStorageMB.Remaining < (limitApi.FileStorageMB.Max * (100 - thresholdApiAndStorage) / 100)) {
            Map<String, Object> msg = new Map<String, Object>();
            msg.put('code', 'SFDC_FILE_STORAGE_THRESHOLD_EXCEEDED');
            msg.put('percentFileStorageCrossed', thresholdApiAndStorage);
            msg.put('maxLimitMB', limitApi.FileStorageMB.Max);
            msg.put('remainingLimit', limitApi.FileStorageMB.Remaining);

            MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
        }

        System.Debug('query=' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        for (Account act : scope) {
            //Annual Funded Cap Alert
            act.Annual_Funded_Cap__c = act.Annual_Funded_Cap__c == null ? 0 : act.Annual_Funded_Cap__c;

            if (act.Total_Funded_YTD__c > (act.Annual_Funded_Cap__c * thresholdFundingCaps / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_ANNUAL_FUNDED_CAP_EXCEEDED');
                msg.put('investor', act.Name);
                msg.put('thresholdFundingCapPercent', thresholdFundingCaps);

                MW_LogUtility.warn('MW_Alerts', null, null, 'execute', msg);
            }

            //Monthly Funded Cap Alert
            act.Monthly_Funded_Cap__c = act.Monthly_Funded_Cap__c == null ? 0 : act.Monthly_Funded_Cap__c;

            if (act.Total_Funded_MTD__c > (act.Monthly_Funded_Cap__c * thresholdFundingCaps / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_MONTHLY_FUNDED_CAP_EXCEEDED');
                msg.put('investor', act.Name);
                msg.put('thresholdFundingCapPercent', thresholdFundingCaps);

                MW_LogUtility.warn('MW_Alerts', null, null, 'execute', msg);
            }

            // Monthly Allocation Cap Alert
            act.Monthly_Allocation_Cap__c = act.Monthly_Allocation_Cap__c == null ? 0 : act.Monthly_Allocation_Cap__c;
            Decimal fundedCap = act.Monthly_Funded_Cap__c == null ? 0 : act.Monthly_Funded_Cap__c;
            Decimal percentageAllocated = (act.Total_Allocations_MTD__c / act.Monthly_Allocation_Cap__c * 100).setScale(1);

            if (percentageAllocated > thresholdFundingCaps) {                
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_MONTHLY_ALLOCATION_CAP_EXCEEDED');
                msg.put('investor', act.Name);
                msg.put('thresholdFundingCapPercent', thresholdFundingCaps);
                msg.put('numberAllocated', act.Total_Allocations_MTD__c.setScale(0));
                msg.put('allocationCap', act.Monthly_Allocation_Cap__c.setScale(0));
                msg.put('fundingAllocated', act.Total_Funded_MTD__c.setScale(0));
                msg.put('fundingCap', fundedCap.setScale(0));
                msg.put('percentAllocated', percentageAllocated);

                MW_LogUtility.warn('MW_Alerts', null, null, 'execute', msg);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
    }


    private LimitsJson getLimitsJson() {
        String apiLimitUrl = baseUrl + SalesforceLimitsUrl;
        System.debug('apiLimitUrl=' + apiLimitUrl);
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(apiLimitUrl);

        httpRequest.setMethod('GET');
        httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        //httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());

        Http http = new Http();
        HttpResponse httpResponse = new HttpResponse();
        LimitsJson limits = new limitsJson();

        try {
            if (!Test.isRunningTest()) {
                httpResponse = http.send(httpRequest);
            } else {
                httpResponse.setBody('{"DailyApiRequests":{"Max":5000000,"Remaining":100000},"DataStorageMB":{"Max":200,"Remaining":10},"FileStorageMB":{"Max":200,"Remaining":10}}');
                httpResponse.setStatusCode(200);
            }

            System.debug('httpResponse.getBody()=' + httpResponse.getBody());

            if (httpResponse.getStatusCode() == 200) {
                limits = (LimitsJson) JSON.deserialize(httpResponse.getBody(), LimitsJson.class);
            }
        } catch (System.Exception e) {
            System.debug('ERROR: ' + e);
            //throw e;
        }

        return limits;
    }

    private static String getSalesforceInstanceUrl() {
        return URL.getSalesforceBaseUrl().toExternalForm();
    }

    private class LimitsJson {
        public cls_DataStorageMB DataStorageMB;
        public cls_FileStorageMB FileStorageMB;
        public cls_DailyApiRequests DailyApiRequests;
    }

    private class cls_DataStorageMB {
        public Integer Max;
        public Integer Remaining;
    }

    private class cls_FileStorageMB {
        public Integer Max;
        public Integer Remaining;
    }

    private class cls_DailyApiRequests {
        public Integer Max;
        public Integer Remaining;
    }
}