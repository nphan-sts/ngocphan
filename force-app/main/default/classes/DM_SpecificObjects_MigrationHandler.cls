/*
 * 
 * 
 * @author = Pallavi
 */
public with sharing class DM_SpecificObjects_MigrationHandler 
    {
      public static String productType;
      public static Map<String,String> dmLPTIdExternalIdMap = new Map<String,String>();
      public static Map<String,String> dmInvOrderIdExternalIdMap = new Map<String,String>();
      public static Map<String,String> dmLDTIdExternalIdMap = new Map<String,String>();     //pallavi
      public static Map<String,String> dmBILLExternalIdMap = new Map<String,String>();     //pallavi
      public DM_Metadata_Config_Wrapper configWrapper1 = ParserUtil.getParser();    //pallavi
        
      public void DM_FieldMapping_LoanAccount(DM_Loan_Account__c scope)
      {
        //System.debug('inside DM_FieldMapping_LoanAccount');
        if(scope !=null)
        {
              productType=scope.Product_Type__c;
        }
      }
      
    //Method will do Static and Dynamic field mapping for Loan Disbursal Transaction
    /*public List<loan__Loan_Disbursal_Transaction__c> DM_StaticFieldMapping_ldt(List<DM_Loan_Disbursal_Transaction__c> scopeList, Id parentId)
      {
        //System.debug('inside DM_StaticFieldMapping_ldt');
        loan__Loan_Disbursal_Transaction__c ldt;
        List<loan__Loan_Disbursal_Transaction__c> ldtList = new List<loan__Loan_Disbursal_Transaction__c>();
        if(!scopeList.isEmpty())
        {
              for(DM_Loan_Disbursal_Transaction__c scope : scopeList){
                  ldt = new loan__Loan_Disbursal_Transaction__c();
                  ldt.loan__Loan_Account__c = parentId;
                  ldt.loan__ACH_Filename__c =  scope.DM_ACH_Filename__c;
                  ldt.loan__Archived__c  =  scope.DM_Archived__c;
                  ldt.loan__Bank_Account__c = scope.DM_Bank_Account__c;
                  ldt.loan__Check__c = scope.DM_Check__c;
                  ldt.loan__Cleared__c = scope.DM_Cleared__c ;
                  ldt.loan__Contribution_From_Excess__c = scope.DM_Contribution_From_Excess__c;
                  ldt.loan__Custom_Logic__c = scope.DM_Custom_Logic__c;
                  ldt.loan__Disbursal_Date__c = scope.Dm_Disbursal_Date__c;
                  ldt.loan__Disbursal_Time__c = scope.DM_Disbursal_Time__c;
                  ldt.loan__Disbursed_Amt__c = scope.DM_Disbursed_Amt__c;
                  ldt.External_Id__c = scope.DM_External_Id__c;
                  ldt.loan__Loan_Disbursal_Transaction_Type__c = scope.DM_Loan_Disbursal_Transaction_Type__c;
                  ldt.loan__Financed_Amount__c = scope.DM_Financed_Amount__c;
                  ldt.loan__Interest_Rate__c = scope.DM_Interest_Rate__c;
                  ldt.loan__Internal_Accounting_Generated__c = scope.DM_Internal_Accounting_Generated__c;
                  ldt.loan__Loan_Snapshot__c = scope.DM_Loan_Snapshot__c;
                  ldt.loan__Master_Archive_Object__c = scope.DM_Master_Archive_Object__c;
                  ldt.loan__Mode_of_Payment__c = scope.Dm_Mode_Of_Payment__c;
                  ldt.loan__Number_Of_Interest_Only_Payments__c = scope.DM_Number_Of_Interest_Only_Payments__c;
                  ldt.loan__Reference__c = scope.DM_Reference__c;
                  ldt.loan__Rejected__c = scope.DM_Rejected__c;
                  ldt.loan__Reversed__c = scope.DM_Reversed__c;
                  ldt.loan__Sent_To_ACH__c = scope.DM_Sent_To_ACH__c;
                  ldt.loan__Sent_To_ACH_On__c = scope.DM_Sent_To_ACH_On__c;
                  ldt.loan__Summary__c = scope.DM_Summary__c;
                  ldt.loan__Summary_Record_Id__c = scope.DM_Summary_Record_Id__c;
                  ldt.loan__Pre_Paid_Fee__c = scope.DM_Pre_Paid_Fee__c;
                  ldt.loan__Refinanced_Amount__c = scope.DM_Refinanced_Amount__c;
                  if(scope.DM_Refinanced_Amount__c == null)	//pallavi
                      ldt.loan__Refinanced_Amount__c = 0;	//pallavi
                  dmLDTIdExternalIdMap.put(scope.Id, scope.DM_External_Id__c);  //pallavi
                  DM_DynamicFieldMapping(scope,ldt,productType);
                  ldtList.add(ldt);
             }   
        }
         return ldtList;
      }*/
      
      //Method will do Static and Dynamic field mapping for Loan Payment Transaction
      public List<loan__Loan_Payment_Transaction__c> DM_StaticFieldMapping_lpt(List<DM_Loan_Payment_Transaction__c> scopeList,Id parentId)
      {
        system.debug('inside DM_StaticFieldMapping_lpt');
        List<loan__Loan_Payment_Transaction__c> lptList = new List<loan__Loan_Payment_Transaction__c>();
        loan__Loan_Payment_Transaction__c lpt;
      
        if(!scopeList.isEmpty())
        {
             /*pallavi(temporary) because txn date is null in staging object*/
            /* List<DM_Due_Payment__c> due = [Select id,DM_Due__r.DM_Payment_Date__c,DM_Due__c,DM_Loan_Payment_Transaction__r.id from 
                                            DM_Due_Payment__c where DM_Loan_Payment_Transaction__c =: scopeList];
             Map<id,Date> txnDate = new Map<Id,Date>();
             for(DM_Due_Payment__c temp : due)
                 txnDate.put(temp.DM_Loan_Payment_Transaction__r.id,temp.DM_Due__r.DM_Payment_Date__c); */
            /*pallavi(temporary)*/  
              for(DM_Loan_Payment_Transaction__c scope :scopeList){
                  lpt = new loan__Loan_Payment_Transaction__c();
                  lpt.loan__Loan_Account__c = parentId;
                  lpt.loan__Payment_Mode__c =  scope.DM_Payment_Mode__c;
                  lpt.loan__Transaction_Amount__c  =  scope.DM_Transaction_Amount__c;
                  lpt.loan__Receipt_Date__c = scope.DM_Receipt_Date__c;
                  lpt.loan__Cleared__c = scope.DM_Cleared__c ;
                  lpt.loan__Rejected__c = scope.DM_Rejected__c;
                  lpt.loan__Reversed__c = scope.DM_Reversed__c;
                  lpt.loan__Principal__c = scope.DM_Principal__c;
                  lpt.loan__Interest__c = scope.DM_Interest__c;
                  lpt.loan__Fees__c = scope.DM_Fees__c;
                  lpt.loan_Is_Migrated__c = scope.DM_Is_Migrated__c;
                  lpt.loan_Migrated_Reversal_Date__c = scope.DM_Migrated_Reversal_Date__c;
                  lpt.loan__transaction_date__c = scope.DM_Transaction_Date__C;
                  lpt.loan__transaction_time__c = scope.DM_Transaction_time__C;
                  lpt.loan__transaction_Creation_Date__c = scope.DM_Transaction_Creation_Date__c;
                  lpt.LAPro_Posted_Date__c = scope.DM_LAPro_Posted_Date__c; //pallavi
                  lpt.External_Id__c=scope.DM_External_Id__c;
                  lpt.loan__Clearing_Date__c = scope.DM_clearing_date__c;   //pallavi
                  System.debug('scope.id----' + scope.id);  //pallavi
                 /* System.debug('scope.id date----' + txnDate.get(scope.id));  //pallavi
                  if(lpt.loan__transaction_date__c == null)
                    lpt.loan__transaction_date__c = txnDate.get(scope.id);*/        //pallavi(temporary) because txn date is null in staging object
                  // lpt.loan__Receipt_ID__c = scope.DM_Receipt_ID__c; -  Field is not writeable: loan__Loan_Payment_Transaction__c.loan__Receipt_ID__c
                  dmLPTIdExternalIdMap.put(scope.Id, scope.DM_External_Id__c);
                  DM_DynamicFieldMapping(scope,lpt,productType);
                  lptList.add(lpt);
              }
        }
          return lptList;
      }//END DM_StaticFieldMapping_lpt
      
      //Method will do Static and Dynamic field mapping for Bill
      public List<loan__Loan_account_Due_Details__c> DM_StaticFieldMapping_bill(List<DM_Bill__c> scopeList,Id parentId)
      {
        system.debug('inside DM_StaticFieldMapping_bill');
        List<loan__Loan_account_Due_Details__c> billList = new List<loan__Loan_account_Due_Details__c>();
        loan__Loan_account_Due_Details__c bill;
        if(!scopeList.isEmpty())
        {
              for(DM_Bill__c scope :scopeList){
                  bill = new loan__Loan_account_Due_Details__c();
                  bill.loan__Loan_Account__c = parentId;
                  bill.External_Id__c = scope.DM_External_Id__c;
                  bill.loan__Transaction_Date__c =  scope.DM_Transaction_Date__c;
                  bill.loan__Due_Date__c  =  scope.DM_Due_Date__c;
                  bill.loan__Due_Amt__c = scope.DM_Due_Amt__c;
                  bill.loan__Payment_Amt__c = scope.DM_Payment_Amt__c ;
                  bill.loan__Payment_Satisfied__c = scope.DM_Payment_Satisfied__c;
                  bill.loan__Due_Type__c = scope.DM_Due_Type__c;
                  bill.loan__Payment_Date__c = scope.DM_Payment_Date__c;
                  bill.loan__DD_Primary_Flag__c = scope.DM_DD_Primary_Flag__c;
                  bill.loan__Due_Type_Description__c = scope.DM_Due_Type_Description__c;    //pallavi
                  bill.loan__Interest_Billed__c = scope.DM_Interest_Billed__c;  //pallavi
                  bill.loan__Principal_Billed__c = scope.DM_Principal_Billed__c;    //pallavi
                  dmBILLExternalIdMap.put(scope.Id, scope.DM_External_Id__c);  //pallavi
                  bill.loan__Interest_Paid__c = scope.DM_Interest_Paid__c;  //pallavi
                  bill.loan__Principal_Paid__c = scope.DM_Principal_Paid__c;    //pallavi
                  DM_DynamicFieldMapping(scope,bill,productType);
                  billList.add(bill);
              }    
        }
          return billList;
      }//END DM_StaticFieldMapping_bill
        
       //Method will do Static and Dynamic field mapping for Repayment Schedule
       public List<loan__Repayment_Schedule__c> DM_StaticFieldMapping_RepaySCH(List<DM_Repayment_Schedule__c> scopeList,Id parentId)
      {
        loan__Repayment_Schedule__c repaySch;
        List<loan__Repayment_Schedule__c> repaySchList = new List<loan__Repayment_Schedule__c>();
        if(!scopeList.isEmpty())
        {
            for(DM_Repayment_Schedule__c scope : scopeList){
              repaySch = new loan__Repayment_Schedule__c();
              repaySch.loan__Loan_Account__c = parentId;
              repaySch.loan__Due_Date__c = scope.DM_Due_Date__c;
              repaySch.loan__Due_Principal__c = scope.DM_Due_Principal__c;
              repaySch.loan__Due_Interest__c = scope.DM_Due_Interest__c;
              repaySch.loan__Balance__c = scope.DM_Balance__c;
              repaySch.External_Id__c = scope.DM_External_Id__c;
              repaySch.loan__Is_Billed__c = scope.DM_Is_Billed__c;  //pallavi
              repaySch.loan__isPaid__c = scope.DM_isPaid__c;    //pallavi
              repaySch.loan__Paid_Interest__c = scope.dm_Paid_Interest__c;	//pallavi
              repaySch.loan__Paid_Principal__c = scope.dm_Paid_Principal__c;	//pallavi
              if(repaySch.loan__Is_Billed__c == true)		//temp
                  repaySch.loan__Is_Posted__c = true;
              DM_DynamicFieldMapping(scope,repaySch,productType);  
              repayschList.add(repaySch);  
            }              
        }
          return repaySchList;
      }//END DM_StaticFieldMapping_RepaySCH
      
      //Method will do Static and Dynamic field mapping for Repayment Schedule Summary
       public List<loan__Repayment_Schedule_Summary__c> DM_StaticFieldMapping_rss(List<DM_Repayment_Schedule_Summary__c> scopeList,Id parentId)
      {
        system.debug('inside DM_StaticFieldMapping_RSS');
        loan__Repayment_Schedule_Summary__c rps;
        List<loan__Repayment_Schedule_Summary__c> rpsList = new List<loan__Repayment_Schedule_Summary__c>();
        if(!scopeList.isEmpty())
        {     
            for(DM_Repayment_Schedule_Summary__c scope : scopeList){
              rps = new loan__Repayment_Schedule_Summary__c();
              rps.loan__RSS_Loan_Account__c = parentId;
              rps.loan__RSS_Seq__c =  scope.DM_RSS_Seq__c;
              rps.External_Id__c = scope.DM_External_Id__c;
              rps.loan__RSS_Repayment_Dt__c  =  scope.DM_RSS_Repayment_Dt__c;
              rps.loan__RSS_Repayment_Amt__c  =  scope.DM_RSS_Repayment_Amt__c;
              rps.loan__RSS_No_Of_Pmts__c  =  scope.DM_RSS_No_Of_Pmts__c;
              DM_DynamicFieldMapping(scope,rps,productType);
              rpsList.add(rps);
           }    
        }
          return rpsList;
      }//END DM_StaticFieldMapping_rss
      
      //Method will do Static and Dynamic field mapping for Automated Payment Setup
       /*public List<loan__Automated_Payment_Setup__c> DM_StaticFieldMapping_aps(List<DM_Automated_Payment_Setup__c> scopeList,Id parentId)
      {
        system.debug('inside DM_StaticFieldMapping_APS');
        loan__Automated_Payment_Setup__c aps;
        List<loan__Automated_Payment_Setup__c> apsList = new List<loan__Automated_Payment_Setup__c>();
        if(!scopeList.isEmpty())
        {
            for(DM_Automated_Payment_Setup__c scope :scopeList){
              aps = new loan__Automated_Payment_Setup__c();
              aps.loan__CL_Contract__c = parentId;
              aps.loan__Bank_Account__c =  scope.DM_Bank_Account__c;
              aps.loan__Debit_Date__c  =  scope.DM_Debit_Date__c;
              aps.loan__Transaction_Amount__c  =  scope.DM_Transaction_Amount__c;
              aps.External_Id__c = scope.DM_External_Id__c;
              aps.loan__Type__c  =  scope.DM_Type__c;
              aps.loan__Amount_Type__c = scope.DM_Amount_Type__c;
              aps.loan__Payment_Mode__c =  scope.DM_Payment_Mode__c;
              aps.loan__Active__c  =  scope.DM_Active__c;
              aps.loan__Frequency__c  =  scope.DM_Frequency__c;
              aps.loan__Debit_Day__c  =  scope.DM_Debit_Day__c;
              aps.loan__Recurring_ACH_Start_Date__c  =  scope.DM_Recurring_ACH_Start_Date__c;
              //aps.loan_Second_Payment_Date__c  =  scope.DM_Second_Payment_Date__c;
              //call Method
                if(scope.DM_Payment_Mode__c == null){   //fixing data problem
                    if(productType == 'Manual Payer'){
                        loan__Payment_Mode__c mode = [Select id from loan__Payment_Mode__c where name = 'Cash'];
                        aps.loan__Payment_Mode__c = mode.id;
                    }
                    if(productType == 'Auto Payer'){
                        loan__Payment_Mode__c mode = [Select id from loan__Payment_Mode__c where name = 'ACU ACH'];
                        aps.loan__Payment_Mode__c = mode.Id;
                    }
                    if(test.isRunningTest()){
                       loan__Payment_Mode__c mode = [Select id from loan__Payment_Mode__c where name = 'Cash'];
                       aps.loan__Payment_Mode__c = mode.id; 
                    }
                }
              DM_DynamicFieldMapping(scope,aps,productType);
              apsList.add(aps);
            }
        }
          return apsList;
      }*///END DM_StaticFieldMapping_aps
      
      //Method will do Static and Dynamic field mapping for Accruals
      /*public List<loan__Accrual_Entry__c> DM_StaticFieldMapping_Accruals(List<DM_Accrual_Entry__c> dmAccrList,Id parentId)
      {
        system.debug('inside DM_StaticFieldMapping_Accruals');
        List<loan__Accrual_Entry__c> accrList = new List<loan__Accrual_Entry__c>();
        loan__Accrual_Entry__c accr;
        if(!dmAccrList.isEmpty())
        {     
              for(DM_Accrual_Entry__c dmAccr: dmAccrList){
                accr = new loan__Accrual_Entry__c();
                accr.loan__Accounting_Entry__c=dmAccr.DM_Accounting_Entry__c;
                accr.External_Id__c = dmAccr.DM_External_Id__c;
                accr.loan__Amount__c=dmAccr.DM_Amount__c;
                accr.loan__Archived__c=dmAccr.DM_Archive__c;
                accr.loan__Loan_Account__c=parentId;
                accr.loan__GL_Posted__c=dmAccr.DM_GL_Posted__c;
                accr.loan__Internal_Accounting_Generated__c=dmAccr.DM_Internal_Accounting_Generated__c;
                accr.loan__Internal_Accounting_Reversal_Generated__c=dmAccr.Internal_Accounting_Reversal_Generated__c;
                accr.loan__Master_Archive_Object__c=dmAccr.DM_Master_Archive_Object__c;
                accr.loan__Transaction_Date__c=dmAccr.DM_Transaction_Date__c;
                DM_DynamicFieldMapping(dmAccr,accr,productType);
                accrList.add(accr);
              }  
        }
          return accrList;
      }*///END DM_StaticFieldMapping_Accruals
      
      //Method will do Static and Dynamic field mapping for Investor Loan
      /*public List<loan__Investor_Loan__c> DM_StaticFieldMapping_InvestorLoan(List<DM_Investment_Order__c> dmOrderList,Id parentId)
      {
        system.debug('inside DM_StaticFieldMapping_InvestorLoan');
        loan__Investor_Loan__c invOrder;
        List<loan__Investor_Loan__c> invOrderList = new List<loan__Investor_Loan__c>();
        if(!dmOrderList.isEmpty())
        {
           for(DM_Investment_Order__c dmOrder : dmOrderList){
            invOrder = new loan__Investor_Loan__c();
            invOrder.loan__Account__c=dmOrder.DM_Account__c;
            invOrder.loan__Inv_Accrued_Interest_Amt__c=dmOrder.DM_Accrued_Interest__c;
            invOrder.loan__Amortization_Schedule_Generation_time__c=dmOrder.DM_Amortization_Schedule_Generation_time__c;
            invOrder.loan__Approval_Date__c=dmOrder.DM_Approval_Date__c;
            invOrder.loan__Archived__c=dmOrder.DM_Archive__c;
            invOrder.loan__Buying_Price__c=dmOrder.DM_Buying_Price__c;
            invOrder.loan__Certificate_Rate__c=dmOrder.DM_Certificate_Rate__c;
            invOrder.loan__Charged_Off_Date__c=dmOrder.DM_Charged_Off_Date__c;
            invOrder.loan__Charged_Off_Fees__c=dmOrder.DM_Charged_Off_Fees__c;
            if(dmOrder.DM_Charged_Off_Fees__c == null)	//pallavi
                invOrder.loan__Charged_Off_Fees__c = 0;
            invOrder.loan__Charged_Off_Interest__c=dmOrder.DM_Charged_Off_Interest__c;	
            if(dmOrder.DM_Charged_Off_Interest__c == null)	//pallavi
                invOrder.loan__Charged_Off_Interest__c = 0;
            invOrder.loan__Charged_Off_Principal__c=dmOrder.DM_Charged_Off_Principal__c;	//pallavi
            if(dmOrder.DM_Charged_Off_Principal__c == null)
                invOrder.loan__Charged_Off_Principal__c = 0;
            invOrder.loan__Collect_Service_Fees_On__c=dmOrder.DM_Collect_Service_Fees_On__c;
            if(dmOrder.DM_Collect_Service_Fees_On__c == null)	//pallavi
                invOrder.loan__Collect_Service_Fees_On__c = 'Interest;Fees';
            invOrder.loan__Loan_Delinquent_Days__c=dmOrder.DM_Created_Loan_Delinquent_Days__c;
            invOrder.loan__Loan_Principal_Remaining__c=dmOrder.DM_Created_Loan_Principal_Remaining__c;
            invOrder.loan__Loan_Status__c=dmOrder.DM_Created_Loan_Status__c;
            invOrder.loan__Discount_Percent__c=dmOrder.DM_Discount_Percent__c;
            if(dmOrder.DM_Discount_Percent__c == null)	//pallavi
                invOrder.loan__Discount_Percent__c = 0;
            invOrder.loan__Enabled_Flag__c=dmOrder.DM_Enabled__c;
            invOrder.loan__Investor_End_Date__c=dmOrder.DM_End_Date__c;
            invOrder.loan__Late_Fees_Amount_Paid__c=dmOrder.DM_Fees_Amount_Paid__c;
            if(dmOrder.DM_Fees_Amount_Paid__c == null)	//pallavi
                invOrder.loan__Late_Fees_Amount_Paid__c = 0;
            invOrder.loan__Generate_Amortization_Schedule__c=dmOrder.DM_Generate_Amortization_Schedule__c;
            invOrder.loan__Interest_Amount_Paid__c=dmOrder.DM_Interest_Amount_Paid__c;
            invOrder.loan__Interest_Exempted_From_Service_Fee__c=dmOrder.DM_Interest_Exempted_From_Service_Fee__c;
            if(dmOrder.DM_Interest_Exempted_From_Service_Fee__c == null)	//pallavi
               invOrder.loan__Interest_Exempted_From_Service_Fee__c = 0; 
            invOrder.loan__Inv_Interest_Posted_Amt__c=dmOrder.DM_Interest_Posted__c;
            if(dmOrder.DM_Interest_Posted__c == null)	//pallavi
               invOrder.loan__Inv_Interest_Posted_Amt__c = 0; 
            invOrder.loan__Interest_Rate_On_Due_Interest__c=dmOrder.DM_Interest_Rate_On_Due_Interest__c;
            if(dmOrder.DM_Interest_Rate_On_Due_Interest__c == null)	//pallavi
               invOrder.loan__Interest_Rate_On_Due_Interest__c = 0;
            invOrder.loan__Interest_Rate_On_Due_IOA__c=dmOrder.DM_Interest_Rate_On_Due_IOA__c;
            if(dmOrder.DM_Interest_Rate_On_Due_IOA__c == null)	//pallavi
               invOrder.loan__Interest_Rate_On_Due_IOA__c = 0;
            invOrder.loan__Interest_Rate_On_Due_Principal__c=dmOrder.DM_Interest_Rate_On_Due_Principal__c;
            if(dmOrder.DM_Interest_Rate_On_Due_Principal__c == null)	//pallavi
               invOrder.loan__Interest_Rate_On_Due_Principal__c = 0;
            invOrder.loan__Interest_Rate_On_Loan_Account__c=dmOrder.DM_Interest_Rate_On_Loan__c;
            invOrder.loan__Interest_Rounding_Error__c=dmOrder.DM_Interest_Rounding_Error__c;
            if(dmOrder.DM_Interest_Rounding_Error__c == null)	//pallavi
               invOrder.loan__Interest_Rounding_Error__c = 0;
            invOrder.loan__Service_Rate__c= 0;//dmOrder.DM_Interest_Service_Rate__c; pallavi(data fix)
            invOrder.loan__Investment_Amount__c=dmOrder.DM_Investment_Amount__c;
            invOrder.loan__Inv_IOA_Accrued__c=dmOrder.DM_IOA_Accrued__c;
            invOrder.loan__IOA_Amount_Paid__c=dmOrder.DM_IOA_Amount_Paid__c;
            invOrder.loan__Inv_IOA_Posted_Amt__c=dmOrder.DM_IOA_Posted__c;
            invOrder.loan__Inv_Last_Interest_Accrual_Post_Date__c=dmOrder.DM_Last_Interest_Accrual_Date__c;
            invOrder.loan__Loan__c=parentId;
            invOrder.loan__Master_Archive_Object__c=dmOrder.DM_Master_Archive_Object__c;
            invOrder.loan__Minimum_Service_Fee__c=dmOrder.DM_Minimum_Service_Fee__c!=null?dmOrder.DM_Minimum_Service_Fee__c:0;	//pallavi
            invOrder.loan__Principal_Amount_Paid__c=dmOrder.DM_Principal_Amount_Paid__c!=null?dmOrder.DM_Principal_Amount_Paid__c:0;    //pallavi
            invOrder.loan__Rebate_Amount_Paid__c=dmOrder.DM_Rebate_Amount_Paid__c!=null?dmOrder.DM_Rebate_Amount_Paid__c:0;	//pallavi
            invOrder.loan__Reinvest_Interest__c=dmOrder.DM_Reinvest_Interest__c;
            invOrder.loan__Reinvest_Principal__c=dmOrder.DM_Reinvest_Principal__c;
            invOrder.loan__Service_Charge_On_Full_Payment_Amount__c=dmOrder.DM_Service_Charge_On_Full_Payment_Amount__c;
            invOrder.loan__Share__c=dmOrder.DM_Share__c;
            invOrder.loan__Investor_Start_Date__c=dmOrder.DM_Start_Date__c;
            invOrder.loan__Status__c=dmOrder.DM_Status__c;
            invOrder.loan__Summary__c=dmOrder.DM_Summary__c;
            invOrder.loan__Summary_Record_Id__c=dmOrder.DM_Summary_Record_Id__c;
            invOrder.loan__Total_Amount_Paid__c=dmOrder.DM_Total_Amount_Paid__c!=null?dmOrder.DM_Total_Amount_Paid__c:0;    //pallavi
            invOrder.loan__Write_Off_Amount__c=dmOrder.DM_Write_Off_Amount__c!=null?dmOrder.DM_Write_Off_Amount__c:0;	//pallavi
            invOrder.loan__Investor_Amortization_Schedule_Generated__c=dmOrder.DM_Investor_Amortization_Schedule_Genera__c;
            invOrder.External_Id__c = dmOrder.DM_External_Id__c;
            dmInvOrderIdExternalIdMap.put(dmOrder.Id, dmOrder.DM_External_Id__c);
            //pallavi (for data fix)
               if(dmOrder.DM_Created_Loan_Principal_Remaining__c == null){
                   DM_Loan_Account__c temp = [Select id,DM_Loan_Amount__c from DM_Loan_Account__c where id =: dmOrder.DM_Loan__c];
                  invOrder.loan__Loan_Principal_Remaining__c=temp.DM_Loan_Amount__c;    
               }
            //pallavi
            DM_DynamicFieldMapping(dmOrder,invOrder,productType);
            InvOrderList.add(invOrder);
           }
        }
          return invOrderList;
      }*///END DM_StaticFieldMapping_InvOrder
      
      //Method will do Static and Dynamic field mapping for Investor Loan Transaction
      /*public List<loan__Investor_Loan_Account_Txns__c> DM_StaticFieldMapping_invLT(List<DM_Investor_Loan_Transaction__c> dmInvLTList,Id parentId){

        system.debug('inside DM_StaticFieldMapping_Accruals');
        loan__Investor_Loan_Account_Txns__c invLT;
        List<loan__Investor_Loan_Account_Txns__c> invLTList = new List<loan__Investor_Loan_Account_Txns__c>();
        if(!dmInvLTList.isEmpty())
        {
            for(DM_Investor_Loan_Transaction__c dmInvLT :dmInvLTList){
                InvLT = new loan__Investor_Loan_Account_Txns__c();
                InvLT.loan__SS_Inv_Accrued_Interest_Amt__c=dmInvLT.DM_Accrued_Interest_Snapshot__c;
                InvLT.loan__ACH_Filename__c=dmInvLT.DM_ACH_Filename__c;
                InvLT.loan__SS_Approval_Date__c=dmInvLT.DM_Approval_Date_Snapshot__c;
                InvLT.loan__Archived__c=dmInvLT.DM_Archive__c;
                InvLT.loan__Balance_After__c=dmInvLT.DM_Balance_After__c;
                InvLT.loan__SS_Certificate_Rate__c=dmInvLT.DM_Certificate_Rate_Snapshot__c;
                InvLT.loan__Charged_Off_Date__c=dmInvLT.DM_Charged_Off_Date__c;
                InvLT.loan__Charged_Off_Fees__c=dmInvLT.DM_Charged_Off_Fees__c;
                InvLT.loan__Charged_Off_Interest__c=dmInvLT.DM_Charged_Off_Interest__c;
                InvLT.loan__Charged_Off_Principal__c=dmInvLT.DM_Charged_Off_Principal__c;
                InvLT.loan__SS_Investor_End_Date__c=dmInvLT.DM_End_Date_Snapshot__c;
                InvLT.loan__Late_Fees_Paid__c=dmInvLT.DM_Fees__c;
                InvLT.loan__GL_Post_Date__c=dmInvLT.DM_GL_Post_Date__c;
                InvLT.loan__Interest_Paid__c=dmInvLT.DM_Interest__c;
                InvLT.loan__Interest_accrual_from_Date__c=dmInvLT.DM_Interest_Accrual_From_Date__c;
                InvLT.loan__Interest_Accrual_On_Prin_Amount__c=dmInvLT.DM_Interest_Accrual_Prin_Amount__c;
                InvLT.loan__Interest_Accrual_To_Date__c=dmInvLT.DM_Interest_Accrual_To_Date__c;
                InvLT.loan__Interest_Accrued_Amount__c=dmInvLT.DM_Interest_Accrued_Amount__c;
                InvLT.loan__SS_Interest_Amount_Paid__c=dmInvLT.DM_Interest_Amount_Paid_Snapshot__c;
                InvLT.loan__SS_Inv_Interest_Posted_Amt__c=dmInvLT.DM_Interest_Balance_Snapshot__c;
                InvLT.loan__SS_Interest_Exempted_From_Service_Fee__c=dmInvLT.DM_Interest_Exempted_From_Serv_Fee_Snaps__c;
                InvLT.loan__SS_Interest_Paid__c=dmInvLT.DM_Interest_Paid_Snapshot__c;
                InvLT.loan__SS_Interest_Rate_On_Loan_Account__c=dmInvLT.DM_Interest_Rate_On_Loan_Snapshot__c;
                InvLT.loan__SS_Interest_Rounding_Error__c=dmInvLT.DM_Interest_Rounding_Error_Snapshot__c;
                InvLT.loan__Interest_Service_Charge__c=dmInvLT.DM_Interest_Service_Charge__c;
                InvLT.loan__SS_Investment_Amount__c=dmInvLT.DM_Investment_Amount_Snapshot__c;
                if(dmInvOrderIdExternalIdMap.containsKey(dmInvLT.DM_Investment_Order__c)){
                    if(DM_SpecificObjects_Data_Creation.externalIdInvOrderIdMap.containsKey(dmInvOrderIdExternalIdMap.get(dmInvLT.DM_Investment_Order__c))){
                       InvLT.loan__Investor_Loan__c = DM_SpecificObjects_Data_Creation.externalIdInvOrderIdMap.get(dmInvOrderIdExternalIdMap.get(dmInvLT.DM_Investment_Order__c));
                    }
                }
                InvLT.loan__IOA_Paid__c=dmInvLT.DM_IOA__c;
                InvLT.loan__SS_IOA_Amount_Paid__c=dmInvLT.DM_IOA_Amount_Paid_Snapshot__c;
                InvLT.loan__SS_Inv_Last_Interest_Accrual_Post_Date__c=dmInvLT.DM_Last_Interest_Accrual_Date_Snapshot__c;
                InvLT.loan__SS_Late_Fees_Amount_Paid__c=dmInvLT.DM_Late_Fees_Amount_Paid_Snapshot__c;
                InvLT.loan__Late_Fee_Service_Charge__c=dmInvLT.DM_Late_Fee_Service_Charge__c;
                InvLT.loan__SS_Loan_Delinquent_Days__c=dmInvLT.DM_Loan_Delinquent_Days_Snapshot__c;
                if(dmLPTIdExternalIdMap.containsKey(dmInvLT.DM_Loan_Payment_Transaction__c)){
                    if(DM_SpecificObjects_Data_Creation.externalIdLPTIdMap.containsKey(dmLPTIdExternalIdMap.get(dmInvLT.DM_Loan_Payment_Transaction__c))){
                       InvLT.loan__Loan_Payment_Transaction__c = DM_SpecificObjects_Data_Creation.externalIdLPTIdMap.get(dmLPTIdExternalIdMap.get(dmInvLT.DM_Loan_Payment_Transaction__c));
                    }
                }
                InvLT.loan__Loan_Payment_Transaction_Time__c=dmInvLT.DM_Loan_Payment_Transaction_Time__c;
                InvLT.loan__SS_Loan_Principal_Remaining__c=dmInvLT.DM_Loan_Principal_Remaining_Snapshot__c;
                InvLT.loan__SS_Loan_Status__c=dmInvLT.DM_Loan_Status_Snapshot__c;
                InvLT.loan__Master_Archive_Object__c=dmInvLT.DM_Master_Archive_Object__c;
                InvLT.loan__New_Certificate_Rate__c=dmInvLT.DM_New_Certificate_Rate__c;
                InvLT.loan__New_Service_Rate__c=dmInvLT.DM_New_Service_Rate__c;
                InvLT.loan__Old_Certificate_Rate__c=dmInvLT.DM_Old_Certificate_Rate__c;
                InvLT.loan__Old_Service_Rate__c=dmInvLT.DM_Old_Service_Rate__c;
                InvLT.loan__Parent_Txn_Ref__c=dmInvLT.DM_Parent_Txn_Ref__c;
                InvLT.loan__Post_Date__c=dmInvLT.DM_Post_Date__c;
                InvLT.loan__Principal_Paid__c=dmInvLT.DM_Principal__c;
                InvLT.loan__SS_Principal_Amount_Paid__c=dmInvLT.DM_Principal_Amount_Paid_Snapshot__c;
                InvLT.loan__Principal_Service_Charge__c=dmInvLT.DM_Principal_Service_Charge__c;
                InvLT.loan__Reason__c=dmInvLT.DM_Reason__c;
                InvLT.loan__Rebate_Amount_On_Payoff__c=dmInvLT.DM_Rebate_Amount_On_Payoff__c;
                InvLT.loan__Rebate_Amount_On_Refinance__c=dmInvLT.DM_Rebate_Amount_On_Refinance__c;
                InvLT.loan__Rebate_Amount_On_Writeoff__c=dmInvLT.DM_Rebate_Amount_On_Writeoff__c;
                InvLT.loan__Rebate_Payment__c=dmInvLT.DM_Rebate_Payment__c;
                InvLT.loan__Reinvest_Interest__c=dmInvLT.DM_Reinvest_Interest__c;
                InvLT.loan__Reinvest_Principal__c=dmInvLT.DM_Reinvest_Principal__c;
                InvLT.loan__Sent_to_ACH__c=dmInvLT.DM_Sent_to_ACH__c;
                InvLT.loan__Sent_To_ACH_On__c=dmInvLT.DM_Sent_To_ACH_On__c;
                InvLT.loan__SS_Service_Rate__c=dmInvLT.DM_Service_Rate_Snapshot__c;
                InvLT.loan__SS_Share__c=dmInvLT.DM_Share_Snapshot__c;
                InvLT.loan__SS_Enabled_Flag__c=dmInvLT.DM_Snapshot_Enabled_Flag__c;
                InvLT.loan__SS_Rebate_Amount_Paid__c=dmInvLT.DM_SS_Rebate_Amount_Paid__c;
                InvLT.loan__SS_Investor_Start_Date__c=dmInvLT.DM_Start_Date_Snapshot__c;
                InvLT.loan__SS_Status__c=dmInvLT.DM_Status_Snapshot__c;
                InvLT.loan__Summary__c=dmInvLT.DM_Summary__c;
                InvLT.loan__Summary_Record_Id__c=dmInvLT.DM_Summary_Record_Id__c;
                InvLT.loan__Tax__c=dmInvLT.DM_Tax__c;
                InvLT.loan__SS_Total_Amount_Paid__c=dmInvLT.DM_Total_Amount_Paid_Snapshot__c;
                InvLT.loan__Total_Service_Charge__c=dmInvLT.DM_Total_Service_Charge__c;
                InvLT.loan__Txn_Amount__c=dmInvLT.DM_Transaction_Amount__c;
                InvLT.loan__Txn_Code__c=dmInvLT.DM_Transaction_Code__c;
                InvLT.loan__Transaction_Date__c=dmInvLT.DM_Transaction_Date__c;
                InvLT.loan__Txn_Description__c=dmInvLT.DM_Transaction_Description__c;
                InvLT.loan__Txn_Type__c=dmInvLT.DM_Txn_Type__c;
                InvLT.loan__Vat__c=dmInvLT.DM_VAT__c;
                InvLT.loan__Waived__c=dmInvLT.DM_Waived__c;
                InvLT.External_Id__c = dmInvLT.DM_External_Id__c;
                DM_DynamicFieldMapping(dmInvLT,invLT,productType);
                InvLTList.add(InvLT);
            }
        }
          return InvLTList;
      }*///END DM_StaticFieldMapping_invLT

      // **************************************

      //Method will do Static and Dynamic field mapping for Disbursal Transaction Distribution
       /*public List<loan__Disbursal_Txn_Distribution__c> DM_StaticFieldMapping_DDI(List<DM_Disbursal_Transaction_Distribution__c> scopeList,Id parentId)
      {
        system.debug('inside DM_StaticFieldMapping_DDI');
        loan__Disbursal_Txn_Distribution__c ddTxn;
        List<loan__Disbursal_Txn_Distribution__c> ddTxnList = new List<loan__Disbursal_Txn_Distribution__c>();
        if(!scopeList.isEmpty())
        {     
            for(DM_Disbursal_Transaction_Distribution__c scope : scopeList){
              ddTxn = new loan__Disbursal_Txn_Distribution__c();
              ddTxn.loan__Loan_Disbursal_Transaction__c = parentId;
              ddTxn.loan__Distribution_Type__c =  scope.DM_Distribution_Type__c;
              ddTxn.loan__Distribution_Amount__c  =  scope.DM_Distribution_Amount__c;
              ddTxn.loan__Name_of_Entity__c  =  scope.DM_Name_of_Entity__c;
              ddTxn.loan__Reversed__c  =  scope.DM_Reversed__c;
              ddTxn.loan__Sent_To_ACH__c = scope.DM_Sent_To_ACH__c;
              ddTxn.loan__Sent_To_ACH_On__c = scope.DM_Sent_To_ACH_On__c ;
              ddTxn.loan__ACH_Filename__c = scope.DM_ACH_Filename__c ;
              ddTxn.External_Id__c = scope.DM_External_ID__c;
              if(dmLDTIdExternalIdMap.containsKey(scope.DM_Loan_Disbursal_Transaction__c)){
                    if(DM_SpecificObjects_Data_Creation.externalIdLDTIdMap.containsKey(dmLDTIdExternalIdMap.get(scope.DM_Loan_Disbursal_Transaction__c))){
                       ddTxn.loan__Loan_Disbursal_Transaction__c = DM_SpecificObjects_Data_Creation.externalIdLDTIdMap.get(dmLDTIdExternalIdMap.get(scope.DM_Loan_Disbursal_Transaction__c));
                    }
                }
              DM_DynamicFieldMapping(scope,ddTxn,productType);
              ddTxnList.add(ddTxn);
           }    
        }
          return ddTxnList;
      }*///END DM_StaticFieldMapping_DDI


      //Method will do Static and Dynamic field mapping for Rate Schedule Setup (loan__Multi_Step_Loan_Setup__c)
       /*public List<loan__Multi_Step_Loan_Setup__c> DM_StaticFieldMapping_MSLS(List<DM_Multi_Step_Loan_Setup__c> scopeList,Id parentId)
      {
        system.debug('inside DM_StaticFieldMapping_MSLS');
        loan__Multi_Step_Loan_Setup__c MSL;
        List<loan__Multi_Step_Loan_Setup__c> MSLList = new List<loan__Multi_Step_Loan_Setup__c>();
        if(!scopeList.isEmpty())
        {     
            for(DM_Multi_Step_Loan_Setup__c scope : scopeList){
              MSL = new loan__Multi_Step_Loan_Setup__c();
              //MSL.loan__Parent_Multi_Step_Loan_Setup__c = parentId; //pallavi(commented)
              MSL.loan__Start_Date__c = scope.DM_Start_Date__c;
              MSL.loan__Loan_Account__c = parentId;//scope.DM_Loan_Account__c;  //pallavi
              MSL.loan__Interest_Rate__c = scope.DM_Interest_Rate__c;
              MSL.loan__Sequence__c = scope.DM_Sequence__c;
              MSL.loan__Rate_Change_Date_Next__c = Date.newInstance(3100, 12, 31);	//scope.DM_Next_Rate_Change_Date__c;	pallavi
              /*if(scope.DM_Next_Rate_Change_Date__c == null)	//pallavi
                  MSL.loan__Rate_Change_Date_Next__c = Date.newInstance(3100, 12, 31);
              MSL.External_Id__c = scope.DM_External_Id__c; //pallavi
              //MSL.loan__Floating_Rate_Index__c = ;
              
              DM_DynamicFieldMapping(scope,MSL,productType);
              MSLList.add(MSL);
           }    
        }
          return MSLList;
      }*///END DM_StaticFieldMapping_MSL
      
      /*pallavi*/
      //Method will do Static and Dynamic field mapping for due payment
       public List<loan__Due_Payment__c> DM_StaticFieldMapping_LDP(List<DM_Due_Payment__c> scopeList,Id parentId)
      {
        system.debug('inside DM_StaticFieldMapping_LDP');
        loan__Due_Payment__c ddpTxn;
        List<loan__Due_Payment__c> ddpTxnList = new List<loan__Due_Payment__c>();
        if(!scopeList.isEmpty())
        {  
            System.debug('scope is not empty'); //remove
            for(DM_Due_Payment__c scope : scopeList){
              ddpTxn = new loan__Due_Payment__c();
              //ddpTxn.loan__Loan_Disbursal_Transaction__c = parentId;
              ddpTxn.loan__Archived__c =  scope.DM_Archived__c;
              ddpTxn.loan__Fees__c  =  scope.DM_Fees__c;
              ddpTxn.loan__Interest__c  =  scope.DM_Interest__c;
              ddpTxn.loan__Master_Archive_Object__c  =  scope.DM_Master_Archive_Object__c;
              ddpTxn.loan__Payment_Amount__c = scope.DM_Payment_Amount__c;
              ddpTxn.loan__Principal__c = scope.DM_Principal__c ;
              ddpTxn.loan__Summary__c = scope.DM_Summary__c ;
              ddpTxn.loan__Summary_Record_Id__c = scope.DM_Summary_Record_Id__c;
              ddpTxn.loan__TDS__c = scope.DM_TDS__c;
              ddpTxn.External_Id__c = scope.DM_External_Id__c;  //pallavi
               if(dmLPTIdExternalIdMap.containsKey(scope.DM_Loan_Payment_Transaction__c)){
                   System.debug('contains scope.DM_Loan_Payment_Transaction__');    //remove
                    if(DM_SpecificObjects_Data_Creation.externalIdLPTIdMap.containsKey(dmLPTIdExternalIdMap.get(scope.DM_Loan_Payment_Transaction__c))){
                         System.debug('contains dmLPTIdExternalIdMap.DM_Loan_Payment_Transaction__');   //remove
                       ddpTxn.loan__Loan_Payment_Transaction__c = DM_SpecificObjects_Data_Creation.externalIdLPTIdMap.get(dmLPTIdExternalIdMap.get(scope.DM_Loan_Payment_Transaction__c));
                       System.debug('ddpTxn.loan__Loan_Payment_Transaction__c-----' + ddpTxn.loan__Loan_Payment_Transaction__c);    //remove
                    }
                }
                if(dmBILLExternalIdMap.containsKey(scope.DM_Due__c)){
                    if(DM_SpecificObjects_Data_Creation.externalIdBILLMap.containsKey(dmBILLExternalIdMap.get(scope.DM_Due__c))){
                       ddpTxn.loan__Due__c = DM_SpecificObjects_Data_Creation.externalIdBILLMap.get(dmBILLExternalIdMap.get(scope.DM_Due__c));
                    }
                }
              DM_DynamicFieldMapping(scope,ddpTxn,productType);
              ddpTxnList.add(ddpTxn);
           }    
        }
          return ddpTxnList;
      }//END DM_StaticFieldMapping_LDP
      /*pallavi*/
      /*pallavi*/
      //Method will do Static and Dynamic field mapping for due payment
       /*public List<loan__Repayment_Transaction_Adjustment__c> DM_StaticFieldMapping_TxnRev(List<DM_Repayment_Transaction_Reversal__c> scopeList,Id parentId)
      {
        //System.debug('inside DM_StaticFieldMapping_TxnRev');
        loan__Repayment_Transaction_Adjustment__c TxnRev;
        List<loan__Repayment_Transaction_Adjustment__c> TxnRevList = new List<loan__Repayment_Transaction_Adjustment__c>();
        if(!scopeList.isEmpty())
        {  
            for(DM_Repayment_Transaction_Reversal__c scope : scopeList){
              TxnRev = new loan__Repayment_Transaction_Adjustment__c();
              TxnRev.loan__Adjustment_Txn_Date__c = Date.newInstance(scope.DM_Transaction_Time__c.year(), scope.DM_Transaction_Time__c.month(), scope.DM_Transaction_Time__c.day()); //scope.DM_Adjustment_Txn_Date__c;
              TxnRev.loan__Adjustment_Txn_Date__c = scope.DM_Adjustment_Txn_Date__c;
              //TxnRev.loan__Adjusted_Amount__c = scope.DM_Adjusted_Amount__c;
              TxnRev.loan__Archived__c = scope.DM_Archive__c;
              TxnRev.loan__Balance__c = scope.DM_Balance__c;
              TxnRev.loan__Cleared__c = scope.DM_Cleared__c;
              TxnRev.loan__Custom_Logic__c = scope.DM_Custom_Funding_Logic__c;
              TxnRev.loan__Interest_Rate__c = scope.DM_Interest_Rate__c;
              TxnRev.loan__Loan_Snapshot__c = scope.DM_Loan_Snapshot__c;
              TxnRev.loan__Reason_Code__c = scope.DM_Reason_Code__c;
              //TxnRev.loan__Receipt_ID__c = scope.DM_Receipt_ID__c;    loan__Receipt_ID__c is read only
              TxnRev.loan__Reference__c = scope.DM_Reference__c;
              TxnRev.loan__Transaction_Time__c = scope.DM_Transaction_Time__c;
              TxnRev.External_Id__c = scope.DM_External_Id__c;
               if(dmLPTIdExternalIdMap.containsKey(scope.DM_Loan_Payment_Transaction__c)){
                    if(DM_Data_Creation.externalIdLPTIdMap.containsKey(dmLPTIdExternalIdMap.get(scope.DM_Loan_Payment_Transaction__c))){
                       TxnRev.loan__Loan_Payment_Transaction__c = DM_Data_Creation.externalIdLPTIdMap.get(dmLPTIdExternalIdMap.get(scope.DM_Loan_Payment_Transaction__c));
                       //System.debug('TxnRev.loan__Loan_Payment_Transaction__c-----' + TxnRev.loan__Loan_Payment_Transaction__c);    //remove
                    }
                }
              DM_DynamicFieldMapping(scope,TxnRev,productType);
              TxnRevList.add(TxnRev);
           }    
        }
          return TxnRevList;
      }*///END DM_StaticFieldMapping_TxnRev
      /*pallavi*/

      // **************************************
      
      //Utility method - Used for dynamic mapping of field by reading JSON Metadata
      private void DM_DynamicFieldMapping(Sobject scope, Sobject dmSOBJ,String productType){
        system.debug('Inside DM_DynamicFieldMapping.... scope.... '+scope);
        //DM_Metadata_Config_Wrapper configWrapper1 = ParserUtil.getParser();  //pallavi(moving it from here because SOQL limit was exceeding)
        system.debug('configWraper'+configWrapper1);
        Map<String, Map<String, String>> JSONFieldMapping =  DM_Validate_Impl.getFieldMappingFromJSON(configWrapper1);
        //Map<SImple Loan|DM_Loan_Acc,Map<srcObject|SrcField,TargetObj+TargetField+DataType>>
        Map<String,String> tempMap = new Map<String,String>();
        string objName;
        Sobject sObj;        
        String[] fieldMetadata;
        String[] temp;
        String srcField;system.debug('objName.... '+String.valueOf(scope).split(':')[0]);
        objName = String.valueOf(scope).split(':')[0];
        system.debug('objName'+objName);
        system.debug('product type'+productType);
        system.debug('JSON Field Mapping keyset '+JSONFieldMapping.keySet());
        system.debug('JSON Field Mapping keyset '+JSONFieldMapping.values());
        if(JSONFieldMapping.containsKey(productType+'|'+objName.toLowerCase())){
            system.debug('productType|SRCObject Matched');
            tempMap = JSONFieldMapping.get(productType+'|'+objName.toLowerCase());
            system.debug('tempMap size '+tempMap);
            if(tempMap<>null){
                for(String key : tempMap.KeySet()){
                    system.debug('Inside TempMap KeySet');
                    temp = key.split('\\|');
                    system.debug('temp'+temp);
                    srcField=temp[1];
                    system.debug('srcField '+srcField);
                    if(tempMap.get(key)<>null){
                        system.debug('inside tempMap');
                        fieldMetadata = tempMap.get(key).split('\\|');
                        if(scope.get(srcField)<>null){
                            if(dynamicDataTypeCheck(fieldMetadata[2],String.valueOf(scope.get(srcField)))){
                                system.debug('data Type check Succeed');
                                if(fieldMetadata[2]=='Text'){
                                    dmSOBJ.put(fieldMetadata[1],String.valueOf(scope.get(srcField)));
                                }    
                                else if(fieldMetadata[2]=='Date'){
                                    dmSOBJ.put(fieldMetadata[1],dynamicDataTypeDateConversion(String.valueOf(scope.get(srcField))));//Date.valueOf(String.valueOf(scope.get(srcField)))
                                }
                                else if(fieldMetadata[2]=='Checkbox'){
                                    dmSOBJ.put(fieldMetadata[1],dynamicBooleanConversion(String.valueOf(scope.get(srcField))));
                                }
                                else if(fieldMetadata[2]=='Number'){
                                    dmSOBJ.put(fieldMetadata[1],dynamicNumberConversion(String.valueOf(scope.get(srcField))));
                                }else{
                                    /*pallavi*/
                                    if(fieldMetadata[2]=='loan__Loan_Purpose__c')
                                        dmSOBJ.put(fieldMetadata[1],Id.valueOf(String.valueOf(scope.get(srcField))));
                                    /*pallavi*/
                                     //will include other scenarios   
                                }            
                            }//DynamicDataTypeCheck 
                        }//END if(scope.get(srcField)<>null){
                    }//END if(tempMap.get(srcField)<>null){
                }//END FOR Loop
            }//IF not null
        }//END IF ContainsKey
     }//END DM_DynamicFieldMapping_Contract    
     
     private Boolean dynamicDataTypeCheck(String dataType, String value){
         system.debug('inside dynamicDataTypeCheck');
         system.debug('data type '+dataType);
         if(dataType=='Text'){
             return true;
         }
         
         if(dataType=='Date'){
             Pattern pattern =  Pattern.compile('(0?[1-9]|[12][0-9]|3[01])-(0?[1-9]|1[012])-((19|20)\\d\\d)');
             Matcher matcher = pattern.matcher(value);
             return matcher.matches();
         }
         
         if(dataType=='Number'){
             return value.isNumeric();
         }
         
         if(dataType=='Checkbox'){
             if(Value=='True' || Value=='False'){
                 return true;
             }    
         }
         /*pallavi*/
         if(dataType == 'loan__Loan_Purpose__c'){
             if(value!=null)
                 return true;
         }
         /*pallavi*/
         return false;
    }//END dynamicDataTypeCheck
        
    private Date dynamicDataTypeDateConversion(String value){
        Date tempDate;
        String[] dateVal;
        dateVal = value.split('-');
        tempdate = date.newinstance(integer.valueOf(dateVal[2]),integer.valueOf(dateVal[0]),integer.valueOf(dateVal[1]));
        return tempdate;
    }//END dynamicDataTypeDateConversion
    
    private Boolean dynamicBooleanConversion(String Value){
        if(Value=='True'){
            return true;
        }    
        else{
            return false; 
        }
    }
    
    private Decimal dynamicNumberConversion(String Value){
        Decimal num = Decimal.valueOf(value);
        return num;
    }
}//END class DM_MigrationHandler