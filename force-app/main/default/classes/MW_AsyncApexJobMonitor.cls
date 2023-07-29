global class MW_AsyncApexJobMonitor implements Database.batchable<sObject>, Schedulable {
	//Schedulable Process
	global void execute(SchedulableContext sc) {
		//MyBatchClass b = new MyBatchClass();
		//database.executebatch(b);
		MW_AsyncApexJobMonitor b = new MW_AsyncApexJobMonitor();
		List<CronTrigger> batchJobList = [Select id, PreviousFireTime, CronJobDetail.Name From CronTrigger Where CronJobDetail.Name = 'AsyncApexJobMonitor'];
		DateTime previousFireTime = DateTime.Now().AddDays(-1);
		if(batchJobList.size() > 0 && batchJobList[0].PreviousFireTime != null) {
			previousFireTime = batchJobList[0].PreviousFireTime;
		}
		b.query = 'SELECT id, ApexClass.Name, CompletedDate, ExtendedStatus, JobType, MethodName, NumberOfErrors, Status, TotalJobItems FROM AsyncApexJob Where Status = \'Failed\' AND CompletedDate >=' + previousFireTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX') + ' AND CompletedDate <=' + DateTime.Now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
		Database.executeBatch(b, 75);
	}

	//Batchable Process
	public String query;

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<AsyncApexJob> scope){
		//call slack logger
		for(AsyncApexJob bj : scope) {
			Map<String, Object> msg = new Map<String, Object>();
			msg.put('text', ':alert: \n' +
			        '*Status:* ' + bj.Status + '\n' +
			        '*ApexClass* *Name:* ' + bj.ApexClass.Name + '\n' +
			        '*Method* *Name:* ' + bj.MethodName + '\n' +
			        '*NumberOfErrors:* ' + bj.NumberOfErrors + '\n' +
			        '*JobId* ' + bj.id + '\n');
			String body = JSON.serialize(msg);
			if(!Test.isRunningTest()) {
				MW_SlackCallOut.slackCallOut(MW_SlackCallOut.logLevelChannels('Error'), body);
			}
		}
	}

	global void finish(Database.BatchableContext BC){
	}
}