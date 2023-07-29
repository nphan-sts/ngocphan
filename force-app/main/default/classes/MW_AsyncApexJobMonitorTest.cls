@isTest
private class MW_AsyncApexJobMonitorTest {
	@isTest static void MonitorApexJobTest() {
		Test.startTest();

		//Run schedule jobs
		MW_AsyncApexJobMonitor asyncJobSchedule = new MW_AsyncApexJobMonitor();
		System.schedule('AsyncApexJobMonitor', '0 0 0 * * ?', asyncJobSchedule);

		Test.stopTest();
	}
}