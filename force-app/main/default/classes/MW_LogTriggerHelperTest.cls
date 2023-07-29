@isTest
public class MW_LogTriggerHelperTest { 
    @isTest
    public static void constructNewLogMessage() {
        
        MW_LogUtility.JobLog result = new MW_LogUtility.JobLog();
        // Perform test
        Test.startTest();
        MW_LogTriggerHelper helper = new MW_LogTriggerHelper();
        String name = 'test name';
        String apexClass = 'test class';
        String label = 'test logging';
        String type = 'test type';
        String entry = 'test';
        
        result = helper.construct(name, apexClass, label, type, entry);
        Test.stopTest();

        System.assertEquals(result.apexClass, apexClass, 'apexclass is equal');
        System.assertEquals(result.label, label, 'label is equal');
        System.assertEquals(result.type, type, 'type is equal');
        System.assertEquals(result.message, entry, 'entry is equal');

    }
}
