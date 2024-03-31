/*
* 
* 
* @author = Pallavi
*/
public class DM_Validation_stagingObjects_Handler {
    
    public static Id contractId;
    Date currentDate = system.today();
    boolean failure = false;
    List<DM_Error_On_Staging__c> error = new List<DM_Error_On_Staging__c>();
    String loanStatus = '';
    Date currentSystemDate = (new loan.GlobalLoanUtilFacade().getCurrentSystemDate());  //pallavi
    dm_Loan_Account__c contractToUpdate = new dm_Loan_Account__c();
   
    
    public void ValidationWrapper(List<dm_Loan_Account__c> contractList,Map<String,DM_StagingObject_Query_Generator__c> MapQueryGenerate,Map<String,List<sObject>> queryChildContracts){
        System.debug('validate here');
        String objField = '';
        for(dm_Loan_Account__c contract : contractList){
            Set<Id> dmIOIds = new Set<Id>();
            Set<Id> dmLDTIds = new Set<Id>();  //pallavi
            Set<Id> dmLPTIds = new Set<Id>();    //pallavi
            String errors = '';
            Map<Date,Boolean> billMap = new Map<Date,Boolean>();
            
            contractId=contract.Id; 
            //System.debug(contractId);
            
            List<DM_Investment_Order__c> dmIOList = new List<DM_Investment_Order__c>();
            dmIOList = (List<DM_Investment_Order__c>)queryChildContracts.get('DM_Investment_Order__c');
            System.debug('dmIOList ' + dmIOList);
            for(DM_Investment_Order__c temp : dmIOList){//contract.DM_Investment_Orders__r){
                dmIOIds.add(temp.id);
            }
            
            List<dm_Loan_Disbursal_Transaction__c> ldtList = (List<dm_Loan_Disbursal_Transaction__c>)queryChildContracts.get('dm_Loan_Disbursal_Transaction__c');
            for(dm_Loan_Disbursal_Transaction__c temp : ldtList){//contract.dm_Loan_Disbursal_Transactions__r){
                dmLDTIds.add(temp.id);
            }
            
            List<dm_Loan_Payment_Transaction__c> lptList = (List<dm_Loan_Payment_Transaction__c>)queryChildContracts.get('dm_Loan_Payment_Transaction__c');
            
            for(dm_Loan_Payment_Transaction__c temp : lptList){//contract.dm_Loan_Payment_Transactions__r){
                dmLPTIds.add(temp.id);
            }
            loanStatus = contract.DM_Loan_Status__c;
            
            if(contract.DM_Product__c  == null){
                contract.DM_Data_Error__c = 'Product is null on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'no product on Contract,';
                //if(!test.isRunningTest())
                //continue;
            }
            if(contract.dm_Product_Type__c  == null){
                contract.DM_Data_Error__c = 'Product Type is null on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'product type null on Contract,';
                //if(!test.isRunningTest())
                //continue;
            } 
            
            if(contract.dm_Loan_Amount__c == 0 || contract.dm_Loan_Amount__c == null){
                contract.DM_Data_Error__c = 'Loan Amount is zero or null on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'Zero loan amount on Contract,';
                //if(!test.isRunningTest())
                //continue;
            }                                          
            if(contract.dm_Account__c == null){
                contract.DM_Data_Error__c = 'Account is null on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'Account is null on Contract,';
                //if(!test.isRunningTest())
                //continue;
            }
            
            if(contract.dm_Next_Installment_Date__c == null){
                contract.DM_Data_Error__c='Next Due Date/Next Due Generation Date is null on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'Next Due Date null on Contract,';
                
                //if(!test.isRunningTest())
                //continue;
            }
            
            if(contract.dm_Funding_in_Tranches__c == false){
                Decimal paid = contract.dm_Principal_Remaining__c.setscale(2) + contract.dm_Principal_Paid__c.setscale(2);
                Decimal la = contract.dm_Loan_Amount__c.setscale(2)  + contract.dm_Principal_Adjustment__c.setscale(2) - contract.dm_Principal_Adjustment_Subtract__c.setscale(2);
                if (paid != la) {
                    contract.DM_Data_Error__c='There exists a mismatch between the Unpaid + Paid Principal: ' + paid + ' and Loan Amount: ' + la;
                    //errorUpdate.add(contract);
                    errors = errors + 'mismatch in loan amount-' + paid + '/' + la + ',';
                    //if(!test.isRunningTest())
                    //continue;
                }
            }else{
                Decimal paid = contract.dm_Principal_Remaining__c.setscale(2) + contract.dm_Principal_Paid__c.setscale(2);
                Decimal da = contract.dm_Disbursed_Amount__c.setscale(2)  + contract.dm_Principal_Adjustment__c.setscale(2) - contract.dm_Principal_Adjustment_Subtract__c.setscale(2);
                if (paid != da){
                    contract.DM_Data_Error__c= 'There exists a mismatch between the Unpaid + Paid Principal: ' + paid + ' and Disbursed Amount: ' + da;
                    //errorUpdate.add(contract);
                    //if(!test.isRunningTest())
                    //continue;
                }
            }
            
            
            if (contract.dm_Expected_Disbursal_Date__c == null){
                contract.DM_Data_Error__c='Expected Disbursal Date is null on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'Expected Dis Date null on Contract,';
                //if(!test.isRunningTest())
                //continue;
            }
            
            if (contract.dm_Expected_Repayment_Start_Date__c == null){
                contract.DM_Data_Error__c='Expected RePayment Start Date is null on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'Expected Repayment Start Date null on Contract,';
                //if(!test.isRunningTest())
                //continue;
            }
            
            if (contract.dm_Disbursal_Date__c == null){
                contract.DM_Data_Error__c='Disbursal Date is null on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'Disbursal Date null on Contract,';
                //if(!test.isRunningTest())
                //continue;
            }
            
            if (contract.dm_First_Installment_Date__c == null){
                contract.DM_Data_Error__c='First Installment Date is null on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'First Installment Date null on Contract,';
                //if(!test.isRunningTest())
                //continue;
            }    
            
            if (contract.dm_Rate_Change_Dt_Next__c == null){
                contract.DM_Data_Error__c='Next Rate Change date is null on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'Next Rate Change Date null on Contract,';
                //if(!test.isRunningTest())
                //continue;
            }   
            
            if (contract.dm_Term_Cur__c == null || contract.dm_Term_Cur__c == 0){
                contract.DM_Data_Error__c='Term is null or zero on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'Term is null on Contract,';
                //if(!test.isRunningTest())
                //continue;           
            }
            
            if (contract.dm_Number_of_Installments__c == null || contract.dm_Number_of_Installments__c == 0){
                contract.DM_Data_Error__c='Number of installments is null or zero on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'No. of installments null on Contract,';
                //if(!test.isRunningTest())
                //continue;           
            }
            
            if (contract.dm_Maturity_Date_Current__c == null){
                contract.DM_Data_Error__c='Current Maturity Date is null on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'Current Maturity Date null on Contract,';
                //if(!test.isRunningTest())
                //continue;
            }
            
            if (contract.dm_Last_Installment_Date__c == null){
                contract.DM_Data_Error__c='Last Installment Date is null on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'Last Installment Date null on Contract,';
                //if(!test.isRunningTest())
                //continue;
            }
            
            if (contract.dm_Due_Day__c == null || contract.dm_Due_Day__c == 0){
                contract.DM_Data_Error__c='Due Day is null or zero on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'Due Day null on Contract,';
                //if(!test.isRunningTest())
                //continue;                
            }   
            
            
            if (contract.dm_Next_Due_Generation_Date__c == null){
                contract.DM_Data_Error__c='Next Due Generation Date is null on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'Next Due Generation Date null on Contract,';
                //if(!test.isRunningTest())
                //continue;
            }
            
            if (contract.dm_Next_Installment_Date__c == null){
                contract.DM_Data_Error__c='Next Installment Date is null on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'Next Installment Date null on Contract,';
                //if(!test.isRunningTest())
                //continue;
            }
            
            /*if (contract.dm_Next_Due_Generation_Date__c < currentDate) {	//pallavi(commenting it for CRM-365)
contract.DM_Data_Error__c='Next Due Generation date is in past on the loan account.';
//errorUpdate.add(contract);
errors = errors + 'Next Due Generation Date is in past on Contract,';
//if(!test.isRunningTest())
//continue;
} */
            
            /*if (contract.dm_Rate_Change_Dt_Next__c < currentDate ) {    //pallavi(commented because rate change next date ill always be 3000-12-31)     
if (contract.dm_Loan_Status__c == 'Active - Bad Standing' ){
contract.DM_Data_Error__c='Next Rate Change date is in Past on the loan account.';
//errorUpdate.add(contract);
errors = errors + 'Next Rate Change date is in Past on Contract,';
//if(!test.isRunningTest())
//continue;
}else{
contract.DM_Data_Error__c='Next Rate Change date is in Past on the loan account.';
//errorUpdate.add(contract);
errors = errors + 'Next Rate Change date is in Past on Contract,';
//if(!test.isRunningTest())
//continue;
}      
}*/
            if (contract.dm_Next_Due_Generation_Date__c!=null && (contract.dm_Next_Due_Generation_Date__c) <= (contract.dm_Maturity_Date_Current__c) ){
                if (contract.dm_Next_Due_Generation_Date__c.addDays((contract.dm_Pre_Bill_Days__c == null)?0:(Integer)contract.dm_Pre_Bill_Days__c) != contract.dm_Next_Installment_Date__c ){
                    
                    contract.DM_Data_Error__c='There exists a mismatch between the Next Due Date and the Next Due Generation Date and Pre Bill Days.' +
                        ' The Next Due Date must be equal to the Next Due Generate Date plus Pre Bill Days.';
                    //errorUpdate.add(contract);
                    errors = errors + 'Mismatch in Next Due Date and the Next Due Generation Date and Pre Bill Days,';
                    //if(!test.isRunningTest())
                    //continue;
                }
            }
            if (contract.dm_Last_Accrual_Date__c == null ){
                contract.DM_Data_Error__c='Last accrual date is null on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'Last accrual date null on contract,';
                //if(!test.isRunningTest())
                //continue;
            }
            
            /*if (contract.dm_LA_Amortization_Enabled__c){	//default values
                
                if (contract.dm_la_amortization_frequency__c == null) {
                    contract.DM_Data_Error__c='Interest Amortization frequency is null on loan account';
                    //errorUpdate.add(contract);
                    errors = errors + 'Interest Amort frequency null on contract,';    
                    //if(!test.isRunningTest())
                    //continue;
                }
                
                if (contract.dm_LA_Amortized_Balance_Type__c == null) {
                    contract.DM_Data_Error__c='Interest Amortized Balance Type is null on loan account';
                    //errorUpdate.add(contract);
                    errors = errors + 'Interest Amortized Balance Type null on contract,';
                    //if(!test.isRunningTest())
                    //continue;
                }   
            }*/
            
            /*if(contract.dm_Fees_Remaining__c <0 ){
                contract.DM_Data_Error__c='Total unpaid charges are less than 0 on loan account';
                //errorUpdate.add(contract);
                errors = errors + 'Total unpaid charges less than 0 on contract,';
                //if(!test.isRunningTest())
                //continue;
            }*/  
            //temporary(to reject paid in full contracts and charged off contracts)
            /*if(contract.DM_Loan_Status__c == 'Closed - Obligations met' || contract.DM_Loan_Status__c == 'Closed- Written Off' ){
                contract.DM_Data_Error__c='Paid in full/charged off contract';
                errors = errors + 'Paid in full/charged off contract,';               
            }*/ 
            //temporary(to reject paid in full contracts)
            if(contract.DM_Interest_Calculation_Method__c != 'Flexible Repayment'){		//LSP-100
                contract.DM_Data_Error__c='Wrong interest calculation method';
                errors = errors + 'Wrong interest calculation method,';               
            } 
            if(contract.DM_Contractual_Interest_Rate__c <= 0){
                contract.DM_Data_Error__c='Contractual interest rate is 0';
                errors = errors + 'Contractual interest rate is 0,';               
            } 
                                   
            /*LSP-98*/
            List<dm_Loan_Disbursal_Transaction__c> disbursalTxn = [select id from dm_Loan_Disbursal_Transaction__c where DM_CL_Contract__c =: contractId];
            
            if(disbursalTxn.size()== 0){	//LSP-98
                contract.DM_Data_Error__c='No funding transaction on the loan account';
                //errorUpdate.add(contract);
                errors = errors + 'No funding transaction on contract,';
            }
            
            if(contract.DM_Loan_Status__c.equalsIgnoreCase('Closed- Written Off')){
                if(contract.DM_Charged_Off_Date__c == null){
                    contract.DM_Data_Error__c='Charged off Date is null';
                    errors = errors + 'Charged off Date is null,';
                }
                /*if(contract.DM_Charged_Off_Interest__c == 0){	//asked to remove
                    contract.DM_Data_Error__c='Charged off Interest is null';
                    errors = errors + 'Charged off Interest is null,';
                }*/
                if(contract.DM_Charged_Off_Principal__c == 0){
                    contract.DM_Data_Error__c='Charged off Principal is null';
                    errors = errors + 'Charged off Principal is null,';
                }
                if(contract.DM_Last_Transaction_Type__c != 'Charge Off'){
                    contract.DM_Data_Error__c='Last txn type is wrong';
                    errors = errors + 'Last txn type is wrong,';
                }
                List<DM_Other_Loan_Transaction__c> otherTxn = [select id from DM_Other_Loan_Transaction__c where DM_CL_Contract__c =: contractId and DM_Transaction_Type__c = 'Charge Off'];
                if(otherTxn.size()== 0){
                    contract.DM_Data_Error__c='No OLT on charged off contract';
                    //errorUpdate.add(contract);
                    errors = errors + 'No OLT on charged off contract,';
                }
            } 
            /*LSP-98*/
            
            List<DM_Repayment_Schedule_Summary__c> rssList = (List<DM_Repayment_Schedule_Summary__c>)queryChildContracts.get('DM_Repayment_Schedule_Summary__c');
            for(DM_Repayment_Schedule_Summary__c rss : rssList){
                if (rss.dm_RSS_Repayment_Dt__c == null){
                    contract.DM_Data_Error__c='RSS Repayment Date is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'RSS Repayment Date is null,';
                } 
                
                if (rss.DM_CL_Contract__c == null){          
                    contract.DM_Data_Error__c='CL Contract in RSS is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'CL Contract in RSS is null,';
                }
                if (rss.dm_RSS_Seq__c == null){
                    contract.DM_Data_Error__c='Sequence in RSS is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Sequence in RSS is null,';
                } 
                
                if (rss.dm_RSS_Repayment_Amt__c == null){
                    contract.DM_Data_Error__c='Repayment Amount in RSS is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Repayment Amount in RSS is null,';
                }
                if (rss.dm_RSS_No_Of_Pmts__c == null){
                    contract.DM_Data_Error__c='Number of payments in RSS is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'No. of payments in RSS is null,';
                }
            }
            /*LSP-98*/
            
            List<DM_Other_Loan_Transaction__c> oltList = (List<DM_Other_Loan_Transaction__c>)queryChildContracts.get('DM_Other_Loan_Transaction__c');
            if(contract.DM_Loan_Status__c == 'Closed- Written Off'){
                for(DM_Other_Loan_Transaction__c olt : oltList){
                    if(olt.DM_Transaction_Type__c == null){		//'Charge Off' LSP-187
                        contract.DM_Data_Error__c='Txn type is null in OLT';
                        errors = errors + 'Txn type is null in OLT,';
                    }
                    if(olt.DM_Transaction_Type__c == 'Charge Off'){	//LSP-187
                        if (olt.DM_Charged_Off_Date__c == null){
                            contract.DM_Data_Error__c='Charged off Date is null in OLT';
                            errors = errors + 'Charged off Date is null in OLT,';
                        }                    
                        if(olt.DM_Transaction_Date__c == null){
                            contract.DM_Data_Error__c='Txn date is null in OLT';
                            errors = errors + 'Txn date is null in OLT,';
                        }                    
                        /*if(olt.DM_Charged_Off_Interest__c == 0){	//asked to remove
                            contract.DM_Data_Error__c='Charged off Interest is null in OLT';
                            errors = errors + 'Charged off Interest is null in OLT,';
                        }*/
                        if(olt.DM_Charged_Off_Principal__c == 0){
                            contract.DM_Data_Error__c='Charged off Principal is null in OLT';
                            errors = errors + 'Charged off Principal is null in OLT,';
                        }
                    }
                    if(olt.DM_External_Id__c == null){
                        contract.DM_Data_Error__c='External id is null in OLT';
                        errors = errors + 'External id is null in OLT,';
                    }
                }
            }
            /*LSP-98*/	
            
            for(dm_Loan_Payment_Transaction__c lpt : lptList){
                if (lpt.CL_Contract__c ==  null){
                    contract.DM_Data_Error__c='Contract in LPT is null';
                    //errorUpdate.add(contract);
                    if(!errors.containsIgnoreCase('Contract in LPT is null'))
                        errors = errors + 'Contract in LPT is null,';
                }
                if(lpt.DM_Transaction_Date__c > currentSystemDate){
                    contract.DM_Data_Error__c='Transaction Date in LPT greater than CSD';
                    //errorUpdate.add(contract);
                    if(!errors.containsIgnoreCase('Txn Date in LPT greater than CSD'))
                        errors = errors + 'Txn Date in LPT greater than CSD,';
                }
                if (lpt.dm_Payment_Mode__c ==  null){
                    contract.DM_Data_Error__c='Payment mode in LPT is null';
                    //errorUpdate.add(contract);
                    if(!errors.containsIgnoreCase('Payment mode in LPT is null'))
                        errors = errors + 'Payment mode in LPT is null,';
                } 
                if (lpt.dm_Transaction_Amount__c ==  null){          
                    contract.DM_Data_Error__c='Transaction Amount in LPT is null';
                    //errorUpdate.add(contract);
                    if(!errors.containsIgnoreCase('Transaction Amount in LPT is null'))
                        errors = errors + 'Transaction Amount in LPT is null,';
                }
                if (lpt.dm_Receipt_Date__c ==  null){                
                    contract.DM_Data_Error__c='Receipt Date in LPT is null';
                    //errorUpdate.add(contract);
                    if(!errors.containsIgnoreCase('Receipt Date in LPT is null'))
                        errors = errors + 'Receipt Date in LPT is null,';
                }
                
                if (lpt.dm_transaction_date__c ==  null){                  
                    contract.DM_Data_Error__c='Transaction date in LPT is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Transaction Date in LPT is null,';
                }
                if (lpt.dm_transaction_time__c ==  null){
                    contract.DM_Data_Error__c='Transaction time in LPT is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Transaction time in LPT is null,';
                }
                
                if (lpt.DM_LAPro_Posted_Date__c ==  null){
                    contract.DM_Data_Error__c='LAPro Posted Date in LPT is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'LAPro Posted Date in LPT is null,';
                }
                if (lpt.dm_External_Id__c ==  null){
                    contract.DM_Data_Error__c='External Id in LPT is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'External Id in LPT is null,';
                }
                if (lpt.dm_Clearing_Date__c ==  null){
                    contract.DM_Data_Error__c='Clearing Date in LPT is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Clearing Date in LPT is null,';
                }
                if(loanStatus == 'Active - Bad Standing' || loanStatus == 'Active - Good Standing'){	//added due to paid in full contracts //commented out temporarily
                    if(lpt.DM_Write_Off_Recovery_Payment__c && !lpt.DM_Reversed__c && !lpt.DM_Rejected__c){
                        contract.DM_Data_Error__c='Recovery pmt in active loan';
                        if(!errors.containsIgnoreCase('Recovery pmt in active loan'))
                        	errors = errors + 'Recovery pmt in active loan,';
                    }    
                }
                
            }
            
            //List<dm_Loan_Disbursal_Transaction__c> ldtList = new List<dm_Loan_Disbursal_Transaction__c>();
            
            /*for(dm_Loan_Disbursal_Transaction__c temp : contract.dm_Loan_Disbursal_Transactions__r)
ldtList.add(temp);*/
            
            for(dm_Loan_Disbursal_Transaction__c ldt : ldtList){
                
                if (ldt.DM_CL_Contract__c ==  null){            
                    contract.DM_Data_Error__c='Contract in LDT is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Contract in LDT is null,';
                }
                /*
if (ldt.dm_ACH_Filename__c ==  null){
DM_Error_On_Staging__c err = new DM_Error_On_Staging__c();
err.DM_object_name__c = 'dm_Loan_Disbursal_Transaction__c';
err.DM_obj_and_Field_Name__c = 'dm_Loan_Disbursal_Transaction__c + dm_ACH_Filename__c';
error.add(err);
contract.DM_Data_Error__c='ACH FileName in LTD is null';
//errorUpdate.add(contract);
} */
                if (ldt.dm_Bank_Account__c ==  null){
                    contract.DM_Data_Error__c='Bank Account in LDT is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Bank Account in LDT is null,';
                }
                if (ldt.dm_Disbursal_Date__c ==  null){
                    contract.DM_Data_Error__c='Disbursal Date in LTD is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Disbursal Date in LDT is null,';
                }
                if (ldt.dm_Disbursal_Time__c == null){
                    contract.DM_Data_Error__c='Disbursal Time in LTD is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Disbursal Time in LDT is null,';
                }
                if (ldt.dm_Disbursed_Amt__c ==  0){
                    contract.DM_Data_Error__c='Disbursed Amount in LTD is 0';
                    //errorUpdate.add(contract);
                    errors = errors + 'Disbursal Amount in LDT is 0,';
                }
                if (ldt.dm_External_Id__c ==  null){
                    contract.DM_Data_Error__c='External Id in LTD is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'External Id in LDT is null,';
                }
                if (ldt.dm_Loan_Disbursal_Transaction_Type__c == null){
                    contract.DM_Data_Error__c='Loan Disbursal Txn type in LDT is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Loan Disbursal Txn type in LDT is null,';
                }
                if (ldt.dm_Financed_Amount__c ==  0){
                    contract.DM_Data_Error__c='Financed Amount in LDT is 0';
                    //errorUpdate.add(contract);
                    errors = errors + 'Financed Amount in LDT is 0,';
                }/*
if (ldt.dm_Interest_Rate__c ==  null){
DM_Error_On_Staging__c err = new DM_Error_On_Staging__c();
err.DM_object_name__c = 'dm_Loan_Disbursal_Transaction__c';
err.DM_obj_and_Field_Name__c = 'dm_Loan_Disbursal_Transaction__c + dm_Interest_Rate__c';
error.add(err);
contract.DM_Data_Error__c='Interest rate in LDT is null';
//errorUpdate.add(contract);
}
if (ldt.dm_Loan_Snapshot__c ==  null){
DM_Error_On_Staging__c err = new DM_Error_On_Staging__c();
err.DM_object_name__c = 'dm_Loan_Disbursal_Transaction__c';
err.DM_obj_and_Field_Name__c = 'dm_Loan_Disbursal_Transaction__c + dm_Loan_Snapshot__c';
error.add(err);
contract.DM_Data_Error__c='Loan Snapshot in LDT is null';
//errorUpdate.add(contract);
} */
                if (ldt.dm_Mode_of_Payment__c ==  null){
                    contract.DM_Data_Error__c='Mode of Payment in LDT is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Mode of Payment in LDT is null,';
                }
                if (ldt.dm_Number_Of_Interest_Only_Payments__c ==  null){
                    contract.DM_Data_Error__c='Number Of Interest Only Payments in LDT is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Number Of Interest Only Payments in LDT is null,';
                }
                if (ldt.dm_Pre_Paid_Fee__c ==  null){
                    contract.DM_Data_Error__c='Pre Paid Fee in LDT is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Pre Paid Fee in LDT is null,';
                }
               
            }
            
            List<DM_Bill__c> billList = (List<DM_Bill__c>)queryChildContracts.get('DM_Bill__c');
            
            Date tocheckOldBills = Date.newInstance(1900, 01, 01);
            Date tofindMaxBillDate = Date.newInstance(1900, 01, 01);
            for(DM_Bill__c bill : billList){
                
                billMap.put(bill.DM_Due_Date__c,bill.DM_Payment_Satisfied__c);  //pallavi
                
                if (bill.DM_CL_Contract__c ==  null){              
                    contract.DM_Data_Error__c='Contract in bill is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Contract in bill is null,';
                }
                if (bill.dm_External_Id__c ==  null){
                    contract.DM_Data_Error__c='External Id in bill is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'External Id in bill is null,';
                }
                if (bill.dm_Transaction_Date__c ==  null){
                    contract.DM_Data_Error__c='Transaction Date in bill is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Txn Date in bill is null,';
                }
                if (bill.dm_Due_Date__c ==  null){
                    contract.DM_Data_Error__c='Due Date in bill is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Due Date in bill is null,';
                }
                
                if (bill.dm_Payment_Amt__c ==  null){
                    contract.DM_Data_Error__c='Payment Amount in bill is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Payment Amount in bill is null,';
                }
                if (bill.dm_Payment_Date__c ==  null && bill.DM_Payment_Satisfied__c){
                    contract.DM_Data_Error__c='Payment Date in bill is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Payment Date in bill is null,';
                }
                if (bill.dm_Due_Type_Description__c ==  null){
                    contract.DM_Data_Error__c='Due Type Description in bill is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Due Type Description in bill is null,';
                }
                if (bill.dm_Interest_Billed__c ==  null){
                    contract.DM_Data_Error__c='Interest Billed in bill is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Interest Billed in bill is null,';
                }
                if (bill.dm_Principal_Billed__c ==  null){
                    contract.DM_Data_Error__c='Principal Billed in bill is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Principal Billed in bill is null,';
                }
                if (bill.dm_Interest_Paid__c ==  null && bill.DM_Payment_Satisfied__c ){
                    contract.DM_Data_Error__c='Paid Interest in bill is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Paid Interest in bill is null,';
                }
                if (bill.dm_Principal_Paid__c ==  null && bill.DM_Payment_Satisfied__c ){
                    contract.DM_Data_Error__c='Paid Principal in bill is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Paid Principal in bill is null,';
                }
                if(bill.DM_Payment_Satisfied__c){
                    if(bill.dm_Due_Date__c > tocheckOldBills)// && bill.DM_Due_Amt__c > 0)
                        tocheckOldBills = bill.dm_Due_Date__c;
                }
                //to check max bill date
                if(bill.DM_Due_Date__c > tofindMaxBillDate)
                    tofindMaxBillDate = bill.DM_Due_Date__c;
                //to check max bill date
                
                //check 0$ bills
                if(bill.DM_Due_Amt__c == 0){
                    if(!errors.containsIgnoreCase('Zero dollar bill')){
                            errors = errors + 'Zero dollar bill,';
                    }
                    contract.DM_Data_Error__c='Zero dollar bill';
           		}
                //check 0$ bills
                
            }
            /*List<DM_Bill__c> checkOldBills = [Select id from DM_Bill__c	//commented for now(not needed for active loans becz they anyways get rejected in post val)
                                   			  where dm_Due_Date__c <: tocheckOldBills and DM_Payment_Satisfied__c = false
                                              and DM_DD_Primary_Flag__c = true and DM_CL_Contract__c =: contract.id];	//and DM_Due_Amt__c > 0
            if(checkOldBills.size()>0){
                    contract.DM_Data_Error__c='Old bills are unsatisfied';
                    errors = errors + 'Old bills are unsatisfied,';	//tocheckOldBills
           }*/	//not needed for now
           //to check if max bill date is after maturity or charged off date
           if(tofindMaxBillDate > contract.DM_Maturity_Date_Current__c){
                contract.DM_Data_Error__c='Bill post maturity date';
                errors = errors + 'Bill post maturity date,';               
            }
            /*if(contract.DM_Loan_Status__c == 'Closed- Written Off'){
                if(tofindMaxBillDate > contract.DM_Charged_Off_Date__c){	//temporary
                    contract.DM_Data_Error__c='Bill post charged-off date';
                    errors = errors + 'Bill post charged-off date,';               
                }
            }*/
           //to check if max bill date is after maturity or charged off date 
            
            List<dm_Automated_Payment_Setup__c> apsList = (List<dm_Automated_Payment_Setup__c>)queryChildContracts.get('dm_Automated_Payment_Setup__c');//new List<dm_Automated_Payment_Setup__c>();
            
            /*for(dm_Automated_Payment_Setup__c temp : contract.dm_Automated_Payment_Setups__r)
apsList.add(temp);*/
            
            for(dm_Automated_Payment_Setup__c APS : apsList){//System.debug('inside APS..........');
                if (APS.DM_CL_Contract__c ==  null){
                    contract.DM_Data_Error__c = 'CL Contract in APS is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'CL Contract in APS is null,';
                }
                if (APS.dm_Bank_Account__c ==  null){
                    contract.DM_Data_Error__c = 'Bank Account in APS is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Bank Account in APS is null,';
                }
                if (APS.dm_Transaction_Amount__c ==  null){
                    contract.DM_Data_Error__c = 'Transaction Amount in APS is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Txn Amount in APS is null,';
                }
                if (APS.dm_Debit_Date__c ==  null){
                    contract.DM_Data_Error__c = 'Debit Date in APS is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Debit Date in APS is null,';
                }
                if (APS.dm_External_Id__c ==  null){
                    contract.DM_Data_Error__c = 'External Id in APS is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'External Id in APS is null,';
                }
                if (APS.dm_Type__c ==  null){      
                    contract.DM_Data_Error__c = 'Type in APS is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Type in APS is null,';
                }
                if (APS.dm_Amount_Type__c ==  null){
                    contract.DM_Data_Error__c = 'Amount Type in APS is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Amount Type in APS is null,';
                }
                if (APS.dm_Payment_Mode__c ==  null){    
                    contract.DM_Data_Error__c = 'Payment Mode in APS is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Payment Mode in APS is null,';
                }
                if (APS.dm_Frequency__c ==  null){
                    contract.DM_Data_Error__c = 'Frequency in APS is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Frequency in APS is null,';
                }
                if (APS.dm_Debit_Day__c ==  null){
                    contract.DM_Data_Error__c = 'Debit Day in APS is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Debit Day in APS is null,';
                }
                if (APS.dm_Recurring_ACH_Start_Date__c ==  null){
                    contract.DM_Data_Error__c = 'Recurring ACH Start Date in APS is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Recurring ACH Start Date in APS is null,';
                }
            }
            
            
            List<dm_Repayment_Schedule__c> amzList = (List<dm_Repayment_Schedule__c>)queryChildContracts.get('dm_Repayment_Schedule__c');//new List<dm_Repayment_Schedule__c>();
            
            //new
            if(amzList.size()==0 && loanStatus != 'Closed - Obligations met' && loanStatus != 'Closed- Written Off'
              && loanStatus != 'Canceled'){
                    contract.DM_Data_Error__c = 'No AMZ on the contract';
                    errors = errors + 'No AMZ on the contract,';
            }
            //new
            
            for(dm_Repayment_Schedule__c AMZ : amzList){//System.debug('inside AMZ..........');
                if (AMZ.DM_Loan_Product__c ==  null){
                    contract.DM_Data_Error__c = 'Loan Product in AMZ is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Loan Product in AMZ is null,';
                }
                
                /*pallavi*/
                if(billMap.containsKey(AMZ.DM_Due_Date__c)){
                    if(!AMZ.DM_Is_Billed__c){
                        contract.DM_Data_Error__c = 'is billed is not checked for - ' + AMZ.id;
                        //errorUpdate.add(contract);
                        if(!errors.containsIgnoreCase('isBilled not marked correctly')){
                            errors = errors + 'isBilled not marked correctly,';
                        }
                    }
                    if(billMap.get(AMZ.DM_Due_Date__c) && !AMZ.DM_isPaid__c){
                        contract.DM_Data_Error__c = 'is paid is not correctly checked for - ' + AMZ.id;
                        //errorUpdate.add(contract);
                        if(!errors.containsIgnoreCase('isPaid not marked correctly'))
                            errors = errors + 'isPaid not marked correctly,';
                    }
                }
                                                                   
                /*pallavi*/                                                                   
                if (AMZ.dm_Due_Date__c ==  null){
                    contract.DM_Data_Error__c = 'Due Date in AMZ is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Due Date in AMZ is null,';
                }
                if (AMZ.dm_Due_Principal__c ==  null){
                    contract.DM_Data_Error__c = 'Due Principal in AMZ is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Due Principal in AMZ is null,';
                }
                if (AMZ.dm_Due_Interest__c ==  null ){
                    contract.DM_Data_Error__c = 'Due Interest in AMZ is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Due Interest in AMZ is null,';
                }
                if (AMZ.dm_Balance__c ==  null){
                    contract.DM_Data_Error__c = 'Balance in AMZ is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Balance in AMZ is null,';
                }
                
            }
            
            
            List<DM_Repayment_Plan__c> repPlanList = (List<DM_Repayment_Plan__c>)queryChildContracts.get('DM_Repayment_Plan__c');//new List<DM_Repayment_Plan__c>();
            
            
            for(DM_Repayment_Plan__c repPlan : repPlanList){System.debug('inside repPlan..........');
                                                            if (repPlan.DM_External_Id__c ==  null){
                                                                contract.DM_Data_Error__c = 'External Id in repPlan is null';
                                                                //errorUpdate.add(contract);
                                                                errors = errors + 'External Id in repPlan is null,';
                                                            }
                                                            if((repPlan.DM_Sequence_Number__c == 1) && (repPlan.DM_Effective_Date__c != currentSystemDate)){
                                                                contract.DM_Data_Error__c = 'Effective date in repPlan is not curent system date';
                                                                //errorUpdate.add(contract);
                                                                errors = errors + 'Effective date in repPlan is not curent system date,';
                                                            }
                                                           }
            
           
            for(DM_Investment_Order__c IO : dmIOList){System.debug('inside IO..........');
                                                      if (IO.dm_Account__c ==  null){
                                                          contract.DM_Data_Error__c = 'Account in IO is null';
                                                          //errorUpdate.add(contract);
                                                          errors = errors + 'Account in IO is nul,';
                                                      } 
                                                      if ((IO.DM_Accrued_Interest__c ==  null) && (!IO.DM_Status__c.equals('Sold'))){
                                                          contract.DM_Data_Error__c = 'Accrued Interest in IO is null';
                                                          //errorUpdate.add(contract);
                                                          errors = errors + 'Accrued Interest in IO is nul,';
                                                          
                                                      }
                                                     
                                                      /*if ((IO.dm_Interest_Amount_Paid__c ==  null) && (!IO.DM_Status__c.equals('Sold'))){
                                                          contract.DM_Data_Error__c = 'Interest Amount Paid in IO is null';
                                                          //errorUpdate.add(contract);
                                                          errors = errors + 'Interest Amount Paid Interest in IO is null,';
                                                      }*/	//commented out temporarily. check with HM
                                                      if (IO.DM_Interest_Rate_On_Loan__c ==  null){
                                                          contract.DM_Data_Error__c = 'Interest Rate On Loan in IO is null';
                                                          errors = errors + 'Interest Rate in IO is null,';
                                                          
                                                      }
                                                      if (IO.DM_Interest_Service_Rate__c ==  null){
                                                          contract.DM_Data_Error__c = 'Interest Service Rate in IO is null';
                                                          errors = errors + 'Interest Amount Paid Interest in IO is null,';
                                                      }
                                                      if (IO.dm_Investment_Amount__c ==  null){
                                                          contract.DM_Data_Error__c = 'Investment Amount in IO is null';
                                                          errors = errors + 'Investment Amount in IO is null,';
                                                      } 
                                                      if (IO.DM_Last_Interest_Accrual_Date__c ==  null){
                                                          contract.DM_Data_Error__c = 'Last Interest Accrual Date in IO is null';
                                                          errors = errors + 'Last Interest Accrual Date in IO is null,';
                                                      }
                                                      if (IO.DM_Loan__c ==  null){
                                                          contract.DM_Data_Error__c = 'Loan in IO is null';
                                                          errors = errors + 'Loan in IO is null,';
                                                      }
                                                      
                                                      if (IO.dm_Share__c ==  null){
                                                          contract.DM_Data_Error__c = 'Share in IO is null';
                                                          errors = errors + 'Share in IO is null,';
                                                      }
                                                      if (IO.DM_Start_Date__c ==  null){
                                                          contract.DM_Data_Error__c = 'Start Date in IO is null';
                                                          errors = errors + 'Start Date in IO is null,';
                                                      }
                                                      if (IO.dm_Status__c ==  null){
                                                          contract.DM_Data_Error__c = 'Status in IO is null';
                                                          errors = errors + 'Status in IO is null,';
                                                      }
                                                      if (IO.dm_Summary__c ==  null){
                                                          contract.DM_Data_Error__c = 'Summary in IO is null';
                                                          errors = errors + 'Summary in IO is null,';
                                                      }
                                                      
                                                      if (IO.dm_External_Id__c ==  null){
                                                          contract.DM_Data_Error__c = 'External Id in IO is null';
                                                          errors = errors + 'External Id in IO is null,';
                                                      }
                                                      /*LSP-30*/
                                                      if(IO.DM_Status__c.equals('Sold')){
                                                          if(IO.DM_End_Date__c == null){
                                                              contract.DM_Data_Error__c = 'End date in sold IO is null';
                                                              errors = errors + 'End date in sold IO is null,';
                                                          }
                                                          if(IO.DM_Buyer__c == null){
                                                              contract.DM_Data_Error__c = 'Buyer in sold IO is null';
                                                              errors = errors + 'Buyer in sold IO is null,';
                                                          }
                                                      }                                          
                                                      /*LSP-30*/                                          
                                                     }
            List<dm_Multi_Step_Loan_Setup__c> dmMSLList = (List<dm_Multi_Step_Loan_Setup__c>)queryChildContracts.get('dm_Multi_Step_Loan_Setup__c');//new List<dm_Multi_Step_Loan_Setup__c>();
            
            /*for(dm_Multi_Step_Loan_Setup__c temp : contract.DM_Rate_Schedule_Setups__r)
dmMSLList.add(temp);*/
            
            for(dm_Multi_Step_Loan_Setup__c MSL : dmMSLList){
                if (MSL.dm_Start_Date__c ==  null){
                    contract.DM_Data_Error__c = 'Start Date in MSL is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Start Date in MSL is null,';
                }
                if (MSL.dm_Loan_Account__c ==  null){
                    contract.DM_Data_Error__c = 'Loan Account in MSL is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Loan Acc in MSL is null,';
                }
                if (MSL.dm_Interest_Rate__c ==  null){
                    contract.DM_Data_Error__c = 'Interest Rate in MSL is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Interest Rate in MSL is null,';
                }
                if (MSL.dm_Sequence__c ==  null){
                    contract.DM_Data_Error__c = 'Sequence in MSL is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'Sequence in MSL is null,';
                }
                /*if (MSL.DM_Next_Rate_Change_Date__c ==  null){  //pallavi(commented)
DM_Error_On_Staging__c err = new DM_Error_On_Staging__c();
err.DM_object_name__c = 'dm_Multi_Step_Loan_Setup__c';
err.DM_obj_and_Field_Name__c = 'dm_Multi_Step_Loan_Setup__c + DM_Next_Rate_Change_Date__c';
error.add(err);
contract.DM_Data_Error__c = 'Next Rate Change Date in MSL is null';
//errorUpdate.add(contract);
}*/
                if (MSL.dm_External_Id__c ==  null){
                    contract.DM_Data_Error__c = 'External Id in MSL is null';
                    //errorUpdate.add(contract);
                    errors = errors + 'External Id in MSL is null,';
                }                
            }
            //if(failure && !test.isRunningTest())
            //continue;
            
            DM_SqlQueryGenerator_forValidation sqlQuery = new DM_SqlQueryGenerator_forValidation(); 
            String query = sqlQuery.GetQueryStringTemp('DM_Investor_Loan_Transaction__c',contractId,dmIOIds);
            List<DM_Investor_Loan_Transaction__c> childLATList = Database.query(query);
            
            /*for(dm_Investor_Loan_Account_Txns__c temp : childLATList){  //not adding validation because staging is empty
if (temp.dm_Start_Date__c ==  null){
contract.Post_Migration_Error__c = 'dm_Start_Date__c in IO is null';
contract.Post_Migration_Validation_Status__c = 'Failed';
//errorUpdate.add(contract);
failure = true;
//break;
}
}*/
            
            String query1 = sqlQuery.GetQueryStringTemp1('DM_Disbursal_Transaction_Distribution__c',contractId,dmLDTIds,MapQueryGenerate);
            List<DM_Disbursal_Transaction_Distribution__c> childDMDDTList = Database.query(query1);
            System.debug('childDMDDTList----' + childDMDDTList);
            
            for(DM_Disbursal_Transaction_Distribution__c temp : childDMDDTList){  
                if (temp.DM_Loan_Disbursal_Transaction__c ==  null){
                    contract.DM_Data_Error__c = 'Disbursal Transaction in DM_Disbursal_Transaction_Distribution__c is null';  //pallavi(changed temp to DM_Disbursal_Transaction_Distribution__c)
                    //errorUpdate.add(contract);
                    errors = errors + 'Disbursal Txn in DTD is null,';
                }
                if (temp.dm_Distribution_Type__c != 'Disbursement' && temp.dm_Distribution_Type__c !='Refinance' && temp.dm_Distribution_Type__c !='Pre-Paid Fee' ){  //pallavi(changed || to &&)
                    contract.DM_Data_Error__c = 'Distribution Type in DM_Disbursal_Transaction_Distribution__c is wrong';  //pallavi
                    //errorUpdate.add(contract);
                    errors = errors + 'Distribution Type in DTD is wrong,';
                }
                if (temp.dm_Distribution_Amount__c ==  null){
                    contract.DM_Data_Error__c = 'Distribution Amount in DM_Disbursal_Transaction_Distribution__c is null';  //pallavi
                    //errorUpdate.add(contract);
                    errors = errors + 'Distribution Amount in DTD is null,';
                }
                if (temp.dm_Name_of_Entity__c ==  null){
                    contract.DM_Data_Error__c = 'Name of Entity in DM_Disbursal_Transaction_Distribution__c is null';  //pallavi
                    //errorUpdate.add(contract);
                    errors = errors + 'Name of Entity in DTD is null,';
                }
                
                if (temp.dm_External_Id__c ==  null){
                    contract.DM_Data_Error__c = 'External Id in DM_Disbursal_Transaction_Distribution__c is null';  //pallavi
                    //errorUpdate.add(contract);
                    errors = errors + 'External Id in DTD is null,';
                }
            }
            
            String query2 = sqlQuery.GetQueryStringTemp2('DM_Due_Payment__c',contractId,dmLPTIds,MapQueryGenerate);
            List<dm_Due_Payment__c> childDuepayList = Database.query(query2);
            System.debug('childDuepayList----' + childDuepayList);
            
            for(dm_Due_Payment__c temp : childDuepayList){  
                if (temp.dm_Fees__c ==  null){
                    contract.DM_Data_Error__c = 'Fees in dm_Due_Payment__c is null';  //pallavi(changed temp to dm_Due_Payment__c)
                    //errorUpdate.add(contract);
                    errors = errors + 'Fees in Due Payment is null,';
                    
                } 
                if (temp.dm_Payment_Amount__c ==  null){
                    contract.DM_Data_Error__c = 'Payment Amount in dm_Due_Payment__c is null';  //pallavi
                    //errorUpdate.add(contract);
                    errors = errors + 'Payment Amount in Due Payment is null,';
                }
                if (temp.dm_Principal__c ==  null){
                    contract.DM_Data_Error__c = 'Principal in dm_Due_Payment__c is null';  //pallavi
                    //errorUpdate.add(contract);
                    errors = errors + 'Principal in Due Payment is null,';
                }
                if (temp.dm_External_Id__c ==  null){
                    contract.DM_Data_Error__c = 'External Id in dm_Due_Payment__c is null';  //pallavi
                    //errorUpdate.add(contract);
                    errors = errors + 'Ext Id in Due Payment is null,';
                }
                if (temp.dm_Interest__c ==  null){
                    contract.DM_Data_Error__c = 'Interest in dm_Due_Payment__c is null';  //pallavi
                    //errorUpdate.add(contract);
                    errors = errors + 'Interest in Due Payment is null,';
                }
                if (temp.dm_Loan_Payment_Transaction__c ==  null){
                    contract.DM_Data_Error__c = 'Loan Payment Transaction in dm_Due_Payment__c is null';  //pallavi
                    //errorUpdate.add(contract);
                    errors = errors + 'LPT in Due Payment is null,';
                    
                }
                if (temp.dm_Due__c ==  null){
                    if(!errors.containsIgnoreCase('Bill in dm_Due_Payment__c is null')){                    
                    errors = errors + 'Bill in dm_Due_Payment__c is null,';    
                    }    
                    contract.DM_Data_Error__c = 'Bill in dm_Due_Payment__c is null';  //pallavi
                }
            }
            
            if(errors.length()==0){    //remove
                contract.DM_Data_Error__c = '';
                //errorUpdate.add(contract);
            }
            
            //}
            error.addAll(MW_LAPro_ActualObjValidations.getActualObjValidationErrors(contractList));
            if(errors.length()>255)
                errors = errors.substring(0, 255);
            contract.DM_Consolidated_Errors__c = errors;
            if(errors.length()==0)
                contract.DM_Validation_Status__c = 'Success';
            else
                contract.DM_Validation_Status__c = 'Failed';
            contractToUpdate = contract;
        }
        if(!error.isEmpty() && !test.isRunningTest()){
            try{
                //Database.insert(error);
                Database.insert(error, false);
            }
            catch(Exception ex){
                System.debug('exception at insert----' + ex.getMessage());
            }
        }
        if(!test.isRunningTest()){
            try{
                Database.update(contractToUpdate, false);
            }
            catch(Exception ex){
                System.debug('exception at update----' + ex.getMessage());
            }
        }
    }
    
}