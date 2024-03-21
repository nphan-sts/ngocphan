@RestResource(urlMapping='/MemberAccountUpdate/*')
global with sharing class MW_WSMemberAccountUpdate {
   
     global class Response{
        public String status;
        public String errorCode;
        public String errorMessage;
        public String successMessage;
        public Response(){
            errorCode = PayoffConstants.ERROR;
            status = PayoffConstants.FAIL;
        }
    }
    
    @HttpPost
    global static Response MemberAccountUpdate()
    {
           Response res = new Response();
           RestRequest req = RestContext.request;
           Map<String, Object> reqParams = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());  
           String leadId;
           String Phone;
           String Email;
           String Address1;
           String Address2;
           String City;
           String State;
           String ZIP_Code;
          
           loan__Bank_Account__c bankAccountToCreate = new loan__Bank_Account__c();
           
           try
           {
                    if (reqParams.get('leadID') != null)
                    {
                        leadId = (String)reqParams.get('leadID');
                    }
               
                    //Query cl contract to get account id
                    List< loan__Loan_Account__c> clContractListToUpdate = [Select loan__Account__c, name, Id from loan__Loan_Account__c where Application__r.Lead_ID__c =: leadId LIMIT 1 FOR UPDATE];
                    Id accountId;
                    if(clContractListToUpdate.size() > 0)
                     accountId = clContractListToUpdate[0].loan__Account__c;
                      
                    System.debug('******AccountID: '+accountId);
                  
                    List<Account> accountToUpdate = [Select id,name, Phone, cnotify__Email__c,Address_1__c,Address_2__c,State__c,City__c,ZIP_Code__c from Account where Id=: accountId LIMIT 1 FOR UPDATE];
                    //List<Account> accountToUpdate = new List<Account>();
                    if (reqParams.get('Phone') != null) 
                    {
                        Phone = (String)reqParams.get('Phone');
                        accountToUpdate[0].Phone = Phone;
                    }
                    if (reqParams.get('cnotify__Email__c') != null) 
                    {
                        Email = (String)reqParams.get('cnotify__Email__c');
                        accountToUpdate[0].cnotify__Email__c = Email;
                    }
                    if (reqParams.get('Address_1__c') != null) 
                    {
                        Address1 = (String)reqParams.get('Address_1__c');
                        accountToUpdate[0].Address_1__c = Address1;
                    }
                     if (reqParams.get('Address_2__c') != null) 
                    {
                        Address2 = (String)reqParams.get('Address_2__c');
                        accountToUpdate[0].Address_2__c = Address2;
                    }
                     if (reqParams.get('City__c') != null) 
                    {
                        City = (String)reqParams.get('City__c');
                        accountToUpdate[0].City__c = City;
                    }
                    if (reqParams.get('State__c') != null) 
                    {
                        State = (String)reqParams.get('State__c');
                        accountToUpdate[0].State__c = State;
                    }
                    if (reqParams.get('ZIP_Code__c') != null) 
                    {
                        ZIP_Code = (String)reqParams.get('ZIP_Code__c');
                        accountToUpdate[0].ZIP_Code__c = ZIP_Code;
                    }
                    
                   // accountToUpdate = accountToUpdate1;
    
                    //Update Account
                    if(accountToUpdate.size() > 0)
                      upsert accountToUpdate;
                                
                     if(accountToUpdate.size() > 0)
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
               res.errorMessage = e.getMessage() +'; Line Number: '+e.getLineNumber();
               System.debug(logginglevel.error,'line number'+e.getLineNumber());
               System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());

               res.status = peer.Constants.ERROR;
               return res;
               
           }
          
           
           return res;
         
    }

}