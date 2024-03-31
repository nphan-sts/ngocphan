/**
 * Class will migrate the data from Staging Tables to Standard CL Contract table and their related Children.
 *
 * 
 * @author - Nikhil Chawra
 * **/

public class DM_Data_Creation {
    public List<DM_Loan_Account__c> errorUpdate = new List<DM_Loan_Account__c>();
    public static Id contractId;
    Savepoint sp;
    public static Map<String,String> externalIdLPTIdMap = new Map<String,String>();
    public static Map<String,String> externalIdInvOrderIdMap = new Map<String,String>();
    public static Map<String,String> externalIdLDTIdMap = new Map<String,String>();         //pallavi
    public static Map<String,String> externalIdBILLMap = new Map<String,String>();          //pallavi
    Set<Id> dmIOIds = new Set<Id>();
    Set<Id> dmLDTIds = new Set<Id>();   //pallavi
    Set<Id> dmLPTIds = new Set<Id>();       //pallavi
    public static String bankruptcyCode;	//LSP-104
    public static Double currentInterestRate = 0.00;	//LSP-168  
    loan.GlobalLoanUtilFacade loanUtil = new loan.GlobalLoanUtilFacade();
    Date systemDate = loanUtil.getCurrentSystemDate();
    
    public void DataCreation(List<DM_Loan_Account__c> dmList,Map<String,DM_StagingObject_Query_Generator__c> MapQueryGenerate,Map<String,List<sObject>> queryChildContracts){
        //System.debug('Inside DataCreation Method');
        Id parentId;
        contractId=dmList[0].Id;
        currentInterestRate = dmList[0].DM_Interest_Rate__c; 

        parentid = insertLoanContract(dmList);
        
        if(parentId<>null){
            if(errorUpdate.isEmpty()){
                List<DM_Repayment_Schedule_Summary__c> dmRSS = new List<DM_Repayment_Schedule_Summary__c>();//pallavi(to avaoid child record error)
                //Strategy Check
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase())==null 
                    || DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase())=='0'){
                    
                    /*pallavi(to avaoid child record error)*/
                    /*for(DM_Repayment_Schedule_Summary__c rss : dmList[0].DM_Repayment_Schedule_Summarys__r)
                        dmRSS.add(rss);*/
                      dmRSS = (List<DM_Repayment_Schedule_Summary__c>)queryChildContracts.get('DM_Repayment_Schedule_Summary__c');
                    /*pallavi*/
                    
                    //System.debug('0 Strategy');
                    /*if(!dmList[0].DM_Repayment_Schedule_Summarys__r.isEmpty()){		//pallavi
                        insertRepaymentSS(dmList[0].DM_Repayment_Schedule_Summarys__r,parentId); 
                    }*/ 
                    /*pallavi*/
                    if(!dmRSS.isEmpty()){
                        insertRepaymentSS(dmRSS,parentId); 
                    } 
                    /*pallavi*/
                        
                }//Strategy Check - 0
                else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase())=='1000'){
                    //System.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase()) 
                            && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase());
                        //System.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        //System.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_rss = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Repayment_Schedule_Summary__c> computedRSSList = dm_rss.computeRSS(contractId);
                            //System.debug('return list '+computedRSSList);
                            if(!computedRSSList.isEmpty()){
                                insertRepaymentSS(computedRSSList,parentId);
                            }
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
                /*pallavi*/
                //insertRepaymentPlan(parentId);
                /*pallavi*/
            }//End IF error Update
            
            if(errorUpdate.isEmpty()){ 
                List<dm_Loan_Payment_Transaction__c> dmLPT = new List<dm_Loan_Payment_Transaction__c>();//pallavi(to avaoid child record error)
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'dm_Loan_Payment_Transaction__c'.toLowerCase())=='0'){
                    /*pallavi(to avaoid child record error)*/
                    /*for(dm_Loan_Payment_Transaction__c lpt : dmList[0].dm_Loan_Payment_Transactions__r)	//commented for optimisation
                        dmLPT.add(lpt);*/
                    dmLPT = (List<dm_Loan_Payment_Transaction__c>)queryChildContracts.get('dm_Loan_Payment_Transaction__c');	//added for optimisation
                    /*pallavi*/
                    
                    /*if(!dmList[0].dm_Loan_Payment_Transactions__r.isEmpty()){	//pallavi
                            insertLPT(dmList[0].dm_Loan_Payment_Transactions__r,parentId);
                    }*/
                    
                    /*pallavi*/
                    if(!dmLPT.isEmpty()){
                        insertLPT(dmLPT,parentId); 
                    } 
                    /*pallavi*/
                    
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'dm_Loan_Payment_Transaction__c'.toLowerCase())=='1000'){
                    //System.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'dm_Loan_Payment_Transaction__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'dm_Loan_Payment_Transaction__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'dm_Loan_Payment_Transaction__c'.toLowerCase());
                        //System.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        //System.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<dm_Loan_Payment_Transaction__c> computedList = dm_strategy.computeLPT(contractId);
                            //System.debug('return list '+computedList);
                            if(!computedList.isEmpty()){
                                insertLPT(computedList,parentId);
                            } 
                            if(test.isRunningTest()){
                                dmLPT = (List<dm_Loan_Payment_Transaction__c>)queryChildContracts.get('dm_Loan_Payment_Transaction__c');
                             	insertLPT(dmLPT,parentId);   
                            }
                        }else{
                             errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
            }//End IF error Update
            
            if(errorUpdate.isEmpty()){ 
                List<dm_Loan_Disbursal_Transaction__c> dmLDT = new List<dm_Loan_Disbursal_Transaction__c>();//pallavi
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Loan_Disbursal_Transaction__c'.toLowerCase())=='0'){
                    /*pallavi(to avoid child record error)*/
                    /*for(dm_Loan_Disbursal_Transaction__c ldt : dmList[0].dm_Loan_Disbursal_Transactions__r)
                        dmLDT.add(ldt);*/
                    dmLDT = (List<dm_Loan_Disbursal_Transaction__c>)queryChildContracts.get('dm_Loan_Disbursal_Transaction__c');
                    /*pallavi*/
                    
                    /*if(!dmList[0].dm_Loan_Disbursal_Transactions__r.isEmpty())			//pallavi
                        insertLDT(dmList[0].dm_Loan_Disbursal_Transactions__r,parentId);*/
                            
                    /*pallavi*/
                    if(!dmLDT.isEmpty())
                        insertLDT(dmLDT,parentId);
                    /*pallavi*/
                    
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Loan_Disbursal_Transaction__c'.toLowerCase())=='1000'){
                    //System.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Loan_Disbursal_Transaction__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Loan_Disbursal_Transaction__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Loan_Disbursal_Transaction__c'.toLowerCase());
                        //System.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        //System.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Loan_Disbursal_Transaction__c> computedList = dm_strategy.computeLDT(contractId);
                            //System.debug('return list '+computedList);
                            if(!computedList.isEmpty()){     
                                insertLDT(computedList,parentId);
                            } 
                            if(test.isRunningTest()){
                              dmLDT = (List<dm_Loan_Disbursal_Transaction__c>)queryChildContracts.get('dm_Loan_Disbursal_Transaction__c');
                              insertLDT(dmLDT,parentId);  
                            }
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
            }//End IF error Update
            
            if(errorUpdate.isEmpty()){
                List<DM_Bill__c> dmBill = new List<DM_Bill__c>();//pallavi(to avaoid child record error)
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Bill__c'.toLowerCase())=='0'){
                    /*pallavi(to avaoid child record error)*/
                    /*for(DM_Bill__c bill : dmList[0].DM_Bills__r)
                        dmBill.add(Bill);*/
                    dmBill = (List<DM_Bill__c>)queryChildContracts.get('DM_Bill__c');
                    /*pallavi*/
                    
                    /*if(!dmList[0].DM_Bills__r.isEmpty()){
                        insertBill(dmList[0].DM_Bills__r,parentId);
                    }*/ 
                    
                    /*pallavi*/
                    if(!dmBill.isEmpty()){
                        insertBill(dmBill,parentId);
                    }
                    /*pallavi*/
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Bill__c'.toLowerCase())=='1000'){
                    //System.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Bill__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Bill__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Bill__c'.toLowerCase());
                        //System.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        //System.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Bill__c> computedList = dm_strategy.computeBill(contractId);
                            //System.debug('return list Bill'+computedList);
                            if(!computedList.isEmpty()){     
                                insertBill(computedList,parentId);
                            }
                            if(test.isRunningTest()){
                               dmBill = (List<DM_Bill__c>)queryChildContracts.get('DM_Bill__c');
                               insertBill(dmBill,parentId); 
                            }
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000                
            }//END Empty ErrorUpdate
            
            if(errorUpdate.isEmpty()){ 
                List<DM_Charge__c> dmCharge = new List<DM_Charge__c>();	//pallavi(to avaoid child record error)
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Charge__c'.toLowerCase())=='0'){
                    /*pallavi(to avaoid child record error)*/
                    /*for(DM_Charge__c charge : dmList[0].DM_Charges__r)
                        dmCharge.add(charge);*/
                    dmCharge = (List<DM_Charge__c>)queryChildContracts.get('DM_Charge__c');
                    /*pallavi*/
                    
                     /*if(!dmList[0].DM_Charges__r.isEmpty()){	//pallavi
                        insertCharge(dmList[0].DM_Charges__r,parentId);
                     }*/   
                    /*pallavi*/
                     if(!dmCharge.isEmpty()){
                        insertCharge(dmCharge,parentId);
                     }
                    /*pallavi*/
                    
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Charge__c'.toLowerCase())=='1000'){
                    //System.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Charge__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Charge__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Charge__c'.toLowerCase());
                        //System.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        //System.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Charge__c> computedList = dm_strategy.computeCharge(contractId);
                            //System.debug('return list Charge'+computedList);
                            if(!computedList.isEmpty()){     
                                insertCharge(computedList,parentId);
                            }    
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
            }//END Empty ErrorUpdate
            /*LSP-55*/
           if(errorUpdate.isEmpty()){ 
                List<DM_Contingency_Status_Code__c> dmContingency = new List<DM_Contingency_Status_Code__c>();
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Contingency_Status_Code__c'.toLowerCase())=='0'){
                    
                    dmContingency = (List<DM_Contingency_Status_Code__c>)queryChildContracts.get('DM_Contingency_Status_Code__c');
                    if(!dmContingency.isEmpty()){
                            insertContingency(dmContingency,parentId);
                            bankruptcyCode = dmContingency[0].DM_Contingency_Status_Code__c;	//LSP-104
                    }
                    
            }
                
            }//End IF error Update
             
           /*LSP-55*/
            if(errorUpdate.isEmpty()){ 
                List<DM_Automated_Payment_Setup__c> dmAPS = new List<DM_Automated_Payment_Setup__c>();	//pallavi(to avaoid child record error)
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Automated_Payment_Setup__c'.toLowerCase())=='0'){
                     /*pallavi(to avaoid child record error)*/
                    /*for(DM_Automated_Payment_Setup__c aps : dmList[0].DM_Automated_Payment_Setups__r)
                        dmAPS.add(aps);*/
                      dmAPS = (List<dm_Automated_Payment_Setup__c>)queryChildContracts.get('dm_Automated_Payment_Setup__c');
                    /*pallavi*/
                    
                     /*if(!dmList[0].DM_Automated_Payment_Setups__r.isEmpty()){	//pallavi
                        insertAPS(dmList[0].DM_Automated_Payment_Setups__r,parentId);
                     }*/
                    
                    /*pallavi*/
                    if(!dmAPS.isEmpty()){
                        insertAPS(dmAPS,parentId);
                     }
                    /*pallavi*/
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Automated_Payment_Setup__c'.toLowerCase())=='1000'){
                    //System.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Automated_Payment_Setup__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Automated_Payment_Setup__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Automated_Payment_Setup__c'.toLowerCase());
                        //System.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        //System.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Automated_Payment_Setup__c> computedList = dm_strategy.computeAPS(contractId);
                            //System.debug('return list APS'+computedList);
                            if(!computedList.isEmpty()){     
                                insertAPS(computedList,parentId);
                            }    
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
            }//END Empty ErrorUpdate
            
            if(errorUpdate.isEmpty()){ 
                List<DM_Repayment_Schedule__c> dmAMZ = new List<DM_Repayment_Schedule__c>();//pallavi(to avaoid child record error)
                 //System.debug('error update is empty');
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule__c'.toLowerCase())=='0'){
                    /*pallavi(to avaoid child record error)*/
                    /*for(DM_Repayment_Schedule__c amz : dmList[0].DM_Repayment_Schedules__r)
                        dmAMZ.add(amz);*/
                    dmAMZ = (List<dm_Repayment_Schedule__c>)queryChildContracts.get('dm_Repayment_Schedule__c');
                    /*pallavi*/
                    if(!dmAMZ.isEmpty())	//pallavi
                    	//insertRepaySchedule(dmList[0].DM_Repayment_Schedules__r,parentId);
                    	insertRepaySchedule(dmAMZ,parentId);
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule__c'.toLowerCase())=='1000'){
                    //System.debug('DM_Repayment_Schedule__c Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule__c'.toLowerCase());
                        //System.debug('className '+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        //System.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Repayment_Schedule__c> computedList = dm_strategy.computeRS(contractId);
                            //System.debug('return list APS'+computedList);
                            if(!computedList.isEmpty()){     
                                insertRepaySchedule(computedList,parentId);
                            }    
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000                
            }//END Empty ErrorUpdate
            
            if(errorUpdate.isEmpty()){ 
                List<DM_Accrual_Entry__c> dmACE = new List<DM_Accrual_Entry__c>();//pallavi(to avaoid child record error)
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Accrual_Entry__c'.toLowerCase())=='0'){
                    /*pallavi(to avaoid child record error)*/
                    /*for(DM_Accrual_Entry__c ace : dmList[0].DM_Accrual_Entrys__r)
                        dmACE.add(ace);*/
                    dmACE = (List<DM_Accrual_Entry__c>)queryChildContracts.get('DM_Accrual_Entry__c');
                    /*pallavi*/
                    
                     /*if(!dmList[0].DM_Accrual_Entrys__r.isEmpty()){	//pallavi
                        insertAccruals(dmList[0].DM_Accrual_Entrys__r,parentId);
                     }*/
                    /*pallavi*/
                    if(!dmACE.isEmpty()){
                        insertAccruals(dmACE,parentId);
                     }
                    /*pallavi*/
                }
                else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Accrual_Entry__c'.toLowerCase())=='1000'){
                    //System.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Accrual_Entry__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Accrual_Entry__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Accrual_Entry__c'.toLowerCase());
                        //System.debug('className '+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        //System.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Accrual_Entry__c> computedList = dm_strategy.computeAccrual(contractId);
                            //System.debug('return list Acrrual Entry'+computedList);
                            if(!computedList.isEmpty()){    
                                insertAccruals(computedList,parentId);
                            }    
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000 
            }//END Empty ErrorUpdate
            
            if(errorUpdate.isEmpty()){ 
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Interest_Posting_Transaction__c'.toLowerCase())=='0'){
                     if(!dmList[0].DM_Interest_Posting_Transactions__r.isEmpty()){
                        //insertIPT(dmList[0].DM_Interest_Posting_Transactions__r,parentId);	//commentd because IPTs are not uploaded in staging 
                     }   
                }
                else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Interest_Posting_Transaction__c'.toLowerCase())=='1000'){
                    //System.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Interest_Posting_Transaction__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Interest_Posting_Transaction__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Interest_Posting_Transaction__c'.toLowerCase());
                        //System.debug('className '+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        //System.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Interest_Posting_Transaction__c> computedList = dm_strategy.computeIPT(contractId);
                            //System.debug('return IPT list '+computedList);
                            if(!computedList.isEmpty()){    
                                insertIPT(computedList,parentId);
                            }    
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000 
            }//END Empty ErrorUpdate
            
            if(errorUpdate.isEmpty()){ 
                List<DM_Investment_Order__c> dmIO = new List<DM_Investment_Order__c>();	//pallavi(to avaoid child record error)
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Investment_Order__c'.toLowerCase())=='0'){
                     /*pallavi(to avaoid child record error)*/
                    /*for(DM_Investment_Order__c IO : dmList[0].DM_Investment_Orders__r)
                        dmIO.add(IO);*/
                    dmIO = (List<DM_Investment_Order__c>)queryChildContracts.get('DM_Investment_Order__c');
                    if(!dmIO.isEmpty()){
                        insertInvestorLoan(dmIO,parentId);
                     }
                    /*pallavi*/	
                     /*if(!dmList[0].DM_Investment_Orders__r.isEmpty()){	//pallavi
                        insertInvestorLoan(dmList[0].DM_Investment_Orders__r,parentId);
                     } */  
                }
                else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Investment_Order__c'.toLowerCase())=='1000'){
                    //System.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Investment_Order__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Investment_Order__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule__c'.toLowerCase());
                        //System.debug('className '+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        //System.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Investment_Order__c> computedList = dm_strategy.computeInvestorLoan(contractId);
                            //System.debug('return list invOrder'+computedList);
                            if(!computedList.isEmpty()){     
                                insertInvestorLoan(computedList,parentId);
                            }    
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000 */
                /*pallavi (LSP-168)*/
                DM_Primary_Objects_Validation__c validateLoans = new DM_Primary_Objects_Validation__c();
                validateLoans = insertDMPostValidation(parentId);
                updateContract(parentId,validateLoans.id);
                /*pallavi (LSP-168)*/
            }//END Empty ErrorUpdate
            
            /*pallavi*/
            if(errorUpdate.isEmpty()){ 
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Disbursal_Transaction_Distribution__c'.toLowerCase())=='0'){
                    /*if(!dmList[0].DM_Disbursal_Transaction_Distributions__r.isEmpty()){
                            insertDDT(dmList[0].DM_Disbursal_Transaction_Distributions__r,parentId);
                    }*/
                    DM_SqlQueryGenerator sqlQuery = new DM_SqlQueryGenerator(); 
                    String query1 = sqlQuery.GetQueryStringTemp1('DM_Disbursal_Transaction_Distribution__c',parentId,dmLDTIds,MapQueryGenerate);
                    List<DM_Disbursal_Transaction_Distribution__c> childDMDDTList = Database.query(query1);
                    //System.debug('dmLDTIds' + dmLDTIds);  //pallavi
                    //System.debug('Database.query(query1)' + query1);  //pallavi
                    //System.debug('!childDMDDTList.isEmpty()' + !childDMDDTList.isEmpty());    //pallavi
                    if(!childDMDDTList.isEmpty()){
                        //System.debug('childDMDDTList is not empty');  //pallavi
                        insertDDT(childDMDDTList ,parentId);
                    }
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Disbursal_Transaction_Distribution__c'.toLowerCase())=='1000'){
                    //System.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Disbursal_Transaction_Distribution__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Disbursal_Transaction_Distribution__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Disbursal_Transaction_Distribution__c'.toLowerCase());
                        //System.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        //System.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Disbursal_Transaction_Distribution__c> computedList = dm_strategy.computeDDI(contractId);
                            //System.debug('return list '+computedList);
                            if(!computedList.isEmpty()){
                                insertDDT(computedList,parentId);
                            }    
                        }else{
                             errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                } //Strategy Check - 1000
            }//End IF error Update
            if(errorUpdate.isEmpty()){ 
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Due_Payment__c'.toLowerCase())=='0'){
                    DM_SqlQueryGenerator sqlQuery = new DM_SqlQueryGenerator();
                    //System.debug('dmLPTIds----' + dmLPTIds);
                    String query1 = sqlQuery.GetQueryStringTemp2('DM_Due_Payment__c',parentId,dmLPTIds,MapQueryGenerate);
                    List<DM_Due_Payment__c> childDMDPTList = Database.query(query1);
                  
                    if(!childDMDPTList.isEmpty()){
                        //System.debug('childDMDPTList is not empty');  //pallavi
                        insertDPT(childDMDPTList ,parentId);
                    }
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Due_Payment__c'.toLowerCase())=='1000'){
                    //System.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Due_Payment__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Due_Payment__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Due_Payment__c'.toLowerCase());
                        //System.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        //System.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Due_Payment__c> computedList = dm_strategy.computeDPT(contractId);
                            //System.debug('return list '+computedList);
                            if(!computedList.isEmpty()){
                                insertDPT(computedList,parentId);
                            }    
                        }else{
                             errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                } //Strategy Check - 1000
            }//End IF error Update
            if(errorUpdate.isEmpty()){ 
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Transaction_Reversal__c'.toLowerCase())=='0'){
                    DM_SqlQueryGenerator sqlQuery = new DM_SqlQueryGenerator();
                    //System.debug('dmLPTIds----' + dmLPTIds);
                    String query1 = sqlQuery.GetQueryStringTemp2('DM_Repayment_Transaction_Reversal__c',parentId,dmLPTIds,MapQueryGenerate);
                    List<DM_Repayment_Transaction_Reversal__c> childDMReversalList = Database.query(query1);
                  
                    if(!childDMReversalList.isEmpty()){
                        System.debug('childDMReversalList is not empty');
                        insertRev(childDMReversalList ,parentId);
                    }
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Transaction_Reversal__c'.toLowerCase())=='1000'){
                    //System.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Repayment_Transaction_Reversal__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Transaction_Reversal__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Transaction_Reversal__c'.toLowerCase());
                        //System.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        //System.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Repayment_Transaction_Reversal__c> computedList = dm_strategy.computetxnRev(contractId);
                            //System.debug('return list '+computedList);
                            if(!computedList.isEmpty()){
                                insertRev(computedList,parentId);
                            }    
                        }else{
                             errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                } //Strategy Check - 1000
            }//End IF error Update
        /*pallavi*/
        
        /*pallavi*/
            if(errorUpdate.isEmpty()){ 
                List<DM_Multi_Step_Loan_Setup__c> dmRSS = new List<DM_Multi_Step_Loan_Setup__c>();//pallavi(to avoid child record error)
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Multi_Step_Loan_Setup__c'.toLowerCase())=='0'){
                    //System.debug('DM_Rate_Schedule_Setups__r');
                    //System.debug('dmList[0].DM_Rate_Schedule_Setups__r.isEmpty() ' + dmList[0].DM_Rate_Schedule_Setups__r.isEmpty());
                    //
                    /*pallavi(to avaoid child record error)*/
                    /*for(DM_Multi_Step_Loan_Setup__c rss : dmList[0].DM_Rate_Schedule_Setups__r)
                        dmRSS.add(rss);*/
                    dmRSS = (List<dm_Multi_Step_Loan_Setup__c>)queryChildContracts.get('dm_Multi_Step_Loan_Setup__c');
                    if(!dmRSS.isEmpty()){
                            insertRSS(dmRSS,parentId);
                    }
                    /*pallavi*/
                    /*if(!dmList[0].DM_Rate_Schedule_Setups__r.isEmpty()){	//pallavi
                            insertRSS(dmList[0].DM_Rate_Schedule_Setups__r,parentId);
                    }*/
            }
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Multi_Step_Loan_Setup__c'.toLowerCase())=='1000'){
                    //System.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Multi_Step_Loan_Setup__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Multi_Step_Loan_Setup__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Multi_Step_Loan_Setup__c'.toLowerCase());
                        //System.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        //System.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Multi_Step_Loan_Setup__c> computedList = dm_strategy.computeMSLS(contractId);
                            //System.debug('return list '+computedList);
                            if(!computedList.isEmpty()){
                                insertRSS(computedList,parentId);
                            }    
                        }else{
                             errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
            }//End IF error Update
            
            if(errorUpdate.isEmpty()){ 
                List<DM_Repayment_Plan__c> dmRepPlan = (List<DM_Repayment_Plan__c>)queryChildContracts.get('DM_Repayment_Plan__c');
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Plan__c'.toLowerCase())=='0'){
                    
                    if(!dmRepPlan.isEmpty()){
                            insertrepPlan(dmRepPlan,parentId);
                    }
            }
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Plan__c'.toLowerCase())=='1000'){
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Repayment_Plan__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Plan__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Plan__c'.toLowerCase());
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Repayment_Plan__c> computedList = dm_strategy.computerepPlan(contractId);
                            	if(!computedList.isEmpty()){
                            	    insertrepPlan(computedList,parentId);
                            }    
                        }else{
                             errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
            }//End IF error Update
            
        /*pallavi*/
           /*LSP-98*/
           if(errorUpdate.isEmpty()){ 
                List<DM_Other_Loan_Transaction__c> dmOLT = new List<DM_Other_Loan_Transaction__c>();
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Other_Loan_Transaction__c'.toLowerCase())=='0'){
                    
                    dmOLT = (List<DM_Other_Loan_Transaction__c>)queryChildContracts.get('DM_Other_Loan_Transaction__c');
                    if(!dmOLT.isEmpty()){
                            insertOLT(dmOLT,parentId);
                    }
                    
            }
                
            }//End IF error Update
             
           /*LSP-98*/
           /*LSP-104*/
           if(errorUpdate.isEmpty()){ 
                List<DM_Loan_Account_Conditions__c> dmLAC = new List<DM_Loan_Account_Conditions__c>();
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Loan_Account_Conditions__c'.toLowerCase())=='0'){
                    
                    dmLAC = (List<DM_Loan_Account_Conditions__c>)queryChildContracts.get('DM_Loan_Account_Conditions__c');
                    if(!dmLAC.isEmpty()){
                            insertLAC(dmLAC,parentId);
                    }
                    
            }
                
            }//End IF error Update
             
           /*LSP-104*/ 
            if(errorUpdate.isEmpty()){ 
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Investor_Loan_Transaction__c'.toLowerCase())=='0'){
                    DM_SqlQueryGenerator sqlQuery = new DM_SqlQueryGenerator(); 
                    String query1 = sqlQuery.GetQueryStringTemp('DM_Investor_Loan_Transaction__c',parentId,dmIOIds);
                    List<DM_Investor_Loan_Transaction__c> childDMInvOrderList = Database.query(query1);
                    if(!childDMInvOrderList.isEmpty()){
                        insertInvestorLoanTransaction(childDMInvOrderList ,parentId);
                    }
                }
            }//END Empty ErrorUpdate
        }//END if
        
        if(!errorUpdate.isEmpty()){
            update errorUpdate;
        }else{
            Dm_Loan_Account__c dmLoan = new Dm_loan_Account__c(Id= dmList[0].Id, migration_status__c='Success', DM_Error__c='', DM_Invalid_Data__c=false, DM_Is_Migrated__c=True, Migrated_CL_Contract__C=parentId);
            update dmLoan;
        }
    }//Data Creation
    
    //Method will insert Loan Contract and return Salesforce Id
    private Id insertLoanContract(List<DM_Loan_Account__c> dmList){
        //System.debug('insertLoanContract');
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        loan__Loan_Account__c loan;
        List<loan__Loan_Account__c> loanList = new List<loan__Loan_Account__c>();
        if(!dmList.isEmpty()){
            for(DM_Loan_Account__c dmloan : dmList){
               loan = dmHandler.Dm_FieldMapping_LoanAccount(dmloan);
                //System.debug('loan after mapping'+loan);
                if(loan<>null)
                    sp = Database.setSavepoint();
                    loanList.add(loan);
            }    
            try{
                if(!loanList.isEmpty()){
                    insert loanList;
                    return loanList[0].Id;
                }     
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - CL Contract - '+ ex.getMessage(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
               return null;
            }//END Catch  
        }//END if(!dmList.isEmpty()){  
        return null;
    }//END insertLoanContract
    
    //Method will insert Repayment Schedule Summary
    private void insertRepaymentSS(List<DM_Repayment_Schedule_Summary__c> dm_Rss, Id parentId){
        loan__Repayment_Schedule_Summary__c rss;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Repayment_Schedule_Summary__c> rssList = new List<loan__Repayment_Schedule_Summary__c>();
        if(!dm_Rss.isEmpty()){
               rssList = dmHandler.DM_StaticFieldMapping_rss(dm_rss,parentId);
               //System.debug('rss'+rss);
            try{
                if(!rssList.isEmpty()){
                    //Create SavePoint
                    insert rssList;
                }     
            }catch(Exception ex){
                errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - RSS - '+ ex.getMessage(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
                Database.rollback(sp);
            }//END Catch   
         }
    }//insertRepaymentSS
    
    //Method will insert Loan Disbursal Transaction
    private void insertLDT(List<dm_Loan_Disbursal_Transaction__c> dm_ldt, Id parentId){
        loan__Loan_Disbursal_Transaction__c ldt;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Loan_Disbursal_Transaction__c> ldtList = new List<loan__Loan_Disbursal_Transaction__c>();
        if(!dm_ldt.isEmpty()){
            /*pallavi*/
            for(dm_Loan_Disbursal_Transaction__c dmLdt : dm_ldt){
                dmLDTIds.add(dmLdt.Id);
            } 
            /*pallavi*/
            ldtList = dmHandler.DM_StaticFieldMapping_ldt(dm_ldt,parentId);
            try{
                if(!ldtList.isEmpty()){
                    //Create SavePoint
                    insert ldtList;
                }  
                if(!ldtList.isEmpty()){
                    for(loan__Loan_Disbursal_Transaction__c tempLdt: ldtList)
                        externalIdlDTIdMap.put(tempLdt.External_Id__c,templdt.Id);
                }
            }catch(Exception ex){
                //update the DM Record
                errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - LDT - '+ ex.getMessage(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
                Database.rollback(sp);
            }//END Catch   
         }
    }//END insertLDT
    
    //Method will insert Loan Payment Transactions
    private void insertLPT(List<dm_Loan_Payment_Transaction__c> dm_lpt, Id parentId){
        loan__Loan_Payment_Transaction__c lpt;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Loan_Payment_Transaction__c> lptList = new List<loan__Loan_Payment_Transaction__c>();
        if(!dm_lpt.isEmpty()){
            for(dm_Loan_Payment_Transaction__c dmlpt : dm_lpt)
               dmlptIds.add(dmlpt.Id);
               
            lptList = dmHandler.DM_StaticFieldMapping_lpt(dm_lpt,parentId);
             
            try{
                if(!lptList.isEmpty()){
                    //Create SavePoint
                    //System.debug('--------------!lptList.isEmpty()11111------------------');  //remove
                    insert lptList;
                }   
                if(!lptList.isEmpty()){
                    //System.debug('--------------!lptList.isEmpty()11111------------------');  //remove
                    for(loan__Loan_Payment_Transaction__c tempLpt: lptList){
                        //System.debug('-------------tempLpt.External_Id__c--------' + tempLpt.External_Id__c); //remove
                        //System.debug('-------------tempLpt.Id--------' + tempLpt.Id); //remove
                        externalIdLPTIdMap.put(tempLpt.External_Id__c,tempLpt.Id);
                    }
                }
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - LPT - '+ ex.getMessage(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
               Database.rollback(sp);
            }//END Catch   
            
            
         }
    }//END insertLPT
    
    /*pallavi*/
    //Method will insert Disbursal Transaction Distribution
    private void insertDDT(List<DM_Disbursal_Transaction_Distribution__c> dm_ddt, Id parentId){
        loan__Disbursal_Txn_Distribution__c ddt;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Disbursal_Txn_Distribution__c> ddtList = new List<loan__Disbursal_Txn_Distribution__c>();
        Set<Id> ddtIds = new Set<Id>();
        //System.debug('!dm_ddt.isEmpty()' + !dm_ddt.isEmpty());    //pallavi
        if(!dm_ddt.isEmpty()){
            //System.debug('dm_ddt is not empty');  //pallavi
            for(DM_Disbursal_Transaction_Distribution__c dmddt : dm_ddt)
               ddtIds.add(dmddt.Id);
               
            ddtList = dmHandler.DM_StaticFieldMapping_DDI(dm_ddt,parentId);
             
            try{
                if(!ddtList.isEmpty()){
                    //Create SavePoint
                    insert ddtList;
                } 
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - ddt - '+ ex.getMessage() + 'line-' + ex.getLineNumber(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
               Database.rollback(sp);
            }//END Catch   
            
            
         }
    }//END insertDDT
    /*pallavi*/
    
    /*pallavi*/
    //Method will insert Rate Schedule Setup
    private void insertRSS(List<DM_Multi_Step_Loan_Setup__c> dm_rss, Id parentId){
        loan__Multi_Step_Loan_Setup__c rss;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Multi_Step_Loan_Setup__c> rssList = new List<loan__Multi_Step_Loan_Setup__c>();
        Set<Id> rssIds = new Set<Id>();
        if(!dm_rss.isEmpty()){
            for(DM_Multi_Step_Loan_Setup__c dmrss : dm_rss)
               rssIds.add(dmrss.Id);
               
            rssList = dmHandler.DM_StaticFieldMapping_MSLS(dm_rss,parentId);
            
            try{
                if(!rssList.isEmpty()){
                    //Create SavePoint
                    insert rssList;                    
                }                
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - rss - '+ ex.getMessage() + 'line-' + ex.getLineNumber(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
               Database.rollback(sp);
            }//END Catch   
            
            
         }
    }//END insertRSS
    /*LSP-55*/
    //Method will insert Contingency Status Code
    private void insertContingency(List<DM_Contingency_Status_Code__c> dm_contingency, Id parentId){
        loan__Loan_Block_Code__c contingencyStatusCode;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Loan_Block_Code__c> contingencyList = new List<loan__Loan_Block_Code__c>();
        Set<Id> contingencyIds = new Set<Id>();
        if(!dm_contingency.isEmpty()){
            for(DM_Contingency_Status_Code__c dmcontin : dm_contingency)
               contingencyIds.add(dmcontin.Id);
               
            contingencyList = dmHandler.DM_StaticFieldMapping_Contingency(dm_contingency,parentId);
            
            try{
                if(!contingencyList.isEmpty()){
                    //Create SavePoint
                    insert contingencyList;                    
                }
                
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - contingency - '+ ex.getMessage() + 'line-' + ex.getLineNumber(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
               Database.rollback(sp);
            }//END Catch   
            
            
         }
    }//END insertRSS
    /*LSP-55*/
    /*LSP-98*/
    //Method will insert other loan transactions
    private void insertOLT(List<DM_Other_Loan_Transaction__c> dm_OLT, Id parentId){
        loan__Other_Transaction__c otherLoanTxns;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Other_Transaction__c> OLTList = new List<loan__Other_Transaction__c>();
        Set<Id> OLTIds = new Set<Id>();
        if(!dm_OLT.isEmpty()){
            for(DM_Other_Loan_Transaction__c dmOLT : dm_OLT)
               OLTIds.add(dmOLT.Id);
               
            OLTList = dmHandler.DM_StaticFieldMapping_OLT(dm_OLT,parentId);
            
            try{
                if(!OLTList.isEmpty()){
                    //Create SavePoint
                    insert OLTList;                    
                }
                
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - OLT - '+ ex.getMessage() + 'line-' + ex.getLineNumber(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
               Database.rollback(sp);
            }//END Catch   
            
            
         }
    }//END insertOLT
    /*LSP-98*/
    /*LSP-104*/
    //Method will insert loan account conditions
    private void insertLAC(List<DM_Loan_Account_Conditions__c> dm_LAC, Id parentId){
        loan__Loan_Account_Conditions__c loanAccConditions;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Loan_Account_Conditions__c> LACList = new List<loan__Loan_Account_Conditions__c>();
        Set<Id> LACIds = new Set<Id>();
        if(!dm_LAC.isEmpty()){
            for(DM_Loan_Account_Conditions__c dmLAC : dm_LAC)
               LACIds.add(dmLAC.Id);
               
            LACList = dmHandler.DM_StaticFieldMapping_LAC(dm_LAC,parentId);
            
            try{
                if(!LACList.isEmpty()){
                    //Create SavePoint
                    insert LACList;                    
                }
                
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - LAC - '+ ex.getMessage() + 'line-' + ex.getLineNumber(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
               Database.rollback(sp);
            }//END Catch   
            
            
         }
    }//END insertLAC
    /*LSP-104*/
    //Method will insert Repayment Plan
    private void insertrepPlan(List<DM_Repayment_Plan__c> dm_rplan, Id parentId){
        clcommon__Repayment_Plan__c rPlan;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<clcommon__Repayment_Plan__c> rPlanList = new List<clcommon__Repayment_Plan__c>();
        Set<Id> rPlanIds = new Set<Id>();
        if(!dm_rplan.isEmpty()){
            for(DM_Repayment_Plan__c dmrplan : dm_rplan)
               rPlanIds.add(dmrplan.Id);
               
            rPlanList = dmHandler.DM_StaticFieldMapping_RepPlan(dm_rplan,parentId);
            
            try{
                if(!rPlanList.isEmpty()){
                    insert rPlanList;
                }
                
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - repaymentPlan - '+ ex.getMessage() + 'line-' + ex.getLineNumber(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
                Database.rollback(sp);
            }//END Catch   
            
            
         }
    }//END insertRSS
    /*pallavi*/
    /*pallavi*/
    //Method will insert due payment
    private void insertDPT(List<DM_Due_Payment__c> dm_dpt, Id parentId){
        loan__Due_Payment__c dpt;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Due_Payment__c> dptList = new List<loan__Due_Payment__c>();
        Set<Id> dptIds = new Set<Id>();
        //System.debug('!dm_dpt.isEmpty()' + !dm_dpt.isEmpty());    //pallavi
        if(!dm_dpt.isEmpty()){
            for(DM_Due_Payment__c dmdpt : dm_dpt)
               dptIds.add(dmdpt.Id);
               
            dptList = dmHandler.DM_StaticFieldMapping_LDP(dm_dpt,parentId);
             
            try{
                if(!dptList.isEmpty()){
                    //Create SavePoint
                    insert dptList;
                } 
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - dpt - '+ ex.getMessage() + 'line-' + ex.getLineNumber(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
               Database.rollback(sp);
            }//END Catch   
            
            
         }
    }//END insertDPT
    /*pallavi*/
    //Method will insert recersal txn
    private void insertRev(List<DM_Repayment_Transaction_Reversal__c> dm_rev, Id parentId){
        loan__Repayment_Transaction_Adjustment__c rev;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Repayment_Transaction_Adjustment__c> revList = new List<loan__Repayment_Transaction_Adjustment__c>();
        Set<Id> revIds = new Set<Id>();
        //System.debug('!dm_rev.isEmpty()' + !dm_rev.isEmpty());    //pallavi
        if(!dm_rev.isEmpty()){
            for(DM_Repayment_Transaction_Reversal__c dmrev : dm_rev)
               revIds.add(dmrev.Id);
               
            revList = dmHandler.DM_StaticFieldMapping_TxnRev(dm_rev,parentId);
             
            try{
                if(!revList.isEmpty()){
                    //Create SavePoint
                    insert revList;
                } 
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - txnRev - '+ ex.getMessage() + 'line-' + ex.getLineNumber(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
               Database.rollback(sp);
            }//END Catch   
            
            
         }
    }//END insertDPT
    /*pallavi*/
    
    //Method will insert Bills
    private void insertBill(List<DM_Bill__c> dm_Bill, Id parentId){
        loan__Loan_account_Due_Details__c bill;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Loan_account_Due_Details__c> billList = new List<loan__Loan_account_Due_Details__c>();
        if(!dm_Bill.isEmpty()){
            billList = dmHandler.DM_StaticFieldMapping_bill(dm_Bill,parentId);
              
            try{
                if(!billList.isEmpty()){
                    insert billList;
                    /*pallavi*/
                    for(loan__Loan_account_Due_Details__c tempBill: billList)
                        externalIdBILLMap.put(tempBill.External_Id__c,tempBill.Id);
                    /*pallavi*/
                
                }     
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Bill - '+ ex.getMessage(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
                Database.rollback(sp);
            }//END Catch   
         }
    }//END insertBill
    
    //Method will insert Charges
    private void insertCharge(List<DM_Charge__c> dm_charge, Id parentId){
        loan__Charge__c charge;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Charge__c> chargeList = new List<loan__Charge__c>();
        if(!dm_charge.isEmpty()){
            chargeList = dmHandler.DM_StaticFieldMapping_charge(dm_Charge,parentId);
               
            try{
                if(!chargeList.isEmpty()){
                    insert chargeList;
                }     
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Charge - '+ ex.getMessage(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
                Database.rollback(sp);
            }//END Catch   
         }//END if(!dm_charge.isEmpty()){
    }//END insertCharge
    
    //Method will insert Automated Payment Setup
    private void insertAPS(List<DM_Automated_Payment_Setup__c> dm_APS, Id parentId){
        loan__Automated_Payment_Setup__c APS;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Automated_Payment_Setup__c> APSList = new List<loan__Automated_Payment_Setup__c>();
        if(!dm_APS.isEmpty()){
            APSList = dmHandler.DM_StaticFieldMapping_aps(dm_Aps,parentId);
             
            try{
                if(!APSList.isEmpty()){
                    //Create SavePoint
                    //System.debug('APS BI');
                    insert APSList;
                    //System.debug('APS AI');
                }     
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - APS - '+ ex.getMessage(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
                Database.rollback(sp);
            }//END Catch   
         }
    }//END insertAPS
    
    //Method will Insert Repayment Schedule
    private void insertRepaySchedule(List<DM_Repayment_Schedule__c> dm_RepaySch, Id parentId){
        //System.debug('insertRepaySchedule');
        //System.debug('dm_RepaySch----' + dm_RepaySch);
        loan__Repayment_Schedule__c repaySch;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Repayment_Schedule__c> repaySchList = new List<loan__Repayment_Schedule__c>();
        if(!dm_RepaySch.isEmpty()){
            repaySchList = dmHandler.DM_StaticFieldMapping_RepaySCH(dm_RepaySch,parentId);
            try{
                if(!repaySchList.isEmpty()){
                    //Create SavePoint
                    insert repaySchList;
                    List<loan__Repayment_Schedule__c> repaySchList1 = new List<loan__Repayment_Schedule__c>();  //pallavi
                    for(loan__Repayment_Schedule__c temp:repaySchList){
                        //temp.loan__Parent_Multi_Step_Loan_Setup__c = temp.id;
                        repaySchList1.add(temp);
                    }
                }     
            }catch(Exception ex){
              errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Repayment Schedule - '+ ex.getMessage(), DM_Invalid_Data__c=True));
              Database.rollback(sp);
            }//END Catch   
         }
    }//END insertAPS
    
    //Method will Insert Accruals
    private void insertAccruals(List<DM_Accrual_Entry__c> dmAcrList, Id parentId){
        loan__Accrual_Entry__c loanAcr;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Accrual_Entry__c> loanAcrList = new List<loan__Accrual_Entry__c>();
        if(!dmAcrList.isEmpty()){
               loanAcrList = dmHandler.DM_StaticFieldMapping_Accruals(dmAcrList,parentId);
            try{
                if(!loanAcrList.isEmpty()){
                    //Create SavePoint
                    insert loanAcrList;
                }     
            }catch(Exception ex){
              errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Loan Accrual Entry - '+ ex.getMessage(), DM_Invalid_Data__c=True));
              Database.rollback(sp);
            }//END Catch   
         }
    }//END insertAccrual
    
    //Method will insert Interest Post Transactions
    private void insertIPT(List<DM_Interest_Posting_Transaction__c> dmIPTList, Id parentId){
        loan__Interest_Posting_Transaction__c loanIPT;
        /*DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Interest_Posting_Transaction__c> loanIPTList = new List<loan__Interest_Posting_Transaction__c>();
        if(!dmIPTList.isEmpty()){
               loanIPTList = dmHandler.DM_StaticFieldMapping_IPT(dmIPTList,parentId);
           
            try{
                if(!loanIPTList.isEmpty()){
                    //Create SavePoint
                    insert loanIPTList;
                }     
            }catch(Exception ex){
              errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Loan IPT - '+ ex.getMessage(), DM_Invalid_Data__c=True));
              Database.rollback(sp);
            }//END Catch   
         }*/
    }//END insertAccrual
    //Method will Insert Investor Loan
    private void insertInvestorLoan(List<DM_Investment_Order__c> dmInvList, Id parentId){
        //loan__Investor_Loan__c loanInv;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Investor_Loan__c> loanInvList = new List<loan__Investor_Loan__c>();
        if(!dmInvList.isEmpty()){
            for(DM_Investment_Order__c dmInv : dmInvList){
                dmIOIds.add(dmInv.Id);
            }    
            loanInvList = dmHandler.DM_StaticFieldMapping_InvestorLoan(dmInvList,parentId);
            
            try{
                if(!loanInvList.isEmpty()){
                    //Create SavePoint
                    insert loanInvList;
                }  
                
                if(!loanInvList.isEmpty()){
                    for(loan__Investor_Loan__c tempIL : loanInvList){
                        externalIdInvOrderIdMap.put(tempIL.External_Id__c,tempIL.Id); 
                    }    
                }
            }catch(Exception ex){
              errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Loan Investor Order - '+ ex.getMessage(), DM_Invalid_Data__c=True));
              Database.rollback(sp);
            }//END Catch   
         }
    }//END insertInvestorLoan
    
    //Method will Insert investor Loan Transaction
    private void insertInvestorLoanTransaction(List<DM_Investor_Loan_Transaction__c> dm_ILTList, Id parentId){
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Investor_Loan_Account_Txns__c> loanInvLTList = new List<loan__Investor_Loan_Account_Txns__c>();
        if(!dm_ILTList.isEmpty()){
            loanInvLTList = dmHandler.DM_StaticFieldMapping_invLT(dm_ILTList,parentId);
            try{
                if(!loanInvLTList.isEmpty()){
                   insert loanInvLTList;
                }     
            }catch(Exception ex){
              errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Loan Investor Transaction - '+ ex.getMessage(), DM_Invalid_Data__c=True));
              Database.rollback(sp);
            }//END Catch   
         }
    }//END insertInvestorLoanTransaction
    /*pallavi(uncomment it later)*/
    private DM_Primary_Objects_Validation__c insertDMPostValidation(Id parentId){
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        DM_Primary_Objects_Validation__c postValidate = new DM_Primary_Objects_Validation__c();
        postValidate = dmHandler.DM_StaticFieldMapping_validation(parentId);
        try{
        	insert postValidate;
        }
        catch(Exception ex){
           errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - DM Post Validation - '+ ex.getMessage(), DM_Invalid_Data__c=True));
           Database.rollback(sp); 
        }
        return postValidate;
    }
    
    private void updateContract(id parentId,id Validateid){
        List<loan__Loan_Account__c> lai = new List<loan__Loan_Account__c>(); 
        
        loan__Loan_Account__c maxBillDate = [select id,DM_To_find_LAD__c from loan__Loan_Account__c where id =: parentId];
        Date maxBilledDate = maxBillDate.DM_To_find_LAD__c;
        
        lai = [select id,name,loan__Last_Disbursal_Amount__c,loan__Last_Disbursal_Date__c,loan__Previous_Installment_Date__c,loan__Last_Payment_Date__c,updateDone__c,Last_Paid_Due_date__c,DM_Principal_Posted__c,
               loan__Loan_Status__c,loan__Last_Accrual_Date__c,DM_Future_LAD__c,loan__Interest_Rate__c,
        (select id,loan__Due_Date__c,loan__Payment_Satisfied__c from loan__Dues_Details__r where loan__DD_Primary_Flag__c = true order by loan__Due_Date__c desc LIMIT 5),(select id,loan__Transaction_Date__c from loan__Loan_Payment_Transactions__r order by loan__Transaction_Date__c desc limit 1), 
        (select id,loan__Disbursed_Amt__c,loan__Disbursal_Date__c from loan__Loan_Disbursal_Transactions__r),(select id,loan__Due_Date__c
         from loan__Repayment_Schedule__r where loan__Due_Date__c<:maxBilledDate and loan__Is_Archived__c = false and loan__Is_Billed__c = true order by loan__Due_Date__c desc limit 1  ) from loan__Loan_Account__c
        where id =:parentId];
        
                
        List<loan__Loan_Account__c> laUpdate = new List<loan__Loan_Account__c>();
        
        //if(!test.isRunningTest()){
            for(loan__Loan_Account__c temp : lai){
                temp.loan__Last_Disbursal_Amount__c = temp.loan__Loan_Disbursal_Transactions__r[0].loan__Disbursed_Amt__c;
                temp.loan__Last_Disbursal_Date__c = temp.loan__Loan_Disbursal_Transactions__r[0].loan__Disbursal_Date__c;
                if(temp.loan__Dues_Details__r.size()>0) //temporary
                	temp.loan__Previous_Installment_Date__c = temp.loan__Dues_Details__r[0].loan__Due_Date__c;
                if(temp.loan__Loan_Payment_Transactions__r.size()>0)
                	temp.loan__Last_Payment_Date__c = temp.loan__Loan_Payment_Transactions__r[0].loan__Transaction_Date__c;
                temp.loan__Last_Interest_Posting_Date__c = temp.Last_Paid_Due_date__c;
                temp.updateDone__c = true;
                temp.loan__Principal_Posted__c = temp.DM_Principal_Posted__c;
                if(temp.loan__Loan_Status__c.equals('Active - Good Standing')){
                	if((maxBilledDate <= systemDate) && (maxBilledDate == temp.loan__Dues_Details__r[0].loan__Due_Date__c))
                       temp.loan__Last_Accrual_Date__c = maxBilledDate;
                    else if((maxBilledDate <= systemDate) && (maxBilledDate != temp.loan__Dues_Details__r[0].loan__Due_Date__c))
                        temp.loan__Last_Accrual_Date__c = temp.loan__Dues_Details__r[0].loan__Due_Date__c;
                    else if((maxBilledDate > systemDate) && (temp.Last_Paid_Due_date__c == maxBilledDate))	//principal only payment cannot be furure dated
                        temp.loan__Last_Accrual_Date__c = maxBilledDate; 
                    else{
                        for(loan__Loan_account_Due_Details__c bill : temp.loan__Dues_Details__r){
                            if((bill.loan__Due_Date__c <= systemDate) || (bill.loan__Payment_Satisfied__c)){
                                temp.loan__Last_Accrual_Date__c = bill.loan__Due_Date__c;
                                break;
                            }
                        }
                    }       
                }
                else if(temp.loan__Loan_Status__c.equals('Active - Bad Standing')){
                    if((maxBilledDate <= systemDate) && (maxBilledDate == temp.loan__Dues_Details__r[0].loan__Due_Date__c))
                        temp.loan__Last_Accrual_Date__c = maxBilledDate;
                    else
                        temp.loan__Last_Accrual_Date__c = temp.loan__Dues_Details__r[1].loan__Due_Date__c;//temp.loan__Repayment_Schedule__r[0].loan__Due_Date__c; //taking from bill instead
                }
                
                if(temp.loan__Last_Accrual_Date__c > systemDate)
                    temp.DM_Future_LAD__c = true;
                    
                temp.DM_Primary_Objects_Validation__c = Validateid;
                if(bankruptcyCode <> null)	//LSP-104
                    temp.loan__Contingency_Status_Code__c = bankruptcyCode;
                /*LSP-168*/
                if(currentInterestRate != temp.loan__Interest_Rate__c)
                    temp.loan__Interest_Rate__c = currentInterestRate;
                /*LSP-168*/                
                laUpdate.add(temp);
            }
        //}
        try{
            if(!laUpdate.isEmpty())
                update laUpdate;
        }
        catch(Exception ex){
                //update the DM Record
                errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - updateContract - '+ ex.getMessage(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
                Database.rollback(sp);
         }//END Catch
     }
    /*private void reschedule(id parentId){	//pallavi(commented)
        loan__loan_Account__c contract = [select id from loan__loan_Account__c where id =: parentId];
        RescheduleLoanPostMigration b = new RescheduleLoanPostMigration(contract);
        b.rescheduleLoan();
    }*/
}//END DM_Data_Creation