/**
 *  Abstract Class - For Strategy Zero - Validates the Data with Custom Validation Rules(To be included)
 *  
 * 
 * @author - Nikhil Chawra
 * **/

Global abstract class DM_ValidationAbstract implements DM_Validate_Interface
{
    public List<Dm_ValidationWrapper> validationWrapperList = new List<DM_ValidationWrapper>();
    public List<DM_ValidationWrapper> validateDM(List<DM_Loan_Account__c> dmList, DM_Metadata_Config_Wrapper configWrapper)
    {
        system.debug('Inside implementation validateDM method of Abstract Class');
        
        Map<String,DM_Metadata_Config_Wrapper.config> loanTypeAndSrcObj_ConfigMap = new Map<String,DM_Metadata_Config_Wrapper.Config>();
        DM_ValidationWrapper resp;
        
        Boolean successFlag;
        String objName;
        For(DM_Loan_Account__c dloan : dmList){
            resp = new DM_ValidationWrapper();
            successFlag=false;
            objName = String.valueOf(dloan).split(':')[0];
            system.debug('important '+DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap);
            system.debug('map1-----' + dloan.Product_Type__c+'|'+objName.toLowerCase());	//pallavi
            system.debug('map---' + DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dloan.Product_Type__c+'|'+objName.toLowerCase()));
            if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dloan.Product_Type__c+'|'+objName.toLowerCase())=='0'){
                system.debug('Stratagy Check done for Contract Loan == 0');  
                system.debug('Validation Begins -- ');
                //Validations Begins
             /* if(dloan.DM_Account__c == null){
                    resp.errorMessage = 'DM_Account__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Overdue_Principal__c == null){
                    resp.errorMessage = 'DM_Overdue_Principal__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                    
                    
                if(dloan.DM_Overdue_Interest__c == null){
                    resp.errorMessage = 'DM_Overdue_Interest__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Contract_Type__c  == null){
                    resp.errorMessage = 'DM_Contract_Type__c  is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Product__c  == null){
                    resp.errorMessage = 'DM_Product__c  is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Product_Type__c  == null){
                    resp.errorMessage = 'DM_Product_Type__c  is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Loan_Status__c  == null){
                    resp.errorMessage = 'DM_Loan_Status__c  is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Application_Date__c  == null){
                    resp.errorMessage = 'DM_Application_Date__c  is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Disbursal_Date__c  == null){
                    resp.errorMessage = 'DM_Disbursal_Date__c  is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Expected_Disbursal_Date__c  == null){
                    resp.errorMessage = 'DM_Expected_Disbursal_Date__c  is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Loan_Amount__c == null){
                    resp.errorMessage = 'DM_Loan_Amount__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Expected_Repayment_Start_Date__c  == null){
                    resp.errorMessage = 'DM_Expected_Repayment_Start_Date__c  is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Number_of_Installments__c  == null){
                    resp.errorMessage = 'DM_Number_of_Installments__c  is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Frequency_of_Loan_Payment__c  == null){
                    resp.errorMessage = 'DM_Frequency_of_Loan_Payment__c  is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Next_Installment_Date__c == null){
                    resp.errorMessage = 'DM_Next_Installment_Date__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Contractual_Interest_Rate__c  == null){
                    resp.errorMessage = 'DM_Contractual_Interest_Rate__c  is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Interest_Remaining__c  == null){
                    resp.errorMessage = 'DM_Interest_Remaining__c  is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Fees_Remaining__c == null){
                    resp.errorMessage = 'DM_Fees_Remaining__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Principal_Remaining__c  == null){
                    resp.errorMessage = 'DM_Principal_Remaining__c  is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Rate_Change_Dt_Last__c == null){
                    resp.errorMessage = 'DM_Rate_Change_Dt_Last__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Oldest_Due_Date__c == null){
                    resp.errorMessage = 'DM_Oldest_Due_Date__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Pmt_Amt_Cur__c   == null){
                    resp.errorMessage = 'DM_Pmt_Amt_Cur__c   is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Principal_Remaining__c  == null){
                    resp.errorMessage = 'DM_Principal_Remaining__c  is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Last_Installment_Date__c == null){
                    resp.errorMessage = 'DM_Last_Installment_Date__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Payment_Amount__c == null){
                    resp.errorMessage = 'DM_Payment_Amount__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Disbursal_Amount__c == null){
                    resp.errorMessage = 'DM_Disbursal_Amount__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Disbursed_Amount__c == null){
                    resp.errorMessage = 'DM_Disbursed_Amount__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Interest_Only_Period__c == null){
                    resp.errorMessage = 'DM_Interest_Only_Period__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Interest_Type__c == null){
                    resp.errorMessage = 'DM_Interest_Type__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Payment_Application_Mode__c == null){
                    resp.errorMessage = 'DM_Payment_Application_Mode__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Time_Counting_Method__c == null){
                    resp.errorMessage = 'DM_Time_Counting_Method__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Interest_Calculation_Method__c == null){
                    resp.errorMessage = 'DM_Interest_Calculation_Method__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Last_Accrual_Date__c == null){
                    resp.errorMessage = 'DM_Last_Accrual_Date__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Next_Due_Generation_Date__c == null){
                    resp.errorMessage = 'DM_Next_Due_Generation_Date__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Term_Cur__c == null){
                    resp.errorMessage = 'DM_Term_Cur__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                  Continue;
                }
                if(dloan.DM_Due_Day__c == null){
                    resp.errorMessage = 'DM_Due_Day__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Maturity_Date_Current__c == null){
                    resp.errorMessage = 'DM_Maturity_Date_Current__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Contractual_Due_Day__c == null){
                    resp.errorMessage = 'DM_Contractual_Due_Day__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_First_Installment_Date__c == null){
                    resp.errorMessage = 'DM_First_Installment_Date__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Second_Installment_Date__c == null){
                    resp.errorMessage = 'DM_Second_Installment_Date__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Accrual_Start_Date__c == null){
                resp.errorMessage = 'DM_Accrual_Start_Date__c is null)';
                resp.id = dloan.id;
                validationWrapperList.add(resp); 
                  Continue;
                }
                if(dloan.DM_Rate_Change_Dt_Next__c == null){
                    resp.errorMessage = 'DM_Rate_Change_Dt_Next__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Rate_Change_Dt_Last__c == null){
                    resp.errorMessage = 'DM_Rate_Change_Dt_Last__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Oldest_Due_Date__c == null){
                    resp.errorMessage = 'DM_Oldest_Due_Date__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Pmt_Amt_Cur__c == null){
                    resp.errorMessage = 'DM_Pmt_Amt_Cur__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Disbursal_Status__c == null){
                    resp.errorMessage = 'DM_Disbursal_Status__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Branch__c == null){
                    resp.errorMessage = 'DM_Branch__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                if(dloan.DM_Fee_Set__c == null){
                    resp.errorMessage = 'DM_Fee_Set__c is null)';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp); 
                    Continue;
                }
                
                //Object - LPT > 
                
               if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dloan.Product_Type__c+'|'+'DM_Loan_Payment_Transaction__c'.toLowerCase())=='0'){
                    for(DM_Loan_Payment_Transaction__c lpt : dloan.DM_Loan_Payment_Transactions__r){
                        if(lpt.DM_Payment_Mode__c == null){
                            resp.errorMessage = 'LPT DM_Payment_Mode__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(lpt.DM_Transaction_Amount__c == null){
                            resp.errorMessage = 'LPT DM_Transaction_Amount__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(lpt.DM_Receipt_Date__c == null){
                            resp.errorMessage = 'LPT DM_Receipt_Date__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(lpt.DM_Cleared__c  == null){
                            resp.errorMessage = 'LPT DM_Cleared__c  is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(lpt.DM_Rejected__c == null){
                            resp.errorMessage = 'LPT DM_Rejected__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(lpt.DM_Reversed__c == null){
                            resp.errorMessage = 'LPT DM_Reversed__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(lpt.DM_Principal__c == null){
                            resp.errorMessage = 'LPT DM_Principal__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(lpt.DM_Interest__c == null){
                            resp.errorMessage = 'LPT DM_Interest__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(lpt.DM_Fees__c == null){
                            resp.errorMessage = 'LPT DM_Fees__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(lpt.DM_Is_Migrated__c == null){
                            resp.errorMessage = 'LPT DM_Is_Migrated__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(lpt.DM_Reversed__c && lpt.DM_Migrated_Reversal_Date__c == null){
                            resp.errorMessage = 'LPT DM_Migrated_Reversal_Date__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(lpt.DM_Transaction_Date__c == null){
                            resp.errorMessage = 'LPT DM_Transaction_Date__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(lpt.DM_Transaction_Time__c == null){
                            resp.errorMessage = 'LPT DM_Transaction_Time__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(lpt.DM_Cleared__c && lpt.DM_Clearing_Date__c == null){
                            resp.errorMessage = 'LPT DM_Clearing_Date__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                    }//LPT END
                }//LPT Strategy Check
                //Object - Bill
               if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dloan.Product_Type__c+'|'+'DM_Bill__c'.toLowerCase())=='0'){
                    for(DM_Bill__c bill : dloan.DM_Bills__r){
                        if(Bill.DM_Transaction_Date__c == null){
                            resp.errorMessage = 'Bill DM_Transaction_Date__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(Bill.DM_Due_Date__c == null){
                            resp.errorMessage = 'Bill DM_Due_Date__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(Bill.DM_Due_Amt__c == null){
                            resp.errorMessage = 'Bill DM_Due_Amt__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(Bill.DM_Payment_Amt__c  == null){
                            resp.errorMessage = 'Bill DM_Payment_Amt__c  is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(Bill.DM_Payment_Satisfied__c == null){
                            resp.errorMessage = 'Bill DM_Payment_Satisfied__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(Bill.DM_Due_Type__c == null){
                            resp.errorMessage = 'Bill DM_Due_Type__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(Bill.DM_Payment_Date__c == null){
                            resp.errorMessage = 'Bill DM_Payment_Date__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }
                        if(Bill.DM_DD_Primary_Flag__c == null){
                            resp.errorMessage = 'Bill DM_DD_Primary_Flag__c is null';
                            resp.id = dloan.id;
                            validationWrapperList.add(resp);
                            break;
                        }   
                    }//END Bill
                }//END Bill Strategy
                //Object - APS
                
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dloan.Product_Type__c+'|'+'DM_Automated_Payment_Setup__c'.toLowerCase())=='0'){
                    For(DM_Automated_Payment_Setup__c aps : dloan.DM_Automated_Payment_Setups__r){
                        
                    }  //END APS
                }//END APS Strategy
                
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dloan.Product_Type__c+'|'+'DM_Repayment_Schedule__c'.toLowerCase())=='0'){
                    For(DM_Repayment_Schedule__c rss : dloan.DM_Repayment_Schedules__r){
                        
                    }  //END RS
                }//END RS Strategy               
                
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dloan.Product_Type__c+'|'+'DM_Charge__c'.toLowerCase())=='0'){
                    For(DM_Charge__c rss : dloan.DM_Charges__r){
                        
                    }  //END Charge  DM_Repayment_Schedule__c
                }//END Charge Strategy
                
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dloan.Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase())=='0'){
                    For(DM_Repayment_Schedule_Summary__c rss : dloan.DM_Repayment_Schedule_Summarys__r){
                        
                    }//END RSS
                } //END RSS Strategy
                
                // ******** added by NehaDM.
                
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dloan.Product_Type__c+'|'+'dm_Loan_Disbursal_Transaction__c'.toLowerCase())=='0'){
                    For(dm_Loan_Disbursal_Transaction__c rss : dloan.dm_Loan_Disbursal_Transactions__r){
                        
                        if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dloan.Product_Type__c+'|'+'DM_Disbursal_Transaction_Distribution__c'.toLowerCase())=='0'){
                            For(DM_Disbursal_Transaction_Distribution__c DDI : rss.DM_Disbursal_Transaction_Distributions__r){
                                
                            }//END DDI
                        } //END DDI Strategy                    
                        
                    }  //END LDT
                }//END LDT Strategy
                
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dloan.Product_Type__c+'|'+'DM_Multi_Step_Loan_Setup__c'.toLowerCase())=='0'){
                    For(DM_Multi_Step_Loan_Setup__c MSL : dloan.DM_Rate_Schedule_Setups__r){
                        
                    }//END MSL
                } */ //END MSL Strategy
                
                
                // ********
                system.debug('loan '+dloan);
                if(Test.isRunningTest() && dloan.Batch_Type__c=='Error'){
                    system.debug('Throw Fake Error');
                    resp.errorMessage = 'Throw Fake Error for Validation';
                    resp.id = dloan.id;
                    validationWrapperList.add(resp);
                    break;
                }//END  if(Test.isRunningTest() && dloan.Batch_Type__c=='Error'){
                system.debug('shouldt come here');
                successFlag=true;
                validationWrapperList.add(new DM_ValidationWrapper(dloan.Id,successFlag,''));
             }//IF
        }//END 
        
        return validationWrapperList;
    }// abstract public DM_ValidationWrapper LoanContractValidation(DM_Loan_Account__c sRecord);
    
    //Method - if there are any specific custom validation rules needs to performed.
    global abstract List<DM_ValidationWrapper> runAdditionalValidationRules(List<DM_Loan_Account__c> dmList, DM_Metadata_Config_Wrapper cw);
}