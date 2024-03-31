/* Created By Nupur ------
for Generating Expiry Date */
 public class ExpirationAlertEmail {
   public static void daysbeforeExpirationDate(){
        Expiry_Date__c numofdays = Expiry_Date__c.getInstance(); 
        
        list<genesis__Applications__c> applist = [select genesis__Applications__c.CreatedDate,Expiration_Date_for_Email_trigger__c from genesis__Applications__c];
        for(genesis__Applications__c app: applist){
 
            date createdDated = date.newInstance(app.CreatedDate.year(),app.CreatedDate.month(),app.CreatedDate.day());
            app.Expiration_Date_for_Email_trigger__c = createdDated.adddays((Integer)numofdays.No_of_days_for_Expiration__c);
        }  
        update applist;
        // return applist;
        
    }
    
    
}