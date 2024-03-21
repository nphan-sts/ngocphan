@isTest
private class LoanBusinessCalculatorTest {
    @isTest static void testCalculatePurchaseDate() {
        Date d = System.today().addYears(-1);
        Datetime dt = (DateTime)d;
        String dayOfWeek = dt.format('EEEE');
        
        // Test Weekend
        if(dayOfWeek == 'Sunday' || dayOfWeek == 'Saturday'){
            Date originationDate = System.TODAY().addYears(-1);
            Date purchaseDate = LoanBusinessCalculator.calculatePurchaseDate(originationDate, 15);
            System.assertEquals(System.TODAY().addYears(-1).addDays(15), purchaseDate);
        }else{
            // Test Happy Path
            Date originationDate = System.TODAY().addYears(-1);
            Date purchaseDate = LoanBusinessCalculator.calculatePurchaseDate(originationDate, 15);
            System.assertEquals(System.TODAY().addYears(-1).addDays(15), purchaseDate);
        }
    }
}