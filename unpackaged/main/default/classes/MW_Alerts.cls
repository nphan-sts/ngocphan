//Database.executeBatch(new MW_Alerts(), 1);
global class MW_Alerts implements Database.AllowsCallouts, Database.batchable<sObject> {
    private String baseUrl = getSalesforceInstanceUrl();

    private final String SalesforceLimitsUrl = MW_Settings__c.getInstance().SalesforceLimitsUrl__c; //'/services/data/v45.0/limits';
    private final Decimal threshold80 = MW_Settings__c.getInstance().thresholdApiAndStorage__c; //80;
    private final Decimal threshold70 = threshold80 - 10;
    //Batchable Process

    private String query = 'SELECT Id FROM Account LIMIT 1';

    global Database.QueryLocator start(Database.BatchableContext BC) {

        LimitsJson limitApi = getLimitsJson();
        System.debug('limit=' + limitApi);
        System.debug('threshold70=' + threshold70);
        System.debug('threshold80=' + threshold80);

        if (limitApi.DailyApiRequests.Remaining < (limitApi.DailyApiRequests.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.DailyApiRequests.Max;
            Integer remaining = limitApi.DailyApiRequests.Remaining;
            if(remaining < (max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_API_THRESHOLD_EXCEEDED');
                    msg.put('percentDailyAPIThresholdCrossed', threshold80);
                    msg.put('maxDailyLimit', max);
                    msg.put('remainingDailyLimit', remaining);

                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }

            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_API_THRESHOLD_EXCEEDED' + '\n' +
                    'percentDailyAPIThresholdCrossed: '+threshold70+ '\n' +
                    'maxLimitMB: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }

        if (limitApi.DataStorageMB.Remaining < (limitApi.DataStorageMB.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.DataStorageMB.Max;
            Integer remaining = limitApi.DataStorageMB.Remaining;
            if(remaining < (max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_DATA_STORAGE_THRESHOLD_EXCEEDED');
                    msg.put('percentDataStorageCrossed', threshold80);
                    msg.put('maxLimitMB', max);
                    msg.put('remainingLimit', remaining);

                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }

            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_DATA_STORAGE_THRESHOLD_EXCEEDED' + '\n' +
                    'percentDataStorageCrossed: '+threshold70+ '\n' +
                    'maxLimitMB: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }

        if (limitApi.FileStorageMB.Remaining < (limitApi.FileStorageMB.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.FileStorageMB.Max;
            Integer remaining = limitApi.FileStorageMB.Remaining;
            if(remaining < (max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_FILE_STORAGE_THRESHOLD_EXCEEDED');
                msg.put('percentFileStorageCrossed', threshold80);
                msg.put('maxLimitMB', max);
                msg.put('remainingLimit', remaining);
    
                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }
            
            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_FILE_STORAGE_THRESHOLD_EXCEEDED' + '\n' +
                    'percentFileStorageCrossed: '+threshold70+ '\n' +
                    'maxLimitMB: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }
        
        if (limitApi.DailyBulkApiRequests.Remaining < (limitApi.DailyBulkApiRequests.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.DailyBulkApiRequests.Max;
            Integer remaining = limitApi.DailyBulkApiRequests.Remaining;
            if(remaining < (max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_BULK_API_THRESHOLD_EXCEEDED');
                msg.put('percentBulkAPICrossed', threshold80);
                msg.put('maxLimit', max);
                msg.put('remainingLimit', remaining);
    
                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }
            
            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_BULK_API_THRESHOLD_EXCEEDED' + '\n' +
                    'percentBulkAPICrossed: '+threshold70+ '\n' +
                    'maxLimit: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }
                        
        if (limitApi.DailyAsyncApexExecutions.Remaining < (limitApi.DailyAsyncApexExecutions.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.DailyAsyncApexExecutions.Max;
            Integer remaining = limitApi.DailyAsyncApexExecutions.Remaining;
            if(limitApi.DailyAsyncApexExecutions.Remaining < (limitApi.DailyAsyncApexExecutions.Max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_ASYNC_APEX_EXECUTIONS_THRESHOLD_EXCEEDED');
                msg.put('percentCrossed', threshold80);
                msg.put('maxLimit', max);
                msg.put('remainingLimit', remaining);
    
                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }
            
            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_ASYNC_APEX_EXECUTIONS_THRESHOLD_EXCEEDED' + '\n' +
                    'percentCrossed: '+threshold70+ '\n' +
                    'maxLimit: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }
        
        if (limitApi.DailyDeliveredPlatformEvents.Remaining < (limitApi.DailyDeliveredPlatformEvents.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.DailyDeliveredPlatformEvents.Max;
            Integer remaining = limitApi.DailyDeliveredPlatformEvents.Remaining;
            if(limitApi.DailyDeliveredPlatformEvents.Remaining < (limitApi.DailyDeliveredPlatformEvents.Max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_DAILY_DELIVERED_PLATFORM_EVENTS_THRESHOLD_EXCEEDED');
                msg.put('percentCrossed', threshold80);
                msg.put('maxLimit', max);
                msg.put('remainingLimit', remaining);
    
                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }
            
            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_DAILY_DELIVERED_PLATFORM_EVENTS_THRESHOLD_EXCEEDED' + '\n' +
                    'percentCrossed: '+threshold70+ '\n' +
                    'maxLimit: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }
        
        if (limitApi.HourlyPublishedPlatformEvents.Remaining < (limitApi.HourlyPublishedPlatformEvents.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.HourlyPublishedPlatformEvents.Max;
            Integer remaining = limitApi.HourlyPublishedPlatformEvents.Remaining;
            if(limitApi.HourlyPublishedPlatformEvents.Remaining < (limitApi.HourlyPublishedPlatformEvents.Max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_HOURLY_PUBLISHED_PLATFORM_EVENTS_THRESHOLD_EXCEEDED');
                msg.put('percentCrossed', threshold80);
                msg.put('maxLimit', max);
                msg.put('remainingLimit', remaining);
    
                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }
            
            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_HOURLY_PUBLISHED_PLATFORM_EVENTS_THRESHOLD_EXCEEDED' + '\n' +
                    'percentCrossed: '+threshold70+ '\n' +
                    'maxLimit: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }
        
        if (limitApi.DailyDurableGenericStreamingApiEvents.Remaining < (limitApi.DailyDurableGenericStreamingApiEvents.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.DailyDurableGenericStreamingApiEvents.Max;
            Integer remaining = limitApi.DailyDurableGenericStreamingApiEvents.Remaining;
            if(limitApi.DailyDurableGenericStreamingApiEvents.Remaining < (limitApi.DailyDurableGenericStreamingApiEvents.Max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_DAILY_DURABLE_GENERIC_STREAMING_API_EVENTS_THRESHOLD_EXCEEDED');
                msg.put('percentCrossed', threshold80);
                msg.put('maxLimit', max);
                msg.put('remainingLimit', remaining);
    
                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }
            
            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_DAILY_DURABLE_GENERIC_STREAMING_API_EVENTS_THRESHOLD_EXCEEDED' + '\n' +
                    'percentCrossed: '+threshold70+ '\n' +
                    'maxLimit: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }
        
        if (limitApi.HourlyPublishedStandardVolumePlatformEvents.Remaining < (limitApi.HourlyPublishedStandardVolumePlatformEvents.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.HourlyPublishedStandardVolumePlatformEvents.Max;
            Integer remaining = limitApi.HourlyPublishedStandardVolumePlatformEvents.Remaining;
            if(Remaining < (max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_HourlyPublishedStandardVolumePlatformEvents_THRESHOLD_EXCEEDED');
                msg.put('percentCrossed', threshold80);
                msg.put('maxLimit', max);
                msg.put('remainingLimit', remaining);
    
                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }
            
            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_HourlyPublishedStandardVolumePlatformEvents_THRESHOLD_EXCEEDED' + '\n' +
                    'percentCrossed: '+threshold70+ '\n' +
                    'maxLimit: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }
        
        if (limitApi.DailyDurableStreamingApiEvents.Remaining < (limitApi.DailyDurableStreamingApiEvents.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.DailyDurableStreamingApiEvents.Max;
            Integer remaining = limitApi.DailyDurableStreamingApiEvents.Remaining;
            if(Remaining < (max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_DailyDurableStreamingApiEvents_THRESHOLD_EXCEEDED');
                msg.put('percentCrossed', threshold80);
                msg.put('maxLimit', max);
                msg.put('remainingLimit', remaining);

            MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
        }

            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_DailyDurableStreamingApiEvents_THRESHOLD_EXCEEDED' + '\n' +
                    'percentCrossed: '+threshold70+ '\n' +
                    'maxLimit: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }
        
        if (limitApi.DailyGenericStreamingApiEvents.Remaining < (limitApi.DailyGenericStreamingApiEvents.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.DailyGenericStreamingApiEvents.Max;
            Integer remaining = limitApi.DailyGenericStreamingApiEvents.Remaining;
            if(Remaining < (max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_DailyGenericStreamingApiEvents_THRESHOLD_EXCEEDED');
                msg.put('percentCrossed', threshold80);
                msg.put('maxLimit', max);
                msg.put('remainingLimit', remaining);
    
                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }
            
            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_DailyGenericStreamingApiEvents_THRESHOLD_EXCEEDED' + '\n' +
                    'percentCrossed: '+threshold70+ '\n' +
                    'maxLimit: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }
        
        if (limitApi.DailyStandardVolumePlatformEvents.Remaining < (limitApi.DailyStandardVolumePlatformEvents.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.DailyStandardVolumePlatformEvents.Max;
            Integer remaining = limitApi.DailyStandardVolumePlatformEvents.Remaining;
            if(Remaining < (max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_DailyStandardVolumePlatformEvents_THRESHOLD_EXCEEDED');
                msg.put('percentCrossed', threshold80);
                msg.put('maxLimit', max);
                msg.put('remainingLimit', remaining);
    
                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }
            
            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_DailyStandardVolumePlatformEvents_THRESHOLD_EXCEEDED' + '\n' +
                    'percentCrossed: '+threshold70+ '\n' +
                    'maxLimit: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }
        
        if (limitApi.DailyStreamingApiEvents.Remaining < (limitApi.DailyStreamingApiEvents.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.DailyStreamingApiEvents.Max;
            Integer remaining = limitApi.DailyStreamingApiEvents.Remaining;
            if(Remaining < (max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_DailyStreamingApiEvents_THRESHOLD_EXCEEDED');
                msg.put('percentCrossed', threshold80);
                msg.put('maxLimit', max);
                msg.put('remainingLimit', remaining);
    
                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }
            
            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_DailyStreamingApiEvents_THRESHOLD_EXCEEDED' + '\n' +
                    'percentCrossed: '+threshold70+ '\n' +
                    'maxLimit: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }
        
        if (limitApi.DurableStreamingApiConcurrentClients.Remaining < (limitApi.DurableStreamingApiConcurrentClients.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.DurableStreamingApiConcurrentClients.Max;
            Integer remaining = limitApi.DurableStreamingApiConcurrentClients.Remaining;
            if(Remaining < (max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_DurableStreamingApiConcurrentClients_THRESHOLD_EXCEEDED');
                msg.put('percentCrossed', threshold80);
                msg.put('maxLimit', max);
                msg.put('remainingLimit', remaining);
    
                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }
            
            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_DurableStreamingApiConcurrentClients_THRESHOLD_EXCEEDED' + '\n' +
                    'percentCrossed: '+threshold70+ '\n' +
                    'maxLimit: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }
        
        if (limitApi.HourlyTimeBasedWorkflow.Remaining < (limitApi.HourlyTimeBasedWorkflow.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.HourlyTimeBasedWorkflow.Max;
            Integer remaining = limitApi.HourlyTimeBasedWorkflow.Remaining;
            if(Remaining < (max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_HourlyTimeBasedWorkflow_THRESHOLD_EXCEEDED');
                msg.put('percentCrossed', threshold80);
                msg.put('maxLimit', max);
                msg.put('remainingLimit', remaining);
    
                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }
            
            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_HourlyTimeBasedWorkflow_THRESHOLD_EXCEEDED' + '\n' +
                    'percentCrossed: '+threshold70+ '\n' +
                    'maxLimit: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }
        
        if (limitApi.MassEmail.Remaining < (limitApi.MassEmail.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.MassEmail.Max;
            Integer remaining = limitApi.MassEmail.Remaining;
            if(Remaining < (max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_MassEmail_THRESHOLD_EXCEEDED');
                msg.put('percentCrossed', threshold80);
                msg.put('maxLimit', max);
                msg.put('remainingLimit', remaining);
    
                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }
            
            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_MassEmail_THRESHOLD_EXCEEDED' + '\n' +
                    'percentCrossed: '+threshold70+ '\n' +
                    'maxLimit: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }
        
        if (limitApi.MonthlyPlatformEvents.Remaining < (limitApi.MonthlyPlatformEvents.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.MonthlyPlatformEvents.Max;
            Integer remaining = limitApi.MonthlyPlatformEvents.Remaining;
            if(Remaining < (max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_MonthlyPlatformEvents_THRESHOLD_EXCEEDED');
                msg.put('percentCrossed', threshold80);
                msg.put('maxLimit', max);
                msg.put('remainingLimit', remaining);
    
                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }
            
            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_MonthlyPlatformEvents_THRESHOLD_EXCEEDED' + '\n' +
                    'percentCrossed: '+threshold70+ '\n' +
                    'maxLimit: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }
        
        if (limitApi.StreamingApiConcurrentClients.Remaining < (limitApi.StreamingApiConcurrentClients.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.StreamingApiConcurrentClients.Max;
            Integer remaining = limitApi.StreamingApiConcurrentClients.Remaining;
            if(Remaining < (max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_StreamingApiConcurrentClients_THRESHOLD_EXCEEDED');
                msg.put('percentCrossed', threshold80);
                msg.put('maxLimit', max);
                msg.put('remainingLimit', remaining);
    
                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }
            
            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_StreamingApiConcurrentClients_THRESHOLD_EXCEEDED' + '\n' +
                    'percentCrossed: '+threshold70+ '\n' +
                    'maxLimit: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }
        
        if (limitApi.SingleEmail.Remaining < (limitApi.SingleEmail.Max * (100 - threshold70) / 100)) {
            Integer max = limitApi.SingleEmail.Max;
            Integer remaining = limitApi.SingleEmail.Remaining;
            if(Remaining < (max * (100 - threshold80) / 100)) {
                Map<String, Object> msg = new Map<String, Object>();
                msg.put('code', 'SFDC_SingleEmail_THRESHOLD_EXCEEDED');
                msg.put('percentCrossed', threshold80);
                msg.put('maxLimit', max);
                msg.put('remainingLimit', remaining);
    
                MW_LogUtility.warn('MW_Alerts', null, null, 'start', msg);
            }
            
            Map<String, Object> slackMsg = new Map<String, Object>();
        	slackMsg.put('text', ':alert::alert::alert::alert::alert: \n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    'code: '+'SFDC_SingleEmail_THRESHOLD_EXCEEDED' + '\n' +
                    'percentCrossed: '+threshold70+ '\n' +
                    'maxLimit: '+max+ '\n' +
                    'remainingLimit: '+remaining+ '\n' +
                 	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               );
            sendSlackMessage (slackMsg);
        }
        
        System.Debug('query=' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        for (Account act : scope) {
            
        }
    }

    global void finish(Database.BatchableContext BC) {
    }

    private static void sendSlackMessage (Map<String, Object> msg) {
        if(!Test.isRunningTest()) { 
            MW_SlackCallOut.slackCallOut(MW_Settings__c.getInstance().Slack_Middleware_System_Alert_Channel__c, JSON.serialize(msg));
        }
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
                httpResponse.setBody(
                    '{"DailyApiRequests":{"Max":5000000,"Remaining":100000},'+
                    '"DataStorageMB":{"Max":200,"Remaining":10},'+                    
                    '"DailyBulkApiRequests":{"Max":200,"Remaining":10},'+
                    '"DailyAsyncApexExecutions":{"Max":200,"Remaining":10},'+
                    '"DailyDeliveredPlatformEvents":{"Max":200,"Remaining":10},'+
                    '"HourlyPublishedPlatformEvents":{"Max":200,"Remaining":10},'+
                    '"DailyDurableGenericStreamingApiEvents":{"Max":200,"Remaining":10},'+
                    '"HourlyPublishedStandardVolumePlatformEvents":{"Max":200,"Remaining":10},'+
                    '"DailyDurableStreamingApiEvents":{"Max":200,"Remaining":10},'+
                    '"DailyGenericStreamingApiEvents":{"Max":200,"Remaining":10},'+
                    '"DailyStandardVolumePlatformEvents":{"Max":200,"Remaining":10},'+
                    '"DailyStreamingApiEvents":{"Max":200,"Remaining":10},'+
                    '"DurableStreamingApiConcurrentClients":{"Max":200,"Remaining":10},'+
                    '"HourlyTimeBasedWorkflow":{"Max":200,"Remaining":10},'+
                    '"MassEmail":{"Max":200,"Remaining":10},'+
                    '"MonthlyPlatformEvents":{"Max":200,"Remaining":10},'+
                    '"SingleEmail":{"Max":200,"Remaining":10},'+
                    '"StreamingApiConcurrentClients":{"Max":200,"Remaining":10},'+
                    '"FileStorageMB":{"Max":200,"Remaining":10}}'
                );
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
        public cls_DailyBulkApiRequests DailyBulkApiRequests;
        public cls_DailyAsyncApexExecutions DailyAsyncApexExecutions;
        public cls_DailyDeliveredPlatformEvents DailyDeliveredPlatformEvents;
        public cls_HourlyPublishedPlatformEvents HourlyPublishedPlatformEvents;
        public cls_DailyDurableGenericStreamingApiEvents DailyDurableGenericStreamingApiEvents;
        public cls_HourlyPublishedStandardVolumePlatformEvents HourlyPublishedStandardVolumePlatformEvents;
        public cls_DailyDurableStreamingApiEvents DailyDurableStreamingApiEvents;
        public cls_DailyGenericStreamingApiEvents DailyGenericStreamingApiEvents;
        public cls_DailyStandardVolumePlatformEvents DailyStandardVolumePlatformEvents;
        public cls_DailyStreamingApiEvents DailyStreamingApiEvents;
        public cls_DurableStreamingApiConcurrentClients DurableStreamingApiConcurrentClients;
		public cls_HourlyTimeBasedWorkflow HourlyTimeBasedWorkflow;
		public cls_MassEmail MassEmail;
        public cls_MonthlyPlatformEvents MonthlyPlatformEvents;
        public cls_SingleEmail SingleEmail;
        public cls_StreamingApiConcurrentClients StreamingApiConcurrentClients;
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
    
    private class cls_DailyBulkApiRequests {
        public Integer Max;
        public Integer Remaining;
    }
    
    private class cls_DailyAsyncApexExecutions {
        public Integer Max;
        public Integer Remaining;
    }
    
    private class cls_DailyDeliveredPlatformEvents {
        public Integer Max;
        public Integer Remaining;
    }
    
    private class cls_HourlyPublishedPlatformEvents {
        public Integer Max;
        public Integer Remaining;
    }
    
    private class cls_DailyDurableGenericStreamingApiEvents {
        public Integer Max;
        public Integer Remaining;
    }
    
    private class cls_HourlyPublishedStandardVolumePlatformEvents {
        public Integer Max;
        public Integer Remaining;
    }
    
    private class cls_DailyDurableStreamingApiEvents {
        public Integer Max;
        public Integer Remaining;
    }
    
    private class cls_DailyGenericStreamingApiEvents {
        public Integer Max;
        public Integer Remaining;
    }
    
    private class cls_DailyStandardVolumePlatformEvents {
        public Integer Max;
        public Integer Remaining;
    }
    
    private class cls_DailyStreamingApiEvents {
        public Integer Max;
        public Integer Remaining;
    }
    
    private class cls_DurableStreamingApiConcurrentClients {
        public Integer Max;
        public Integer Remaining;
    }
    
    private class cls_HourlyTimeBasedWorkflow {
        public Integer Max;
        public Integer Remaining;
    }
    
    private class cls_MassEmail {
        public Integer Max;
        public Integer Remaining;
    }
    
    private class cls_MonthlyPlatformEvents {
        public Integer Max;
        public Integer Remaining;
    }
    
    private class cls_SingleEmail {
        public Integer Max;
        public Integer Remaining;
    }
    
    private class cls_StreamingApiConcurrentClients {
        public Integer Max;
        public Integer Remaining;
    }
}
