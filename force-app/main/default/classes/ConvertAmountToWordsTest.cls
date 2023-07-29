@isTest
Private Class ConvertAmountToWordsTest{    
    Static testMethod Void getNumberTOWordConvertion_UseCase1(){
        ConvertAmountToWords Amt = new ConvertAmountToWords();
        String convertedStr0 = Amt.getNumberTOWordConvertion(123406780.00);
        String convertedStr1 = Amt.getNumberTOWordConvertion(1030567091);
        String convertedStr2 = Amt.getNumberTOWordConvertion(321456782.12);
        String convertedStr3 = Amt.getNumberTOWordConvertion(10015678.1);
        String convertedStr4 = Amt.getNumberTOWordConvertion(123450789);
        String convertedStr5 = Amt.getNumberTOWordConvertion(12345608.12);
        String convertedStr6 = Amt.getNumberTOWordConvertion(023456700.1);
        //System.assertEquals('One Crore Twenty Three Lakh Forty Five Thousand Six Hundred and Seventy Eight Dollars Only', convertedStr);
    }
}