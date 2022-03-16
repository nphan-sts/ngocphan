/* ****************Modification History******************
 * Modified By        Date          JIRA number
 *1. Bhanupriya        2022/02/25     LSP-551
*/
@isTest
public class LoanRescheduleJobTest {
    //Create testsetup() method
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
       loan__Currency__c curr = loan.TestHelper.createCurrency();
       //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
     
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
       //create office
        loan__Office_Name__c dummyCompany = loan.TestHelper.createOffice();
      dummyCompany.loan__Current_System_Date__c = Date.newInstance(2020, 02, 19);
   
        //Create Account
         Account acc = new Account(
                                Name = 'Test',
                                loan__Investor__c=False,
                                //Borrower_s_Last_Name__c='Testborrower',
                                peer__Last_Name__c = 'Test Last Name',				//LSP-551
                                cnotify__Email__c = 'abc@test.com',
                                loan__SOCIAL_SECURITY_NUMBER__c = '123456789'		//LSP-551
                                );
        insert acc;
        
        LoanPaymentDays__c lpdays = new LoanPaymentDays__c();
        lpdays.AutoPaymentRemainder__c= 3;
        lpdays.ManualPaymentRemainder__c= 5;
        insert lpdays;
              
        //Create Company
        genesis__Company__c comp = genesis.TestHelper.createCompany(); 
        comp.Name = 'payoff';
        update comp;
      
      	User loggedUser = [select Id, Name,username, 
                           CompanyName,
                           loan__Current_Branch__c
                           from User where Id = :UserInfo.getUserId()];
      
        //User Company Assignment...
        loan__User_Branch_Info__c userCompany = new loan__User_Branch_Info__c();
        
        userCompany.loan__Branch__c = dummyCompany.Id;
        userCompany.loan__Default_Branch__c = True;
        userCompany.loan__User__c = loggedUser.id;
        insert userCompany;
       
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
        
    	//create loan account
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
                                            loan__Account__c= acc.Id,
                                            loan__Product_Type__c= 'flexible amz loan',
                                            loan__Loan_Amount__c =100000,
                            				loan__Principal_Remaining__c = 10000,
                                            loan__Loan_Product_Name__c=dummyLP.Id,
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
                                            loan__Last_Accrual_Date__c = System.today(),//Date.newInstance(2020, 01, 19),
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
      		lacc.loan__Reschedule_Status__c = 'Pending';
      		lacc.loan__Branch__c = userCompany.loan__Branch__c;
      		lacc.loan__loan_status__c = 'active - good standing';
        insert lacc; 
      
      	loan__Other_Transaction__c otherTxn = new loan__Other_Transaction__c();
        otherTxn.loan__transaction_type__c = 'Reschedule';
      	otherTxn.loan__Loan_Account__c = lacc.Id;
      	insert otherTxn;
        
    	//create loan Repayment Schedule summary 
        loan__Repayment_Schedule_Summary__c repaymentScheduleSummary = new loan__Repayment_Schedule_Summary__c();
        repaymentScheduleSummary.loan__RSS_No_Of_Pmts__c = 10;
        repaymentScheduleSummary.loan__Archived__c = false;
        repaymentScheduleSummary.loan__RSS_Loan_Account__c = lacc.Id;
        insert repaymentScheduleSummary;
        
    	//create loan Repayment Schedule 1
        loan__Repayment_Schedule__c loanRepaymentSchedule = new loan__Repayment_Schedule__c();
        loanRepaymentSchedule.loan__Due_Date__c = Date.newInstance(2020, 01, 19);
        loanRepaymentSchedule.loan__Loan_Account__c = lacc.Id;
        loanRepaymentSchedule.loan__Is_Archived__c = false;
        insert loanRepaymentSchedule;
        
    	//create loan Repayment Schedule 2
        loan__Repayment_Schedule__c loanRepaymentSchedule1 = new loan__Repayment_Schedule__c();
        loanRepaymentSchedule1.loan__Due_Date__c = Date.newInstance(2020, 02, 19);
        loanRepaymentSchedule1.loan__Loan_Account__c = lacc.Id;
        loanRepaymentSchedule1.loan__Is_Archived__c = false;
        loanRepaymentSchedule1.loan__Balance__c = 10000;
        loanRepaymentSchedule1.loan__Due_Amount__c = 10000;
        insert loanRepaymentSchedule1;
        
    	//create loan Repayment Schedule 3
        loan__Repayment_Schedule__c loanRepaymentSchedule2 = new loan__Repayment_Schedule__c();
        loanRepaymentSchedule2.loan__Due_Date__c = Date.newInstance(2020, 03, 19);
        loanRepaymentSchedule2.loan__Loan_Account__c = lacc.Id;
        loanRepaymentSchedule2.loan__Is_Archived__c = false;
        loanRepaymentSchedule2.loan__Balance__c = 10000;
        loanRepaymentSchedule2.loan__Due_Amount__c = 10000;
        insert loanRepaymentSchedule2;
        
    	//create loan Repayment Schedule 4
        loan__Repayment_Schedule__c loanRepaymentSchedule3 = new loan__Repayment_Schedule__c();
        loanRepaymentSchedule3.loan__Due_Date__c = Date.newInstance(2020, 04, 19);
        loanRepaymentSchedule3.loan__Loan_Account__c = lacc.Id;
        loanRepaymentSchedule3.loan__Is_Archived__c = false;
        loanRepaymentSchedule3.loan__Balance__c = 10000;
        loanRepaymentSchedule3.loan__Due_Amount__c = 10000;
        insert loanRepaymentSchedule3;   
 	}
	// Test method 1
  @isTest
    public static void testReschedulejob(){
           List<loan__Loan_Account__c> loanIds = [Select Id,loan__Branch__r.loan__Current_System_Date__c from loan__Loan_Account__c];
           System.debug('------date----- : '+loanIds[0].loan__Branch__r.loan__Current_System_Date__c);
          List<Id> idList = new List<Id>();
            for(loan__Loan_Account__c loanId:loanIds){
                idList.add(loanId.Id);
            }
        test.startTest();
         LoanRescheduleJob.runRescheduleJob(idList);
		test.stopTest();
        	List<loan__Loan_Account__c> loanAcc = [select Id,loan__Loan_Status__c, loan__Is_Rescheduled__c,loan__Reschedule_Status__c,(Select id,name,loan__Due_Date__c from loan__Repayment_Schedule__r),(select id,name from loan__Repayment_Plan__r) from loan__Loan_Account__c];
             System.assert(!loanAcc.isEmpty());
         /* try{
                LoanRescheduleJob.runRescheduleJob(idList);
                List<loan__Loan_Account__c> loanAcc = [select Id,loan__Loan_Status__c, loan__Is_Rescheduled__c,loan__Reschedule_Status__c,(Select id,name,loan__Due_Date__c from loan__Repayment_Schedule__r),(select id,name from loan__Repayment_Plan__r) from loan__Loan_Account__c];
                System.assert(!loanAcc.isEmpty());
        }catch(Exception e){
            System.debug('Failed to run the batch');
        }*/
    }
    //Test method 2 for Exceptions
    @isTest
    public static void testReschedulejobException(){
          List<Id> idList = new List<Id>();
        /*  try{
                LoanRescheduleJob.runRescheduleJob(idList);
                List<loan__Loan_Account__c> loanAcc = [select Id,loan__Loan_Status__c, loan__Is_Rescheduled__c,loan__Reschedule_Status__c,(Select id,name,loan__Due_Date__c from loan__Repayment_Schedule__r),(select id,name from loan__Repayment_Plan__r) from loan__Loan_Account__c];
                System.assert(!loanAcc.isEmpty());
        }catch(Exception e){
            System.debug('Failed to run the batch');
        }
    }*/
        test.startTest();
        LoanRescheduleJob.runRescheduleJob(idList);
		test.stopTest();
        List<loan__Loan_Account__c> loanAcc = [select Id,loan__Loan_Status__c, loan__Is_Rescheduled__c,loan__Reschedule_Status__c,(Select id,name,loan__Due_Date__c from loan__Repayment_Schedule__r),(select id,name from loan__Repayment_Plan__r) from loan__Loan_Account__c];
           System.assert(!loanAcc.isEmpty());
    }
}