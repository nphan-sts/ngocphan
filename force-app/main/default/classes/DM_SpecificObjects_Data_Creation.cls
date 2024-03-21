/**
 *
 * 
 * @author - Pallavi
 * **/

public class DM_SpecificObjects_Data_Creation {
    public List<DM_Loan_Account__c> errorUpdate = new List<DM_Loan_Account__c>();
    public static Id contractId;
    Savepoint sp;
    public static Map<String,String> externalIdLPTIdMap = new Map<String,String>();
    public static Map<String,String> externalIdInvOrderIdMap = new Map<String,String>();
	public static Map<String,String> externalIdLDTIdMap = new Map<String,String>();			//pallavi
    public static Map<String,String> externalIdBILLMap = new Map<String,String>();			//pallavi
    Set<Id> dmIOIds = new Set<Id>();
	Set<Id> dmLDTIds = new Set<Id>();	//pallavi
	Set<Id> dmLPTIds = new Set<Id>();		//pallavi
    Set<String> dmLPTExtIds = new Set<String>();
    
    public void DataCreation(List<DM_Loan_Account__c> dmList){
        system.debug('Inside DataCreation Method');
        Id parentId;
        contractId=dmList[0].Id;
        System.debug('contract Id - '+contractId);
        parentId = dmList[0].Migrated_CL_Contract__c;
 
        system.debug('ParentId '+parentId);
        
        List<loan__loan_account__c> contract = [Select id,
                                               (Select id,external_id__C from loan__Loan_Payment_Transactions__r where ToBeDeleted__c = false),
                                               (Select id,external_id__C from loan__Loan_Disbursal_Transactions__r),
                                               (Select id,external_id__c from loan__Dues_Details__r where ToBeDeleted__c = false),
                                               (Select id,external_id__c from loan__Automated_Payment_Setup__r),
                                               (Select id,external_id__c from loan__Investors_Loans__r),
                                               (Select id,external_id__c from loan__Accrual_Entries__r),
                                               (Select id,external_id__c from loan__Multi_Step_Loan_Setup__r)
                                               From loan__loan_account__c where id =: parentId];
        DM_SpecificObjects_MigrationHandler dmHandler = new DM_SpecificObjects_MigrationHandler();
        dmHandler.DM_FieldMapping_LoanAccount(dmList[0]);
        System.debug('contract fetched.... '+contract);
            if(errorUpdate.isEmpty()){
                //Strategy Check
                //if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase())==null 
                //    || DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase())=='0'){
                    
                    system.debug('0 Strategy');
                    if(!dmList[0].DM_Repayment_Schedule_Summarys__r.isEmpty()){
                        insertRepaymentSS(dmList[0].DM_Repayment_Schedule_Summarys__r,parentId); 
                    }       
            }//End IF error Update
            
            if(errorUpdate.isEmpty()){ 
                //if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'dm_Loan_Payment_Transaction__c'.toLowerCase())=='0'){
                    if(!dmList[0].dm_Loan_Payment_Transactions__r.isEmpty()){
                        System.debug('dmList is not empty');
                        
                        List<loan__Loan_Payment_Transaction__c> lpt = contract[0].loan__Loan_Payment_Transactions__r;
                        Set<String> lpt_extID = new Set<String>();
                        List<dm_Loan_Payment_Transaction__c> finalList = new List<dm_Loan_Payment_Transaction__c>();
                        
                        for(loan__Loan_Payment_Transaction__c temp : lpt)
                            lpt_extID.add(temp.external_id__C);
                        
                        if(lpt_extID.size()==0){
                            for(dm_Loan_Payment_Transaction__c temp : dmList[0].DM_Loan_Payment_Transactions__r)
                                finalList.add(temp);
                        }
                        else{
                        for(DM_Loan_Payment_Transaction__c temp : dmList[0].DM_Loan_Payment_Transactions__r){
                            if(!lpt_extId.contains(temp.dm_external_id__c))
                                finalList.add(temp);
                        }
                        }
                        System.debug('finalList for insertLPT---- ' + finalList);
                            insertLPT(finalList,parentId);
                    }    
                /*}else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'dm_Loan_Payment_Transaction__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'dm_Loan_Payment_Transaction__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'dm_Loan_Payment_Transaction__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'dm_Loan_Payment_Transaction__c'.toLowerCase());
                        system.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<dm_Loan_Payment_Transaction__c> computedList = dm_strategy.computeLPT(contractId);
                            system.debug('return list '+computedList);
                            if(!computedList.isEmpty()){
                                insertLPT(computedList,parentId);
                            }    
                        }else{
                             errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000*/
            }//End IF error Update
            
            /*if(errorUpdate.isEmpty()){ 
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Loan_Disbursal_Transaction__c'.toLowerCase())=='0'){
                    if(!dmList[0].dm_Loan_Disbursal_Transactions__r.isEmpty())
                        insertLDT(dmList[0].dm_Loan_Disbursal_Transactions__r,parentId);
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Loan_Disbursal_Transaction__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Loan_Disbursal_Transaction__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Loan_Disbursal_Transaction__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Loan_Disbursal_Transaction__c'.toLowerCase());
                        system.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Loan_Disbursal_Transaction__c> computedList = dm_strategy.computeLDT(contractId);
                            system.debug('return list '+computedList);
                            if(!computedList.isEmpty()){     
                                insertLDT(computedList,parentId);
                            }    
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
            }//End IF error Update*/
            
            if(errorUpdate.isEmpty()){
                System.debug('bill');
               // if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Bill__c'.toLowerCase())=='0'){
               //     System.debug('true');
                    if(!dmList[0].DM_Bills__r.isEmpty()){
                        
                        System.debug('dmList is not empty');
                        
                        List<loan__Loan_account_Due_Details__c> bill = contract[0].loan__Dues_Details__r;
                        Set<String> bill_extID = new Set<String>();
                        List<DM_Bill__c> finalList = new List<DM_Bill__c>();
                        
                        for(loan__Loan_account_Due_Details__c temp : bill)
                            bill_extId.add(temp.external_id__C);
                        
                        if(bill_extId.size()==0){
                            for(DM_Bill__c temp : dmList[0].DM_Bills__r)
                                finalList.add(temp);
                        }
                        else{
                        for(DM_Bill__c temp : dmList[0].DM_Bills__r){
                            if(!bill_extId.contains(temp.dm_external_id__c))
                                finalList.add(temp);
                        }
                        }
                        System.debug('finalList for insertBill---- ' + finalList);
                        insertBill(finalList,parentId);
                    }
                /*}else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Bill__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');	// won't be used
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Bill__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Bill__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Bill__c'.toLowerCase());
                        system.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Bill__c> computedList = dm_strategy.computeBill(contractId);
                            system.debug('return list Bill'+computedList);
                            if(!computedList.isEmpty()){     
                                insertBill(computedList,parentId);
                            }   
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }*///Strategy Check - 1000
                /*pallavi*/
                //updateContract(parentId);
                /*pallavi*/
            }//END Empty ErrorUpdate
            
            /*if(errorUpdate.isEmpty()){ 
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Charge__c'.toLowerCase())=='0'){
                     if(!dmList[0].DM_Charges__r.isEmpty()){
                        insertCharge(dmList[0].DM_Charges__r,parentId);
                     }   
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Charge__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Charge__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Charge__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Charge__c'.toLowerCase());
                        system.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Charge__c> computedList = dm_strategy.computeCharge(contractId);
                            system.debug('return list Charge'+computedList);
                            if(!computedList.isEmpty()){     
                                insertCharge(computedList,parentId);
                            }    
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
            }//END Empty ErrorUpdate
            if(errorUpdate.isEmpty()){ 
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Automated_Payment_Setup__c'.toLowerCase())=='0'){
                     if(!dmList[0].DM_Automated_Payment_Setups__r.isEmpty()){
                        insertAPS(dmList[0].DM_Automated_Payment_Setups__r,parentId);
                     }
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Automated_Payment_Setup__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Automated_Payment_Setup__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Automated_Payment_Setup__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Automated_Payment_Setup__c'.toLowerCase());
                        system.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Automated_Payment_Setup__c> computedList = dm_strategy.computeAPS(contractId);
                            system.debug('return list APS'+computedList);
                            if(!computedList.isEmpty()){     
                                insertAPS(computedList,parentId);
                            }    
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
            }*/ //END Empty ErrorUpdate
            
            if(errorUpdate.isEmpty()){ 
                 System.debug('error update is empty');
                //if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule__c'.toLowerCase())=='0'){
                     if(!dmList[0].DM_Repayment_Schedules__r.isEmpty())
                        insertRepaySchedule(dmList[0].DM_Repayment_Schedules__r,parentId);system.debug('insertRepaySchedule done........');
            }//END Empty ErrorUpdate
            
            /*if(errorUpdate.isEmpty()){ 
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Accrual_Entry__c'.toLowerCase())=='0'){
                     if(!dmList[0].DM_Accrual_Entrys__r.isEmpty()){
                        insertAccruals(dmList[0].DM_Accrual_Entrys__r,parentId);
                     }   
                }
                else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Accrual_Entry__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Accrual_Entry__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Accrual_Entry__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Accrual_Entry__c'.toLowerCase());
                        system.debug('className '+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Accrual_Entry__c> computedList = dm_strategy.computeAccrual(contractId);
                            system.debug('return list Acrrual Entry'+computedList);
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
                        insertIPT(dmList[0].DM_Interest_Posting_Transactions__r,parentId);
                     }   
                }
                else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Interest_Posting_Transaction__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Interest_Posting_Transaction__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Interest_Posting_Transaction__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Interest_Posting_Transaction__c'.toLowerCase());
                        system.debug('className '+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Interest_Posting_Transaction__c> computedList = dm_strategy.computeIPT(contractId);
                            system.debug('return IPT list '+computedList);
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
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Investment_Order__c'.toLowerCase())=='0'){
                     if(!dmList[0].DM_Investment_Orders__r.isEmpty()){
                        insertInvestorLoan(dmList[0].DM_Investment_Orders__r,parentId);
                     }   
                }
                else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Investment_Order__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Investment_Order__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Investment_Order__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule__c'.toLowerCase());
                        system.debug('className '+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Investment_Order__c> computedList = dm_strategy.computeInvestorLoan(contractId);
                            system.debug('return list invOrder'+computedList);
                            if(!computedList.isEmpty()){     
                                insertInvestorLoan(computedList,parentId);
                            }    
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000 */
            //}//END Empty ErrorUpdate
			
			/*pallavi*/
			/*if(errorUpdate.isEmpty()){ 
				if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Disbursal_Transaction_Distribution__c'.toLowerCase())=='0'){
                    /*if(!dmList[0].DM_Disbursal_Transaction_Distributions__r.isEmpty()){
                            insertDDT(dmList[0].DM_Disbursal_Transaction_Distributions__r,parentId);
                    }*/
					/*DM_SqlQueryGenerator sqlQuery = new DM_SqlQueryGenerator(); 
                    String query1 = sqlQuery.GetQueryStringTemp1('DM_Disbursal_Transaction_Distribution__c',parentId,dmLDTIds);
                    List<DM_Disbursal_Transaction_Distribution__c> childDMDDTList = Database.query(query1);
                    System.debug('dmLDTIds' + dmLDTIds);	//pallavi
                    System.debug('Database.query(query1)' + query1);	//pallavi
                    System.debug('!childDMDDTList.isEmpty()' + !childDMDDTList.isEmpty());	//pallavi
                    if(!childDMDDTList.isEmpty()){
                        System.debug('childDMDDTList is not empty');	//pallavi
                        insertDDT(childDMDDTList ,parentId);
                    }
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Disbursal_Transaction_Distribution__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Disbursal_Transaction_Distribution__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Disbursal_Transaction_Distribution__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Disbursal_Transaction_Distribution__c'.toLowerCase());
                        system.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Disbursal_Transaction_Distribution__c> computedList = dm_strategy.computeDDI(contractId);
                            system.debug('return list '+computedList);
                            if(!computedList.isEmpty()){
                                insertDDT(computedList,parentId);
                            }    
                        }else{
                             errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                } //Strategy Check - 1000
            }//End IF error Update*/
            if(errorUpdate.isEmpty()){ 
					DM_SpecificObjects_SqlQueryGenerator sqlQuery = new DM_SpecificObjects_SqlQueryGenerator();
                    System.debug('dmLPTIds----' + dmLPTIds);
                    String query1 = sqlQuery.GetQueryStringTemp2('DM_Due_Payment__c',parentId,dmLPTIds);
                    List<DM_Due_Payment__c> childDMDPTList = Database.query(query1);
                
                	System.debug('childDMDPTList----' + childDMDPTList);
                    
                    List<loan__Due_Payment__c> duePay = [Select id,External_id__c from loan__Due_Payment__c where
                                                         loan__Loan_Payment_Transaction__r.external_id__c IN :dmLPTExtIds
                                                         And ToBeDeleted__c = false];
                
                	Set<String> dyePayExtid = new Set<String>();
                    for(loan__Due_Payment__c temp : duePay)
                        dyePayExtid.add(temp.External_id__c);
                
					List<DM_Due_Payment__c> finalchildDMDPTList = new List<DM_Due_Payment__c>();
                
                	for(DM_Due_Payment__c temp : childDMDPTList){
                    	if(!dyePayExtid.contains(temp.DM_External_Id__c))
                            finalchildDMDPTList.add(temp);
                	}
                        
                    if(!finalchildDMDPTList.isEmpty()){
                        
                        insertDPT(childDMDPTList ,parentId);
                    }
                /*}else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Due_Payment__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Due_Payment__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Due_Payment__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Due_Payment__c'.toLowerCase());
                        system.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Due_Payment__c> computedList = dm_strategy.computeDPT(contractId);
                            system.debug('return list '+computedList);
                            if(!computedList.isEmpty()){
                                insertDPT(computedList,parentId);
                            }    
                        }else{
                             errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                } //Strategy Check - 1000*/
            }//End IF error Update
		/*pallavi*/
		
		/*pallavi*/
			/*if(errorUpdate.isEmpty()){ 
				if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Multi_Step_Loan_Setup__c'.toLowerCase())=='0'){
                    System.debug('DM_Rate_Schedule_Setups__r');
                    System.debug('dmList[0].DM_Rate_Schedule_Setups__r.isEmpty() ' + dmList[0].DM_Rate_Schedule_Setups__r.isEmpty());
                    if(!dmList[0].DM_Rate_Schedule_Setups__r.isEmpty()){
                            insertRSS(dmList[0].DM_Rate_Schedule_Setups__r,parentId);
                    }
		    }
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Multi_Step_Loan_Setup__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Multi_Step_Loan_Setup__c'.toLowerCase()) 
                        && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Multi_Step_Loan_Setup__c'.toLowerCase())<>null){
                        
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Multi_Step_Loan_Setup__c'.toLowerCase());
                        system.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Multi_Step_Loan_Setup__c> computedList = dm_strategy.computeMSLS(contractId);
                            system.debug('return list '+computedList);
                            if(!computedList.isEmpty()){
                                insertRSS(computedList,parentId);
                            }    
                        }else{
                             errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
            }//End IF error Update
		/*pallavi*/
            
           /* if(errorUpdate.isEmpty()){ 
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Investor_Loan_Transaction__c'.toLowerCase())=='0'){
                    DM_SqlQueryGenerator sqlQuery = new DM_SqlQueryGenerator(); 
                    String query1 = sqlQuery.GetQueryStringTemp('DM_Investor_Loan_Transaction__c',parentId,dmIOIds);
                    List<DM_Investor_Loan_Transaction__c> childDMInvOrderList = Database.query(query1);
                    if(!childDMInvOrderList.isEmpty()){
                        insertInvestorLoanTransaction(childDMInvOrderList ,parentId);
                    }
                }
                /*else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Investor_Loan_Transaction__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Investor_Loan_Transaction__c'.toLowerCase()) && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Investor_Loan_Transaction__c'.toLowerCase())<>null){
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule__c'.toLowerCase());
                        system.debug('className '+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Investor_Loan_Transaction__c> computedList = dm_strategy.computeInvLT(contractId);
                            system.debug('return list invLoanTransaction'+computedList);
                            if(!computedList.isEmpty())     
                                insertInvestorLoanTransaction(computedList,parentId);
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000 */
           // }//END Empty ErrorUpdate
        
        if(!errorUpdate.isEmpty()){
            update errorUpdate;
        }else{
            Dm_Loan_Account__c dmLoan = new Dm_loan_Account__c(Id= dmList[0].Id, migration_status__c='Success', DM_Error__c='', DM_Invalid_Data__c=false, DM_Is_Migrated__c=True, Migrated_CL_Contract__C=parentId);
            update dmLoan;
        }
    }//Data Creation
    
    //Method will insert Repayment Schedule Summary
    private void insertRepaymentSS(List<DM_Repayment_Schedule_Summary__c> dm_Rss, Id parentId){
        loan__Repayment_Schedule_Summary__c rss;
        DM_SpecificObjects_MigrationHandler dmHandler = new DM_SpecificObjects_MigrationHandler();
        List<loan__Repayment_Schedule_Summary__c> rssList = new List<loan__Repayment_Schedule_Summary__c>();
        if(!dm_Rss.isEmpty()){
               rssList = dmHandler.DM_StaticFieldMapping_rss(dm_rss,parentId);
               system.debug('rss'+rss);
            try{
                if(!rssList.isEmpty()){System.debug('inserting rss... ');
                    //Create SavePoint
                    insert rssList;System.debug('inserting rss... done');
                }     
            }catch(Exception ex){System.debug('inserting rss failed... ');
                errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - RSS - '+ ex.getMessage(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
                Database.rollback(sp);
            }//END Catch   
         }
    }//insertRepaymentSS
    
    //Method will insert Loan Disbursal Transaction
    /*private void insertLDT(List<dm_Loan_Disbursal_Transaction__c> dm_ldt, Id parentId){
        loan__Loan_Disbursal_Transaction__c ldt;
        DM_SpecificObjects_MigrationHandler dmHandler = new DM_SpecificObjects_MigrationHandler();
        List<loan__Loan_Disbursal_Transaction__c> ldtList = new List<loan__Loan_Disbursal_Transaction__c>();
        if(!dm_ldt.isEmpty()){
			for(dm_Loan_Disbursal_Transaction__c dmLdt : dm_ldt){
                dmLDTIds.add(dmLdt.Id);
            } 
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
    }*///END insertLDT
    
    //Method will insert Loan Payment Transactions
    private void insertLPT(List<dm_Loan_Payment_Transaction__c> dm_lpt, Id parentId){
        loan__Loan_Payment_Transaction__c lpt;
        DM_SpecificObjects_MigrationHandler dmHandler = new DM_SpecificObjects_MigrationHandler();
        List<loan__Loan_Payment_Transaction__c> lptList = new List<loan__Loan_Payment_Transaction__c>();
        if(!dm_lpt.isEmpty()){
            for(dm_Loan_Payment_Transaction__c dmlpt : dm_lpt){
               dmlptIds.add(dmlpt.Id);
               dmLPTExtIds.add(dmlpt.DM_External_Id__c);
            }
               
            lptList = dmHandler.DM_StaticFieldMapping_lpt(dm_lpt,parentId);
            try{
                if(!lptList.isEmpty()){
                    //Create SavePoint
                    //System.debug('--------------!lptList.isEmpty()11111------------------');	//remove
                    insert lptList;system.debug('insertLPT... record inserted............');
                }   
                if(!lptList.isEmpty()){
                   // System.debug('--------------!lptList.isEmpty()22222------------------');	//remove
                    for(loan__Loan_Payment_Transaction__c tempLpt: lptList){
                       // System.debug('-------------tempLpt.External_Id__c--------' + tempLpt.External_Id__c);	//remove
                       // System.debug('-------------tempLpt.Id--------' + tempLpt.Id);	//remove
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
    /*private void insertDDT(List<DM_Disbursal_Transaction_Distribution__c> dm_ddt, Id parentId){
        loan__Disbursal_Txn_Distribution__c ddt;
        DM_SpecificObjects_MigrationHandler dmHandler = new DM_SpecificObjects_MigrationHandler();
        List<loan__Disbursal_Txn_Distribution__c> ddtList = new List<loan__Disbursal_Txn_Distribution__c>();
        Set<Id> ddtIds = new Set<Id>();
        System.debug('!dm_ddt.isEmpty()' + !dm_ddt.isEmpty());	//pallavi
        if(!dm_ddt.isEmpty()){
            System.debug('dm_ddt is not empty');	//pallavi
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
    }*///END insertDDT
	/*pallavi*/
	
	/*pallavi*/
	//Method will insert Rate Schedule Setup
    /*private void insertRSS(List<DM_Multi_Step_Loan_Setup__c> dm_rss, Id parentId){
        loan__Multi_Step_Loan_Setup__c rss;
        DM_SpecificObjects_MigrationHandler dmHandler = new DM_SpecificObjects_MigrationHandler();
        List<loan__Multi_Step_Loan_Setup__c> rssList = new List<loan__Multi_Step_Loan_Setup__c>();
        Set<Id> rssIds = new Set<Id>();
        if(!dm_rss.isEmpty()){
            for(DM_Multi_Step_Loan_Setup__c dmrss : dm_rss)
               rssIds.add(dmrss.Id);
               
            rssList = dmHandler.DM_StaticFieldMapping_MSLS(dm_rss,parentId);
            List<loan__Multi_Step_Loan_Setup__c> rssList1 = new List<loan__Multi_Step_Loan_Setup__c>();	//pallavi
            
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
    }*///END insertDDT
	/*pallavi*/
	/*pallavi*/
	//Method will insert due payment
    private void insertDPT(List<DM_Due_Payment__c> dm_dpt, Id parentId){
        loan__Due_Payment__c dpt;
        DM_SpecificObjects_MigrationHandler dmHandler = new DM_SpecificObjects_MigrationHandler();
        List<loan__Due_Payment__c> dptList = new List<loan__Due_Payment__c>();
        Set<Id> dptIds = new Set<Id>();
        System.debug('!dm_dpt.isEmpty()' + !dm_dpt.isEmpty());	//pallavi
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
    
    //Method will insert Bills
    private void insertBill(List<DM_Bill__c> dm_Bill, Id parentId){
        loan__Loan_account_Due_Details__c bill;
        DM_SpecificObjects_MigrationHandler dmHandler = new DM_SpecificObjects_MigrationHandler();
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
  
    //Method will insert Automated Payment Setup
    /*private void insertAPS(List<DM_Automated_Payment_Setup__c> dm_APS, Id parentId){
        loan__Automated_Payment_Setup__c APS;
        DM_SpecificObjects_MigrationHandler dmHandler = new DM_SpecificObjects_MigrationHandler();
        List<loan__Automated_Payment_Setup__c> APSList = new List<loan__Automated_Payment_Setup__c>();
        if(!dm_APS.isEmpty()){
            APSList = dmHandler.DM_StaticFieldMapping_aps(dm_Aps,parentId);
             
            try{
                if(!APSList.isEmpty()){
                    //Create SavePoint
                    system.debug('APS BI');
                    insert APSList;
                    system.debug('APS AI');
                }     
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - APS - '+ ex.getMessage(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
                Database.rollback(sp);
            }//END Catch   
         }
    }*///END insertAPS
    
    //Method will Insert Repayment Schedule
    private void insertRepaySchedule(List<DM_Repayment_Schedule__c> dm_RepaySch, Id parentId){
        System.debug('insertRepaySchedule');
        System.debug('dm_RepaySch----' + dm_RepaySch);
        loan__Repayment_Schedule__c repaySch;
        DM_SpecificObjects_MigrationHandler dmHandler = new DM_SpecificObjects_MigrationHandler();
        List<loan__Repayment_Schedule__c> repaySchList = new List<loan__Repayment_Schedule__c>();
        if(!dm_RepaySch.isEmpty()){
            repaySchList = dmHandler.DM_StaticFieldMapping_RepaySCH(dm_RepaySch,parentId);
            try{
                if(!repaySchList.isEmpty()){
                    //Create SavePoint
                    insert repaySchList;
                    List<loan__Repayment_Schedule__c> repaySchList1 = new List<loan__Repayment_Schedule__c>();	//pallavi
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
    /*private void insertAccruals(List<DM_Accrual_Entry__c> dmAcrList, Id parentId){
        loan__Accrual_Entry__c loanAcr;
        DM_SpecificObjects_MigrationHandler dmHandler = new DM_SpecificObjects_MigrationHandler();
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
    }*///END insertAccrual
    
    //Method will Insert Investor Loan
    /*private void insertInvestorLoan(List<DM_Investment_Order__c> dmInvList, Id parentId){
        loan__Investor_Loan__c loanInv;
        DM_SpecificObjects_MigrationHandler dmHandler = new DM_SpecificObjects_MigrationHandler();
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
    }*///END insertInvestorLoan
    
    //Method will Insert investor Loan Transaction
    /*private void insertInvestorLoanTransaction(List<DM_Investor_Loan_Transaction__c> dm_ILTList, Id parentId){
        loan__Investor_Loan_Account_Txns__c loanInvLT;
        DM_SpecificObjects_MigrationHandler dmHandler = new DM_SpecificObjects_MigrationHandler();
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
    }*///END insertInvestorLoanTransaction
    /*pallavi*/
}//END DM_SpecificObjects_Data_Creation