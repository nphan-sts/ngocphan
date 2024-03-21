public with sharing class QueryObjectBatch implements Database.batchable<CustomObjectWrapper>, Database.AllowsCallouts, Database.Stateful{

    /** 
    Another thing to note when using apex for session Ids is that since Summer '17 the SessionId will no longer be printed out in Debug logs.
    Instead, you will see SESSION_ID_REMOVED.
    There are ways around this but do be careful, it is a security risk having SessionIds in your debug log
    System.debug(UserInfo.getOrganizationId().substring(0, 15) + '  ' +  UserInfo.getSessionId().substring(15));
    Remove the space to get the actual Session ID, the space is needed for the SessionID to print out.
    */
    private List<CustomObjectWrapper> activeObject;
    private List<List<String>> csvRowList;
    private Boolean inLastTwoMonths = false;
    private String version = '';


    static String option1 = 'TotalRecord';
    static String option2 = 'TotalRecordInLast2Months';

    public QueryObjectBatch(Boolean inLastTwoMonths) {
        this.inLastTwoMonths = inLastTwoMonths;
        activeObject = new List<CustomObjectWrapper>();
        csvRowList = new List<List<String>>();
        version = ApiVersion.getNewestAPIVersion();

    }


    public Iterable<CustomObjectWrapper> start(Database.BatchableContext bc){
        return new ObjectIterable();
    }

    public void execute(Database.BatchableContext bc, List<CustomObjectWrapper> scope) {

        String option = inLastTwoMonths ? option2 : option1;


        for (CustomObjectWrapper obj : scope) {
            QueryObjectList queryHandler = new QueryObjectList(obj);

            if (inLastTwoMonths) {
                obj = queryHandler.queryObjectTotalTwoMonths(version);
            }
            else {
                obj = queryHandler.queryObjectTotalAllTime(version);

            }

            if (obj != null && obj.totalRecord > 0) {
                activeObject.add(obj);
                csvRowList.add(new List<String>{obj.objectType, obj.objectApiName, obj.ojbectLabel, String.valueOf(obj.totalRecord)});
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('**finsih**');
        for (CustomObjectWrapper obj : activeObject) {
            System.debug(obj.objectApiName);
            System.debug(obj.ojbectLabel);
            System.debug('----------');
        }
        List<String> csvHeaders = new List<String>();
        csvHeaders.add('Object Type');
        csvHeaders.add('Object Api Name');
        csvHeaders.add('Object Label');
        csvHeaders.add('Total Records');
        CreateCsvFile.createCSV(csvHeaders, csvRowList, inLastTwoMonths ? 'ActiveObjectInLastTwoMonths' :'ActiveObject');
    }


}