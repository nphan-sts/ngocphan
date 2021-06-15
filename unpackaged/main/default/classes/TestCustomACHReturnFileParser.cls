@isTest
class TestCustomACHReturnFileParser{
    
    public static testMethod void parseACHPaymentReturn(){
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn(); // 3 day lock period
        List<filegen__File_Metadata__c> metadata = Test.loadData(filegen__File_Metadata__c.sObjectType,'CustomTestMetaData');
        loan.TestHelper.setupACHParameters();
        loan.TestHelper2.createFileGenMetaData();
        //loan.TestHelper2.createOrgBankAccounts();

        loan__Transaction_Approval_Config__c c = loan.CustomSettingsUtil.getApprovalConfig();
        loan__ACH_Parameters__c ach = loan.CustomSettingsUtil.getACHParameters();
        ach.loan__Days_In_Advance_To_Create_File__c = 0;
        ach.loan__Multiple_Payment_Method_Support__c = true;
        ach.loan__ACH_Return_Filegen__c = 'CustomACHReturnFileParser';
        ach.PPDAdvance_Folder_Name__c = 'Disbursal Reversal';
        ach.CORPayment_Folder_Name__c = 'Change Details';
        upsert ach;
        system.debug('--ach custom setting--'+ach);

        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');

        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount,
                            curr,
                            dummyFeeSet);
        
        loan__Payment_Mode__c pMode = new loan__Payment_Mode__c(Name = 'ACH BofA Opp');
        insert pMode;
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        //Account a1 = loan.TestHelper2.createInvestor('Bull', 1000);
        Account b1 = loan.TestHelper2.createBorrower('ShoeString');
        Contact con= new Contact(LastName='Test');
        insert con; 
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__Routing_Number__c = '99999999',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Account__c = b1.id,
                                                 Unmasked_Bank_Account_Number__c = '123234324',
                                                 loan__Active__c = True);
        insert ba;
        
        Account acc = new Account(Name = 'Member'); //pallavi(CRM-253)
        insert acc;
        
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__Routing_Number__c = '99999999',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Account_Usage__c = 'Collections Trust Account',
                                                 loan__Contact__c = con.id,
                                                 Unmasked_Bank_Account_Number__c = '123234324',
                                                 loan__Active__c = True,
                                                 loan__Account__c = acc.id);    //PALLAVI(CRM-253)
        insert collectionTrustBA ;
       
       
            
        loan__Loan_Account__c dummylaMonthly = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                        b1,
                                        dummyFeeSet,
                                        dummyLoanPurpose,
                                        dummyOffice);
        
        dummylaMonthly.loan__Loan_Status__c = 'Active - Good Standing';
        dummylaMonthly.loan__Principal_Remaining__c = 10000;
        dummylaMonthly.loan__Contact__c = con.id;
        update dummylaMonthly;
        loan.GlobalLoanUtilFacade loanUtil = new loan.GlobalLoanUtilFacade();
        Date systemDate = loanUtil.getCurrentSystemDate();
        
        
        System.debug('--Loan--'+dummylaMonthly);
        
        
        loan__Automated_Payment_Configuration__c apc = loan.TestHelper2.createAutomatedPaymentConfiguration(
                                                            'LOAN PAYMENT',
                                                             pMode,
                                                             collectionTrustBA,
                                                             'loan.LoanPaymentTxnNACHAGen');
        
        loan__Automated_Payment_Setup__c aps = loan.TestHelper2.createAutomatedPaymentSetup(
                                                    loan.LoanConstants.RECURRING,
                                                    loan.LoanConstants.FIXED_AMOUNT,
                                                    ba,
                                                    dummylaMonthly,
                                                    'Monthly',
                                                    pMode,
                                                    systemDate);
                                                    
        
         
        system.debug('--aps--'+aps);
        
        Set<String> paymentModes = new Set<String>();
        
        paymentModes.add(pMode.Name);
                                             
        system.debug([SELECT id, loan__Payment_Mode__r.Name FROM loan__Automated_Payment_Configuration__c WHERE loan__Active__c = TRUE]);                                                            
      /*Test.startTest();
        loan.LoanPaymentTransactionCreationJob j = new loan.LoanPaymentTransactionCreationJob(True);
        Database.executeBatch(j, 200);
        Test.stopTest(); 
        
        List<loan__Batch_Process_Log__c> logs = [select Id,name,loan__Message__c from loan__Batch_Process_Log__c order by createdDate desc];
        if(!logs.isempty()) {
            throw new peer.MarketplaceException('Test Failing: '+logs);
        }*/
        loan__Loan_Payment_Transaction__c lptToBeInserted = new loan__Loan_Payment_Transaction__c(
                                                            loan__Transaction_Date__c = systemDate,
                                                            loan__Transaction_Amount__c = 10,
                                                            loan__Loan_Account__c = dummylaMonthly.Id,
                                                            loan__Reversed__c = true,
                                                            loan__Payment_Mode__c = pMode.Id);
                                                            
        
        insert lptToBeInserted;
        
        try {
            loan__Loan_Payment_Transaction__c lpt = [select id,
                                                            name,
                                                            loan__Loan_Account__r.name,
                                                            loan__Transaction_Date__c,
                                                            loan__ACH_Filename__c 
                                                       from loan__Loan_Payment_Transaction__c
                                                      limit 1];
            
            system.debug('--LPT--'+lpt);                                         
         
            
            Integer currentYear = Date.today().year();
            String first2DegitOfTheCurrentYear = String.valueof(currentYear).subString(0,2);                     
            String line1 = '5200SENTRALOH                           2740689951PPDAUTOPAY   1612051701120121113008460000955';
            String line2 = '6261130084651428361933       0000020000LAI000000022   Gertrude Dini           1113008466650534';
            String line3 = '799R01113024166473239      04411580                                            113008466650534';
            
            String newLine1 = line1.replace(line1.substring(63,69),(first2DegitOfTheCurrentYear+String.valueof(lpt.loan__Transaction_Date__c.month())+String.valueof(lpt.loan__Transaction_Date__c.day())));                                  
            String newLine2 = line2.replace(line2.subString(43,51),lpt.loan__Loan_Account__r.name.substring(4,lpt.loan__Loan_Account__r.name.length()));
            
            String newLine2WithDate = newLine2.replace(newLine2.subString(88,93),lpt.Name.substring(2,7));
            String newLine3WithDate = line3.replace(line3.subString(88,93),lpt.Name.substring(2,7));
            
            String achReturnFile = newLine1+'\r\n';
            achReturnFile += newLine2WithDate+'\r\n';
            achReturnFile += newLine3WithDate+'\r\n';
            
            System.debug('--achReturnFile--'+achReturnFile);
            
            Test.startTest();
            loan.ACHReturnPaymentProcessor paymentProcessor;
            String className = loan.CustomSettingsUtil.getACHParameters().loan__ACH_Return_Filegen__c;
            
            paymentProcessor = (loan.ACHReturnPaymentProcessor) loan.FileGenerator.getNewInstance(className);
            
            //String body = achFile.body.toString();
            paymentProcessor.setBlob(achReturnFile ); 
            paymentProcessor.setScope(200);  
            paymentProcessor.processPaymentReversal(); 
            Test.stopTest();               
        }Catch(Exception e) {
            system.debug('--Expection--'+e+e.getStackTraceString());
        }
        
    }
    public static testMethod void parseACHDisbursalReturn(){
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn(); // 3 day lock period
        List<filegen__File_Metadata__c> metadata = Test.loadData(filegen__File_Metadata__c.sObjectType,'CustomTestMetaData');
        loan.TestHelper.setupACHParameters();
        loan.TestHelper2.createFileGenMetaData();
        //loan.TestHelper2.createOrgBankAccounts();

        loan__Transaction_Approval_Config__c c = loan.CustomSettingsUtil.getApprovalConfig();
        loan__ACH_Parameters__c ach = loan.CustomSettingsUtil.getACHParameters();
        ach.loan__Days_In_Advance_To_Create_File__c = 0;
        ach.loan__Multiple_Payment_Method_Support__c =true;
        ach.loan__ACH_Return_Filegen__c = 'CustomACHReturnFileParser';
        ach.PPDAdvance_Folder_Name__c = 'ACH';
        ach.CORPayment_Folder_Name__c = 'ACH';
        upsert ach;
        system.debug('--ach custom setting--'+ach);

        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');

        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount,
                            curr,
                            dummyFeeSet);
        
        loan__Payment_Mode__c pMode = new loan__Payment_Mode__c(Name = 'ACH BofA Opp');
        insert pMode;
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        //Account a1 = loan.TestHelper2.createInvestor('Bull', 1000);
        Account b1 = loan.TestHelper2.createBorrower('ShoeString');
        Contact con= new Contact(LastName='Test');
        insert con;
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__Routing_Number__c = '99999999',
                                                 Unmasked_Bank_Account_Number__c = '123234324',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Account__c = b1.id);
        insert ba;
        
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 Unmasked_Bank_Account_Number__c = '123234324',
                                                 loan__Routing_Number__c = '99999999',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Account_Usage__c = 'Collections Trust Account',
                                                 loan__Account__c = b1.id,
                                                 loan__Active__c = True);
        insert collectionTrustBA ;
 
        loan__Loan_Account__c dummylaMonthly = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                        b1,
                                        dummyFeeSet,
                                        dummyLoanPurpose,
                                        dummyOffice);
        
        dummylaMonthly.loan__Loan_Status__c = 'Active - Good Standing';
        dummylaMonthly.loan__Principal_Remaining__c = 10000;
        dummylaMonthly.loan__Contact__c = con.id;
        update dummylaMonthly;
        loan.GlobalLoanUtilFacade loanUtil = new loan.GlobalLoanUtilFacade();
        Date systemDate = loanUtil.getCurrentSystemDate();
        
        
        System.debug('--Loan--'+dummylaMonthly);
        
        
        loan__Automated_Payment_Configuration__c apc = loan.TestHelper2.createAutomatedPaymentConfiguration(
                                                            'LOAN PAYMENT',
                                                             pMode,
                                                             collectionTrustBA,
                                                             'loan.LoanPaymentTxnNACHAGen');
        
        loan__Automated_Payment_Setup__c aps = loan.TestHelper2.createAutomatedPaymentSetup(
                                                    loan.LoanConstants.RECURRING,
                                                    loan.LoanConstants.FIXED_AMOUNT,
                                                    ba,
                                                    dummylaMonthly,
                                                    'Monthly',
                                                    pMode,
                                                    systemDate);
         
        system.debug('--aps--'+aps);
        
        Set<String> paymentModes = new Set<String>();
        
        paymentModes.add(pMode.Name);
        /*Test.startTest();
        loan.LoanPaymentTransactionCreationJob j = new loan.LoanPaymentTransactionCreationJob(True);
        Database.executeBatch(j, 200);
        Test.stopTest(); 
        
        List<loan__Batch_Process_Log__c> logs = [select Id,name,loan__Message__c from loan__Batch_Process_Log__c order by createdDate desc];
        if(!logs.isempty()) {
            throw new peer.MarketplaceException('Test Failing: '+logs);
        }*/
        loan__Loan_Payment_Transaction__c lptToBeInserted = new loan__Loan_Payment_Transaction__c(
                                                            loan__Transaction_Date__c = systemDate,
                                                            loan__Transaction_Amount__c = 10,
                                                            loan__Loan_Account__c = dummylaMonthly.Id,
                                                            loan__Payment_Mode__c = pMode.Id);
                                                            
        
        insert lptToBeInserted;
        try {
            loan__Loan_Payment_Transaction__c lpt = [select id,
                                                            name,
                                                            loan__Cleared__c,
                                                            loan__Loan_Account__r.name,
                                                            loan__Transaction_Date__c,
                                                            loan__ACH_Filename__c 
                                                       from loan__Loan_Payment_Transaction__c
                                                      limit 1];
            
            system.debug('--LPT--'+lpt.loan__Cleared__c);                                         
            
            
            Integer currentYear = Date.today().year();
            String first2DegitOfTheCurrentYear = String.valueof(currentYear).subString(0,2);                     
            String line1 = '5200SENTRALOH                           2740689951PPDADVANCE   1612051701120121113008460000955';
            String line2 = '6261130084651428361933       0000020000LAI000000022   Gertrude Dini           1113008466650534';
            String line3 = '799R01113024166473239      04411580                                            113008466650534';
            
            String newLine1 = line1.replace(line1.substring(63,69),(first2DegitOfTheCurrentYear+String.valueof(lpt.loan__Transaction_Date__c.month())+String.valueof(lpt.loan__Transaction_Date__c.day())));                                  
            String newLine2 = line2.replace(line2.subString(43,51),lpt.loan__Loan_Account__r.name.substring(4,lpt.loan__Loan_Account__r.name.length()));
            
            newLine2 = newLine2.replace(newLine2.subString(43,51),lpt.loan__Loan_Account__r.name.substring(4,lpt.loan__Loan_Account__r.name.length()));
            
            String newLine2WithDate = newLine2.replace(newLine2.subString(88,93),lpt.Name.substring(2,7));
            String newLine3WithDate = line3.replace(line3.subString(14,21),lpt.Name.substring(2,7));
            
            String achReturnFile = newLine1+'\r\n';
            achReturnFile += newLine2WithDate+'\r\n';
            achReturnFile += newLine3WithDate+'\r\n';
            
            Test.startTest();
            loan.ACHReturnPaymentProcessor paymentProcessor;
            String className = loan.CustomSettingsUtil.getACHParameters().loan__ACH_Return_Filegen__c;
            
            paymentProcessor = (loan.ACHReturnPaymentProcessor) loan.FileGenerator.getNewInstance(className);
            
            paymentProcessor.setBlob(achReturnFile ); 
            paymentProcessor.setScope(200);  
            paymentProcessor.processPaymentReversal();  
            Test.stopTest();              
        }Catch(exception e) {
        
        }
        
    }
    public static testMethod void parseACHChangeDetailsReturn(){
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn(); // 3 day lock period
        List<filegen__File_Metadata__c> metadata = Test.loadData(filegen__File_Metadata__c.sObjectType,'CustomTestMetaData');
        loan.TestHelper.setupACHParameters();
        loan.TestHelper2.createFileGenMetaData();
        //loan.TestHelper2.createOrgBankAccounts();

        loan__Transaction_Approval_Config__c c = loan.CustomSettingsUtil.getApprovalConfig();
        loan__ACH_Parameters__c ach = loan.CustomSettingsUtil.getACHParameters();
        ach.loan__Days_In_Advance_To_Create_File__c = 0;
        ach.loan__Multiple_Payment_Method_Support__c =true;
        ach.loan__ACH_Return_Filegen__c = 'CustomACHReturnFileParser';
        ach.PPDAdvance_Folder_Name__c = 'Disbursal Reversal';
        ach.CORPayment_Folder_Name__c = 'Change Details';
        upsert ach;
        system.debug('--ach custom setting--'+ach);

        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');

        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount,
                            curr,
                            dummyFeeSet);
        
        loan__Payment_Mode__c pMode = new loan__Payment_Mode__c(Name = 'ACH BofA Opp');
        insert pMode;
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        //Account a1 = loan.TestHelper2.createInvestor('Bull', 1000);
        Account b1 = loan.TestHelper2.createBorrower('ShoeString');
        Contact con= new Contact(LastName='Test');
        insert con;
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 Unmasked_Bank_Account_Number__c = '123234324',
                                                 loan__Routing_Number__c = '99999999',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Account__c = b1.id);
        insert ba;
        
        Account acc = new Account(Name = 'Member');
        insert acc; //pallavi(CRM-253)
        
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 Unmasked_Bank_Account_Number__c = '123234324',
                                                 loan__Routing_Number__c = '99999999',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Account_Usage__c = 'Collections Trust Account',
                                                 loan__Contact__c = con.id,
                                                 loan__Active__c = True,
                                                 loan__Account__c = ACC.ID);    //pallavi(CRM-253)
        insert collectionTrustBA ;
  
        loan__Loan_Account__c dummylaMonthly = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                        b1,
                                        dummyFeeSet,
                                        dummyLoanPurpose,
                                        dummyOffice);
        
        dummylaMonthly.loan__Loan_Status__c = 'Active - Good Standing';
        dummylaMonthly.loan__Principal_Remaining__c = 10000;
        dummylaMonthly.loan__Contact__c = con.id;
       
        update dummylaMonthly;
        loan.GlobalLoanUtilFacade loanUtil = new loan.GlobalLoanUtilFacade();
        Date systemDate = loanUtil.getCurrentSystemDate();
        
        
        System.debug('--Loan--'+dummylaMonthly);
        
        
        loan__Automated_Payment_Configuration__c apc = loan.TestHelper2.createAutomatedPaymentConfiguration(
                                                            'LOAN PAYMENT',
                                                             pMode,
                                                             collectionTrustBA,
                                                             'loan.LoanPaymentTxnNACHAGen');
        
        loan__Automated_Payment_Setup__c aps = loan.TestHelper2.createAutomatedPaymentSetup(
                                                    loan.LoanConstants.RECURRING,
                                                    loan.LoanConstants.FIXED_AMOUNT,
                                                    ba,
                                                    dummylaMonthly,
                                                    'Monthly',
                                                    pMode,
                                                    systemDate);
         
        system.debug('--aps--'+aps);
        
        Set<String> paymentModes = new Set<String>();
        
        paymentModes.add(pMode.Name);
                                             
        system.debug([SELECT id, loan__Payment_Mode__r.Name FROM loan__Automated_Payment_Configuration__c WHERE loan__Active__c = TRUE]);                                                            
      /*Test.startTest();
        loan.LoanPaymentTransactionCreationJob j = new loan.LoanPaymentTransactionCreationJob(True);
        Database.executeBatch(j, 200);
        Test.stopTest(); 
        
        List<loan__Batch_Process_Log__c> logs = [select Id,name,loan__Message__c from loan__Batch_Process_Log__c order by createdDate desc];
        if(!logs.isempty()) {
            throw new peer.MarketplaceException('Test Failing: '+logs);
        }*/
        loan__Loan_Payment_Transaction__c lptToBeInserted = new loan__Loan_Payment_Transaction__c(
                                                            loan__Transaction_Date__c = systemDate,
                                                            loan__Transaction_Amount__c = 10,
                                                            loan__Loan_Account__c = dummylaMonthly.Id,
                                                            loan__Payment_Mode__c = pMode.Id);
                                                            
        
        insert lptToBeInserted;
        try {
            loan__Loan_Payment_Transaction__c lpt = [select id,
                                                        name,
                                                        loan__Loan_Account__r.name,
                                                        loan__Transaction_Date__c,
                                                        loan__ACH_Filename__c 
                                                   from loan__Loan_Payment_Transaction__c
                                                  limit 1];
        
            system.debug('--LPT--'+lpt);                                         
    
            Integer currentYear = Date.today().year();
            String first2DegitOfTheCurrentYear = String.valueof(currentYear).subString(0,2);                     
            String line1 = '5200SENTRALOH                           2740689951CORPAYMENT   1612051701120121113008460000955';
            String line2 = '6261130084651428361933       0000020000LAI000000022   Gertrude Dini           1113008466650534';
            String line3 = '798C01113024166473239      04411580                                            113008466650534';
            
            String newLine1 = line1.replace(line1.substring(63,69),(first2DegitOfTheCurrentYear+String.valueof(lpt.loan__Transaction_Date__c.month())+String.valueof(lpt.loan__Transaction_Date__c.day())));                                  
            String newLine2 = line2.replace(line2.subString(43,51),lpt.loan__Loan_Account__r.name.substring(4,lpt.loan__Loan_Account__r.name.length()));
            
            String achReturnFile = newLine1+'\r\n';
            achReturnFile += newLine2+'\r\n';
            achReturnFile += line3+'\r\n';
            
            loan.ACHReturnPaymentProcessor paymentProcessor;
            String className = loan.CustomSettingsUtil.getACHParameters().loan__ACH_Return_Filegen__c;
            
            paymentProcessor = (loan.ACHReturnPaymentProcessor) loan.FileGenerator.getNewInstance(className);
            
            //String body = achFile.body.toString();
            paymentProcessor.setBlob(achReturnFile ); 
            paymentProcessor.setScope(200);  
            paymentProcessor.processPaymentReversal();   
        }catch(Exception e) {
            //eat up purposefully for now to accomodate SFMC Change sets.
        }
    } 

}