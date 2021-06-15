/* ****************Modification History******************
 * Last Modified by        Date          JIRA number
 *      1. Pallavi        2020/01/27     LOS-28(Remove references to InvestorAccount field on CL contract)
 *      
 ******************Modification History******************/
@isTest
public class TestBankrupcy {
    
    public static testMethod void TestBankrupt(){
        
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Account_External_ID__c = 'Test';
        insert acc;
        
           //Creating loan account 
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount); 
        dummyFee.loan__Amount__c = 3;      
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
                                                 loan__Routing_Number__c = '99999999',
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
                                                 loan__Routing_Number__c = '99999999',
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
        
        System.debug('Loan Account --' + loanAccount);
        loanAccount.loan__Account__c = acc.Id;
        loanAccount.loan__Loan_Status__c = 'Active - Good Standing';
        update loanAccount;
        System.debug('Loan Account 2--' + loanAccount);
        
        Test.startTest();
        
        acc.Bankrupt__c = TRUE;
        update acc;
        
        List<id> accid = new list<id>();
        accid.add(acc.id);
        BankRupt.MarkBankRupt(accid);
        Database.executebatch(new BankruptJob(),1);
        
        Test.stopTest();
    }
    
    public static Loan__loan_account__c CreateLoanContract(id accId){
        
        loan.TestHelper.createSeedDataForTesting();
        //Create Currency...
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        
        //Create a dummy MF_Account... 
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('AccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('IncAccountForTest','30000 - INCOME');
        
        //Create a Fee,Fee Set and link them...
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        //Create Company...
        loan__Office_Name__c dummyCompany = loan.TestHelper.createOffice();
        
        User loggedUser = [select Id, Name,username, 
                           CompanyName,
                           loan__Current_Branch__c
                           from User where Id = :UserInfo.getUserId()];
        
        //User Compnay Assignment...
        loan__User_Branch_Info__c userCompany = new loan__User_Branch_Info__c();
        
        userCompany.loan__Branch__c = dummyCompany.id;
        userCompany.loan__Default_Branch__c = True;
        userCompany.loan__User__c = loggedUser.id;
        insert userCompany;
        
        //Create a Client
        loan__Client__c dummyClient = loan.TestHelper.createClient(dummyCompany);
        
        //Create a dummy Loan Product...
        loan__Loan_Product__c dummyLoanLP = loan.TestHelper.createLoanProduct(dummyCompany,
                                                                              dummyAccount, 
                                                                              curr, 
                                                                              dummyFeeSet);
        dummyLoanLP.Name = 'Regular Loan';
        dummyLoanLP.loan__Minimum_Amount_Due_Type__c = 'Percent';
        update dummyLoanLP;
        
        //Company Product Assignment...
        loan__Branch_Loan_Product__c branchProduct = new loan__Branch_Loan_Product__c();
        branchProduct.loan__Branch__c = dummyCompany.id;
        branchProduct.loan__Loan_Product__c = dummyLoanLP.Id;
        insert branchProduct;
        
        Contact con = genesis.TestHelper.createContact();
        
        //Create Loan Purpose...
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        Loan__loan_account__c loanContract = new loan__loan_account__c();
        
        Date da = date.today();
        
        loanContract.loan__Account__c = accId;
        loanContract.loan__Loan_Purpose__c=dummyLoanPurpose.id;
        loanContract.loan__Fee_Set__c = dummyFeeSet.id;
        loanContract.loan__Loan_Product_Name__c = dummyLoanLP.id;
        loanContract.OwnerId = loggedUser.id;
        loanContract.loan__Branch__c = dummyClient.id;
        loanContract.loan__Overdue_Interest_Rate__c=12; 
        loanContract.loan__Frequency_of_Loan_Payment__c='Monthly'; 
        loanContract.loan__Client__c = dummyClient.id;
        loanContract.loan__First_Installment_Date__c= da.addMonths(1); 
        loanContract.loan__Expected_Disbursal_Date__c=da; 
        loanContract.loan__Repayment_Tied_to_Meeting_Schedule__c=false; 
        loanContract.loan__Repayment_Procedure__c='Equal Monthly Installments'; 
        loanContract.loan__Interest_Calculation_Method__c='Declining Balance'; 
        loanContract.loan__Expected_Repayment_Start_Date__c=da.addMonths(1); 
        loanContract.loan__Contractual_Due_Day__c=3; 
        loanContract.loan__Due_Day__c=3; 
        loanContract.loan__Next_Due_Generation_Date__c=da.addMonths(1); 
        loanContract.loan__Next_Installment_Date__c=da.addMonths(1); 
        loanContract.loan__Last_Installment_Date__c=da.addYears(1); 
        loanContract.loan__Maturity_Date_Current__c=da.addYears(1); 
        loanContract.loan__la_next_amortization_date__c=da; 
        loanContract.loan__LA_Amortization_Enabled__c=true; 
        loanContract.loan__LA_Amortized_Balance_Type__c='Interest'; 
        loanContract.loan__LA_Amortization_Frequency__c='Monthly'; 
        loanContract.loan__Delinquency_Grace_Days__c=10; 
        loanContract.loan__Interest_Remaining__c=0; 
        loanContract.loan__Excess__c=0; 
        loanContract.loan__Delinquent_Amount__c=0; 
        loanContract.loan__Pmt_Amt_Cur__c=1200; 
        loanContract.loan__Branch__c='a2Bn0000000IZFgEAO'; 
        loanContract.loan__Oldest_Due_Date__c=da.addMonths(1); 
        loanContract.loan__Term_Cur__c=12;  
        loanContract.loan__Disbursal_Date__c=da; 
        loanContract.loan__Last_Accrual_Date__c=da; 
        loanContract.loan__Loan_Status__c='Active - Good Standing';
        
        insert loanContract;
        return loanContract;
    }
}