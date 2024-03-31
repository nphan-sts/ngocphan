/* ****************Modification History******************************************
 * Created By        Date          JIRA number
 *1. Pallavi        2020/08/13     CRM-755(Make NeoVerify Initiated Manually)
 *      
 ******************Modification History******************************************/
global class YodleeTransactionAPICallOut {
    
        public static String cobSession = null;
        public static String userToken = null;
        public static String yodleeAccountId;
        public static integer count= 0;
        public static id applicationId = null;
        public static String LeadID = '';
        public static id accountId = null;
        public static integer NumberOfdays = 0;
        public static list<ints__Yodlee_User_Credentials__c> userCredentials = new list<ints__Yodlee_User_Credentials__c>();
        public static Map<String,String> param = new Map<String,String>();
        public static list<Yodlee_User_Account__c> yodleeAccDetails;
        public static set<Yodlee_User_Account__c> yodleeAccDetails1 = new set<Yodlee_User_Account__c>();
      public static List<String> bankAccId = new List<String>();  //pallavi
    
    
        public static String getCobSession(){
            System.debug(logginglevel.error,'...YodleeTransactionAPICallOut ...IN getCobSession ');
            ints.YodleeAPIIntegration api = new ints.YodleeAPIIntegration();
            ints.YodleeResponse.Cls_session cob = new ints.YodleeResponse.Cls_session();
    
            system.debug(logginglevel.error,'ints.YodleeResponse.Cls_session :: cob :'+cob);
            try {
                ints.YodleeResponse res  =  api.apiCall('cobrandLogin',param);
                System.debug(logginglevel.error,'ints.YodleeResponse :: RES :'+ res);
                param.put('Cobrand_Id',res.session.cobSession);
                cobSession = res.session.cobSession;
                System.debug(LoggingLevel.ERROR,'cobSession :: '+cobSession);
                return cobSession;
            } catch(exception e){
                System.debug(LoggingLevel.ERROR, e.getMessage());
                return 'Exception '+ e.getMessage();
            }
        }
    
        webservice static String UserToken(id accountId){
            System.debug('...YodleeTransactionAPICallOut ...UserToken ' +accountId);
            String username;
            String password;
            ints.YodleeResponse.Cls_sessions users = new ints.YodleeResponse.Cls_sessions();
            ints.YodleeAPIIntegration api = new ints.YodleeAPIIntegration();
    
            try {
                userCredentials = [select id, name
                                   //ints__Account__r.Yodlee_Account_Id__c
                                   FROM ints__Yodlee_User_Credentials__c
                                   WHERE ints__Account__c =: accountId LIMIT 1];
    
                System.debug(logginglevel.error, 'In USER TOKEN () : userCredentials  ::'+userCredentials);
    
                if(userCredentials.size() < = 0) {
                    return 'Exception : No User Credentials found';
                }
                else {
                    param.put('userId', userCredentials.get(0).Id);
                    //commented by Neha because we are not using yodleeAccountId anywhere.
                    //yodleeAccountId = userCredentials.get(0).ints__Account__r.Yodlee_Account_Id__c;
                    //System.debug(logginglevel.error,'yodleeAccountId = userCredentials.get(0).ints__Account__r.Yodlee_Account_Id__c :: '+yodleeAccountId );
                    if(!test.isRunningTest()) {
                        ints.YodleeResponse res = api.apiCall('userLogin',param);
                        if(res.errorMessage==null) {
                            param.put('userSession', res.user.Session.userSession);
    
                            userToken = res.user.Session.userSession;
                        }
                        else
                            return null;
                        System.debug(logginglevel.error, 'In USER TOKEN () : '+userToken );
                        return userToken;
                    }
                    else{
                        userToken = 'lfjkjdslfldfjdslkl';
                        return userToken;
                    }
                }
    
            } catch(Exception e){
                return 'Exception: ' + e.getMessage() + '. Please contact your administrator.';
            }
        }
    
        webservice static String getTransactions(id accId, id appId, Integer noOfDays){
    
            //System.debug(logginglevel.error,'...YodleeTransactionAPICallOut ...IN getTransactions: ACCID: '+accountId + 'APPID :' +applicationId);
            applicationId = appId;
            accountId = accId;
            NumberOfdays = noOfDays;
            List< genesis__Applications__c> applist = [Select id, Lead_ID__c from genesis__Applications__c where id =: applicationId LIMIT 1];
            LeadID = applist[0].Lead_ID__c;
            System.debug(logginglevel.error,'...YodleeTransactionAPICallOut ...IN getTransactions: ACCID: '+accountId + 'APPID :' +applicationId + 'LeadID: '+LeadID);
    
            System.debug(logginglevel.error,'Calling GETCobsessionMethod');
            cobSession = getCobSession();
            System.debug(logginglevel.error,'cobSession : '+cobSession);
    
            //get User Token
            //changed by Neha.
            if(cobSession != null) {
                System.debug(logginglevel.error,'IN IF Block : cobSession != null');
                userToken = UserToken(accountId);
            }
    
            if(cobSession == null || cobSession.contains('Error')) {
                System.debug(logginglevel.error,'IN IF Block : cobSession == null || cobSession.contains(Error)');
                return 'Cobsession is NULL.Please contact your administrator.';
            }
    
            if(userToken == null || userToken.contains('Exception')) {
    
                return 'UserSession is NULL.Please contact your administrator.';
            }else{
                System.debug(logginglevel.error,'IN ELSE Block : calling deleteYodleeTxn() method ::');
    
                Account acc = [Select id,name,
                               Avg_Daily_Balance__c,
                               Last_Update_Date__c
                               FROM Account
                               WHERE id =: accountId];
                System.debug(logginglevel.error,' ACC Record'+acc);
    
                list<Yodlee_User_Transaction__c> yodleeTxn = new list<Yodlee_User_Transaction__c>();
                set<Yodlee_User_Transaction__c> yodleeTxn1 = new set<Yodlee_User_Transaction__c>();
                ints__Yodlee_Cobrand_Credentials__c cobrand = ints__Yodlee_Cobrand_Credentials__c.getInstance();
                System.debug(logginglevel.error,' ints__Yodlee_Cobrand_Credentials__c.getInstance() Result :: cobrand ::'+cobrand);
    
                String url = cobrand.ints__Rest_URL__c;
                Integer fromDateAttVal  = Integer.valueof(cobrand.FromDate_Attribute_value__c);
                System.debug(logginglevel.error,' cobrand.ints__Rest_URL__c result :: URL ::'+url);
                String response;
                try {
    
                    System.debug(logginglevel.error,'Creating Request');
                    HttpRequest req = new HttpRequest();
                    req.setMethod('GET');
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Authorization', '{cobSession=' + cobSession + ',userSession=' + userToken + '}');
    
                    //time duration of Transactions
                    if(!Test.isRunningTest()) {
                        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
                        DateTime csd = util.getCurrentSystemDate();
                        //DateTime csd = Date.Today();
                        DateTime fromDateAttrb;
                        if(NumberOfdays!=null && NumberOfdays != -1) {
                            fromDateAttrb = csd - NumberOfdays;
                        }
                        else
                            fromDateAttrb = csd - fromDateAttVal;
                        String fromDate = fromDateAttrb.format('yyyy-MM-dd');
                        String toDate = csd.format('yyyy-MM-dd');
    
                        System.debug(logginglevel.error, 'fromDate +'+fromDate );
    
                        Url = url + 'transactions?container=bank&&&&fromDate=' + fromDate + '&toDate=' + toDate;
                        /*if(count != 1 || yodleeAccountId == null){
                            Url = url + 'transactions?container=bank&&&&fromDate=' + fromD + '&toDate=' + toD;
                           }
                           else {
                            Url = url + 'transactions?container=bank&&&accountId=' + yodleeAccountId +'&fromDate=' + fromD + '&toDate=' + toD+'&&&&&&&&';
                           }*/
                        //System.debug('URL--> ' + url);
                        req.setEndpoint(url);
    
                        //To return fake response in case of Test.
                        if(Test.isRunningTest()) {
                            System.debug('Test: Fake Response');
                        }
    
                        // Create a new http object to send the request object
                        // A response object is generated as a result of the request
                        Http http = new Http();
                        HTTPResponse res = http.send(req);
                        response = res.getBody();
                    }
                    //To return fake response in case of Test.
                    else{
                        response =  '{'+
                                   '  "transaction": ['+
                                   '    {'+
                                   '      "CONTAINER": "bank",'+
                                   '      "id": 25335410,'+
                                   '      "type": "OTHER_DEPOSITS",'+
                                   '      "subType": "CREDIT",'+
                                   '      "amount": {'+
                                   '        "amount": 3465,'+
                                   '        "currency": "USD"'+
                                   '      },'+
                                   '      "baseType": "CREDIT",'+
                                   '      "categoryType": "INCOME",'+
                                   '      "categoryId": 32,'+
                                   '      "category": "Other Income",'+
                                   '      "categorySource": "SYSTEM",'+
                                   '      "description": {'+
                                   '        "original": "DESC",'+
                                   '        "simple": "DESC"'+
                                   '      },'+
                                   '      "date": "2017-03-16",'+
                                   '      "postDate": "2017-03-16",'+
                                   '      "transactionDate": "2017-03-16",'+
                                   '      "isManual": false,'+
                                   '      "status": "POSTED",'+
                                   '      "accountId": 10563602,'+
                                   '      "runningBalance": {'+
                                   '        "amount": 59,'+
                                   '        "currency": "USD"'+
                                   '      },'+
                                   '      "checkNumber": "DAG-133",'+
                                   '      "highLevelCategoryId": 10000012'+
                                   '    },'+
                                   '    {'+
                                   '      "CONTAINER": "bank",'+
                                   '      "id": 25335413,'+
                                   '      "type": "OTHER_DEPOSITS",'+
                                   '      "subType": "CREDIT",'+
                                   '      "amount": {'+
                                   '        "amount": 9846,'+
                                   '        "currency": "USD"'+
                                   '      },'+
                                   '      "baseType": "CREDIT",'+
                                   '      "categoryType": "INCOME",'+
                                   '      "categoryId": 32,'+
                                   '      "category": "Other Income",'+
                                   '      "categorySource": "SYSTEM",'+
                                   '      "description": {'+
                                   '        "original": "DESC",'+
                                   '        "simple": "DESC"'+
                                   '      },'+
                                   '      "date": "2017-03-02",'+
                                   '      "postDate": "2017-03-02",'+
                                   '      "transactionDate": "2017-03-16",'+
                                   '      "isManual": false,'+
                                   '      "status": "POSTED",'+
                                   '      "accountId": 10563602,'+
                                   '      "runningBalance": {'+
                                   '        "amount": 59,'+
                                   '        "currency": "USD"'+
                                   '      },'+
                                   '      "checkNumber": "DAG-333",'+
                                   '      "highLevelCategoryId": 10000012'+
                                   '    }'+
                                   '  ]'+
                                   '}';
                    }
    
                    system.debug(LoggingLevel.ERROR,'RESPONSE :: ' +response);
                }
                catch(Exception ex){
                    System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
                    return 'Something went wrong.Please contact your administrator for it.';
                }
                response = response.replace('"transaction":', '"transactions":');
                response = response.replace('"currency":', '"currencyAmount":');
                response = response.replace('"accountId":','"YodleeAccount":');
        List<Yodlee_User_Account__c> bankholder1 = [Select id,YodleeBankAccountId__c from Yodlee_User_Account__c
                               WHERE Yodlee_Account__c = :accountId and Yodlee_Application__c =: applicationId];  //pallavi
                /*pallavi*/
                if(!bankholder1.isempty()){
                    for(Yodlee_User_Account__c temp:bankholder1){
                        bankAccId.add(temp.YodleeBankAccountId__c);
                    }
                }
                /*pallavi*/
                getYodleeAccount(accountId, applicationId);
                deleteYodleeTxn(accountId, applicationId);
                insert yodleeAccDetails;
                GetTransactionContainer getTxn = GetTransactionContainer.parse(response);
                list<Yodlee_User_Account__c> bankholder = [select id,
                                                              Account_Holder_Name__c,YodleeBankAccountId__c
                                                              From Yodlee_User_Account__c
                                                              WHERE Yodlee_Account__c = :accountId and Yodlee_Application__c =: applicationId ];
                
                Map<String, String> mapBankIdYodleeAccount = new Map<String,String>(); 
                for(Yodlee_User_Account__c userAcc : bankholder) {
                    mapBankIdYodleeAccount.put(userAcc.YodleeBankAccountId__c,userAcc.id);
                }
                // populate the map here with bankid and yodlee user account id 
                
                try {
                    if(getTxn != null && getTxn.transactions!=null && getTxn.transactions.size() > 0) {
                        for(GetTransactionContainer.cls_transaction txn : getTxn.transactions) {
                        
                        
                        
                            Yodlee_User_Transaction__c yodleeT = new Yodlee_User_Transaction__c();
                            System.debug('...Transaction...'+ txn);
                            //yodleeT.Transaction_Amount__c = txn.amount.amount;
                            yodleeT.Transaction_Date__c = txn.transactionDate;
                            yodleeT.Category__c = String.isEmpty(txn.category) ? '' : txn.category;
                            if(txn.description.original.length()>255){
                                yodleeT.Description__c = txn.description.original.substring(0, 255);
                                }
                               else {
                                yodleeT.Description__c = String.isEmpty(txn.description.original) ? '' : txn.description.original;
                                }
                            yodleeT.Balance__c = txn.runningBalance == null ? 0 : txn.runningBalance.amount;
                            yodleeT.Yodlee_Account__c = accountId;
                            yodleeT.Yodlee_Application__c = applicationId;
                            yodleeT.postDate__c = txn.postDate;
                            System.debug(' . ** **** ' +txn.postDate);
                            if(mapBankIdYodleeAccount.containsKey(txn.YodleeAccount)) {
                                yodleeT.yodlee_user_account__c = mapBankIdYodleeAccount.get(txn.YodleeAccount);
                            }
                            
                            string bankid = String.ValueOf(txn.YodleeAccount);
                            yodleeT.YodleeBankAccountId__c = bankid;
                            //yodleeT.yodlee_user_account__c = mapBankIdYodleeAccount.get(txn.YodleeAccount);
                            /*for(Yodlee_User_Account__c userAcc : bankholder) {
                                if(bankholder != null && bankholder.size() > 0 &&  userAcc.YodleeBankAccountId__c.equalsIgnoreCase(bankid)) { 
                                    yodleeT.Account_Holder_Name__c = userAcc.Account_Holder_Name__c;  
                                } 
                            }*/
                                                
                            if(txn.baseType != null || txn.baseType != '') {
                                if(txn.baseType == 'CREDIT') {
                                    yodleeT.Credit__c = txn.amount == null ? 0 : txn.amount.amount;
                                }
                                else if(txn.baseType == 'DEBIT') {
                                    yodleeT.Debit__c = txn.amount == null ? 0 : txn.amount.amount;
                                }
                            }
                            yodleeT.Transaction_Type__c = String.isEmpty(txn.baseType) ? '' : txn.baseType;
                            yodleeT.isLatest__c = TRUE;
                            yodleeTxn1.add(yodleeT);
                        }
                        //getYodleeAccount(accountId, applicationId);
                        //deleteYodleeTxn(accountId, applicationId);
    
                        //insert yodleeAccDetails;
                        YodleeTxn.addAll(YodleeTxn1);
                        insert YodleeTxn;
    
                        // create attachment of raw response
    
                        Attachment a = new Attachment(parentid=applicationId, Name = 'linked_acct_'+LeadID+'.json', Body=Blob.valueOf(response), ContentType='application/json' );
                        insert a;
                        System.debug('*******ATTID'+a.id);
                        AvgDailyBalance avg = new AvgDailyBalance();
                        acc.Avg_Daily_Balance__c = avg.countAvgDailyBalance(yodleeTxn);
                        update acc;
                        
                        //pallavi(commented for CRM-755)
                        //Neoverify Call queue
                        /*Set<Id> s1 = new Set<Id>();
                        s1.add(applicationId);
              
                        ID jobID = System.enqueueJob(new MW_NeoVerifyTransactionsCalloutQueue(s1));
                        MW_Callout__c newCalloutJob = new MW_Callout__c();
                        newCalloutJob.JobID__c = jobID;
                        newCalloutJob.Status__c = 'Queued';
                        insert newCalloutJob;*/
                        
                        // Neoverify call queue end                  
                        
                        return 'Bank Account Transaction Details pulled successfully.';
    
                        
                    }
                    else{
                        //deleteYodleeTxn(accountId, applicationId);
                        return 'No Transaction Found for the user.';
                    }
                }
    
                catch(exception e){
                    // retry yodlee call incase it fails
                    if(count == 0 && count < 3) {
                        count++;
                        System.debug('...Count...'+count);
                        getTransactions(accountId,applicationId,NumberOfdays);
    
                    }
                    System.debug('Error--> ' + e.getMessage() + ', '+ e.getStackTraceString());
                    return 'Something went wrong. Please contact your administrator for it. ' + e.getMessage();
                }
            }
            return '';
        }
    
        //Yodlee Bank Accounts added on 18.12.2017
        //@Future(callout=true)
        public static void getYodleeAccount(Id accountId, Id applicationId){
            System.debug('...YodleeTransactionAPICallOut ...getYodleeAccount' +accountId);
            yodleeAccDetails = new list<Yodlee_User_Account__c>();
    
    
            ints__Yodlee_Cobrand_Credentials__c cobrand = ints__Yodlee_Cobrand_Credentials__c.getInstance();
            String url = cobrand.ints__Rest_URL__c+'accounts';
            System.debug(logginglevel.error,'URL yodleebankaccount ++'+url);
            String response;
    
            try {
    
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', '{cobSession=' + cobSession + ',userSession=' + userToken + '}');
                //String fromD = fromDate.format('yyyy-MM-dd');
                //String toD = toDate.format('yyyy-MM-dd');
                System.debug('URL--> ' + url);
                req.setEndpoint(url);
    
                //To return fake response in case of Test.
                if(Test.isRunningTest()) {
                    System.debug('Test: Fake Response');
                }
    
                // Create a new http object to send the request object
                // A response object is generated as a result of the request
                Http http = new Http();
                HTTPResponse res = http.send(req);
                response = res.getBody();
                system.debug(LoggingLevel.ERROR, response);
            }
            catch(Exception ex){
                System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
            }
    
            response = response.replace('"account":', '"bankAccounts":');
            response = response.replace('"currency":', '"currencyAmount":');
            System.debug('Get Response--> ' + response);
            GetYodleeAccountResponseAPI getAccounts = GetYodleeAccountResponseAPI.parse(response);
            System.debug('GetAccounts--> ' + getAccounts);
    
            try {
                if(getAccounts != null) {
                    System.debug(logginglevel.error,'getAccounts.bankAccounts.'+getAccounts.bankAccounts);
                    if(getAccounts.bankAccounts != null && getAccounts.bankAccounts.size() > 0) {
                        For(GetYodleeAccountResponseAPI.yodleeAccount bankAccount: getAccounts.bankAccounts){
                            Yodlee_User_Account__c yodleeAcc = new Yodlee_User_Account__c();
                            system.debug('Acc Name:' + bankAccount.accountName);
                            yodleeAcc.Name = String.isEmpty(bankAccount.providerName) ? '' : bankAccount.providerName;
                            if(bankAccount.holderProfile !=null)
                            {
                                if(bankAccount.holderProfile.size()>0)
                                {
                                    yodleeAcc.Account_Holder_Name__c = ((bankAccount.holderProfile[0].name== null || String.isEmpty(bankAccount.holderProfile[0].name.displayed)) ? '' : bankAccount.holderProfile[0].name.displayed); 
                                } 
                            }
                            
                            if(bankAccount.accountType!=null) { yodleeAcc.Account_Type__c = String.isEmpty(bankAccount.accountType) ? '' : bankAccount.accountType; }
                            if(bankAccount.availableBalance!=null && bankAccount.availableBalance.amount!=null) { yodleeAcc.Available_Balance__c = bankAccount.availableBalance.amount == null ? 0 : bankAccount.availableBalance.amount;}
                            if(bankAccount.accountNumber!=null) {yodleeAcc.Account_Number__c = String.isEmpty(bankAccount.accountNumber) ? '' : bankAccount.accountNumber;}
                            if(bankAccount.currentBalance!=null && bankAccount.currentBalance.amount!=null) { yodleeAcc.Current_Balance__c = bankAccount.currentBalance.amount == null ? 0 : bankAccount.currentBalance.amount;}
                            if(bankAccount.accountStatus!=null) { yodleeAcc.Status__c = String.isEmpty(bankAccount.accountStatus) ? '' : bankAccount.accountStatus;}
                            yodleeAcc.Yodlee_Account__c = accountId;
                            yodleeAcc.YodleeBankAccountId__c = String.valueOf(bankAccount.Id);
                            yodleeAcc.Yodlee_Application__c = applicationId;
                            if(!bankAccId.isEmpty()){  //pallavi
                              if(!bankAccId.contains(String.valueOf(bankAccount.Id)))  //pallavi
                            yodleeAccDetails1.add(yodleeAcc);
                            }
                            else  //pallavi
                                yodleeAccDetails1.add(yodleeAcc);  //pallavi
                        }
                        yodleeAccDetails.addAll(yodleeAccDetails1);
    
                        // Neha - Bank Account can be multiple.What should we do in this case.?? Why we have to update this Flag.
                        /*loan__Bank_Account__c bankAccount = [SELECT YodleeBank_Accounts__c FROM loan__Bank_Account__c where loan__Account__c =: accountId limit 1];
                           bankAccount.YodleeBank_Accounts__c = true;*/
                    }
                }
            }
    
            catch(exception e){
    
                System.debug('Error--> ' + e.getMessage() + ', '+ e.getStackTraceString());
            }
        }
    
        Public static void deleteYodleeTxn(id accountId, id applicationId){
    
            System.debug(logginglevel.error,'...YodleeTransactionAPICallOut ...IN deleteYodleeTxn() : accountId :: ' + accountId + ' applicationId :: '+applicationId);
            //delete any user transaction records if available
            try {
                list<Yodlee_User_Transaction__c> yodleeTxn = [select id,
                                                              Yodlee_Account__c
                                                              From Yodlee_User_Transaction__c
                                                              WHERE Yodlee_Account__c = :accountId and Yodlee_Application__c =: applicationId];
    
                System.debug(logginglevel.error,'List of Yodlee Transactions to be deleted : '+yodleeTxn );
                if(yodleeTxn != null && yodleeTxn.size() > 0) {
                    delete yodleeTxn;
                    System.debug(logginglevel.error,'Transaction size --> ' + yodleeTxn.size() + yodleeTxn);
                    System.debug(logginglevel.error,'Bank Account Details already exists. Please delete it and try again');
                }
    
                /*list<Yodlee_User_Account__c> yodleeAccounts = [select id from Yodlee_User_Account__c where  //pallavi
                                                               Yodlee_Account__c = :accountId and Yodlee_Application__c =: applicationId];
                System.debug(logginglevel.error,'List of Yodlee Accounts to be deleted : '+yodleeTxn );
    
                if(yodleeAccounts != null && yodleeAccounts.size() > 0) {
                    delete yodleeAccounts;
                    System.debug('Accounts size --> ' + yodleeTxn.size() + yodleeTxn);
                }*/
            } catch(DmlException e){
                System.debug('Continue');
            }
    
        }
    }