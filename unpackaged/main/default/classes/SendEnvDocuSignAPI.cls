/*  Description: Send Documents for e-Sign through DocuSign API
    Developer           Date            Description
    Mohseen Begum       12/05/2017      Created
                        25/09/2017      Modified
    Other tickets       NA              CRM-1003, CLS-193, LOS-196
    Pallavi             2019-11-29      LOS-205(setting the tieout to 120 sec) 
    Abhijeet            2023-01-31.     LPC-354 Update Anniversary / Payment start date logic for prom note for Feb month
    --------------------------------------------------------------------------- */

public with sharing class SendEnvDocuSignAPI {
    
    Public static boolean isDSTrgExecuting = true;
    Public static boolean isvoidTrgExecuting = true;
    Public static Date signDateforPaymentStartDate;
    Public FINAL static Integer timeOut = 120000;
    Public FINAL Static String dateFormat = 'MMMMMMMM dd, yyyy';
            
    
    Public Static String accountID = DocuSignAPICred__c.getInstance().account_ID__c;
    Public Static String userName = DocuSignAPICred__c.getInstance().userName__c;
    Public Static String passWord = DocuSignAPICred__c.getInstance().passWord__c;
    Public Static String integratorKey = DocuSignAPICred__c.getInstance().integrator_Key__c;
    Public Static String DocusignEndpoint = DocuSignAPICred__c.getInstance().EndpointURL__c;
    
    public SendEnvDocuSignAPI (boolean isExecuting){
        isDSTrgExecuting= isExecuting;
        isvoidTrgExecuting = isExecuting;
    }

    public Static Void sendDocuSignEnvelope(Id ApplicationId){

        if(isDSTrgExecuting) {
            sendInvestorDocuments(ApplicationId);
            isDSTrgExecuting= false;
        }
    }

    public Static Void voidDocuSignEnvelope(String envelopeID){

        if(isvoidTrgExecuting) {
            voidInvestorDocuments(envelopeID);
            isvoidTrgExecuting= false;
        }
    }

    
    @Future(callout=true)
    public static Void sendInvestorDocuments(Id ApplicationId){

        List<genesis__Applications__c> lstApp = [SELECT Applicant_Name__c, Name, DocuSignFlag__c, Application_Email__c, Bank_Account__c, Employer__c, Investor__c, DocuSign_EnvelopeId__c,Borrower_Name_Formula__c,
                                                    Employment_Status__c, genesis__Account__c, genesis__Bank_Account_Number__c,
                                                    genesis__Bank_Account_Type__c, genesis__Bank_Name__c, genesis__Loan_Amount__c,
                                                    genesis__Monthly_Income_Expense_Info__c, genesis__No_Of_Payments_Required_Upfront__c,
                                                    genesis__Payment_Amount__c, genesis__Payment_Due_Date__c, genesis__Routing_Number__c,
                                                    genesis__Status__c, Investor__r.Name, genesis__Term__c,
                                                    genesis__Account__r.Borrower_s_First_Name__c, genesis__Account__r.Borrower_s_Last_Name__c,
                                                    genesis__Account__r.peer__First_Name__c, genesis__Account__r.peer__Last_Name__c,
                                                    genesis__Account__r.loan__SOCIAL_SECURITY_NUMBER__c, genesis__Account__r.peer__Date_of_Birth__c,
                                                    genesis__Account__r.Address_1__c, genesis__Account__r.Address_2__c, genesis__Account__r.City__c,
                                                    genesis__Account__r.State__c, genesis__Account__r.ZIP_Code__c,
                                                    genesis__Account__r.Suffix__c,
                                                    genesis__Account__r.Phone, genesis__Account__r.peer__Email__c,
                                                    Payoff_UID__c, Lead_ID__c, TU_consumer_id__c,
                                                    genesis__Account__r.cnotify__Email__c,
                                                    genesis__Total_Estimated_Interest__c,  
                                                    genesis__Financed_Amount__c,   
                                                    Origination_fee__c,    
                                                    Last_Payment_Amount__c,    
                                                    DCP_total_amount__c,       
                                                    Bank_Account__r.loan__bank_name__c, 
                                                    (select id,genesis__Name_of_employer__c,Work_Email__c,
                                                    genesis__Phone__c,genesis__Number_of_years_on_job__c,
                                                    genesis__Position__c from genesis__Employment_Information__r order by createddate limit 1),
                                                    genesis__Account__r.US_Citizen__c
                                                    FROM genesis__Applications__c where Id=:applicationId ORDER BY CreatedDate LIMIT 1];
        

        if(!lstApp.isEmpty()) {

            system.debug('App:' +lstApp[0].genesis__Status__c);

            String name = '';
            name = lstApp[0].genesis__Account__r.peer__First_Name__c +' '+ lstApp[0].genesis__Account__r.peer__Last_Name__c;
            String email = '';
            if(lstApp[0].Application_Email__c != null)
                email = lstApp[0].Application_Email__c;
            String address1 = '';
            if(lstApp[0].genesis__Account__r.Address_1__c != null)
                address1 = lstApp[0].genesis__Account__r.Address_1__c;
            String address2 = '';
            if(lstApp[0].genesis__Account__r.Address_2__c != null)
                address2 = lstApp[0].genesis__Account__r.Address_2__c;
            
            
            Decimal finance_charge = 0;
            Decimal amount_financed = 0;
            Decimal last_payment_amount = 0;
            Decimal ach_amount = 0;
            
            if((lstApp[0].genesis__Total_Estimated_Interest__c != null)&&(lstApp[0].Origination_fee__c != null))  
                finance_charge = lstApp[0].genesis__Total_Estimated_Interest__c + lstApp[0].Origination_fee__c;
            
            if(lstApp[0].genesis__Financed_Amount__c != null)
                amount_financed = lstApp[0].genesis__Financed_Amount__c;
            
            if(lstApp[0].Last_Payment_Amount__c != null)
                last_payment_amount = lstApp[0].Last_Payment_Amount__c;
            
            if(lstApp[0].DCP_total_amount__c != null)
                ach_amount = lstApp[0].genesis__Loan_Amount__c - lstApp[0].Origination_fee__c - lstApp[0].DCP_total_amount__c;
            

            String workPhone = '';
            String employerName = '';
            String empTenure = '';
            String position = '';
            String workEmail = '';
            String tu_consumer_id = '';
            if(lstApp[0].genesis__Employment_Information__r != null && lstApp[0].genesis__Employment_Information__r.size() > 0) {

                if(lstApp[0].genesis__Employment_Information__r[0].genesis__Phone__c != null)
                    workPhone = lstApp[0].genesis__Employment_Information__r[0].genesis__Phone__c;

                if(lstApp[0].genesis__Employment_Information__r[0].genesis__Name_of_employer__c != null)
                    employerName = lstApp[0].genesis__Employment_Information__r[0].genesis__Name_of_employer__c;

                if(lstApp[0].genesis__Employment_Information__r[0].genesis__Number_of_years_on_job__c != null)
                    empTenure = String.valueof(lstApp[0].genesis__Employment_Information__r[0].genesis__Number_of_years_on_job__c);

                if(lstApp[0].genesis__Employment_Information__r[0].genesis__Position__c != null)
                    position = lstApp[0].genesis__Employment_Information__r[0].genesis__Position__c;

                if(lstApp[0].genesis__Employment_Information__r[0].Work_Email__c!= null)
                    workEmail = lstApp[0].genesis__Employment_Information__r[0].Work_Email__c;
                
                if(lstApp[0].TU_consumer_id__c!= null)
                    tu_consumer_id = lstApp[0].TU_consumer_id__c;
                
            }

            String docType;
            List<DocuSign_Template__c> lstDSTemplate;
            String templateID;

            List<genesis__Document_Category__c> documentType = [select Id, genesis__Category_Name__c from genesis__Document_Category__c
                                                                where Application_Status__c = :lstApp[0].genesis__Status__c and genesis__Category_Name__c='ESign Documents'];

            if(!documentType.isEmpty()) {

                docType = documentType[0].genesis__Category_Name__c;
                lstDSTemplate = [select Name, Template_Id__c, State__c from DocuSign_Template__c where
                                    Account__c =:lstApp[0].Investor__c and Document_Category__c= :documentType[0].Id and Active__c = True];

                if(!lstDSTemplate.isEmpty()) {
                    
                    if(lstApp[0].genesis__Account__r.State__c != null) {
                        for(DocuSign_Template__c dsTemplate : lstDSTemplate) {
                            if(dsTemplate.State__c != null) {
                                String[] statesList = dsTemplate.State__c.split(',');
                                if(statesList.size()==1) {
                                    if((lstApp[0].genesis__Account__r.State__c).toUppercase() == (dsTemplate.State__c).toUppercase())
                                        templateID = dsTemplate.Template_Id__c;
                                }else{
                                    for(Integer i=0; i<statesList.size(); i++) {
                                        if((lstApp[0].genesis__Account__r.State__c).toUppercase() == statesList[i].toUppercase().trim())
                                            templateID = dsTemplate.Template_Id__c;
                                    }
                                }
                            }
                            else
                                templateID = dsTemplate.Template_Id__c;
                        }
                    }
                    String accountSuffix = '';
                    if(lstApp[0].genesis__Account__r.Suffix__c != null) {
                        accountSuffix = lstApp[0].genesis__Account__r.Suffix__c;
                    }
                    Boolean chkUSCitizen = false, chkNonUSCitizen = false;
                    if(lstApp[0].genesis__Account__r.US_Citizen__c != null) {
                        if(lstApp[0].genesis__Account__r.US_Citizen__c)
                            chkUSCitizen = true;
                        else
                            chkNonUSCitizen = true;
                    }
                    String memberDOB ='';
                    if(lstApp[0].genesis__Account__r.peer__Date_of_Birth__c != null) {
                        memberDOB = lstApp[0].genesis__Account__r.peer__Date_of_Birth__c.format();
                    }
                    Boolean accountSavings = false, accountCheckings = false;
                    String acctNumber ='', lenderRountingNumber = '';
                    if(lstApp[0].genesis__Account__c != null) {
                        List<loan__Bank_Account__c> lstAccount = [SELECT loan__Account_Type__c, Unmasked_Bank_Account_Number__c, loan__Routing_Number__c FROM loan__Bank_Account__c WHERE loan__Account__c =:lstApp[0].genesis__Account__c and loan__Active__c = true];
                        if(!lstAccount.isEmpty()) {
                            if(lstAccount [0].loan__Account_Type__c != null) {
                                if(lstAccount[0].loan__Account_Type__c == 'Savings')
                                    accountSavings = true;
                                if(lstAccount[0].loan__Account_Type__c == 'Checking')
                                    accountCheckings = true;
                                if(lstAccount[0].Unmasked_Bank_Account_Number__c!= null)
                                    acctNumber = lstAccount[0].Unmasked_Bank_Account_Number__c;
                                if(lstAccount[0].loan__Routing_Number__c != null)
                                    lenderRountingNumber = lstAccount[0].loan__Routing_Number__c;
                            }
                        }
                    }

                    List<Pricing_Offer__c> lstOffer = [SELECT Application__c, Amount__c, Interest_Rate__c,IntRate_Words__c, Monthly_Payment__c, Term__c, Origination_Fee_Rate__c,APR__C FROM Pricing_Offer__c where Application__c =:ApplicationId and Is_Offer_Selected__c=true];  //pallavi

                    Decimal loanTerm = 0;
                    String monthlyPayment = '', paymentAmount = '', adjPaymentAmountD = '';
                    Decimal adjPaymentAmount = 0.00, adjMonthlyPayment = 0.00;
                    String paymentAmountW = 'Zero';
                    Decimal ROI = 0;
                    String ROI_W = '';
                    Decimal apr = 0;
                    Decimal total_of_payments = 0;
                    Decimal OriginationFeeRate = 0;
                    list<String> currFormat = new String[] {'0','number','###,###,##0.00'};
                    list<String> monthlyCurrFormat = new String[] {'0','number','###,###,##0.00'};
                    if(!lstOffer.isEmpty()) {
                        if(lstOffer[0].Origination_Fee_Rate__c!= null)
                            OriginationFeeRate = lstOffer[0].Origination_Fee_Rate__c;
                        if(lstOffer[0].Term__c != 0)
                            loanTerm = lstOffer[0].Term__c;
                        if(lstOffer[0].Monthly_Payment__c != null && lstOffer[0].Monthly_Payment__c != 0) {
                            adjMonthlyPayment = lstOffer[0].Monthly_Payment__c;
                            adjMonthlyPayment = adjMonthlyPayment.setScale(2);
                            monthlyPayment = String.valueOf(adjMonthlyPayment);
                        }

                        if(lstOffer[0].Amount__c != null && lstOffer[0].Amount__c != 0) {
                            adjPaymentAmount = lstOffer[0].Amount__c;
                            adjPaymentAmountD = '$ '+ String.valueOf(lstOffer[0].Amount__c.setScale(2));

                            paymentAmount = String.valueOf(adjPaymentAmount);
                            paymentAmount = String.format(adjPaymentAmount.format(),currFormat);
                            paymentAmount = paymentAmount + '.00';
                            ConvertAmountToWords cAmount = new ConvertAmountToWords();
                            paymentAmountW = cAmount.getNumberTOWordConvertion(lstOffer[0].Amount__c).substringBefore('Dollars Only');
                        }
                        if(lstOffer[0].Interest_Rate__c != null){
                            ROI = lstOffer[0].Interest_Rate__c;
                            ROI_W = lstOffer[0].IntRate_Words__c;
                        }
                        
                        if(lstOffer[0].APR__c != null)
                            apr = lstOffer[0].APR__c;
                        if((lstOffer[0].Monthly_Payment__c != null)&&(lstOffer[0].Term__c != null))
                            total_of_payments = lstOffer[0].Monthly_Payment__c * lstOffer[0].Term__c;
                        
                    }
                    
                    
                    List<DCp_Arcus_Transactions__c> lstDCP = [SELECT id,Requested_Amount__c
                                    FROM DCp_Arcus_Transactions__c WHERE Application__c =: ApplicationId and Pay_at_Funding__c = true];
                    

                    List<genesis__Amortization_Schedule__c> lstAmortization = [SELECT genesis__Due_Date__c FROM genesis__Amortization_Schedule__c where genesis__Application__c=:ApplicationId];
                    String paymentEndDate, paymentStartDate;
                    if(!lstAmortization.isEmpty()) {
                        Integer lstSize = lstAmortization.Size();
                        if(lstAmortization[0].genesis__Due_Date__c != null) {
                             /* LPC-359 Feb payment start date / anniversary date promissory note issue fix */
                            if(signDateforPaymentStartDate == null){
                                signDateforPaymentStartDate = system.today();
                            } 
                            Date anniversaryDate = getPaymentStartDate();
                            paymentStartDate = getFormattedDate(anniversaryDate); 
                        }
                        if(lstAmortization[lstSize-1].genesis__Due_Date__c != null) {
                            Date dt = addWorkingDays(system.today(),3,Integer.valueOf(loanTerm)); 
                            dt = getCalculatedDate(dt); 
                            paymentEndDate = getFormattedDate(dt); 
                        }
                    }
                    String appLoanId = '';
                    if(lstApp[0].Lead_ID__c!= null) {
                        String payoffLoanID = lstApp[0].Lead_ID__c;
                        List<String> splitLoanID = payoffLoanID.split('-');
                        appLoanId = 'P'+(splitLoanID[4]).toUppercase();
                    }
                    else{
                        appLoanId = string.valueOf(lstApp[0].Name).toUppercase();
                    }    
                        
                    String endPoint = DocusignEndpoint+'/accounts/'+accountID+'/envelopes/';

                    //This Endpoint supports creating an envelope with the templateId.
                    HttpRequest req = new HttpRequest();
                    String methodType = 'POST';
                    req.setEndpoint(endpoint);
                    req.setMethod(methodType);

                    //Apex HTTP Method Initialization.
                    String authorizationHeader = '<DocuSignCredentials><Username>'+userName+
                                                    '</Username><Password>'+Password+
                                                    '</Password><IntegratorKey>'+integratorKey+
                                                    '</IntegratorKey></DocuSignCredentials>';
                    System.debug('Authorization Header:..........' + authorizationHeader);
                    req.setHeader('X-DocuSign-Authentication', authorizationHeader);
                    req.setHeader('Accept','application/json');
                    req.setHeader('Content-Length','162100');
                    req.setHeader('Content-Type','application/json');
                    req.setHeader('Content-Disposition','form-data');
                    req.setTimeout(timeOut); 

                    String json =
                        '{'+
                        '"emailBlurb": "Dear '+ lstApp[0].Borrower_Name_Formula__c + ',<br /> <br /> Congrats! Your Payoff Loan documents are ready for you to review, accept and eSign for your convenience. All you need to do is click the link below and follow the instructions to accept, and sign your final documents.<br /><br /> This is a required final step before we deposit your Payoff Loan funds into your bank account.<br /><br /> If you have any questions, feel free to give us a call at 1-800-878-0901.",'+
                        '"emailSubject": "Action Required - Please eSign your '+ docType +' '+ applicationId +'",'+
                        '"status": "sent",'+                        
                        '"templateId" : "'+templateID +'",'+
                        '"templateRoles": ['+
                        '{'+
                        '"email": "'+email+'",'+
                        '"name": "'+name+'",'+
                        '"clientUserId": "'+lstApp[0].Lead_ID__c+'",'+
                        '"roleName": "Member",'+
                        '"tabs": '+
                        '{'+
                        '"textTabs": ['+
                        '{'+

                        '"tabLabel": "MemberName",'+
                        '"value": "'+name+'"'+
                        '},'+

                        '{'+
                        '"tabLabel": "BankAccountNumber",'+
                        '"value": " "'+
                        '},'+

                        '{'+

                        '"tabLabel": "PaymentAmount",'+
                        '"value": "'+paymentAmount+'"'+
                        '},'+
                        '{'+

                        '"tabLabel": "PaymentAmount$",'+
                        '"value": "'+adjPaymentAmountD+'"'+
                        '},'+
                        '{'+

                        '"tabLabel": "PaymentAmountPN",'+
                        '"value": "'+paymentAmount+'"'+
                        '},'+
                        '{'+
                        
                        '"tabLabel": "TU_consumer_id",'+
                        '"value": "'+tu_consumer_id+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "ACHDate",'+
                        '"value": " "'+
                        '},'+
                        '{'+

                        '"tabLabel": "BankName",'+
                        '"value": "'+lstApp[0].Bank_Account__r.loan__bank_name__c+'"' +           
                        '},'+
                        '{'+
                        '"tabLabel": "BankPhoneNumber",'+
                        '"value": " "' +
                        '},'+
                        '{'+
                        '"tabLabel": "AccountNumber",'+
                        '"value": "'+acctNumber+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "RoutingAccountNumber",'+
                        '"value": "'+lenderRountingNumber+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "FirstName",'+
                        '"value": "'+lstApp[0].genesis__Account__r.peer__First_Name__c+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MiddleName",'+
                        '"value": "'+ +'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "LastName",'+
                        '"value": "'+lstApp[0].genesis__Account__r.peer__Last_Name__c+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "SSN",'+
                        '"value": "'+lstApp[0].genesis__Account__r.loan__SOCIAL_SECURITY_NUMBER__c +'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "DOB",'+
                        '"value": "'+memberDOB+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MemberAddress1",'+
                        '"value": "'+address1+' '+address2+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MemberAddress2",'+
                        '"value": "'+address2+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MemberCity",'+
                        '"value": "'+lstApp[0].genesis__Account__r.City__c+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MemberState",'+
                        '"value": "'+lstApp[0].genesis__Account__r.State__c+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MemberZIP",'+
                        '"value": "'+lstApp[0].genesis__Account__r.ZIP_Code__c+'"'+
                        '},'+                                       '{'+
                        '"tabLabel": "MemberHPhone",'+
                        '"value": "'+lstApp[0].genesis__Account__r.Phone+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MemberWPhone",'+
                        '"value": "'+workPhone+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MemberPhone",'+
                        '"value": "'+ lstApp[0].genesis__Account__r.Phone +'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MemberEmail",'+
                        '"value": "'+lstApp[0].genesis__Account__r.cnotify__Email__c+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MemberWEmail",'+
                        '"value": "'+workEmail+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MemberEmployer",'+
                        '"value": "'+employerName+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MemberOccupation",'+
                        '"value": "'+position +'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "EmploymentTenure",'+
                        '"value": "'+empTenure +'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "ApplicationId",'+
                        '"value": "'+appLoanId+'"'+
                        '},'+

                        '{'+
                        '"tabLabel": "ApplicationLoanId",'+
                        '"value": "'+appLoanId+'"'+
                        '},'+

                        '{'+
                        '"tabLabel": "ApplicationLoanId_2",'+
                        '"value": "'+appLoanId+'"'+
                        '},'+

                        '{'+
                        '"tabLabel": "MSuffix",'+
                        '"value": "'+ accountSuffix+'"'+
                        '},'+

                        '{'+
                        '"tabLabel": "PaymentAmountW",'+
                        '"value": "'+ paymentAmountW+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "LoanTerm",'+
                        '"value": "'+loanTerm+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MonthlyPayment",'+
                        '"value": "'+monthlyPayment +'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "ROI",'+
                        '"value": "'+ROI +'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "ROI_W",'+
                        '"value": "'+ROI_W +'"'+
                        '},'+
                        '{'+
                        
                        '"tabLabel": "finance_charge",'+
                        '"value": "'+finance_charge +'"'+
                        '},'+
                        '{'+
                        
                        '"tabLabel": "amount_financed",'+
                        '"value": "'+amount_financed +'"'+
                        '},'+
                        '{'+
                        
                        '"tabLabel": "last_payment_amount",'+
                        '"value": "'+last_payment_amount +'"'+
                        '},'+
                        '{'+
                        
                        '"tabLabel": "total_of_payments",'+
                        '"value": "'+total_of_payments +'"'+
                        '},'+
                        '{'+
                        
                        '"tabLabel": "apr",'+
                        '"value": "'+apr +'"'+
                        '},'+
                        '{'+
                        
                        '"tabLabel": "ach_amount",'+
                        '"value": "'+ach_amount +'"'+
                        '},'+
                        '{'+

                        '"tabLabel": "origination_fee_rate",'+  
                        '"value": "'+OriginationFeeRate+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "ROI_PN",'+
                        '"value": "'+ROI +'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "PaymentStartDate",'+
                        '"value": "'+paymentStartDate +'"'+
                        '},'+ '{'+
                        '"tabLabel": "PaymentEndDate",'+
                        '"value": "'+paymentEndDate +'"'+
                        '},'+ '{'+
                        '"tabLabel": "ROI_PerYear",'+
                        '"value": "'+ROI +'"'+
                        '},'+

                        '{'+
                        '"tabLabel": "MemberAddress1T",'+
                        '"value": "'+address1+' '+address2+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MemberAddress2T",'+
                        '"value": "'+address2+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MemberCityT",'+
                        '"value": "'+lstApp[0].genesis__Account__r.City__c+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MemberStateT",'+
                        '"value": "'+lstApp[0].genesis__Account__r.State__c+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MemberZIPT",'+
                        '"value": "'+lstApp[0].genesis__Account__r.ZIP_Code__c+'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "EmploymentTenureT",'+
                        '"value": "'+empTenure +'"'+
                        '},'+
                        '{'+
                        '"tabLabel": "MSuffixT",'+
                        '"value": "'+accountSuffix +'"'+
                        '},'+

                        '],'+
                        '"checkboxTabs": ['+                
                        '{'+
                        '"tabLabel": "chkAlliant2",'+
                        '"selected": "'+chkNonUSCitizen+'"'+
                        '}'+
                        '],'+
                        '"radioGroupTabs": ['+
                        '{'+
                        '"groupName": "MemberAccountType",'+
                        '"radios": ['+
                        '{'+
                        '"value": "Savings",'+
                        '"selected": "'+accountSavings+'"'+
                        '},'+
                        '{'+
                        '"value": "Checking",'+
                        '"selected": "'+accountCheckings+'"'+
                        '}'+
                        ']'+
                        '},'+
                        '{'+
                        '"groupName": "CitizenshipType",'+
                        '"radios": ['+
                        '{'+
                        '"value": "USCitizen",'+
                        '"selected": "'+chkUSCitizen+'"'+
                        '},'+
                        '{'+
                        '"value": "NonUSCitizen",'+
                        '"selected": "'+chkNonUSCitizen+'"'+
                        '}'+
                        ']'+
                        '},'+
                        ']'+
                        '}'+
                        '}'+']'+
                        '}';
                    

                    try {
                        req.setBody(json);
                        Http http = new Http();
                        HTTPResponse res;
                        res = http.send(req);
                        String webhookReq = MW_WebhookHandler.SendDetailstoUI(String.valueOf(res.getBody()), lstApp[0].Lead_ID__c);
                        MW_LogUtility.info('SendEnvDocuSignAPI', String.valueOf(ApplicationId), lstApp[0].Lead_ID__c, 'sendInvestorDocuments', res.getBody(), res);
                        
                        WrapperDocuSign wrapInst = WrapperDocuSign.parse(res.getBody());
                        if(wrapInst.status.containsIgnorecase('sent')) {
                            
                            MW_SynchronizeHandler.avoidrecursiveFuture=true;
                            lstApp[0].genesis__Status__c = 'docusign_loan_docs_sent';
                            lstApp[0].DocuSign_EnvelopeId__c = wrapInst.envelopeId;
                            lstApp[0].DocuSign_Envelope_ID__c = wrapInst.envelopeId;
                            lstApp[0].DocuSignFlag__c = false;
                            lstApp[0].Webhook_Docusign__c = webhookReq;
                            lstApp[0].DocuSign_Envelope_Status__c=wrapInst.status;
                            update lstApp[0];
                        }
                    }
                    catch(Exception ex){
                        MW_LogUtility.error('SendEnvDocuSignAPI', String.valueOf(ApplicationId), lstApp[0].Lead_ID__c, 'sendInvestorDocuments', ex);
                    }
                }
            }
        }

    }

    //@Future(callout=true)
    public static Void voidInvestorDocuments(String envelopeId){

        String endPoint = DocusignEndpoint+'/accounts/'+accountID+'/envelopes/'+envelopeId;

        //This Endpoint supports voiding an envelope with the envelopeID.
        HttpRequest req = new HttpRequest();
        String methodType = 'PUT';
        req.setEndpoint(endpoint);
        req.setMethod(methodType);
        req.setTimeout(timeOut); 

        //Apex HTTP Method Initialization.
        String authorizationHeader = '<DocuSignCredentials><Username>'+userName+
                                        '</Username><Password>'+Password+
                                        '</Password><IntegratorKey>'+integratorKey+
                                        '</IntegratorKey></DocuSignCredentials>';
        System.debug('Authorization Header:..........' + authorizationHeader);
        //Authorization header generating using DocuSign credentials.
        req.setHeader('X-DocuSign-Authentication', authorizationHeader);
        req.setHeader('Accept','application/json');
        req.setHeader('Content-Type','application/json');
        String json = '{'+
                        '"status": "voided",'+
                        '"voidedReason" : "Your Application has been Expired. Please re-apply."'+
                        '}';
        try {
            req.setBody(json);
            Http http = new Http();
            HTTPResponse res;
            //Docusign Request Callout.
            System.debug('Req:.......'+ req);
            res = http.send(req);
            MW_LogUtility.info('SendEnvDocuSignAPI', '', '', 'voidInvestorDocuments', res.getBody(), res);
            
        }
        catch(Exception ex){
            MW_LogUtility.error('SendEnvDocuSignAPI', '', '', 'voidInvestorDocuments', ex);
        }
    }

    public static String getDocumentId(String envelopeId){

        String endPoint = DocusignEndpoint+'/accounts/'+accountID+'/envelopes/'+envelopeId+'/documents';

        //This Endpoint supports voiding an envelope with the envelopeID.
        HttpRequest req = new HttpRequest();
        String methodType = 'GET';
        req.setEndpoint(endpoint);
        req.setMethod(methodType);

        //Apex HTTP Method Initialization.
        String authorizationHeader = '<DocuSignCredentials><Username>'+userName+
                                        '</Username><Password>'+Password+
                                        '</Password><IntegratorKey>'+integratorKey+
                                        '</IntegratorKey></DocuSignCredentials>';
        //Authorization header generating using DocuSign credentials.
        req.setHeader('X-DocuSign-Authentication', authorizationHeader);
        req.setHeader('Accept','application/json');
        req.setHeader('Content-Type','application/json');
        req.setTimeout(timeOut); 
        try {

            Http http = new Http();
            HTTPResponse res;
            //Docusign Request Callout.
            res = http.send(req);
            MW_LogUtility.info('SendEnvDocuSignAPI', '', '', 'getDocumentId', res.getBody(), res);

            DocusignDocumentResponse docIdResponse =  (DocusignDocumentResponse) System.JSON.deserialize(res.getBody(), DocusignDocumentResponse.class);
            if(docIdResponse!=null && docIdResponse.envelopeDocuments!=null && docIdResponse.envelopeDocuments.size()>0) {
                for(DocusignDocumentResponse.EnvelopeDocuments env:docIdResponse.envelopeDocuments) {
                    if(env.name.contains('Payoff Promissory Note')) {
                        return env.documentId;
                    }
                }

            }
        }
        catch(Exception ex){
            MW_LogUtility.error('SendEnvDocuSignAPI', '', '', 'getDocumentId', ex);
        }
        return null;
    }

    public static String getEnvelopeStatus(String envelopeId){

        String endPoint = DocusignEndpoint+'/accounts/'+accountID+'/envelopes/'+envelopeId;

        //This Endpoint supports voiding an envelope with the envelopeID.
        HttpRequest req = new HttpRequest();
        String methodType = 'GET';
        req.setEndpoint(endpoint);
        req.setMethod(methodType);
        req.setTimeout(timeOut); 

        //Apex HTTP Method Initialization.
        String authorizationHeader = '<DocuSignCredentials><Username>'+userName+
                                        '</Username><Password>'+Password+
                                        '</Password><IntegratorKey>'+integratorKey+
                                        '</IntegratorKey></DocuSignCredentials>';
        //Authorization header generating using DocuSign credentials.
        req.setHeader('X-DocuSign-Authentication', authorizationHeader);
        req.setHeader('Accept','application/json');
        req.setHeader('Content-Type','application/json');

        try {

            Http http = new Http();
            HTTPResponse res;
            //Docusign Request Callout.
            res = http.send(req);
            MW_LogUtility.info('SendEnvDocuSignAPI', '', '', 'getEnvelopeStatus', res.getBody(), res);

            DocusignDocumentResponse docIdResponse =  (DocusignDocumentResponse) System.JSON.deserialize(res.getBody(), DocusignDocumentResponse.class);
            if(docIdResponse!=null && docIdResponse.status!=null ) {

                return docIdResponse.status;
            }
        }
        catch(Exception ex){
            MW_LogUtility.error('SendEnvDocuSignAPI', '', '', 'getEnvelopeStatus', ex);
        }
        return null;
    }

    public static String updateDocumentFields(String envelopeId,String documentId){
        Decimal loanTerm = 0;
        List<genesis__applications__c> apps = [SELECT id,name, genesis__Term__c FROM genesis__applications__c where DocuSign_Envelope_ID__c!=null and DocuSign_Envelope_ID__c =:envelopeId ];
        if(apps!=null && apps.size()>0) {
            if(apps[0].genesis__Term__c != 0)
                loanTerm = apps[0].genesis__Term__c;
        }
        List<dsfs__DocuSign_Recipient_Status__c> docSignRecipt=[select id,dsfs__DocuSign_Recipient_Id__c from dsfs__DocuSign_Recipient_Status__c where dsfs__Envelope_Id__c =:envelopeId];
        System.debug('...voidInvestorDocuments...' );
        try {
            String endPoint = DocusignEndpoint+'/accounts/'+accountID+'/envelopes/'+envelopeId+'/recipients/'+docSignRecipt[0].dsfs__DocuSign_Recipient_Id__c+'/tabs';
            //This Endpoint supports voiding an envelope with the envelopeID.

            HttpRequest req = new HttpRequest();
            String methodType = 'GET';
            req.setEndpoint(endPoint);
            req.setMethod(methodType);

            //Apex HTTP Method Initialization.
            String authorizationHeader = '<DocuSignCredentials><Username>'+userName+
                                            '</Username><Password>'+Password+
                                            '</Password><IntegratorKey>'+integratorKey+
                                            '</IntegratorKey></DocuSignCredentials>';
            //Authorization header generating using DocuSign credentials.
            req.setHeader('X-DocuSign-Authentication', authorizationHeader);
            req.setHeader('Accept','application/json');
            req.setHeader('Content-Type','application/json');
            req.setTimeout(timeOut);
            Http http = new Http();
            HTTPResponse res;
            //Docusign Request Callout.
            res = http.send(req);
            MW_LogUtility.info('SendEnvDocuSignAPI', '', '', 'updateDocumentFields', res.getBody(), res);

            DocusignTabAPIResponse tabResponse =  DocusignTabAPIResponse.parse(res.getBody());
            string psdocumentId,psrecipientId,pspageNumber,pstabId,pedocumentId,perecipientId,pepageNumber,petabId;
            for(DocusignTabAPIResponse.TextTabs txttb: tabResponse.textTabs) {
                If(txttb.tabLabel=='PaymentStartDate'){
                    psdocumentId = txttb.documentId;
                    psrecipientId = txttb.recipientId;
                    pspageNumber = txttb.pageNumber;
                    pstabId = txttb.tabId;
                }
                If(txttb.tabLabel=='PaymentEndDate'){
                    pedocumentId = txttb.documentId;
                    perecipientId = txttb.recipientId;
                    pepageNumber = txttb.pageNumber;
                    petabId = txttb.tabId;
                }
            }

            /* LPC-359 Feb payment start date / anniversary date promissory note issue fix */
            if(signDateforPaymentStartDate == null){
                signDateforPaymentStartDate = system.today();
            } 
            Date anniversaryDate = getPaymentStartDate();
            String paymentStartDate = getFormattedDate(anniversaryDate); 
            
            Date endDt = addWorkingDays(system.today(),3,Integer.valueOf(loanTerm)); 
            endDt = getCalculatedDate(endDt); 
            String paymentEndDate = getFormattedDate(endDt); 
            
            String json = '{"textTabs": [{'+
                            '"tabLabel": "PaymentStartDate",'+
                            '"value" :"'+paymentStartDate+'",'+
                            '"documentId" :"'+psdocumentId+'",'+
                            '"recipientId" :"'+psrecipientId+'",'+
                            '"pageNumber" :"'+pspageNumber+'",'+
                            '"tabId" :"'+pstabId+'"'+
                            '},'+
                            '{'+
                            '"name": "PaymentEndDate",'+
                            '"value" :"'+paymentEndDate+'",'+
                            '"documentId" :"'+pedocumentId+'",'+
                            '"recipientId" :"'+perecipientId+'",'+
                            '"pageNumber" :"'+pepageNumber+'",'+
                            '"tabId" :"'+petabId+'"'+
                            '}]}';
            methodType = 'PUT';
            System.debug('DocuSign json:...' +json);
            req.setMethod(methodType);
            req.setBody(json);
            //Docusign Request Callout.
            res = http.send(req);
            if(res.getStatusCode() == 200) {
                return 'Succesfully Updated the Document Tabs !!';

            } else {
                return 'Tab text update failed!!';
            }

        }
        catch(Exception ex){
            MW_LogUtility.error('SendEnvDocuSignAPI', '', '', 'updateDocumentFields', ex);
        }
        return null;
    }
    public static Date getPaymentStartDate(){
        Date orignationDt = addWorkingDays(signDateforPaymentStartDate,3,0); 
        Date anniversaryDate      = orignationDt.addMonths(1);
        //Set anniversary date March 1st instead of Feb 28.
        if(handleFebruary(orignationDt)){
            anniversaryDate = anniversaryDate.addDays(1);
        }
        return anniversaryDate;       
    }
    public static boolean handleFebruary(Date originationDate){
        if(originationDate.month() == 1 && (originationDate.day() == 29 || originationDate.day() == 30 || originationDate.day() == 31))
        {
            return true;
        }
        return false;
    }
    public static Date addWorkingDays(Date dateParam, Integer numberOfDays,Integer numberOfMonths){
        CustomTriggerOnApplicationHandler ctdh = new CustomTriggerOnApplicationHandler();
        Date dateval = ctdh.addWorkingDaysTodate(dateParam,numberOfDays);
        if(numberOfMonths > 0){
            dateval= dateval.addMonths(numberOfMonths);
        }
        return dateval;
    }
    
    public static Date getCalculatedDate(Date dateParam){
        Date dt = dateParam.addDays(MW_DocuSignTriggerHandler.calcdate(dateParam));
        return dt;
    }
    public static String getFormattedDate(Date dateParam){
        return DateTime.newInstance(dateParam.year(),dateParam.month(),dateParam.day()).format(dateFormat);
    }
}