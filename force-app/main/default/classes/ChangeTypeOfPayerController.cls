/* ****************Modification History******************
 * Last Modified by        Date          JIRA number
 *      1. Pallavi        2020/01/27     LOS-28(Remove references to InvestorAccount field on CL contract)
 *      
 ******************Modification History******************/
public with sharing class ChangeTypeOfPayerController 
{
    public ApexPages.StandardController Controller;
    public Id loanAccId{get;set;}
    public loan__Loan_Account__c loanAcc{get;set;}
    public loan__Automated_Payment_Setup__c aps{get;set;}
    public Date systemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
    public List<loan__Automated_Payment_Setup__c> apsetup{get;set;}
    public ChangeTypeOfPayerController(ApexPages.StandardController controller)
    {
        this.Controller = Controller;
        loanAccId = ((loan__Loan_Account__c)Controller.getRecord()).Id;
        apsetup = [Select id,name,
                        loan__Active__c,
                        loan__Type__c                        
                    from loan__Automated_Payment_Setup__c
                    where loan__Type__c = 'RECURRING'
                    And loan__Active__c = True
                    And loan__CL_Contract__c =: loanAccId];
        
    }
    public PageReference changeAppStatus(){       
        // Get the selected records (optional, you can use getSelected to obtain ID's and do your own SOQL)
        
        loanAcc = (loan__Loan_Account__c)Controller.getRecord();
        loan__Loan_Account__c  loanAccQuery = [Select id,name,
                    loan__Account__c,
                    //Investor_Account__c,      commented(LOS-28)
                    loan__Next_Due_Generation_Date__c,
                    loan__Pre_Bill_Days__c,
                    loan__Loan_Product_Name__c,
                    loan__Loan_Product_Name__r.name,
                    loan__Payment_Mode__c,   
                    loan__Frequency_of_Loan_Payment__c,
                    loan__Next_Installment_Date__c,
                    (Select id,name,
                        loan__Active__c,
                        loan__Type__c                        
                        from loan__Automated_Payment_Setup__r
                        where loan__Type__c = 'RECURRING'
                        And loan__Active__c = True)                                                           
                    from loan__Loan_Account__c 
                    where id =: loanAccId];   
                    
        loan__Org_Parameters__c orgParam = loan.CustomSettingsUtil.getOrgParameters();
        loan__Loan_Product__c autoLP;
        loan__Loan_Product__c manualLP;
        Integer DiffPrebillDays;
        try{
        
            autoLP = [Select id,name,
                            loan__Pre_Bill_Days__c
                        From loan__Loan_Product__c 
                        Where name = : orgParam.Auto_Payer_Lending_Product_Name__c];
            
        }
        catch(Exception e){
            System.debug('Exception'+ e);
            throw new ints.IntegrationException('Auto Payer Lending Product is not setup properly.Please Check CustomSettings>>OrgParams>>Auto_Payer_Lending_Product_Name__c');
        }
        try{
        
            manualLP = [Select id,name,
                            loan__Pre_Bill_Days__c
                        From loan__Loan_Product__c 
                        Where name = : orgParam.Manual_Payer_Lending_product_name__c];
            
        }
        catch(Exception e){
            System.debug('Exception'+ e);
            throw new ints.IntegrationException('Manual Payer Lending Product is not setup properly.Please Check CustomSettings>>OrgParams>>Manual_Payer_Lending_product_name__c');
        }
        
        DiffPrebillDays = Integer.valueOf(manualLP.loan__Pre_Bill_Days__c - autoLP.loan__Pre_Bill_Days__c);
        
        if(loanAcc.loan__Loan_Product_Name__c == manualLP.id){
            
            loanAcc.loan__Loan_Product_Name__c = autoLP.id;
            loanAcc.loan__Pre_Bill_Days__c = autoLP.loan__Pre_Bill_Days__c;
            loanAcc.loan__Next_Due_Generation_Date__c = loanAcc.loan__Next_Due_Generation_Date__c + DiffPrebillDays;
            
            loan__Bank_Account__c bankAcc;
            
            try{
                bankAcc = [Select id,name,
                                loan__Active__c 
                            From loan__Bank_Account__c 
                            Where loan__Active__c = True
                            And loan__Account__c =: loanAccQuery.loan__Account__c limit 1];
            }catch(Exception e){
                System.debug('Exception'+ e);
                throw new ints.IntegrationException('Unable to find any active bank account for this borrower');
            }
            /*LOS-28*/
            loan__Investor_Loan__c investor = [select id,name,loan__Account__c from loan__Investor_Loan__c where loan__Loan__c =: loanAccQuery.id and loan__Status__c = 'Active' limit 1];
            /*LOS-28*/
            loan__Automated_Payment_Configuration__c apc;
                try{
                  apc = [Select id,name,
                                loan__Payment_Mode__c,
                                loan__Bank_Account__c,
                                loan__Bank_Account__r.loan__Account__c
                            From loan__Automated_Payment_Configuration__c
                            Where loan__Bank_Account__r.loan__Account__c =: investor.loan__Account__c //loanAccQuery.Investor_Account__c  //LOS-28
                            limit 1];
                 }
                 catch(exception ex){
                     loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToUnderwriterQueue:  '+ex.getlinenumber()+'Error: '+ex.getMessage() + loanAccQuery.name);
                     insert logs;
                     throw new ints.IntegrationException('NO APC FOUND FOR THIS INVESTOR');

                 }
            
            aps = new loan__Automated_Payment_Setup__c();
            aps.loan__Type__c = 'RECURRING';
            aps.loan__Amount_Type__c= loan.LoanConstants.CURRENT_PAYMENT_AMOUNT;
            //aps.loan__Transaction_Amount__c=loanApplication.genesis__Payment_Amount__c; No need to set transaction because 
            aps.loan__CL_Contract__c=loanAccQuery.Id;
            aps.loan__Payment_Mode__c = apc.loan__Payment_Mode__c;
            aps.loan__Active__c = true;                
            aps.loan__Bank_Account__c = bankAcc.id;
            aps.loan__Debit_Date__c = loanAccQuery.loan__Next_Installment_Date__c;
            aps.loan__Frequency__c = loanAccQuery.loan__Frequency_of_Loan_Payment__c;
            aps.loan__Setup_Date__c=systemDate;
            aps.loan__Recurring_ACH_Start_Date__c = aps.loan__Debit_Date__c;
            //aps.loan__Recurring_ACH_End_Date__c = loanAccount.loan__Maturity_Date_Current__c;    //Do not set End date as they want to keep trying for APS if Loan is not paid completely.
            aps.loan__Retry__c = 'Disabled'; 
        }
        else if(loanAcc.loan__Loan_Product_Name__c == autoLP.id){
            loanAcc.loan__Loan_Product_Name__c = manualLP.id;
            loanAcc.loan__Pre_Bill_Days__c = manualLP.loan__Pre_Bill_Days__c;
            loanAcc.loan__Next_Due_Generation_Date__c = loanAcc.loan__Next_Due_Generation_Date__c - DiffPrebillDays;
            if(loanAccQuery.loan__Automated_Payment_Setup__r != null && loanAccQuery.loan__Automated_Payment_Setup__r.size() > 0){
                aps = loanAccQuery.loan__Automated_Payment_Setup__r[0];
                aps.loan__Active__c = False;
                System.debug('APS......   ' + aps);
            
            }
        
        }
        
        
        return null;        
    }
    public PageReference confirmChanges()
    {       
        // Call StandardSetController 'save' method to update (optional, you can use your own DML)
        if(loanAcc != null){
            update loanAcc;
        }
        if(aps != null){
            upsert aps;
        }
        return controller.save();   
    }  
}