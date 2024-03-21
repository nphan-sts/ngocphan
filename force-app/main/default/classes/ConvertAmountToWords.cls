public class ConvertAmountToWords{

    // Call this method with Number to convert
    public String getNumberTOWordConvertion(Decimal num) {

        Decimal inputVal = num;
        Decimal inputValDollar = inputVal - Math.floor(inputVal);
        inputVal = Math.floor(inputVal);

        String obStr = inputVal.toPlainString();
        String[] numReversed = obStr.split('');
        String[] actnumber = reverse(numReversed);
        String firstHalf = convertInWords(numReversed, actnumber);

        Integer tmp = Math.round(inputValDollar * 100);
        inputValDollar = (Decimal)tmp / 100; System.debug('jj :' + inputValDollar);
        String dollarStr = inputValDollar.toPlainString();
        String secondHalf;
        if (dollarStr == '0') {
            secondHalf = '';
        } else if (dollarStr.length() != 4) {
            dollarStr = dollarStr + '0';
            dollarStr = dollarStr.substring(2);
            String [] numReversedDollar = dollarStr.split('');
            String[] actnumberDollar = reverse(numReversedDollar);
            secondHalf = convertInWords(numReversedDollar, actnumberDollar);
        } else {
            dollarStr = dollarStr.substring(2);
            String [] numReversedDollar = dollarStr.split('');
            String[] actnumberDollar = reverse(numReversedDollar);
            secondHalf = convertInWords(numReversedDollar, actnumberDollar);
        }

        String SumOFHalves = '';

        if (secondHalf.length() > 4) {
            firstHalf = firstHalf.replace('Only', 'Dollars And ');
            secondHalf = secondHalf.replace('Only', 'Cents Only');
            SumOFHalves = firstHalf + secondHalf;
        } else {
            firstHalf = firstHalf.replace('Only', 'Dollars Only');
            SumOFHalves = firstHalf;
        }

        // IF amount has any value
        if (SumOFHalves.length() > 5) {
            return SumOFHalves;
        } else {
            return '';
        }
    }
    // Method reverse the number
    public List<String> reverse(List<String> strToRev) {
        List<String> revList = new List<String>();
        for (Integer i = strToRev.size() - 1; i >= 0; i--) {
            revList.add(strToRev.get(i));
        }
        revList.add('');
        return revList;
    }

    public String convertInWords(String[] numRev, String[] actnum) {
        List<String> iWords = new List<String> {'Zero', ' One', ' Two', ' Three', ' Four', ' Five', ' Six', ' Seven', ' Eight', ' Nine'};
        List<String> ePlace = new List<String> {' Ten', ' Eleven', ' Twelve', ' Thirteen', ' Fourteen', ' Fifteen', ' Sixteen', ' Seventeen', ' Eighteen', ' Nineteen'};
        List<String> tensPlace = new List<String> {'dummy', ' Ten', ' Twenty', ' Thirty', ' Forty', ' Fifty', ' Sixty', ' Seventy', ' Eighty', ' Ninety' };

        Integer iWordsLength = numRev.size();
        String totalWords = '';
        List<String> inWords = new List<String>();
        for (Integer k = 0; k < iWordsLength; k++) {
            inWords.add('');
        }
        String finalWord = '';
        Integer j = 0;

        // Main For loop
        for (Integer i = 0; i < iWordsLength; i++) {

            if (i == 0) {
                if (actnum[i] == '0' || actnum[i + 1] == '1') {
                    inWords[j] = '';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])];
                }
                inWords[j] = inWords[j] + ' Only';
            } else if (i == 1) {

                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i] == '1') {
                    inWords[j] = ePlace[Integer.valueof(actnum[i - 1])];
                } else {
                    inWords[j] = tensPlace[Integer.valueof(actnum[i])];
                }
            } else if (i == 2) {
                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i - 1] != '0' && actnum[i - 2] != '0') {
                    inWords[j] = iWords[Integer.valueof(actnum[i])] + ' Hundred and';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])] + ' Hundred';
                }
            } else if (i == 3) {
                if (actnum[i] == '0' || actnum[i + 1] == '1') {
                    inWords[j] = '';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])];
                }
                if (actnum[i + 1] != '0' || Integer.valueof(actnum[i]) > 0) {
                    inWords[j] = inWords[j] + ' Thousand';
                }
            } else if (i == 4) {

                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i] == '1') {
                    inWords[j] = ePlace[Integer.valueof(actnum[i - 1])];
                } else {
                    inWords[j] = tensPlace[Integer.valueof(actnum[i])];
                }

            } else if (i == 5) {
                if (actnum[i] == '0' || actnum[i + 1] == '1') {
                    inWords[j] = '';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])];
                }
                if (actnum[i + 1] != '0' || Integer.valueof(actnum[i]) > 0) {
                    inWords[j] = inWords[j] + ' Lakh';
                }
            } else if (i == 6) {

                if (actnum[i] == '0') {
                    inWords[j] = '';
                    System.debug('AAnum' + actnum);
                    System.debug(actnum[i]);
                } else if (actnum[i] == '1') {
                    inWords[j] = ePlace[Integer.valueof(actnum[i - 1])];
                } else {
                    inWords[j] = tensPlace[Integer.valueof(actnum[i])];
                }

            } else if (i == 7) {
                if (actnum[i] == '0' || actnum[i + 1] == '1' ) {
                    inWords[j] = '';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])];
                }
                inWords[j] = inWords[j] + ' Crore';
            } else if (i == 8) {

                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i] == '1') {
                    inWords[j] = ePlace[Integer.valueof(actnum[i - 1])];
                } else {
                    inWords[j] = tensPlace[Integer.valueof(actnum[i])];
                }

            }

            j++;
        }
        // End of For loop

        // Reverse the List
        inWords = reverse(inWords);

        for (Integer i = 0; i < inWords.size(); i++) {
            finalWord += inWords[i];
        }

        return finalWord;
    }


}