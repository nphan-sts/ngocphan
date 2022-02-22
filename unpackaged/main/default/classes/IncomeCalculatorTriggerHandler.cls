public class IncomeCalculatorTriggerHandler {

   List<Income_Calculators__c> newRecords;
   Map<Id, Income_Calculators__c> oldMap;
   Map<Id, Income_Calculators__c> newMap;
   private static final Map<String,Integer> frequencyNumberMap = new Map<String,Integer>{
   
   'Weekly' => 52,
   'Bi-Weekly' => 26,
   'Semi-Monthly' => 24,
   'Monthly' => 12,
   'Annually' => 1
   
   };

    public static boolean avoidrecursive = true;

    public IncomeCalculatorTriggerHandler(List<Income_Calculators__c> pNewRecords, Map<Id, Income_Calculators__c> pNewMap, Map<Id, Income_Calculators__c> pOldMap) {
        this.newRecords = pNewRecords;
        this.oldMap = pOldMap;
        this.newMap = pNewMap;
    }

    public void beforeUpdate(){
        if(avoidrecursive){
            avoidrecursive = false;
            updateAnnualizedIncome(); 
        }       
    }

    public void beforeInsert(){
        updateAnnualizedIncome(); 
    }
    
    public void updateAnnualizedIncome(){
        List<Income_Calculators__c> updateRecords = new List<Income_Calculators__c>();
        for(Income_Calculators__c inc : newRecords){
            if(inc.YTD__c){
                if(inc.Pay_Period_Start_Date__c == null){ 
                    inc.Pay_Period_Start_Date__c = Date.newInstance(System.Today().year(),1,1); 
                }
                if(inc.Pay_Period_End_Date__c == null){
                    inc.Pay_Period_End_Date__c = System.Today();
                }
                inc.Number_of_Pays__c = getNumberOfPays(inc);
                integer days_elapsed = (inc.Pay_Period_Start_Date__c.daysbetween(inc.Pay_Period_End_Date__c)+1);
                inc.Annualized_Income__c = (inc.Amount__c / days_elapsed) * 365;
            }else{
                inc.Annualized_Income__c = inc.Amount__c * frequencyNumberMap.get(inc.Frequency_Type__c);
            }
        }
        
    }
    
    public Integer getWEEKNumber(Date dateVal){
        return Integer.valueOf(DateTime.newInstanceGmt(dateVal.toStartOfWeek(), Time.NewInstance(12,0,0,0)).format('w'));    
    }
    
    public Decimal getNumberOfPays(Income_Calculators__c inc){
        Decimal endWeek = getWEEKNumber(inc.Pay_Period_End_Date__c);
        Decimal startWeek = getWEEKNumber(inc.Pay_Period_Start_Date__c);
        switch on inc.Frequency_Type__c {
            when 'Weekly' {       
                return endWeek - startWeek;
            }   
            when 'Bi-Weekly' {       
                return ((endWeek - startWeek) / 2).round(System.RoundingMode.CEILING);
            }
            when 'Semi-Monthly' {       
                return ((inc.Pay_Period_Start_Date__c.monthsBetween(inc.Pay_Period_End_Date__c)+1)*2) +
                (inc.Pay_Period_End_Date__c.day() > 27 ? 0 : -1) + 
                (inc.Pay_Period_Start_Date__c.day() > 15 ? -1 : 0);
            }
            when 'Monthly' {       
                return inc.Pay_Period_Start_Date__c.monthsBetween(inc.Pay_Period_End_Date__c) == 0 ? 1 : inc.Pay_Period_Start_Date__c.monthsBetween(inc.Pay_Period_End_Date__c)+1;
            }
            when 'Annually' {       
                return 1;
            }
            when else {
                throw new CustomIncomeCalculatorException('Unsupported frequency type : ' + inc.Frequency_Type__c);
            }
        }
    }
    public class CustomIncomeCalculatorException extends Exception {}
}