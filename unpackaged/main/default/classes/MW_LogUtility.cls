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

    /*
     For using in both application triggers.
     */
    public static Map<String, Object> applicationTriggerEntryLog() {
        Map<String, Object> logs = new Map<String, Object>();
        logs.put('trigger.context', MW_LogUtility.toLoggableTrigger());
        if (Trigger.isInsert) {
            logs.put('trigger.new', MW_LogUtility.toLoggableApps(Trigger.new));
        } else if (Trigger.isUpdate) {
            logs.put('trigger.on', MW_LogUtility.toLoggableObjs(Trigger.old,
                    new List<String> {'Id', 'Lead_ID__c'}));
            logs.put('trigger.diffs',
                    MW_LogUtility.toTriggerUpdateDiffs(
                            new List<String> {'genesis__Status__c',
                                            'Investor__c',
                                            'Last_Investor_Assigned_On__c'}));
        }
        logs.put('InvestorAllocation.allocationForADVPcalled', InvestorAllocation.allocationForADVPcalled);
        return logs;
    }

    /**
     * Log out an exception object.
     */
    public static void error(String cls, String appId, String leadId, String method, Exception ex) {
        emit('Error', cls, appId, leadId, method, new ExceptionDO(ex));
    }

    /**
     * Log an informative map as an error
     * @param cls Class where it occurs
     * @param label A label that unites this error message with potentially other error messages of same variety
     * @param info A map containing informative keys and values for context
     */
    public static void errorMessage(String cls, String label, Object info) {
        new MW_LogTriggerHelper().construct('Error Message', cls, label, 'Error', JSON.serialize(info));
    }

    /**
     * A trigger safe implementation of info logging
     * @param cls The class where it occurs
     * @param label A label to unite this log messages with others of same variety
     * @param info A map containing useful information for context
     */
    public static void infoMessage(String cls, String label, Object info) {
        new MW_LogTriggerHelper().construct('Info Message', cls, label, 'Info', JSON.serialize(info));
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
            log.data = JSON.deserializeUntyped((String)data);
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
     * So long as you execute within a Trigger, this method works.
     * @param trigger trigger to get context from
     * @return Map containing only those which are true
     */
    public static String toLoggableTrigger() {
        List<String> context = new List<String>();

        if (Trigger.isAfter) {
            context.add('isAfter');
        }
        if (Trigger.isBefore) {
            context.add('isBefore');
        }
        if (Trigger.isInsert) {
            context.add('isInsert');
        }
        if (Trigger.isUpdate) {
            context.add('isUpdate');
        }
        if (Trigger.isDelete) {
            context.add('isDelete');
        }
        if (Trigger.isUndelete) {
            context.add('isUndelete');
        }
        if (Trigger.isExecuting) {
            context.add('isExecuting');
        }
        return String.join(context, ', ');
    }

    /**
     * Returns a log safe version of an application list
     * @param apps The list of applications pref with id, lead id and status
     * @return A list containing data from getLogInfo
     */
    public static List<Map<String, Object>> toLoggableApps(List<genesis__Applications__c> apps) {
        List<Map<String, Object>> logs = new List<Map<String, Object>>();
        if (apps == null) {
            return logs;
        }
        for (genesis__Applications__c app : apps) {
            logs.add(toLoggableApp(app));
        }
        return logs;
    }

    /**
     * Returns a log safe version of an application no PII
     * Checks before outputting, so developer friendly if not in SOQL query
     * @param app Application object pref with id, lead id and status
     * @return returns a map containing app id, lead id and status only.
     */
    public static Map<String, Object> toLoggableApp(genesis__Applications__c app) {

        String appId;
        String leadId;
        String status;
        String investor;
        String lastAssignedOn;

        if (app == null) {
            appId = 'Null app, no id';
            leadId = 'Null app, no lead id';
            status = 'Null app, no status';
            investor = 'Null app no investor';
            lastAssignedOn = 'Null app no investor last assigned date';
        } else {

            Map<String, Object> fieldValues = app.getPopulatedFieldsAsMap();

            if (fieldValues.get('Id') != null) {
                appId = app.Id;
            }
            if (fieldValues.get('Lead_ID__c') != null) {
                leadId = app.Lead_ID__c;
            }
            if (fieldValues.get('genesis__Status__c') != null) {
                status = app.genesis__Status__c;
            }
            if (fieldValues.get('Investor__c') != null) {
                investor = app.Investor__c;
            }
            if (fieldValues.get('Last_Investor_Assigned_On__c') != null) {
                lastAssignedOn = app.Last_Investor_Assigned_On__c.formatGmt('EEE, MMM d yyyy HH:mm:ss');
            }
        }

        Map<String, Object> msg = new Map<String, Object>();
        msg.put('Id', appId);
        msg.put('Lead_ID__c', leadId);
        msg.put('genesis__Status__c', status);
        msg.put('Investor__c', investor);
        msg.put('Last_Investor_Assigned_On__c', lastAssignedOn);

        return msg;
    }

    /**
     * Log any field requested
     * @param sobjs The list of objs with fields for logging
     * @param fieldKeys The list of fields
     * @return A list containing data from getLogInfo
     */
    public static List<Map<String, Object>> toLoggableObjs(List<SObject> sobjs, List<String> fieldKeys) {
        List<Map<String, Object>> logs = new List<Map<String, Object>>();
        if (sobjs == null || sobjs.isEmpty()) {
            return logs;
        }
        for (SObject obj : sobjs) {
            logs.add(toLoggableObj(obj, fieldKeys));
        }
        return logs;
    }

    /**
     * Not log safe
     * Checks before outputting, so developer friendly if not in SOQL query
     * @param sobj An SObject with fields queried
     * @param fieldKeys The list of fields
     * @return returns a map containing requested fields, if available
     */
    public static Map<String, Object> toLoggableObj(SObject sobj, List<String> fieldKeys) {

        Map<String, Object> msg = new Map<String, Object>();
        if (sobj == null) {
            return msg;
        }

        Map<String, Object> values = sobj.getPopulatedFieldsAsMap();
        if (fieldKeys == null || fieldKeys.isEmpty()) {
            return msg;
        }

        for (String key : fieldKeys) {
            Object obj = values.get(key);
            msg.put(key, toLogValue(obj));
        }

        return msg;
    }

    public static List<Map<String, Object>> toTriggerUpdateDiffs() {
        return toTriggerUpdateDiffs(new List<String>());
    }

    /**
     * Generate a list of update diffs in the current executing Trigger
     * Behaves by rules according toSObjectKeyDiff
     * @param revealKeys These keys are revealed to the logs in addition to name only in the 'diff'
     * @return A list of diffs
     */
    public static List<Map<String, Object>> toTriggerUpdateDiffs(List<String> revealKeys) {
        List<Map<String, Object>> diffs = new List<Map<String, Object>>();
        if (Trigger.isUpdate == null || !Trigger.isUpdate) {
            return diffs;
        }

        if (Trigger.newMap == null || Trigger.newMap.isEmpty()) {
            return diffs;
        }

        if (Trigger.oldMap == null || Trigger.oldMap.isEmpty()) {
            return diffs;
        }

        for (Id id : Trigger.newMap.keySet()) {
            Map<String, Object> diff = toSObjectKeyDiff(Trigger.newMap.get(id), Trigger.oldMap.get(id), revealKeys);
            diffs.add(diff);
        }

        return diffs;
    }

    public static Map<String, Object> toSObjectKeyDiff(SObject newObject, SObject oldObject) {
        return toSObjectKeyDiff(newObject, oldObject, new List<String>());
    }

    /**
     * A non PII spilling diff.  Outputs Lead ID and App id if Applications
     * @param newObject The new version
     * @param oldObject The old version
     * @param revealKeys Keys to always show in the new object
     *
     * @return A map with keys explained insertions, deletions, and updates
     */
    public static Map<String, Object> toSObjectKeyDiff(SObject newObject, SObject oldObject, List<String> revealKeys) {

        Map<String, Object> diff = new Map<String, Object>();
        if (newObject == null) {
            diff.put('Invalid Diff', 'New object is empty');
            return diff;
        } else if (oldObject == null) {
            diff.put('Invalid Diff', 'Old object is empty');
            return diff;
        }

        Map<String, Object> oldm = oldObject.getPopulatedFieldsAsMap();
        Map<String, Object> newm = newObject.getPopulatedFieldsAsMap();
        List<String> keys = new List<String>();
        keys.addAll(newm.keySet());
        keys.sort();

        List<String> addedList = new List<String>();
        List<String> removedList = new List<String>();
        List<String> updateList = new List<String>();

        /*
        For the reveal keys, output based on new.
        Otherwise, just report the key that changed.
         */
        for (String key : keys) {
            Boolean isReveal = revealKeys.contains(key);
            Object oldVal = oldm.get(key);
            Object newVal = newm.get(key);

            if (oldVal == null && newVal != null) {
                if (isReveal) {
                    addedList.add(key + ': [null => ' + toLogValue(newVal) + ']');
                } else {
                    addedList.add(key);
                }
            } else if (oldVal != null && newVal == null) {
                if (isReveal) {
                    removedList.add(key + ': [' + toLogValue(oldVal) + ' => null]');
                } else {
                    removedList.add(key);
                }
            } else if (oldVal != newVal) {
                if (isReveal) {
                    updateList.add(key + ': [' + toLogValue(oldVal) + ' => ' + toLogValue(newVal) + ']');
                } else {
                    updateList.add(key);
                }
            }
        }

        if (!addedList.isEmpty()) {
            diff.put('added', String.join(addedList, ', '));
        }
        if (!removedList.isEmpty()) {
            diff.put('removed', String.join(removedList, ', '));
        }
        if (!updateList.isEmpty()) {
            diff.put('updated', String.join(updateList, ', '));
        }

        return diff;
    }

    /**
     * @param obj Return something loggable.
     *
     * @return If null, null, else if date, to string format in gmt.
     */
    private static Object toLogValue(Object obj) {
        if (obj == null) {
            return 'null';
        }
        if (obj instanceof Datetime) {
            Datetime dt = (Datetime) obj;
            return dt.formatGmt('EEE, MMM d yyyy HH:mm:ss');
        } else {
            return obj;
        }
    }
}