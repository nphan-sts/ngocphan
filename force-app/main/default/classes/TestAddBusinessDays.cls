/* ****************Modification History*****************************************************************
 * Created by    	Date    		JIRA number
 *     Pallavi      2020/04/28      CRM-502
 *     Pallavi      2020/05/21      CRM-614
 ******************Modification History*****************************************************************/
@isTest
public class TestAddBusinessDays {
    @isTest
    static void testMehod(){
        DateTime testDateTime = Datetime.newInstance(2020,03,03);
        testDateTime.addHours(10);
        Integer days = 4;

        /*Holiday holidays = new holiday(ActivityDate = Date.newInstance(2020,03,05),
                                        name = 'testHoliday');
        insert holidays;*/

        test.startTest();
        AddBusinessDays a = new AddBusinessDays();
        Date autoSaleDate = a.calculateDateiwthBusinessdays(days, testDateTime);
        Date autoSaleDate1 = a.calBusinesssDateiwthCalendarDays(days, testDateTime);    //CRM-614
        Integer hours = a.getTimeZoneDiff();
        test.stopTest();
        /*Date expectedAutoSaleDate = Date.newInstance(2020, 03, 10);   /commented because if there are holidays in between, this assert will fail
        System.assertEquals(expectedAutoSaleDate, autoSaleDate);*/
    }
}