/* ****************Modification History*****************************************************************
 * Created by    	Date    		JIRA number
 *     Pallavi      2020/04/28      CRM-502 auto sale to funding partner(to calculate date by adding only business days)
 *     Pallavi      2020/05/21      CRM-614 auto Loan sale day calculation updatesr(to calculate date by adding calendar days)
 ******************Modification History*****************************************************************/
public class AddBusinessDays {
    public Date calculateDateiwthBusinessdays(Integer totalDays,DateTime initialDateTime){

        integer daysToadd = 0;
        integer Calculatedays = 0;
        integer finaldaysToCalculateDate = totalDays;
        Date autoSaleDate = initialDateTime.date();
        Date initialDate = initialDateTime.date();
        Integer days = totalDays;
        String dayOfWeek = '';
        DateTime startDateTime = initialDateTime;
      

        Map<String,Integer> weekDays = new Map<String,Integer>();
        weekDays.put('Monday', 5);
        weekDays.put('Tuesday', 4);
        weekDays.put('Wednesday', 3);
        weekDays.put('Thursday', 2);
        weekDays.put('Friday', 1);
        
        while(finaldaysToCalculateDate != 0){
            dayOfWeek=startDateTime.format('EEEE');
            System.debug('initialDate ' + initialDate + ' days ' + days + ' dayOfWeek ' +dayOfWeek );
            
            Integer toCheckMinDaysForWeekend = weekDays.get(dayOfWeek);
            if(toCheckMinDaysForWeekend <= days){
                Calculatedays = (days/toCheckMinDaysForWeekend) * 2;
                if(days + Calculatedays < 7)
                    daysToadd = Calculatedays;
                else
                    daysToadd = ((days + Calculatedays)/7) * 2;
            }
            finaldaysToCalculateDate = finaldaysToCalculateDate + daysToadd;
            autoSaleDate = autoSaleDate.addDays(finaldaysToCalculateDate);
            startDateTime = startDateTime.addDays(finaldaysToCalculateDate);
            finaldaysToCalculateDate = 0;
            List<holiday> holidays = [select id,ActivityDate from Holiday where ActivityDate >: initialDate and ActivityDate <=: autoSaleDate];
            System.debug(holidays);
            for(holiday b : holidays){
                Datetime checkWeekend = (Datetime) b.ActivityDate;
                checkWeekend = checkWeekend.addHours(10);
                String Weekend = checkWeekend.format('EEEE');
                if(!Weekend.equalsIgnoreCase('Saturday') && !Weekend.equalsIgnoreCase('Sunday'))
                    finaldaysToCalculateDate++;
            }
            days = finaldaysToCalculateDate;
            initialDate = autoSaleDate;
            daysToadd = 0;
            System.debug('finaldaysToCalculateDate ' + finaldaysToCalculateDate);
        }
        System.debug('autoSaleDate ' + autoSaleDate);
        return autoSaleDate;
    }
    /*CRM-614*/
    public Date calBusinesssDateiwthCalendarDays(Integer totalDays,DateTime initialDateTime){

        Date autoSaleDate;
        DateTime endDateTime;
        boolean holiday = true;
        
        endDateTime = initialDateTime.addDays(totalDays);
        Set<Date> holidayDates;

        while(holiday){
            if(endDateTime.format('EEEE').equalsIgnoreCase('Saturday')){
                endDateTime = endDateTime.addDays(2);
            }
            else if(endDateTime.format('EEEE').equalsIgnoreCase('Sunday')){
                endDateTime = endDateTime.addDays(1);
            }

            holidayDates = checkHoliday(endDateTime.date(),endDateTime.addDays(totalDays).date());
            if(holidayDates.size() == 0)
                holiday = false;
            for(integer i = 1; i<=holidayDates.size();i++){
                if(holidayDates.contains(endDateTime.date()))
                    endDateTime = endDateTime.addDays(1);
                else{
                    if(i==1)
                        holiday = false;
                    break;
                }
            }
        }
        
        autoSaleDate = endDateTime.date();

        System.debug('autoSaleDate ' + autoSaleDate);
        return autoSaleDate;
    }
    Set<Date> checkHoliday(Date startDate, Date endDate){
        List<holiday> holidays = [select id,ActivityDate from Holiday where ActivityDate >=: startDate and ActivityDate <=: endDate];
        Set<Date> setHoliday = new Set<Date>();
        for(holiday temp : holidays)
            setHoliday.add(temp.ActivityDate);
        return setHoliday;
    }
    public Integer getTimeZoneDiff(){
        Schema.DescribeFieldResult fieldResult = Organization.TimeZoneSidKey.getdescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Map<String,String> gmtValue = new Map<String,String>();
        for(Schema.PicklistEntry ple1 : ple)
            gmtValue.put(ple1.getValue(), ple1.getlabel());
        
        Organization org =[select id,TimeZoneSidKey from Organization];
        String timeZone = gmtValue.get(org.TimeZoneSidKey);
        Integer dayLightVaue = Integer.valueOf(timeZone.substring(6,7));

        return dayLightVaue;
    }
    /*CRM-614*/
}