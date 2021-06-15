public class LoanBusinessCalculator {
    
    public static Date calculatePurchaseDate(Date originationDate, Integer days) {
        Date potentialPurchaseDate = originationDate.addDays(days);
        
        while (isWeekend(potentialPurchaseDate) || isHoliday(potentialPurchaseDate)) {
            potentialPurchaseDate = potentialPurchaseDate.addDays(1);
        }

        return potentialPurchaseDate;
    }

    public static Boolean isHoliday(Date d) {
        List<Holiday> holidays = [SELECT Id, ActivityDate FROM Holiday WHERE ActivityDate =: d];
        return holidays != null && holidays.size() > 0;
    }

    public static Boolean isWeekend(Date d) {
        Integer days = d.daysBetween(d.toStartOfWeek());
        return days == -6 || days == 0;
    }

}