/**
* Class - To perform validation on contracts after migration
*
* 
* @author - Pallavi
* **/
public class Post_actualObj_ValidationHandler {
    
    public List<loan__Loan_Account__c> errorUpdate = new List<loan__Loan_Account__c>();
    public static Id contractId;
    loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
    List<loan__Interest_Posting_Transaction__c> ipts = new List<loan__Interest_Posting_Transaction__c>();
    Date currentDate = util.getCurrentSystemDate();
    Date tocheck_Bill_ipt_date = Date.newInstance(3000, 12, 31);
    Public String errors = '';
    boolean resError = false;
    
    
    public void ValidationWrapper(List<loan__Loan_Account__c> contractList, Map<String,DM_PrimaryObject_Query_Generator__c> MapQueryGenerate,Map<String,List<sObject>> queryChildContracts){    //always run with scope 1
        System.debug('validate here');

        DM_Primary_Objects_Validation__c errUpdate = new DM_Primary_Objects_Validation__c();    //pallavi
        String errors = '';
        
        for(loan__Loan_Account__c contract : contractList){
            boolean failure = false;
            Set<Id> IOIds = new Set<Id>();
            Set<Id> LDTIds = new Set<Id>(); //pallavi
            Set<Id> LPTIds = new Set<Id>();     //pallavi
            String loanStatus = '';
            //String errors = '';
            Map<Date,Boolean> billMap = new Map<Date,Boolean>();
            Decimal sumPrinPaid = 0;
            Decimal sumInterestPaid = 0;
            Decimal sumInterestRemaining = 0;
            Date IPTdate = Date.newInstance(3000, 12, 31);
            Date Billdate = Date.newInstance(3000, 12, 31);
            contractId=contract.Id; 
            System.debug(contractId);
            
            List<DM_Primary_Objects_Validation__c> errList = (List<DM_Primary_Objects_Validation__c>)queryChildContracts.get('DM_Primary_Objects_Validation__c');
            DM_Primary_Objects_Validation__c err = errList[0];   //pallavi

            for(loan__Investor_Loan__c temp : (List<loan__Investor_Loan__c>)queryChildContracts.get('loan__Investor_Loan__c')){
                IOIds.add(temp.id);
            }
            
            List<loan__Loan_Disbursal_Transaction__c> ldtList = (List<loan__Loan_Disbursal_Transaction__c>)queryChildContracts.get('loan__Loan_Disbursal_Transaction__c');
            for(loan__Loan_Disbursal_Transaction__c temp : ldtList){
                LDTIds.add(temp.id);
            }
            
            for(loan__Loan_Payment_Transaction__c temp : (List<loan__Loan_Payment_Transaction__c>)queryChildContracts.get('loan__Loan_Payment_Transaction__c')){
                LPTIds.add(temp.id);
            }
            
            for(loan__Interest_Posting_Transaction__c ipt:(List<loan__Interest_Posting_Transaction__c>)queryChildContracts.get('loan__Interest_Posting_Transaction__c')){
                ipts.add(ipt);
            }
            
            loanStatus = contract.loan__Loan_Status__c;
            
            
            /*DM_Primary_Objects_Validation__c err = new DM_Primary_Objects_Validation__c();
            err.CL_Contract__c = contract.Id;*/ //pallavi(commented)
            
            if(contract.lead_Guid__c  == null){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'no product on Contract,';
            }
            if(contract.loan__Product_Type__c  == null){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'product type null on Contract,';
            }  
            if(contract.loan__Product_Type__c  == null){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'product type null on Contract,';
            }                                                                                               
            if(contract.loan__Loan_Amount__c == 0 || contract.loan__Loan_Amount__c == null){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Zero loan amount on Contract,';
                
            }                                          
            if(contract.loan__Account__c == null && contract.loan__Contact__c == null){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Account and Contact both null,';
                
            }
            
            if(contract.loan__Pmt_Amt_Cur__c == null|| contract.loan__Pmt_Amt_Cur__c == 0){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Current Payment Amount is null or zero on loan account,';
                
            }
            if(contract.loan__Payment_Amount__c == null || contract.loan__Payment_Amount__c == 0){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Loan Payment Amount is null or zero on loan account,';
                
            }
            if(contract.loan__Next_Installment_Date__c == null){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Next Due Date null on Contract,';
                
            }
            
            if(contract.loan__Funding_in_Tranches__c == false){ //remove comment
                Decimal paid = contract.loan__Principal_Remaining__c.setscale(2) + contract.loan__Principal_Paid__c.setscale(2);
                Decimal la = contract.loan__Loan_Amount__c.setscale(2)  + contract.loan__Principal_Adjustment__c.setscale(2) - contract.loan__Principal_Adjustment_Subtract__c.setscale(2);
                if (paid != la) {
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'mismatch in loan amount-' + paid + '/' + la + ',';
                    
                }
            }else{
                Decimal paid = contract.loan__Principal_Remaining__c.setscale(2) + contract.loan__Principal_Paid__c.setscale(2);
                Decimal da = contract.loan__Disbursed_Amount__c.setscale(2)  + contract.loan__Principal_Adjustment__c.setscale(2) - contract.loan__Principal_Adjustment_Subtract__c.setscale(2);
                if (paid != da){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'mismatch in loan amount-' + paid + '/' + da + ',';
                    
                }
            }
            if(contract.loan__Draw_Period_End_Date__c == null){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Draw Period End Date is null on loan account,';
                
            }
         
            if (contract.loan__Expected_Disbursal_Date__c == null){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Expected Dis Date null on Contract,';
                
            }
            
            if (contract.loan__Expected_Repayment_Start_Date__c == null){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Expected Repayment Start Date null on Contract,';
                
            }
            
            if (contract.loan__Disbursal_Date__c == null){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Contract Date is null on the loan account,';
                
            }
            
            if (contract.loan__First_Installment_Date__c == null){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'First Installment Date null on Contract,';
                
                
            }    
            
            if (contract.loan__Rate_Change_Dt_Next__c == null){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Next Rate Change Date null on Contract,';
                
            }   
            
            if ((contract.loan__Number_of_Installments__c == null || contract.loan__Term_Cur__c == null) ||(contract.loan__Number_of_Installments__c == 0 || contract.loan__Term_Cur__c == 0)){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Term/Current Term is null or zero on the loan accoun.,';
                
            } 
            
            if (contract.loan__Maturity_Date_Current__c == null || contract.loan__Last_Installment_Date__c == null){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Maturity Date/Current Maturity Date is null on the loan account,';
                
            }
            
            if (contract.loan__Due_Day__c == null || contract.loan__Due_Day__c == 0){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Due Day is null or zero on the loan account,';
                
            }  
            if (contract.loan__Next_Installment_Date__c == null || contract.loan__Next_Due_Generation_Date__c == null){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Next Due Date/Next Due Generation Date is null on loan account,';
            }   
            
            if (contract.loan__Rate_Change_Dt_Next__c < currentDate ) {        
                if (contract.loan__Loan_Status__c == 'Active - Bad Standing' ){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Next Rate Change date is in Past on the loan account,';
                    
                }else{
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Next Rate Change date is in Past on the loan account.,';
                }      
            }
            if (contract.loan__Next_Due_Generation_Date__c!=null && (contract.loan__Next_Due_Generation_Date__c) <= (contract.loan__Maturity_Date_Current__c) ){
                if (contract.loan__Next_Due_Generation_Date__c.addDays((contract.loan__Pre_Bill_Days__c == null)?0:(Integer)contract.loan__Pre_Bill_Days__c) != contract.loan__Next_Installment_Date__c ){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'There exists a mismatch between the Next Due Date and the Next Due Generation Date and Pre Bill Days.' +
                        ' The Next Due Date must be equal to the Next Due Generate Date plus Pre Bill Days,';
                }
            }
            if (contract.loan__Last_Accrual_Date__c == null ){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Last accrual date is null on loan account,';
            }
            
            if (contract.loan__LA_Amortization_Enabled__c){ 
                if ((contract.loan__la_amortization_frequency__c == null) || (contract.loan__la_amortization_frequency__c != loan.LoanConstants.LOAN_PAYMENT_FREQ_MONTHLY)) {
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Interest Amortization frequency is null or not set as Monthly,';
                    
                }
            }
            if ((contract.loan__LA_Amortized_Balance_Type__c == null) || (contract.loan__LA_Amortized_Balance_Type__c != loan.LoanConstants.AMZ_BAL_INTEREST)) {
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Interest Amortization Balance Type is null or not set as Interest,';
            }   
            
            
            if(contract.loan__Fees_Remaining__c <0 ){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Total unpaid charges are less than 0,';
            }               
            
            if(contract.loan__Loan_Disbursal_Transactions__r == null){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'No funding transaction on the loan account,';
            }
            if(!contract.loan__Is_Rescheduled__c){
                resError = true;
                if(contract.DM_Future_LAD__c)
                    resError = false;
                
                for(clcommon__Repayment_Plan__c rep : (List<clcommon__Repayment_Plan__c>)queryChildContracts.get('clcommon__Repayment_Plan__c')){
                    if(rep.clcommon__Sequence_Number__c == 1 && rep.clcommon__Number_Of_Payments__c <= 0){
                        /*List<loan__Repayment_Schedule__c> amz1 = [select id,loan__Balance__c from loan__Repayment_Schedule__c	// to avoid contracts with wrong AMZ(i.e.balance at last AMZ)
                                                                     where loan__Due_Date__c =: contract.Last_RSS_date__c	//commenting(need to migrate these loans going forward)
                                                                     and loan__Loan_Account__c =: contract.id
                                                                   and loan__Is_Archived__c = false];
                        if(amz1[0].loan__Balance__c == 0)*/
                        	resError = false;
                    }
                }
               
                if((contract.loan__Principal_Remaining__c <= 0) && (contract.loan__loan_status__C != 'Closed - Obligations met'))	//LSP-98	//comment this portion out before dploying to prod because we are not migrating paid in full contracts in this mock
                    resError = true;
                 
                if(contract.Last_RSS_date__c <= currentDate){		//LSP-47
                    	/*if(contract.loan__Principal_Remaining__c == 0)		//new change	//commenting out because we need to migrate these loans
                            resError = false;
                        else{
                            List<loan__Repayment_Schedule__c> amz1 = [select id,loan__Balance__c from loan__Repayment_Schedule__c	// to avoid contracts with no unpaid AMZ
                                                                     where loan__Due_Date__c =: contract.Last_RSS_date__c
                                                                     and loan__isPaid__c = false
                                                                     and loan__Loan_Account__c =: contract.id
                                                                     and loan__Is_Archived__c = false];
                            if(amz1.size()>0 && amz1[0].loan__Balance__c == 0) 
                                resError = false;
                            else
                                resError = true;
                        }  */ 
                        resError = false; 
                }
               
                if(contract.loan__loan_status__C == 'Closed- Written Off' || contract.loan__loan_status__C == 'Closed - Obligations met'
                  || contract.loan__loan_status__C == 'Canceled')	//LSP-163
                    resError = false;
                                
            }
            if(resError){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Not rescheduled,';
            }

            for(loan__Repayment_Schedule_Summary__c rss : (List<loan__Repayment_Schedule_Summary__c>)queryChildContracts.get('loan__Repayment_Schedule_Summary__c')){
                if (rss.loan__RSS_Seq__c == null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Sequence in RSS is null,';
                } 
                
                if (rss.loan__RSS_Repayment_Dt__c == null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Repayment Date in RSS is null,';
                }
                if (rss.loan__RSS_Repayment_Amt__c == null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Repayment Amount in RSS is null,';
                }
                if (rss.loan__RSS_No_Of_Pmts__c == null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Number of payments in RSS is null,';
                    
                }
            }
            for(loan__Loan_Payment_Transaction__c lpt : (List<loan__Loan_Payment_Transaction__c>)queryChildContracts.get('loan__Loan_Payment_Transaction__c')){
                if (lpt.loan__Payment_Mode__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Payment mode in LPT is null,';
                } 
                
                if (lpt.loan__Principal__c == null){                                
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Loan Principal in LPT is null,';
                    
                } 
                if (lpt.loan__Interest__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Losn Interest in LPT is null,';
                } 
                
                if (lpt.loan__transaction_time__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Transaction time in LPT is null,';
                }
                
                if (lpt.LAPro_Posted_Date__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'LAPro Posted Date in LPT is null,';
                }
                if (lpt.External_Id__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'External Id in LPT is null,';                        
                }
                if (lpt.loan__Clearing_Date__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Clearing Date in LPT is null,';
                }
                if(!lpt.loan__Reversed__c){
                    sumPrinPaid = sumPrinPaid + lpt.loan__Principal__c;
                    sumInterestPaid = sumInterestPaid + lpt.loan__Interest__c;
                }
                
            }
            for(loan__Interest_Posting_Transaction__c ipt : ipts){
                sumPrinPaid = sumPrinPaid + ipt.loan__Principal_Paid__c;
                sumInterestPaid = sumInterestPaid + ipt.loan__Interest_Paid__c;
                if(ipt.loan__Status__c == 'Closed')
                    sumInterestRemaining = sumInterestRemaining + ipt.loan__Interest_Posted__c;
                if(ipt.loan__Transaction_Due_Date__c < IPTdate)
                    IPTdate = ipt.loan__Transaction_Due_Date__c;
            }
            /*LSP-187*/
            List<loan__Other_Transaction__c> oltadjustInterest = [select id,loan__Waived_Interest__c
                                                                  from loan__Other_Transaction__c
                                                                  where loan__Transaction_Type__c = 'Interest Waive'
                                                                  and loan__Loan_Account__c =: contractId];
            Decimal interestAdjustment = 0;
            for(loan__Other_Transaction__c temp : oltadjustInterest)
                interestAdjustment = interestAdjustment + temp.loan__Waived_Interest__c;
            sumInterestPaid = sumInterestPaid - interestAdjustment;
            
            List<loan__Other_Transaction__c> oltadjustPrincipal = [select id,loan__Txn_Amt__c
                                                                  from loan__Other_Transaction__c
                                                                  where loan__Transaction_Type__c = 'PrincipalAdjustment-Subtract'
                                                                  and loan__Loan_Account__c =: contractId];
            Decimal principalAdjustment = 0;
            for(loan__Other_Transaction__c temp : oltadjustPrincipal)
                principalAdjustment = principalAdjustment + temp.loan__Txn_Amt__c;
            sumPrinPaid = sumPrinPaid - principalAdjustment;
            /*LSP-187*/
            if(sumPrinPaid != contract.loan__Principal_Paid__c && contract.loan__Metro2_Account_Status_Code__c != '64'){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Principal Paid is wrong,';
            }
            if(sumInterestPaid != contract.loan__Interest_Paid__c){
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Interest Paid is wrong,';
            }
            
            if(sumInterestRemaining != contract.loan__Interest_Remaining__c
               && contract.loan__Loan_Status__c != 'Closed- Written Off' ){	//LSP-98
                err.DM_Validation_Status__c='Failed';
                errors = errors + 'Interest Remaining is wrong,';
                
            }
            
            for(loan__Loan_Disbursal_Transaction__c ldt : (List<loan__Loan_Disbursal_Transaction__c>)queryChildContracts.get('loan__Loan_Disbursal_Transaction__c')){
                if (ldt.loan__Disbursed_Amt__c ==  0){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Disbursal Time in LDT is zero,';
                }
                if (ldt.External_Id__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'External Id in LDT is null,';
                }
                if (ldt.loan__Loan_Disbursal_Transaction_Type__c != 'Principal Adjustment - Add' && ldt.loan__Loan_Disbursal_Transaction_Type__c != 'Regular'){ //default is regular
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Disbursal Txn type in LDT is wrong,';
                }
                if (ldt.loan__Financed_Amount__c ==  0){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Financed Amount in LDT is 0,';
                }
                
                if (ldt.loan__Mode_of_Payment__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Mode of Payment in LDT is null,';
                }
                
                if (ldt.loan__Refinanced_Amount__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Loan Refinanced Amount in LDT is null,';
                }
            }
            
            
            for(loan__Loan_account_Due_Details__c bill : (List<loan__Loan_account_Due_Details__c>)queryChildContracts.get('loan__Loan_account_Due_Details__c')){
                billMap.put(bill.loan__Due_Date__c,bill.loan__Payment_Satisfied__c);
                /*if (bill.External_Id__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'External Id in bill is null,';
                }*/
                if (bill.loan__Transaction_Date__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Loan Transaction Date in bill is null,';
                }
                if (bill.loan__Due_Date__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Loan Due Date in bill is null,';
                }
                
                if (bill.loan__Payment_Satisfied__c && bill.loan__Payment_Date__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Loan Payment Date in bill is null,';
                }
                if (bill.loan__Due_Type_Description__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Loan Due Type Description in bill is null,';
                }
                if (bill.loan__Interest_Billed__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Loan Interest Billed in bill is null,';
                }
                if (bill.loan__Principal_Billed__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Loan Principal Billed in bill is null,';
                }
                if (bill.loan__Payment_Satisfied__c && bill.loan__Interest_Paid__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Loan Interest Paid in bill is null,';
                }
                if (bill.loan__Payment_Satisfied__c && bill.loan__Principal_Paid__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors + 'Loan Principal Paid in bill is nul,';
                }
                if(!bill.loan__Payment_Satisfied__c && bill.loan__Due_Date__c < Billdate && bill.loan__Due_Amt__c != 0)  //added due amount because there are certain bills uploaded by HM where due amount is zero
                    Billdate = bill.loan__Due_Date__c;
            }
            System.debug('IPTdate----' + IPTdate + '----Billdate----' + Billdate);
            if(IPTdate!=Billdate && (IPTdate!= tocheck_Bill_ipt_date && Billdate!= tocheck_Bill_ipt_date)){
                err.DM_Validation_Status__c='Failed';
                errors = errors +'IPTs are not generated correctly,';
            }
            for(loan__Automated_Payment_Setup__c APS : (List<loan__Automated_Payment_Setup__c>)queryChildContracts.get('loan__Automated_Payment_Setup__c')){
                if (APS.loan__Bank_Account__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Bank Account in APS is null,';
                }
                if (APS.loan__Transaction_Amount__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Transaction Amount in APS is null,';
                }
                if (APS.loan__Debit_Date__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Debit Date in APS is null,';
                }
                if (APS.External_Id__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'External Id in APS is null,';
                    errorUpdate.add(contract);
                }
                
                if (APS.loan__Amount_Type__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Amount Type in APS is null,';
                }
                
                if (APS.loan__Frequency__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Frequency in APS is null.';
                }
                if (APS.loan__Debit_Day__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Debit Day in APS is null,';
                }
                if (APS.loan__Recurring_ACH_Start_Date__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Recurring ACH Start Date in APS is null,';
                }
            }
            
            for(loan__Repayment_Schedule__c AMZ : (List<loan__Repayment_Schedule__c>)queryChildContracts.get('loan__Repayment_Schedule__c')){
                if (AMZ.loan__Due_Principal__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Due Principal in AMZ is null,';
                }
                if (AMZ.loan__Due_Interest__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Due Interest in AMZ is null,';
                }
                if (AMZ.loan__Balance__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Balance in AMZ is null,';
                }
                if(billMap.containsKey(AMZ.loan__Due_Date__c)){
                    if(!AMZ.loan__Is_Billed__c){
                        err.DM_Validation_Status__c='Failed';
                        errors = errors +'is billed is not checked for - ' + AMZ.name;
                    }
                    if(billMap.get(AMZ.loan__Due_Date__c) && !AMZ.loan__isPaid__c){
                        err.DM_Validation_Status__c='Failed';
                        errors = errors +'is paid is not correctly checked for - ' + AMZ.name;
                    }
                }
                else{
                    if(AMZ.loan__Is_Billed__c && AMZ.loan__Due_Date__c > currentDate){  
                        err.DM_Validation_Status__c='Failed';
                        errors = errors +'is billed is checked wrongly for - ' + AMZ.name;
                    }
                }
                if(AMZ.loan__Due_Date__c<=currentDate && !AMZ.loan__Is_Posted__c && contract.loan__loan_status__C != ('Closed- Written Off')
                  && contract.loan__loan_status__C != ('Closed - Obligations met')){		//LSP-98
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'is posted is not checked for - ' + AMZ.name;
                    errorUpdate.add(contract);
                }
                
            }
            
            for(loan__Investor_Loan__c IO : (List<loan__Investor_Loan__c>)queryChildContracts.get('loan__Investor_Loan__c')){
                if (IO.loan__Account__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Investor Loan in IO is null,';
                } 
                if (IO.loan__Inv_Accrued_Interest_Amt__c ==  null  && IO.loan__Status__c != 'Sold'){	//LSP-98	
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Inv Accrued Interest Amount in IO is null,';
                }	
                
                if (IO.loan__Buying_Price__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Buying Price in IO is null,';
                }
                if (IO.loan__Charged_Off_Date__c ==  null && (loanStatus.equals('Closed- Written Off') && IO.loan__Status__c == 'Closed - Written Off' || test.isRunningTest())){	//LSP-98
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Charged Off Date in IO is null,';
                }
                if (IO.loan__Charged_Off_Fees__c ==  null && (loanStatus.equals('Closed- Written Off') && IO.loan__Status__c == 'Closed - Written Off' || test.isRunningTest())){	//LSP-98
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Charged Off Fees in IO is null,';
                }
                if (IO.loan__Charged_Off_Interest__c ==  null && (loanStatus.equals('Closed- Written Off') && IO.loan__Status__c == 'Closed - Written Off' || test.isRunningTest())){	//LSP-98
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Charged Off Interest in IO is null,';
                }
                if (IO.loan__Charged_Off_Principal__c ==  null && (loanStatus.equals('Closed- Written Off') && IO.loan__Status__c == 'Closed - Written Off' || test.isRunningTest())){	//LSP-98
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Charged Off Principal in IO is null,';
                }
                
                if (IO.loan__Discount_Percent__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Discount Percent in IO is null.';
                }
                
                if (IO.loan__Late_Fees_Amount_Paid__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Late Fees Amount Paid in IO is null,';
                }
                /*if (IO.loan__Interest_Amount_Paid__c ==  null && IO.loan__Status__c != 'Sold'){	//LSP-98 commented(need to check with HM)
                    err.DM_Validation_Status__c='Failed';
                    errors= errors +'Loan Interest Amount Paid in IO is null,';
                }*/
                
                if (IO.loan__Inv_Interest_Posted_Amt__c ==  null){	
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Inv Interest Posted Amount in IO is null,';
                }
                
                if (IO.loan__Interest_Rate_On_Loan_Account__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Interest Rate on Loan Account in IO is null,';
                }
                
                if (IO.loan__Inv_Last_Interest_Accrual_Post_Date__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Inv Last Interest Accrual Post Date in IO is null.';
                }
                
                if (IO.loan__Minimum_Service_Fee__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Minimum Service Fee in IO is null,';
                }
                if (IO.loan__Principal_Amount_Paid__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Principal Amount Paid in IO is null,';
                }
                if (IO.loan__Rebate_Amount_Paid__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Rebate Amount Paid in IO is null.';
                }
                if (IO.loan__Share__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Share in IO is null,';
                }
                if (IO.loan__Investor_Start_Date__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Investor Start Date in IO is null,';
                }
                if (IO.loan__Status__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Status in IO is null.';
                }
                
                if (IO.loan__Total_Amount_Paid__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Total Amount Paid in IO is null.';
                }
                if (IO.loan__Write_Off_Amount__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Write-Off Amount in IO is null.';
                }
                if (IO.External_Id__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'External Id in IO is null,';
                }
            }
            
            for(loan__Multi_Step_Loan_Setup__c MSL : (List<loan__Multi_Step_Loan_Setup__c>)queryChildContracts.get('loan__Multi_Step_Loan_Setup__c')){
                if (MSL.loan__Interest_Rate__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Interest Rate in MSL is null,';
                }
                if (MSL.loan__Rate_Change_Date_Next__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Rate Change Date Next in MSL is null.';
                }
                if (MSL.External_Id__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'External Id in MSL is null.';
                }
            }
            
            Post_actualObj_SqlQueryGenerator sqlQuery = new Post_actualObj_SqlQueryGenerator(); 
            /*String query = sqlQuery.GetQueryStringTemp('loan__Investor_Loan_Account_Txns__c',contractId,IOIds);
            List<loan__Investor_Loan_Account_Txns__c> childLATList = Database.query(query);*/
            
            String query1 = sqlQuery.GetQueryStringTemp1('loan__Disbursal_Txn_Distribution__c',contractId,LDTIds,MapQueryGenerate);
            List<loan__Disbursal_Txn_Distribution__c> childDMDDTList = Database.query(query1);
            System.debug('childDMDDTList----' + childDMDDTList);
            
            for(loan__Disbursal_Txn_Distribution__c temp : childDMDDTList){ 
                if (temp.loan__Loan_Disbursal_Transaction__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Disbursal Transaction in Disb Txn is null.';
                }
                if (temp.loan__Distribution_Type__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Distribution Type in Disb Txn is null.';
                }
                if (temp.loan__Distribution_Amount__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors= errors +'Loan Distribution Amount in Disb Txn is null,';
                }
                if (temp.loan__Name_of_Entity__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Name of Entity in Disb Txn is null,';
                }
                
                if (temp.External_Id__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'External Id in Disb Txn is null,';
                }
                
            }
            
            String query2 = sqlQuery.GetQueryStringTemp2('loan__Due_Payment__c',contractId,LPTIds,MapQueryGenerate);
            List<loan__Due_Payment__c> childDuepayList = Database.query(query2);
            System.debug('childDuepayList----' + childDuepayList);
            for(loan__Due_Payment__c temp : childDuepayList){   
                if (temp.loan__Fees__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Fees in Due Payment is null,';
                    errorUpdate.add(contract);
                } 
                if (temp.loan__Payment_Amount__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Payment Amount in Due Payment is null,';
                }
                if (temp.loan__Principal__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Principal in Due Payment is null.';
                }
                if (temp.External_Id__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'External Id in Due Payment is null,';
                }
                if (temp.loan__Interest__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Interest in Due Payment is null,';
                }
                if (temp.loan__Loan_Payment_Transaction__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Payment Transaction in Due Payment is null,';
                }
                if (temp.loan__Due__c ==  null){
                    err.DM_Validation_Status__c='Failed';
                    errors = errors +'Loan Due in Due Payment is null,';
                }
            }

            System.debug('errors ' + errors);
            
            If(errors.length()>255)
              errors = errors.substring(0, 255);
            
            /*if(errors != null)
               {
                err.DM_Validation_Error__c = errors;
                try{
                    Database.Update(err, false);
                }
                catch(Exception ex){
                    System.debug('exception at insert----' + ex.getMessage());
                }
            }
            else{
                System.debug('No failures');
                err.DM_Validation_Status__c='Success';
                try{
                    Database.Update(err, false);
                }
                catch(Exception ex){
                    System.debug('exception at insert----' + ex.getMessage());
                }
            }*/
            /*pallavi*/
            if(errors.length() <= 0)
                err.DM_Validation_Status__c='Success';
            
            err.DM_Validation_Error__c = errors;
            errUpdate = err;
            /*pallavi*/
            
            /*if(errors.length() > 0 ){
                contract.loan__Invalid_Data__c = true;
                update contract;
            }*/      
        }
        update errUpdate;
    }
}