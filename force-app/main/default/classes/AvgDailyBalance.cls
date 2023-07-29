public class AvgDailyBalance {
    
    public static double avgDailyBal;
    
    public double countAvgDailyBalance(list<Yodlee_User_Transaction__c> yodleeTxn){
        
        integer len = yodleeTxn.size();
        
        double runningBal = 0;
        double count = 0;
        try{
            For(integer i=0; i< len; i++){
                double dailyBal = 0;
                For(integer j=i;j< len; j++){
                    if(yodleeTxn.get(i).postDate__c == yodleeTxn.get(j).postDate__c){
                        dailyBal += yodleeTxn.get(j).Balance__c;
                    }
                    else {
                        dailyBal = yodleeTxn.get(j).Balance__c;
                        break;
                    }
                    runningBal += dailyBal;
                }
                count += 1;
            }
            avgDailyBal = (runningBal / count);
            return avgDailyBal;
        } catch(Exception e){
            System.debug('Avg Daily Bal -> ' + e.getMessage());
            return 0;
        }
        
    } 
}