/**
* Main Logging class for sending data to wherever logs need to be sent (for example, DataDog.)
* This will take a collection of information to log out, to make it easier to track
*  information down.
*/
public class MW_LogUtility {
    
    /**
* The Data Object for carrying general log data. This data will be common
*  for all logged data.
*/
    public class Log {
        public String apexClass;
        public String applicationId;
        public String leadId;
        public String method;
        public Object data;
        public String type;
        public Integer statusCode;
    }
    
    /**
* The Data Object for carrying DAG log data. This data will be common
*  for all generic job logs.
*/
    public class JobLog {
        public String apexClass;
        public String label;
        public String message;
        public String type;
        
    }
    
/*MKT Added for LSP-306*/
    public static void dagError(
        string jobName,
        string jobClass,
        object documentData
    )
    {
        emit('Error', jobClass, null, jobName, null, documentData, null);
    }
    /*END- LSP-306*/
    
    /**
* This is used to carry exception data to send in a log, since Exception
*  objects aren't JSON serializable.
*/
    public class ExceptionDO {
        public String message;
        public String stackTrace;
        public String type;
        public Integer lineNumber;
        
        public ExceptionDO(Exception e) {
            message = e.getMessage();
            stackTrace = e.getStackTraceString();
            type = e.getTypeName();
            lineNumber = e.getLineNumber();
        }
    }
    
    /** Determines whether to send logs in a batch. */
    public static Boolean isBatch { get; private set; }
    /** The logs to send in a batch. */
    public static List<Log> batchLogs { get; private set; }
    
    static {
        isBatch = false;
        batchLogs = new List<Log>();
    }
    
    /**
* Enables batch mode for sending logs.
*/
    public static void beginBatch() {
        isBatch = true;
    }
    
    /**
* Sends all the batch logs and disables batch logging.
*/
    public static void sendBatch() {
        MW_DataDogCallOut.sendBatch(batchLogs);
        isBatch = false;
        batchLogs = new List<Log>();
    }
    
    /**
* @param className The class name executing the allocation.
* @param appId The app id associated with this attempt
* @param leadId The lead id for sharing
* @param checklist The checklist instance to gather information
*/
    public static void sendAllocationRulesetErrors(String className, String appId, String leadId, genesis__Checklist__c checklist) {
        
        String description = checklist.genesis__Description__c;
        
        if (description != null) {
            
            if (description.containsIgnoreCase('exception')) {
                clcommon__Batch_Process_Log__c bpl = new clcommon__Batch_Process_Log__c();
                bpl.clcommon__Type__c = 'Exception';
                bpl.clcommon__Batch_Id__c = appId;
                bpl.clcommon__Message__c =
                    className + ': ' +
                    'App with Lead Id: ' + leadId +
                    ' failed investor allocation rule execution with description:"' + description + '" ' +
                    ' and message: "' + checklist.genesis__Message__c + '"';
                insert bpl;
            }
        }
    }
    
    /**
* Log out an exception object.
*/
    public static void error(String cls, String appId, String leadId, String method, Exception ex) {
        emit('Error', cls, appId, leadId, method, new ExceptionDO(ex));
    }

    /**
     * A generic error where a single app id and lead id does not apply
     * @param cls The invoking class
     * @param method The invoking message
     * @param data Key data
     * @param e The exception to report
     */
    public static void error(String cls, String method, Object data, Exception e) {
        Map<String, Object> msgdata = new Map<String, Object>();
        msgdata.put('data', data);
        msgdata.put('exception', new ExceptionDO(e));
        emit('Error', cls, null, null, method, msgdata);
    }

    /**
     * A generic error where a single app id and lead id does not apply, and no exception.
     * @param cls The invoking class
     * @param method The invoking message
     * @param data Key data
     */
    public static void error(String cls, String method, Object data) {
        emit('Error', cls, null, null, method, data);
    }

    /**
    * Log an informative map as an info, via EventBus, not direct callout
    *
    * @param cls Class where it occurs
    * @param label A label that unites this info message with potentially other info messages of same variety
    * @param info A map containing informative keys and values for context
    */
    public static void infoMessage(String cls, String label, Object info) {
        emitMessage('Info Message', cls, label, 'Info', info);
    }

    /**
    * Log an informative map as an warning, via EventBus, not direct callout
    *
    * @param cls Class where it occurs
    * @param label A label that unites this info message with potentially other info messages of same variety
    * @param info A map containing informative keys and values for context
    */
    public static void warnMessage(String cls, String label, Object info) {
        emitMessage('Warn Message', cls, label, 'Warn', info);
    }

    /**
     * Log an informative map as an error, via EventBus, not direct callout
     *
     * @param cls Class where it occurs
     * @param label A label that unites this error message with potentially other error messages of same variety
     * @param info A map containing informative keys and values for context
     */
    public static void errorMessage(String cls, String label, Object info) {
        emitMessage('Error Message', cls, label, 'Error', info);
    }

    private static void emitMessage(String name, String cls, String label, String type, Object data) {
        new MW_LogTriggerHelper().construct(name, cls, label, type, JSON.serialize(data));
    }

    /**
* Log out a *warning* with generic Data. Anything can be passed into data so that
*  the structure can be defined by the developer.
*/
    public static void warn(String cls, String appId, String leadId, String method, Object data) {
        emit('Warning', cls, appId, leadId, method, data);
    }
    
    /**
* Log out a *warning* with generic Data. Anything can be passed into data so that
*  the structure can be defined by the developer.
* This does not take appId or leadId, for cases where it's not related
*  to an application.
*/
    public static void warn(String cls, String method, Object data) {
        emit('Warning', cls, null, null, method, data);
    }
    
    /**
* Log out generic Data. Anything can be passed into data so that
*  the structure can be defined by the developer.
*/
    public static void info(String cls, String appId, String leadId, String method, Object data) {
        emit('Info', cls, appId, leadId, method, data);
    }
    
    /**
* Log out generic Data. Anything can be passed into data so that
*  the structure can be defined by the developer.
* This does not take appId or leadId, for cases where it's not related
*  to an application.
*/
    public static void info(String cls, String method, Object data) {
        emit('Info', cls, null, null, method, data);
    }
    
    /**
* Log out generic Data. Anything can be passed into data so that
*  the structure can be defined by the developer.
* This also takes an HTTP Response so that the message type can be determined by the
*  response status code.
*/
    public static void info(String cls, String appId, String leadId, String method, Object data, HttpResponse response) {
        String type = 'Info';
        if (!isStatusCodeValid(response.getStatusCode())) {
            if (isStatusCodeError(response.getStatusCode())) {
                type = 'Error';
            } else {
                type = 'Warning';
            }
        }
        emit(type, cls, appId, leadId, method, data, response.getStatusCode());
    }
    
    /**
* Method to build and emit a log line to whatever service we are using to
*  record logs.
*/
    private static void emit(String type, String cls, String appId, String leadId, String method, Object data) {
        emit(type, cls, appId, leadId, method, data, null);
    }
    
    /**
* Method to build and emit a log line to whatever service we are using to
*  record logs.
* This version takes in an Integer code for the HTTP status code.
*/
    private static void emit(String type, String cls, String appId, String leadId, String method, Object data, Integer code) {
        MW_LogUtility.Log log = new MW_LogUtility.Log();
        log.apexClass = cls;
        log.applicationId = appId;
        log.leadId = leadId;
        log.method = method;
        log.data = data;
        log.type = type;
        log.statusCode = code;
        try {
            // Use a try/catch so that if `data` can't be cast to string, or isn't JSON,
            //  it doesn't fail execution altogether.
            if(log.data != null){
                log.data = JSON.deserializeUntyped((String)data);
            }
        } catch (Exception e) {}
        
        // Send the log out to the appropriate service
        if (isBatch) {
            batchLogs.add(log);
        } else {
            MW_DataDogCallOut.send(log);
        }
    }
    
    /**
* A method to determine if a status code is valid or not.
*/
    public static Boolean isStatusCodeValid(Integer statusCode) {
        return statusCode < 400;
    }
    
    /**
* A method to determine if a status code is an error or not.
*/
    public static Boolean isStatusCodeError(Integer statusCode) {
        return statusCode >= 500;
    }
/**
* A method to create a MW_LogUtility.Log instance and return it
*/
    public static MW_LogUtility.Log getLogRecord(String cls,String appId,String leadId,String method,Object data,String type,Integer code){
        MW_LogUtility.Log log = new MW_LogUtility.Log();
        log.apexClass = cls;
        log.applicationId = appId;
        log.leadId = leadId;
        log.method = method;
        log.data = data;
        log.type = type;
        log.statusCode = code;
        return log; 
    }
}