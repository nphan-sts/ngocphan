/*
Specific details documentation available within class - MWOriginationDocuments_AppDocs_Manual
Following is the script to run this job, one time to test.
//Run one time
String ss = String.valueOf(Datetime.now().second());
String min = String.valueOf(Datetime.now().minute() + 1);
String hour = String.valueOf(Datetime.now().hour());
String dayOfMonth = String.valueOf(Datetime.now().day());
String mnth = String.valueOf(Datetime.now().month());
String dayOfWeek = '?';
String yr = String.valueOf(Datetime.now().year());

//parse to cron expression
String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + dayOfMonth + ' ' + mnth + ' ' + dayOfWeek + ' ' + yr;
//String nextFireTime = '15 28 15 13 3 ? 2019';
System.debug('nextFireTime=' + nextFireTime);

Set<String> appStatus = new Set<String>{'Decline_Manual_Review', 'Declined'};
//All possible values - AppCreatedDate, AppModifiedDate, DocuSignSignedDate
String selectAppsBy = 'AppCreatedDate';
//DateTime Type (yyyy-mm-ddT17:00:00Z), In case of day range, because of UTC timezone, MINUS 7 hours in the date. For eg. '2019-05-15T00:00:00Z' should be '2019-05-14T17:00:00Z'
String appStartDate = 'YESTERDAY';
//DateTime Type (yyyy-mm-ddT07:00:00Z), In case of day range, because of UTC timezone, ADD 7 hours in the date. For eg. '2019-05-15T00:00:00Z' should be '2019-05-16T07:00:00Z'
String appEndDate = 'YESTERDAY';

MW_OriginationDocs_AppScheduler_Manual OrgDocsAppScheduler = new MW_OriginationDocs_AppScheduler_Manual(selectAppsBy, appStartDate, appEndDate, appStatus);
system.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, OrgDocsAppScheduler);
 */
global class MW_OriginationDocs_AppScheduler_Manual implements Schedulable {

    Set<String> appStatus = new Set<String>();
    String selectAppsBy;
    String appStartDate;
    String appEndDate;

    public MW_OriginationDocs_AppScheduler_Manual(String pSelectAppsBy, String pAppStartDate, String pAppEndDate, Set<String> pAppStatus) {
        this.appStatus = pAppStatus;
        this.selectAppsBy = pSelectAppsBy;
        this.appStartDate = pAppStartDate;
        this.appEndDate = pAppEndDate;
    }

    global void execute(SchedulableContext SC) {
        if (string.isEmpty(selectAppsBy) || string.isEmpty(appStartDate) || string.isEmpty(appEndDate) || appStatus.size() == 0) {
            System.debug('Parameters are null');
        }

        Database.executeBatch(new MWOriginationDocuments_AppDocs_Manual(selectAppsBy, appStartDate, appEndDate, appStatus), 1);
    }

}