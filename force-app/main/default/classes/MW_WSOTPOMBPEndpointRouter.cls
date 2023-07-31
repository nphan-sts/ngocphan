@RestResource(urlMapping='/OTPOMBPEndpoint1/*')
global with sharing class MW_WSOTPOMBPEndpointRouter {

    @HttpPost
    global static String OTPOMBPEndpointRouter()
    {

           RestRequest req1 = RestContext.request;
           System.debug('HERE'+req1);
           Map<String, Object> reqParams = (Map<String, Object>)JSON.deserializeUntyped(req1.requestBody.toString());
           Id applicationId;
           String leadGuid;
           Decimal transactionAmount;
           String debitDate;
           String paymentModeName;
           String frequency;
           String amountType;
           String type;
           String manualSpreadName;
           String response;
           JSONGenerator jsonBody = JSON.createGenerator(true);
           jsonBody.writeStartObject();

           try
           {

                    if (reqParams.get('leadGuid') != null)
                    {
                        leadGuid = (String)reqParams.get('leadGuid');
                    }
                    if (reqParams.get('transactionAmount') != null)
                    {
                        transactionAmount = (Decimal)reqParams.get('transactionAmount');
                        jsonBody.writeNumberField('transactionAmount', transactionAmount);
                    }
                    if (reqParams.get('debitDate') != null)
                    {
                        debitDate = (String)reqParams.get('debitDate');
                        jsonBody.writeStringField('debitDate', debitDate);

                    }
                    if (reqParams.get('paymentModeName') != null)
                    {
                        //paymentModeName = (String)reqParams.get('paymentModeName');
                        paymentModeName = getPaymentMode(leadGuid);
                        jsonBody.writeStringField('paymentModeName', paymentModeName);

                    }
                    if (reqParams.get('frequency') != null)
                    {
                        frequency = (String)reqParams.get('frequency');
                         jsonBody.writeStringField('frequency', frequency);
                    }
                    if (reqParams.get('amountType') != null)
                    {
                        amountType = (String)reqParams.get('amountType');
                        jsonBody.writeStringField('amountType', amountType);

                    }
                    if (reqParams.get('type') != null)
                    {
                        type = (String)reqParams.get('type');
                        jsonBody.writeStringField('type', type);

                    }
                    if (reqParams.get('manualSpreadName') != null)
                    {
                        manualSpreadName = (String)reqParams.get('manualSpreadName');
                        jsonBody.writeStringField('manualSpreadName', manualSpreadName);
                    }
                    jsonBody.writeEndObject();
                    String reqBody = jsonBody.getAsString();

                    //Query application to get accpunt id
                    List<loan__Loan_Account__c> clContractList = [Select id, name, lead_Guid__c from loan__Loan_Account__c where lead_Guid__c =: leadGuid LIMIT 1 FOR UPDATE];
                    Id clContractId;
                    if(clContractList.size() > 0)
                     clContractId = clContractList[0].id;

                    // Calling CLS OTP and OMBP endpoints here

                  
                            String siteURL = MW_Settings__c.getInstance().OTPOMBPSiteURL__c;
                            String endPoint = siteURL+'/services/apexrest/peer/v2/loanAccounts/setupACH/'+clContractId;
                            HttpRequest req = new HttpRequest();
                            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                            req.setHeader('Content-Type', 'application/json');
                            req.setMethod('POST');
                            req.setHeader('Content-Type', 'application/json');
                            req.setHeader('Cache-Control', 'no-cache');

                            System.debug('CLS Request :: >>>' +reqBody  );

                            req.setEndpoint(endPoint);
                            req.setbody(reqBody);
                            Http http = new Http();

                            System.debug('Request:: >>' +req);
                            HTTPResponse res = http.send(req);
                            System.debug('Response :: >> ' +res.getBody()  );

                            response = res.getBody();


                    return response;
           }
          catch(Exception e)
           {
               System.debug('Error: ' + e.getLineNumber() + ' Desc. ' + e.getMessage()+' Stack: '+e.getStackTraceString());

               System.debug(logginglevel.error,'line number'+e.getLineNumber());
               System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());

               return 'Error: ' + e.getLineNumber() + ' Desc. ' + e.getMessage()+' Stack: '+e.getStackTraceString();

           }

    }
    
    public static String getPaymentMode(String LeadId){
        
        loan__Automated_Payment_Configuration__c apc = null;
        
        loan__Loan_Account__c loanAccount = getloanAccountDetails(LeadId);
        
        try{
            apc = [
                SELECT Id,
                       Name,
                       loan__Payment_Mode__r.Name
                FROM   loan__Automated_Payment_Configuration__c
                WHERE  loan__Bank_Account__r.loan__Account__c = :loanAccount.Investor_Account__c
                AND    loan__Active__c = TRUE
                LIMIT  1
            ];
        }
        catch(exception ex)
        {    
           loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToUnderwriterQueue:  '+ex.getlinenumber()+'Error: '+ex.getMessage() + loanAccount.name);             
           insert logs;             
           throw new ints.IntegrationException('NO APC FOUND FOR THIS INVESTOR');         
        }
        return apc.loan__Payment_Mode__r.Name;
    }
    
    
    
     public static loan__Loan_Account__c getloanAccountDetails(String LeadId){
        loan__Loan_Account__c loanAcc = [select id, name, Investor_Account__c, lead_Guid__c
                                                from loan__Loan_Account__c where lead_Guid__c=:LeadId];
        
        
        return loanAcc;
    }

}