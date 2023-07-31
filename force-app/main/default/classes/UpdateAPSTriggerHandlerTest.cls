// Test class for UpdateAPSTriggerHandler class

@isTest
public class UpdateAPSTriggerHandlerTest {

    public static testmethod void updateLoanOtherTrxns(){
    
        Test.StartTest();
        UpdateAPSTriggerHandler.isRecursive = false;
    
        loan__Org_Parameters__c loanorg = loan.CustomSettingsUtil.getOrgParameters();
        loanorg.Manual_Payer_Lending_product_name__c = 'Manual Payer';
        loanorg.Auto_Payer_Lending_Product_Name__c = 'Auto Payer';
        upsert loanorg;
        
        
        //Creating loan account 
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
    
         //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount); 
        dummyFee.loan__Amount__c = 30;      
        dummyFee.loan__Time_Of_Charge__c = 'Other';
        upsert dummyFee;
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        System.debug('dummyOffice'+dummyOffice.name);

        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP1 = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            curr, 
                            dummyFeeSet);
        dummyLP1.name = 'Auto Payer';
        dummyLP1.loan__Pre_Bill_Days__c = 5;
        upsert dummyLP1;
                          
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            curr, 
                            dummyFeeSet);
        dummyLP.name = 'Manual Payer';
        dummyLP.loan__Pre_Bill_Days__c = 5;
        upsert dummyLP;

        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();        
        dummyLoanPurpose.loan__Loan_Purpose_Code__c = 'Refinance';
        account dummyClient = new account(); 
        dummyClient.Name = 'Payoff';
        dummyClient.peer__Last_Name__c = 'Account';
        dummyClient.peer__First_Name__c = 'Test';
        insert dummyClient;
        
        Account invacc = new Account();
        invacc.name = 'investor';
        insert invacc;
        
        loan__Payment_Mode__c pm = new loan__Payment_Mode__c();
        pm.name = 'Wire';
        insert pm;
        
        //investor bank acc.
        loan__Bank_Account__c bainv = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__Routing_Number__c = '999999999',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Active__c = true,
                                                 Unmasked_Bank_Account_Number__c = '99999999',
                                                 loan__Account__c = invacc.id);
        insert bainv;
        
        loan__Automated_Payment_Configuration__c invaps = new loan__Automated_Payment_Configuration__c();
        invaps.loan__Payment_Mode__c = pm.id;
        invaps.loan__Bank_Account__c = bainv.id;
        invaps.loan__Filegen_Class__c = 'CustomLoanPaymentTxnNACHAGen';
        invaps.loan__Folder_Name__c = 'ACU';
        invaps.loan__File_Type__c = 'CSV';
        invaps.loan__Event__c = 'LOAN PAYMENT';
        insert invaps;
        
        
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__Routing_Number__c = '999999999',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Active__c = true,
                                                 Unmasked_Bank_Account_Number__c = '99999999',
                                                 loan__Account__c = dummyClient.id);
        insert ba;
        
        
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                    dummyClient,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
        loanAccount.loan__Number_of_Installments__c     = 12;                                  
        loanAccount.Loan__Loan_Status__c                = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        loanAccount.Loan__Fees_Remaining__c             = 100;
        loanAccount.Loan__Interest_Remaining__c         = 500;
        loanAccount.Loan__Principal_Remaining__c        = 1000;
        loanAccount.Loan__Fractionalization_Status__c   = loan.LoanConstants.FRACTIONALIZATION_STATUS_ACTIVE;
        loanAccount.Loan__Pay_off_Amount_As_Of_Today__c = loanAccount.loan__Fees_Remaining__c + loanAccount.loan__Principal_Remaining__c;
        loanAccount.loan__Delinquent_Amount__c             = 5000;
        loanAccount.loan__Next_Due_Generation_Date__c = date.today().adddays(15);
        //loanAccount.Investor_Account__c = invacc.id;  //commented(LOS-28)
        upsert loanAccount;  
        system.assertNotEquals(loanAccount.id,null,'LoanAccount not inserted');

    
    
    loan__Other_Transaction__c otherTxn = new loan__Other_Transaction__c();
    otherTxn.loan__Transaction_Type__c = 'Charge Off' ;
    otherTxn.loan__Loan_Account__c = loanAccount.id ;
    otherTxn.loan__Txn_Date__c = Date.today().addDays(-10);
    otherTxn.loan__Charged_Off_Principal__c = 1200.00;
    otherTxn.loan__Charged_Off_Interest__c = 54.96;
    otherTxn.loan__Charged_Off_Date__c = Date.today().addDays(-10);
    insert otherTxn;
    system.assertEquals(otherTxn.loan__Transaction_Type__c, 'Charge Off','charge off transaction cretaed');
    
    
    loan__Other_Transaction__c otherTxn1 = new loan__Other_Transaction__c();
    otherTxn1 .loan__Transaction_Type__c = 'Charge Off' ;
    otherTxn1 .loan__Loan_Account__c = loanAccount.id ;
    otherTxn1 .loan__Txn_Date__c = Date.today();
    otherTxn1 .loan__Charged_Off_Principal__c = 1100.00;
    otherTxn1 .loan__Charged_Off_Interest__c = 54.96;
    otherTxn1 .loan__Charged_Off_Date__c = Date.today();
    insert otherTxn1;
    system.assertEquals(otherTxn.loan__Transaction_Type__c,'Charge Off','charge off transaction cretaed');
    
    List<loan__Other_Transaction__c> chargeOffTrxns=[Select id, name,loan__Transaction_Type__c,loan__Loan_Account__c from loan__Other_Transaction__c
                                                     where loan__Transaction_Type__c ='Charge Off' ];
        
        
        if(chargeOffTrxns !=null && chargeOffTrxns.size()>0){
            otherTxn1.loan__Charged_Off_Principal__c = 1200.00;
            
        }
        
        update otherTxn1;
        
        UpdateAPSTriggerHandler.isRecursive = true;
        system.assertNotEquals(otherTxn.loan__Charged_Off_Date__c,otherTxn1.loan__Charged_Off_Date__c,'Charged off date is updated');
        system.assertNotEquals(loanAccount.loan__Charged_Off_Date__c,otherTxn1.loan__Charged_Off_Date__c,'Charged off date is updated');
    Test.stopTest();
    
    }

 }