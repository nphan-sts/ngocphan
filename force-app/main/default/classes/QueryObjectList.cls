public with sharing class QueryObjectList extends CalloutClient{
    
    private static string sourceOrgDomainURL = 'https://happymoney-cls-01.my.salesforce.com';
    private string sourceOrgSessionId ='00D41000002GiRY!AQsAQAHoGLH5QvFc_0I3h9N9tX9B048.6uUGBSma7rZ_hxJsGlAzNm_pLvNI9YW90oxCL6fyBBOHXFCXjmvPRmo0TexyMZd0';
    CustomObjectWrapper objectWrapper;
    private string sourceEndPointURL;
    private Integer totalRec = 0;

    public QueryObjectList(CustomObjectWrapper objectWrapper) {
        this.objectWrapper = objectWrapper;
        System.debug('***object api name : ' + objectWrapper.objectApiName);
        System.debug('***object label : ' + objectWrapper.ojbectLabel);
    }

    public CustomObjectWrapper queryObjectTotalAllTime(String apiVersion) {

        sourceEndPointURL = sourceOrgDomainURL +'/services/data/'+ apiVersion + '/limits/recordCount?sObjects=' + objectWrapper.objectApiName;

        String resbody = queryObject();
        
        TotalRecordWrapper res = parseTotalRecordWrapper(resbody);

        if (res.sObjects.size() > 0) {
            System.debug('***response total:'+res.sObjects.get(0).count); 
            totalRec = res.sObjects.get(0).count;
        }

        if (totalRec <= 0) {
            return null;
        }

        objectWrapper.totalRecord = totalRec;

        return objectWrapper;
    }

    public CustomObjectWrapper queryObjectTotalTwoMonths(String apiVersion) {
        try {
            sourceEndPointURL = sourceOrgDomainURL +'/services/data/'+ apiVersion + '/query?q=SELECT+count(Id)+from+' + objectWrapper.objectApiName + '+Where+CreatedDate+<=+LAST_N_MONTHS:2';
    
            String resbody = queryObject();
            
            ObjectResponse res = parseObjectResponse(resbody);

            System.debug('***response total:'+res.records.get(0).expr0); 

            totalRec = res.records.get(0).expr0;
    
            if (totalRec <= 0) {
                return null;
            }
    
            objectWrapper.totalRecord = totalRec;
            
        } catch (Exception e) {
            System.debug(e.getMessage());

            if (e.getMessage() == 'Read timed out') {

                CustomObjectWrapper objectWrapper = queryObjectTotalAllTime(apiVersion);

                objectWrapper.totalRecord -= queryObjectTotalBeforeTwoMonths(apiVersion); 

                if (objectWrapper.totalRecord <= 0) {
                    return null;
                }
                return objectWrapper;

            }
        }
        return objectWrapper;
    }

    private Integer queryObjectTotalBeforeTwoMonths(String apiVersion) {
        try {
            sourceEndPointURL = sourceOrgDomainURL +'/services/data/'+ apiVersion + '/query?q=SELECT+count(Id)+from+' + objectWrapper.objectApiName + '+Where+CreatedDate+>+LAST_N_MONTHS:2';

            String resbody = queryObject();
            
            ObjectResponse res = parseObjectResponse(resbody);
            
            totalRec = res.records.get(0).expr0;

            System.debug('***response total:'+totalRec); 
        } catch (Exception e) {
            throw new CalloutClientException(e.getMessage());
        }
        return totalRec;
    }

    private String queryObject() {
        createRequest();

        doCallout();

        String resbody = handleResponse();

        return resbody;
    }

    private void createRequest() {
        request = super.createRequest(HTTP_METHOD_GET);
        request.setEndpoint(sourceEndPointURL);
        request.setHeader(HEADER_AUTHORIZATION, HEADER_BEARER_AUTHORIZATION + ' ' + sourceOrgSessionId);
    }

    private String handleResponse() {
        if (isStatusCodeOk()) {
            return getResponseBody();
        } else {
            throw new CalloutClientException('Invalid status code: ' + getResponseStatusCode());
        }
    }

    public class ObjectResponse{
        public Integer totalSize;	//1
        public boolean done;
        public Records[] records;

    }

    class Records {
        public Attributes attributes;
        public Integer expr0;	//16027548
    }

    class Attributes {
        public String type;	//AggregateResult
    }
    
    public static ObjectResponse parseObjectResponse(String json){
        return (ObjectResponse) System.JSON.deserialize(json, ObjectResponse.class);
    }
    /**
     static testMethod void testParse() {
         String json=		'{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"expr0":16027548}]}';
         fromJSON obj = parse(json);
         System.assert(obj != null);
        }
     */

    public class TotalRecordWrapper{
        public TotalRecord[] sObjects; 
    }
 
	class TotalRecord {
		public Integer count;	//0
		public String name;	//Contract
	}

    public static TotalRecordWrapper parseTotalRecordWrapper(String json){
		return (TotalRecordWrapper) System.JSON.deserialize(json, TotalRecordWrapper.class);
	}

}