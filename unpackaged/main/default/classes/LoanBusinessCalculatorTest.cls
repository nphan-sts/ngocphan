@isTest
private class LoanBusinessCalculatorTest {
    
    @isTest static void testCalculatePurchaseDate() {
        // Test Happy Path
        Date originationDate = Date.newInstance(2021, 4, 5);
        Date purchaseDate = LoanBusinessCalculator.calculatePurchaseDate(originationDate, 15);
        System.assertEquals(Date.newInstance(2021, 4, 20), purchaseDate);

        // Test Weekend
        originationDate = Date.newInstance(2021, 4, 2);
        purchaseDate = LoanBusinessCalculator.calculatePurchaseDate(originationDate, 15);
        System.assertEquals(Date.newInstance(2021, 4, 19), purchaseDate);

        // Test Holiday
        originationDate = Date.newInstance(2021, 5, 14);
        purchaseDate = LoanBusinessCalculator.calculatePurchaseDate(originationDate, 15);
        System.assertEquals(Date.newInstance(2021, 6, 1), purchaseDate);
    }
}