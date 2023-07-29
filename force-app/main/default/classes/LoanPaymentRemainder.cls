global class LoanPaymentRemainder Implements Database.batchable<sObject>, Schedulable{
     String query;
     Date CSD = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();   
     LoanPaymentDays__c paymentDueDays = LoanPaymentDays__c.getInstance();  
     Integer autoPaymentDue = Integer.valueOf(paymentDueDays.AutoPaymentRemainder__c);
     Integer manualPaymentDue = Integer.valueOf(paymentDueDays.ManualPaymentRemainder__c);
     Date D3Remainder = CSD + autoPaymentDue;
     Date D15Remainder = CSD + manualPaymentDue;
     //System.debug('...Dates...'+ D3Remainder +'...'+ D15Remainder );
     
     global LoanPaymentRemainder(){
         String productType = 'Manual';
         query = 'SELECT ID, loan__Previous_Installment_Date__c,loan__Account__r.cnotify__Email__c,loan__Loan_Product_Name__r.name, loan__Payment_Amount__c, loan__Next_Installment_Date__c, loan__Account__r.ID,Borrowers_First_Name__c,loan__Account__r.Borrower_s_Last_Name__c,loan__Loan_Product_Name__c from loan__Loan_Account__c WHERE loan__Previous_Installment_Date__c = :D3Remainder OR (loan__Previous_Installment_Date__c = :D15Remainder AND loan__Loan_Product_Name__r.name like \'%' + productType + '%\')';
         System.debug(logginglevel.error,'query+++'+query); 
     }   
     global LoanPaymentRemainder(String query){
         this.query = query;
     }
     
     global void execute(SchedulableContext sc){
         LoanPaymentRemainder lpr = new LoanPaymentRemainder();
         Database.executeBatch(lpr,1);
     }
     
     global Database.QueryLocator start(Database.BatchableContext bc){
         System.debug('...Query...'+query);
         return Database.getQueryLocator(query);
     }
     
     global void execute(Database.BatchableContext bc, List<sObject> scope){
         System.debug('...Scope....' + scope);
         try{
             List<loan__Loan_Account__c > lstLoanPayments = (List<loan__Loan_Account__c >)scope;
             List<loan__Loan_Account__c > lstPaymentRemainders = new List<loan__Loan_Account__c>(); 
             String userId = UserInfo.getUserId();
             
             Id templateId;         
             Id templateId3D =  [select id, name from EmailTemplate where developername = 'Upcoming_Auto_Loan_Payment_Reminder'].Id;
             Id templateIdManual =  [select id, name from EmailTemplate where developername = 'Upcoming_Manual_Loan_Payment_Reminder'].Id;         
                  
             Contact con = new Contact();
             con.LastName = 'Test';
             con.Email = 'no-reply@organization.com';
             insert con; 
             
             Id orgWideEmailId;
             OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where DisplayName = 'PayOff' LIMIT 1];
             if(owea != null)
                orgWideEmailId = owea.Id;
                
             for(loan__Loan_Account__c loanAccount : lstLoanPayments){
                if(loanAccount.loan__Previous_Installment_Date__c != null && loanAccount.loan__Previous_Installment_Date__c == D3Remainder)                
                    templateId = templateId3D;
                
                else if(loanAccount.loan__Previous_Installment_Date__c != null && loanAccount.loan__Loan_Product_Name__r.name != null && (loanAccount.loan__Previous_Installment_Date__c == D15Remainder && loanAccount.loan__Loan_Product_Name__r.name.contains('Manual')))
                    templateId = templateIdManual;                
                String emailAddress = loanAccount.loan__Account__r.cnotify__Email__c;
                SendLoanPaymentEmailHandler.SendMail(templateId, loanAccount.ID, con.Id, orgWideEmailId, emailAddress);
             }
             delete con;
         }
         catch(Exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in SendEnvDocuSignAPI.voidInvestorDocuments:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
            insert logs;
            System.debug('Exception: '+ex.getMessage());    
        }
     }   
     
     global void finish(Database.BatchableContext bc){
     
     } 
}