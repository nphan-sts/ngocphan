/* ****************Modification History******************
 * Modified By        Date          JIRA number
 *1. Bhanupriya		2022/03/02		LSP-556  
 ******************Modification History******************/

@isTest
public class BillsGenerationJobTest {
@testSetup static void setup() {
    	loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
    	
    	loan__Trigger_Parameters__c triggerParam = new loan__Trigger_Parameters__c();
        triggerParam.loan__Disable_Loan_Account_Trigger__c=true;
        insert triggerParam;
    
       	loan.TestHelper.createSeedDataForTesting();
    	loan__office_Type__c testBranchType = new loan__Office_Type__c(Name='Test Data',
                                                        loan__Office_Type_Short_Code__c='TestSC' );
        insert testBranchType;
    	
       Id rtId = Schema.SObjectType.loan__Office_Name__c.getRecordTypeInfosByName().get('Root Branch').getRecordTypeId();
       loan__Currency__c curr = loan.TestHelper.createCurrency();
       //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
     
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
		system.debug('Junction fee' +dummyFeeJunction);
    	//Create Company
        genesis__Company__c comp = genesis.TestHelper.createCompany(); 
        comp.Name = 'payoff';
        update comp;
    	loan__Branch_Location__c testLoc = new loan__Branch_Location__c(Name='Test Data',
                                            loan__Address_Line_1__c = 'Add1',
                                            loan__Address_Line_2__c = 'Add2',
                                            loan__State__c = 'MH',
                                            loan__Phone__C = '32323232',
                                            loan__Zip_code__c = 33333
                                            );
        insert testLoc;
    	//Create Company...
        loan__Office_Name__c dummyCompany = new loan__Office_Name__c(Name='PayOff Inc.',
                                                    loan__Office_Location__c = testLoc.ID,
                                                    loan__Office_Short_Name__c = 'XXXCSN',
                                                    loan__Cash_Account__c = dummyAccount.Id,
                                                    loan__Check_Account__c = dummyAccount.Id,
                                                    loan__Bank_Account_Checks__c = dummyAccount.Id,
                                                    loan__Inward_Check_Clearance_Account__c = dummyAccount.Id,
                                                    loan__Outward_Check_Clearance_Account__c= dummyAccount.Id,
                                                    loan__Profit_and_Loss_Account__c = dummyAccount.Id,
                                                    loan__Loan_Schedule_tied_to_Meeting_Schedule__c = false,
                                                    loan__Mark_Suspended_After_Days__c = 180,
                                                    loan__State__c = 'Active',
                                                    loan__Write_Off_Suggestion_Days__c = 90,
                                                   // loan__Office_Type__c = testBranchType.ID,
                                                    loan__Days_in_advance_to_create_Collection_Rep__c=1,
                                                    loan__Current_System_Date__c = Date.newInstance(2020, 02, 19),
                                                   	RecordTypeId = rtId,
                                                    loan__Is_Branch__c=true);
		insert dummyCompany;
    
     	User loggedUser = [select Id, Name,username, 
                           CompanyName,
                           loan__Current_Branch__c
                           from User where Id = :UserInfo.getUserId()];
		System.debug('----- loggedUser: '+loggedUser.CompanyName +' ....... '+loggedUser.loan__Current_Branch__c);
    	
        //User Company Assignment...
        loan__User_Branch_Info__c userCompany = new loan__User_Branch_Info__c();
        
        userCompany.loan__Branch__c = dummyCompany.Id;
        userCompany.loan__Default_Branch__c = True;
        userCompany.loan__User__c = loggedUser.id;
        insert userCompany;System.debug('............. '+userCompany.loan__Branch__r.loan__Current_System_Date__c);

        //Create Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            peer__Last_Name__c = 'Test Last Name',			//LSP-556
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789'
            );
        insert acc;
        
        LoanPaymentDays__c lpdays = new LoanPaymentDays__c();
        lpdays.AutoPaymentRemainder__c= 3;
        lpdays.ManualPaymentRemainder__c= 5;
        insert lpdays;
              
           
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyCompany, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__General_Rounding_Mode__c = null;
        dummyLP.loan__Digits_After_Decimals__c = null;
        update dummyLP;
        
        //creating CL Product
        clcommon__CL_Product__c pr = new clcommon__CL_Product__c();
        pr.loan__Lending_Product__c = dummyLP.id;
        pr.clcommon__Product_Name__c = 'P1';
        insert pr;
       
    	//create application
        genesis__applications__c application = new genesis__applications__c();
        application.genesis__Product_Type__c = 'Loan';
        application.genesis__Loan_Amount__c = 100000;
        application.genesis__status__c = 'NEW - ENTERED';
        application.genesis__Term__c = 12;
        application.genesis__Payment_Frequency__c = 'MONTHLY';
        application.genesis__Interest_Rate__c = 10;
        application.genesis__Days_Convention__c = 'ACTUAL/ACTUAL';
        application.genesis__Expected_Start_Date__c = system.today();
        application.genesis__Expected_First_Payment_Date__c = system.today().addDays(60);
        application.genesis__Expected_Close_Date__c = system.today().addDays(30);
        application.genesis__Interest_Calculation_Method__c = 'Declining Balance';
        application.genesis__Interest_Only_Period__c = 0;
        application.genesis__Interest_Rate__c = 10;
        application.genesis__Account__c = acc.Id;
        application.genesis__Total_Estimated_Interest__c=500;
        application.genesis__Valid_Pricing_Flag__c=false;
        application.genesis__Probability__c=100.00;
        application.genesis__Payment_Amount__c=100000;
        application.genesis__Company__c = comp.id;
        application.genesis__CL_Product__c = pr.id;
        insert application;
           
    	//create Loan account
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
                                          	loan__Account__c = acc.Id,
                                            loan__Product_Type__c = 'Flexible Amz Loan',
                                            loan__Loan_Amount__c =100000,
            								loan__Principal_Remaining__c = 10000,
                                           	loan__Loan_Product_Name__c = dummyLP.Id,
                                            loan__Payment_Amount__c=100000,
                                            loan__Previous_Installment_Date__c= system.today(),
                                            application__c = application.id,
                                            loan__First_Installment_Date__c = Date.newInstance(2020, 01, 19), 
                                            loan__Next_Installment_Date__c = Date.newInstance(2020, 02, 19),
                                            loan__Maturity_Date_Current__c = Date.newInstance(2022, 01, 19), 
                                            loan__Frequency_of_Loan_Payment__c = 'Monthly',
                                            loan__Last_Installment_Date__c = Date.newInstance(2020, 01, 19) , 
                                            loan__Is_Rescheduled__c = false, 
                                            loan__Loan_Status__c = 'Active - Bad Standing', 
                                            lead_Guid__c = '',
                                            loan__Oldest_Due_Date__c = Date.newInstance(2020, 01, 19),
                                            loan__Last_Payment_Date__c = Date.newInstance(2020, 01, 19),
                                           	loan__Accrual_Start_Date__c = Date.newInstance(2020, 01, 19),
                                            loan__Interest_Rate__c = 10,
                                            loan__Pmt_Amt_Cur__c = 1000,
                                            loan__Term_Cur__c = 100,
                                            loan__Last_Accrual_Date__c = Date.newInstance(2020, 01, 19),
                                            loan__Disbursal_Date__c = Date.newInstance(2019, 12, 19),
                                            loan__Payment_Application_Mode__c = 'Deposit',
                                            loan__Additional_Loan_Amount__c = 1000,
                                            loan__Accrual_Amount_Accounted_For__c = 10000,
                                            loan__ACH_Debit_Amount__c =1000,
                                            loan__Add_Fee_Amount_To_Bill__c = true,
                                            loan__Adjust_Deposit_Amount_In_Payoff__c = true,
                                            loan__Amount_Due_Till_Current__c = 10000,
                                            loan__Cancellation_Tolerance_Amount__c =100,
                                            loan__Delinquent_Amount__c =1000,
                                            loan__Disbursal_Amount__c = 100000,
                                            loan__Metro2_Account_highest_bal_amount__c =1000,
                                            loan__Last_Billed_Amount__c = 1000,
                                            loan__Last_Disbursal_Amount__c = 10000,
                                            loan__Last_Payment_Amount__c = 1000,
                                            Loan_Premium_Amount__c =1000,
                                            loan__Maximum_Advance_Amount__c = 10000,
                                            loan__Maximum_Draw_Amount__c = 10000,
                                            loan__Minimum_Advance_Amount__c =100,
                                            loan__Minimum_Amount_Due__c =100,
                                            loan__Minimum_Due_Amount_On_Billing__c =1000,
                                            loan__Minimum_Draw_Amount__c = 100,
                                            loan__Next_Repayment_Amount_As_Of_Today__c =10000,
                                            loan__Uncleared_Disbursal_Amount__c =10000,
                                            loan__Uncleared_Repayment_Amount__c =10000,
                                            loan__Uncleared_Written_Off_Amount__c =10000,
                                            loan__Loan_Balance__c = 10000
                                            );
    	lacc.loan__Pre_Bill_Days__c = 0;
    	lacc.loan__Next_Due_Generation_Date__c = Date.newInstance(2020, 02, 19);
    	lacc.loan__Branch__c = userCompany.loan__Branch__c;
    	lacc.loan__loan_status__c = 'active - good standing';
    	lacc.loan__invalid_data__c = false;
        insert lacc; 
    	
        
      //create Repayment Schedule Summary 1
        loan__Repayment_Schedule_Summary__c repaymentScheduleSummary = new loan__Repayment_Schedule_Summary__c();
        repaymentScheduleSummary.loan__RSS_No_Of_Pmts__c = 10;
        repaymentScheduleSummary.loan__Archived__c = false;
        repaymentScheduleSummary.loan__RSS_Loan_Account__c = lacc.Id;
        insert repaymentScheduleSummary;
        
      //create Repayment Summary 
        loan__Repayment_Schedule__c loanRepaymentSchedule = new loan__Repayment_Schedule__c();
        loanRepaymentSchedule.loan__Due_Date__c = Date.newInstance(2020, 01, 19);
        loanRepaymentSchedule.loan__Loan_Account__c = lacc.Id;
        loanRepaymentSchedule.loan__Is_Archived__c = false;
        insert loanRepaymentSchedule;
        
        loan__Repayment_Schedule__c loanRepaymentSchedule1 = new loan__Repayment_Schedule__c();
        loanRepaymentSchedule1.loan__Due_Date__c = Date.newInstance(2020, 02, 19);
        loanRepaymentSchedule1.loan__Loan_Account__c = lacc.Id;
        loanRepaymentSchedule1.loan__Is_Archived__c = false;
        loanRepaymentSchedule1.loan__Balance__c = 10000;
        loanRepaymentSchedule1.loan__Due_Amount__c = 10000;
        insert loanRepaymentSchedule1;
        
        loan__Repayment_Schedule__c loanRepaymentSchedule2 = new loan__Repayment_Schedule__c();
        loanRepaymentSchedule2.loan__Due_Date__c = Date.newInstance(2020, 03, 19);
        loanRepaymentSchedule2.loan__Loan_Account__c = lacc.Id;
        loanRepaymentSchedule2.loan__Is_Archived__c = false;
        loanRepaymentSchedule2.loan__Balance__c = 10000;
        loanRepaymentSchedule2.loan__Due_Amount__c = 10000;
        insert loanRepaymentSchedule2;
        
        loan__Repayment_Schedule__c loanRepaymentSchedule3 = new loan__Repayment_Schedule__c();
        loanRepaymentSchedule3.loan__Due_Date__c = Date.newInstance(2020, 04, 19);
        loanRepaymentSchedule3.loan__Loan_Account__c = lacc.Id;
        loanRepaymentSchedule3.loan__Is_Archived__c = false;
        loanRepaymentSchedule3.loan__Balance__c = 10000;
        loanRepaymentSchedule3.loan__Due_Amount__c = 10000;
        insert loanRepaymentSchedule3;   
        
 }

	@isTest
    public static void testRunBillGeneration(){  
        	
        		List<loan__Loan_Account__c> loanIds = [Select Id,loan__Branch__r.loan__Current_System_Date__c from loan__Loan_Account__c];
        		List<Id> idList = new List<Id>();
            	for(loan__Loan_Account__c loanId:loanIds){
                		idList.add(loanId.Id);
            	}
				test.startTest();
            	BillsGenerationJob.runBillingJob(idList);
        		test.stopTest();
			loan__Loan_Account__c lac = [select id ,loan__Unpaid_Bills__c from loan__Loan_Account__c];
        	system.assertEquals(lac.loan__Unpaid_Bills__c,true);
        
        	}
    
    

}