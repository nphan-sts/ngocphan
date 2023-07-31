@RestResource(urlMapping='/ACHAccount/*')
global with sharing class MW_WSACHAccount {
   
     global class Response{
        public String status;
        public String errorCode;
        public String errorMessage;
        public String successMessage;
       /* public Response(){
            errorCode = PayoffConstants.ERROR;
            status = PayoffConstants.FAIL;
        }*/
    }
    
    @HttpPost
    global static Response ACHAccount()
    {
           Response res = new Response();
           RestRequest req = RestContext.request;
           Map<String, Object> reqParams = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());  
           Id applicationId;
           String bankAccountNumber;
           String bankAccountType;
           String bankAccountName;
           String bankRoutingNumber;
           String paymentMode;
           String firstName;
           String lastName;
           
           loan__Bank_Account__c bankAccountToCreate = new loan__Bank_Account__c();
           
           try
           {
                    if (reqParams.get('genesis__Applications__c') != null)
                    {
                        applicationId = (Id)reqParams.get('genesis__Applications__c');
                    }
                    if (reqParams.get('loan__Bank_Account_Number__c') != null) 
                    {
                        bankAccountNumber = (String)reqParams.get('loan__Bank_Account_Number__c');
                    }
                    if (reqParams.get('loan__Account_Type__c') != null) 
                    {
                        bankAccountType = (String)reqParams.get('loan__Account_Type__c');
                    }
                    if (reqParams.get('loan__Bank_Name__c') != null) 
                    {
                        bankAccountName = (String)reqParams.get('loan__Bank_Name__c');
                    }
                    if (reqParams.get('loan__Routing_Number__c') != null) 
                    {
                        bankRoutingNumber = (String)reqParams.get('loan__Routing_Number__c');
                    }
                    if (reqParams.get('Payment_Mode__c') != null) 
                    {
                        paymentMode = (String)reqParams.get('Payment_Mode__c');
                    }
                    if (reqParams.get('First_Name__c') != null) 
                    {
                        firstName = (String)reqParams.get('First_Name__c');
                    }
                    if (reqParams.get('Last_Name__c') != null) 
                    {
                        lastName = (String)reqParams.get('Last_Name__c');
                    }
                    
                    //Query application to get accpunt id
                    List< genesis__Applications__c> applicationListToUpdate = [Select genesis__Account__c, Bank_Account__c, name, Id from genesis__Applications__c where id =: applicationId LIMIT 1 FOR UPDATE];
                    Id accountId;
                    if(applicationListToUpdate.size() > 0)
                     accountId = applicationListToUpdate[0].genesis__Account__c;
                      
                     //   System.debug('******AccountID: '+accountId);
                    
                    //Create bank account
                    String maskedBankAccount = bankAccountNumber != null || bankAccountNumber != ''? '*******' + bankAccountNumber .right(4) : bankAccountNumber;
                    bankAccountToCreate.loan__Bank_Account_Number__c = maskedBankAccount;
                    bankAccountToCreate.loan__Account_Type__c = bankAccountType;
                    bankAccountToCreate.loan__Bank_Name__c = bankAccountName;
                    bankAccountToCreate.loan__Routing_Number__c = bankRoutingNumber;
                    bankAccountToCreate.loan__Account__c = accountId;
                    bankAccountToCreate.loan__Active__c = true;
                    bankAccountToCreate.Unmasked_Bank_Account_Number__c=bankAccountNumber;
                    bankAccountToCreate.First_Name__c = firstName;
                    bankAccountToCreate.Last_Name__c = lastName;
                    bankAccountToCreate.loan__Account_Usage__c = 'Borrower/Investor Account';
                    
                    insert bankAccountToCreate;          
                     
                    //Get bank account Id
                    Id bankAccountId = bankAccountToCreate.id;
                    
                    // Get CL product based on payment Mode
                    String paymentType;
                    if(paymentMode == 'AutoPay') paymentType = 'Auto Payer';
                    else paymentType = 'Manual Payer';
                   
                    List<clcommon__CL_Product__c> productlist  = new List<clcommon__CL_Product__c>([SELECT Id,Name from clcommon__CL_Product__c where clcommon__Product_Name__c=: paymentType limit 1]);
              
                    //Add bank account to application
                    if(applicationListToUpdate.size() > 0)
                    {
                       applicationListToUpdate[0].Bank_Account__c =  bankAccountId;              
                       applicationListToUpdate[0].Payment_Mode__c = paymentMode;
                       applicationListToUpdate[0].genesis__CL_Product__c =productlist[0].Id;
                    }
                    //Update application
                    if(applicationListToUpdate.size() > 0)
                      update applicationListToUpdate;
                     
                     //   System.debug('******BankAccountID: '+bankAccountId);
                     //   System.debug('******applicationListToUpdate: '+applicationListToUpdate);
            
                     if(applicationListToUpdate.size() > 0)
                     {
                         res.successMessage ='Success!!';
                         res.status = peer.Constants.SUCCESS;
                     }  
                     else
                     {
                           res.errorCode = 'INVALID_INPUT';
                           res.status = peer.Constants.ERROR;
                     }
           
           }
           catch(Exception e)
           {
               res.errorCode = 'INVALID_INPUT';
               res.errorMessage = e.getMessage() +'Line Number:'+e.getLineNumber();
               System.debug(logginglevel.error,'line number'+e.getLineNumber());
               System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());

               res.status = peer.Constants.ERROR;
               return res;
               
           }
          
           
           return res;
         
    }

}