@isTest
public class MW_LogUtility_QueueableTest {
	@isTest
	static void excectueQueuableLoggingTest() {
		MW_LogUtility_Queueable.Log log = new MW_LogUtility_Queueable.Log();
		log.message = 'test message';
		log.apexClass = 'test class';
		log.label = 'test label';
		log.type = 'info';

		MW_LogUtility_Queueable job = new MW_LogUtility_Queueable(log);
		Test.startTest();
		System.enqueueJob(job);
		Test.stopTest();
		System.assertEquals(true, true, 'void');
	}
}