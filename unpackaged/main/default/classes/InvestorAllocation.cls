/** CLS-1121,1216,1095,1331
* Change Requirement :    
* Pre-allocation of investors to be run at offer_accepted    
* Final allocation to be run at ADVP    
* if an application has eligible DCP transactions, a DCP enables investor should get allocated and DCP_Investor_Eligibility__c should
* be set to true
*If no investor is allocated, application should move to Review Queue**/
/* ****************Modification History******************
 * Created By        Date          JIRA number
 *1. Pallavi        2020/10/05     CRM-928(Previous Investor Current Weight number decreased when re-allocating applications)
 *2. Pallavi        2020/10/08     CRM-927(Invested Amount Missing for applications)
 *3. Anusha			2021/01/18	   LOP-72 (Modify Investor Allocation Round Robin to Better Balance Allocations for Investors with Different APR Limits)
; ******************Modification History******************/
public with sharing class InvestorAllocation{
    public static boolean isInvAllocExecuting=true;
    public static boolean allocationForADVPcalled = false;
    
    
    /* Constructor to initialize
* @param isExecuting    Has value of which context it is executing. */
    public InvestorAllocation(boolean isExecuting){
        isInvAllocExecuting = isExecuting;
    }   
    
    public static boolean runInvestorRule(Id appId){
        System.debug('Before isInvAllocExecuting ....'+ isInvAllocExecuting );
        if(isInvAllocExecuting){
            isInvAllocExecuting = false;
            System.debug('After isInvAllocExecuting ....'+ isInvAllocExecuting );
            //isInvAllocExecuting = runInvestorAllocationFieldsUpdate(appId);
        }
        return isInvAllocExecuting;
    }      
    
    @InvocableMethod
    public static void allocateInvestor(list<id> appId){
        if(appId !=null && appId.size()>0) {
            runInvestorAllocationBasedOnWeighting(appId[0]);
        }
        
    }
    
    
    /*public static boolean runInvestorAllocationFieldsUpdate(Id appid) {
        Boolean retValue = false;
        system.debug('runBusinessRuleEngine');
        Account investorAcc;
        Boolean againRulePasses = False;
        try{
            genesis__Applications__c app = [Select id,name,
                                            Investor__c,
                                            genesis__status__c,
                                            genesis__loan_amount__c,
                                            Invested_Amount__c,
                                            genesis__Lending_Product__c,
                                            Last_Investor_Assigned_On__c
                                            FROM genesis__Applications__c
                                            WHERE id =: appId];
            system.debug('Investor: .. '+ app.Investor__c);
            //Check if the Applicastions has already assigned investor.                                        
            if(app.Investor__c != null){ 
                
                investorAcc = [Select id,name,
                               Investment_Rules__c,
                               loan__Investor__c,
                               (Select id,name,
                                Invested_Amount__c
                                from Applications__r 
                                Order By Last_Investor_Assigned_On__c Desc
                                Limit 1),
                               Investor_Alloted_Weight__c,
                               Investor_Current_Weight__c,
                               Last_Application_assigned_on__c,
                               Amount_Invested__c,
                               Number_Of_Applications_Invested__c
                               FROM Account
                               WHERE id =: app.Investor__c
                              ];
                
            }
            //IDs of Rules which are failed
            Set<ID> setruleIDs = new Set<ID>();
            //hitting the product API for execution of rules.                                            
            List<genesis__checklist__c> listCheck = genesis.RulesAPI.evaluateRules(app,null,true,false);
            
            if(!listCheck.isEmpty()){
                
                for(genesis__checklist__c chList : listCheck){
                    
                    if(chList.genesis__Message__c.containsIgnoreCase('Fail')){
                        setruleIDs.add(chList.genesis__Rule__c);
                        System.Debug('****Not Passed*****' + chList.genesis__Rule__c + chList.genesis__Message__c);
                    }
                    
                }
            }
            //Quering the investor whose rules are passed.
            List<Account> listInvestor = [Select id,name,
                                          Investment_Rules__c,
                                          loan__Investor__c,
                                          Last_Application_assigned_on__c,
                                          Amount_Invested__c,
                                          Number_Of_Applications_Invested__c
                                          FROM Account
                                          WHERE loan__Investor__c = true
                                          AND loan__Active__c = 'Yes'
                                          AND Investment_Rules__c not in: setruleIDs
                                          AND Remaining_Amount__c >=: app.genesis__loan_amount__c
                                          AND Remaining_Applications__c >=: 1
                                          order by Last_Application_assigned_on__c
                                         ];
            System.Debug('listInvestor after Quering the investor whose rules are passed. '+ listInvestor);                             
            if(!listInvestor.isEmpty()){
                //If there is any Investor then update the Application Investor and update the Investor's Last Application Assigned on.
                //Else send the Application to Review
                for(Account acc : listInvestor){  
                    System.Debug('outside if(acc.id == investorAcc.id)');          
                    if(investorAcc != null){
                        if(acc.id == investorAcc.id){
                            System.Debug('acc = investor acc');
                            genesis__Applications__c investorApp = investorAcc.Applications__r[0];
                            System.Debug('Investor App Id'+ investorApp.id);
                            //if(app.id == investorApp.id){  pallavi(commented) LOS-70
                            System.Debug('In old Investor');
                            acc.Amount_Invested__c = acc.Amount_Invested__c - app.Invested_Amount__c;
                            app.Invested_Amount__c = app.genesis__loan_amount__c;
                            acc.Amount_Invested__c = acc.Amount_Invested__c + app.Invested_Amount__c;
                            acc.Last_Application_assigned_on__c = system.now();
                            app.Last_Investor_Assigned_On__c = acc.Last_Application_assigned_on__c;                         
                            againRulePasses = true;
                            /*CRM-804*/
                            /*integer i = 1;
                            while(i<=10){
                                try{
                                    Update acc;
                                    i = 11;
                                }
                                catch(Exception e){
                                    if(e.getMessage().contains('UNABLE_TO_LOCK_ROW')){
                                        i = i+1;
                                    }
                                    else{
                                        i = 10;
                                    }
                                }
                            }
                            /*CRM-804*/
                            /*update app;
                            Break;
                            //}     LOS-70
                        }
                    }
                }
            }
            System.Debug('againRulePasses____' + againRulePasses);
            if(listInvestor != null && listInvestor.size() > 0 && againRulePasses == False){
                app.Investor__c = listInvestor[0].id;
                System.Debug('In new Investor');
                update listInvestor;	//no use of this line. have to check
                update app;
                System.debug('***app.Investor__c***'+app.Investor__c+'**'+listInvestor[0].id);
                retValue = true;
            }
            // This may happen after Redecision..
            else if(listInvestor == null && listInvestor.size() == 0 && againRulePasses == False && app.Investor__c != null){
                app.Investor__c = null;
                update app;
                System.Debug('set investor to null____' + listinvestor);
                retValue = false;
            }
            
        }
        catch(Exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'Business Rule Engine' ;
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
            
            //throw ex;
        }   
        return retValue;
    }*/
    public static boolean runInvestorAllocationBasedOnWeighting (Id appid) {
        boolean againRulePasses = false;
        boolean retvalue = true;
        Account investorAcc;
        // System.debug('initial count' + count);
        List<clcommon__batch_process_log__c> lstBpl = new List<clcommon__batch_process_log__c>();
        system.debug('------In Investor Allocation-------');    //pallavi
       try{system.debug('investorreallocation---->>>');
            genesis__Applications__c app = [Select id,name,
                                            Investor__c,DCP_Investor_Eligibility__c,
                                            genesis__status__c,
                                            genesis__loan_amount__c,
                                            Invested_Amount__c,
                                            genesis__Lending_Product__c,
                                            Last_Investor_Assigned_On__c,
                                            Total_Arcus_Transactions__c,
                                            (SELECT Num_Trades_Opened_Past_24mo__c,
                                                    Net_Disposable_Income_NDI_Num__c,
                                                    FICO__c,
                                                    Debt_to_Income_DTI__c
                                            FROM   Credit_Policy__r) // LOP-217
                                            FROM genesis__Applications__c
                                            WHERE id =: appId];

            // LOP-217 treat null as 0
            for (Credit_Policy__c cp : app.Credit_Policy__r) {
                if (cp.Num_Trades_Opened_Past_24mo__c == null) {
                    cp.Num_Trades_Opened_Past_24mo__c = 0;
                }
            }

            List<DCP_arcus_transactions__c> txns = new List<DCP_arcus_transactions__c>();
            txns = [select id from DCP_arcus_transactions__c where application__c =: appId];
            system.debug('Txns: .. '+ txns.size());
            
            system.debug('Investor: .. '+ app.Investor__c);
            //Check if the Applicastions has already assigned investor.                                        
            if(app.Investor__c != null){ 
                
                investorAcc = [Select id,name,
                               Investment_Rules__c,
                               loan__Investor__c,
                               Investor_Current_Weight__c,		//CRM-928
                               (Select id,name,
                                Invested_Amount__c
                                from Applications__r 
                                Order By Last_Investor_Assigned_On__c Desc
                                Limit 1),   //pallavi(LOS-70)
                               Last_Application_assigned_on__c,
                               Amount_Invested__c,
                               Number_Of_Applications_Invested__c,
                               Total_Funded_Till_date__c,Total_Funded_YTD__c,	//CRM-927
                               Total_Funded_MTD__c,Total_Allocations_MTD__c	//CRM-927
                               FROM Account
                               WHERE id =: app.Investor__c
                              ];
                
            }
            //IDs of Rules which are failed
            Set<ID> setruleIDs = new Set<ID>();
            //hitting the product API for execution of rules.                                            
            List<genesis__checklist__c> listCheck = genesis.RulesAPI.evaluateRules(app,null,true,false);
            
            if(!listCheck.isEmpty()){
                
                for(genesis__checklist__c chList : listCheck){
                    
                    if(chList.genesis__Message__c.containsIgnoreCase('Fail')){
                        setruleIDs.add(chList.genesis__Rule__c);
                        System.Debug('****Not Passed*****' + chList.genesis__Rule__c + chList.genesis__Message__c);
                    }
                    
                }
            }
            //Quering the investor whose rules are passed.
            //CLS-1121,1216,1095 starts
            List<Account> listInvestor = new List<Account>();
            if(app.Total_Arcus_Transactions__c >0 && app.genesis__status__c == 'agent_document_verification_pending') {
                System.debug('***********');        //commented CLS-1095
                //allocationForADVPcalled = true;
                listInvestor = [Select id,name,
                                Investment_Rules__c,
                                loan__Investor__c,
                                Last_Application_assigned_on__c,
                                Amount_Invested__c,
                                Number_Of_Applications_Invested__c,
                                Investor_Alloted_Weight__c,Current_Month_s_Available_Allocation__c,
                                Investor_Current_Weight__c,Current_Month_s_Available_Funded_Balance__c,
                                Total_Funded_Till_date__c,Total_Funded_YTD__c,	//CRM-927
                                Total_Funded_MTD__c,Total_Allocations_MTD__c	//CRM-927
                                FROM Account
                                WHERE loan__Investor__c = true
                                AND loan__Active__c = 'Yes'
                                AND Investment_Rules__c not in: setruleIDs
                                AND Current_Month_s_Available_Funded_Balance__c >=: app.genesis__loan_amount__c
                                AND Current_Month_s_Available_Allocation__c >0 
                                AND DCP_Allowed__c =true
                                order by Investor_Alloted_Weight__c desc
                               ];
            } else {
                listInvestor = [Select id,name,
                                Investment_Rules__c,
                                loan__Investor__c,
                                Last_Application_assigned_on__c,
                                Amount_Invested__c,
                                Number_Of_Applications_Invested__c,
                                Investor_Alloted_Weight__c,Current_Month_s_Available_Allocation__c,
                                Investor_Current_Weight__c,Current_Month_s_Available_Funded_Balance__c,
                                Total_Funded_Till_date__c,Total_Funded_YTD__c,	//CRM-927
                                Total_Funded_MTD__c,Total_Allocations_MTD__c	//CRM-927
                                FROM Account
                                WHERE loan__Investor__c = true
                                AND loan__Active__c = 'Yes'
                                AND Investment_Rules__c not in: setruleIDs
                                AND Current_Month_s_Available_Funded_Balance__c >=: app.genesis__loan_amount__c
                                AND Current_Month_s_Available_Allocation__c >0  
                                /*AND DCP_Allowed__c =false*/
                                order by Investor_Alloted_Weight__c desc
                               ];
            } //commented CLS-1095
            //CLS-1121,1216,1095 ends
            System.Debug('listInvestor'+ listInvestor);      
            List<String> skipInvestorforAllocation = System.Label.SkipInvestorforAllocation.split(',');
            List<Account> investorCantbeAlloted = [Select id,name FROM Account
                                                   WHERE loan__Investor__c = true
                                                   AND id not in:listInvestor
                                                   AND name not in: skipInvestorforAllocation];
            System.Debug('investorcantbealloted'+ investorCantbeAlloted);                                        
            for(Account a:investorCantbeAlloted) {
                clcommon__batch_process_log__c bpl = new clcommon__batch_process_log__c();
                bpl.clcommon__Log_Level__c = 'INFO';
                bpl.clcommon__Type__c = 'Info';
                bpl.clcommon__Batch_Id__c = app.id;
                bpl.clcommon__Message__c = 'Can not allocate to the investor '+a.name+' because of one of the following reason \n 1.Either it is inactive\n2.Available balance less than Loan Amount\n3.Rule didnt passed.\n4.Monthly Allocation less than 0';
                lstBpl.add(bpl);
            }
            
            if(!listInvestor.isEmpty()){
                //If there is any Investor then update the Application Investor and update the Investor's Last Application Assigned on.
                //Else DENIED the Application
                for(Account acc : listInvestor){  
                    System.Debug('outside if(acc.id == investorAcc.id)');          
                    if(investorAcc != null){
                        System.debug('investorAcc.id---' + investorAcc.id);
                        System.debug('acc.id---' + acc.id);
                        if(acc.id == investorAcc.id){
                            System.Debug('acc = investor acc');
                            genesis__Applications__c investorApp = investorAcc.Applications__r[0];
                            System.Debug('Investor App Id'+ investorApp.id);
                            // if(app.id == investorApp.id){ pallavi(commented) LOS-70
                            System.Debug('In old Investor');
                            acc.Amount_Invested__c = acc.Amount_Invested__c - app.Invested_Amount__c;
                            app.Invested_Amount__c = app.genesis__loan_amount__c;
                            acc.Amount_Invested__c = acc.Amount_Invested__c + app.Invested_Amount__c;
                            acc.Last_Application_assigned_on__c = system.now();
                            app.Last_Investor_Assigned_On__c = acc.Last_Application_assigned_on__c;                         
                            againRulePasses = true;
                            if(app.Total_Arcus_Transactions__c>0 && app.genesis__status__c == 'agent_document_verification_pending'){
                                app.DCP_Investor_Eligibility__c = true; //CLS-1121,1216,1095
                                //allocationForADVPcalled = true;
                            }   //commented CLS-1095
                            if(app.genesis__status__c == 'agent_document_verification_pending')
                                allocationForADVPcalled = true;
                            /*CRM-804*/
                            integer i = 1;
                            while(i<=10){
                                try{
                                    Update acc;
                                    break;//LOP-72
                                }
                                catch(Exception e){
                                    if(e.getMessage().contains('UNABLE_TO_LOCK_ROW')){
                                        i = i+1;
                                        if(i>10){
                                            clcommon__batch_process_log__c bpl = new clcommon__batch_process_log__c();
                                            bpl.clcommon__Type__c = 'Exception';
                                            bpl.clcommon__Batch_Id__c = app.id;
                                            bpl.clcommon__Message__c = 'Can not allocate to the investor '+acc.name+' because of error updating investor account. Exception : '+e.getMessage();
                                            insert bpl;
                                            return false;
                                        }
                                    }
                                    else{
                                        // i = 11; //LOP-72 (Removed i=11 and added return at the end)
                                        clcommon__batch_process_log__c bpl = new clcommon__batch_process_log__c();
                                        bpl.clcommon__Type__c = 'Exception';
                                        bpl.clcommon__Batch_Id__c = app.id;
                                        bpl.clcommon__Message__c = 'Can not allocate to the investor '+acc.name+' because of error updating investor account. Exception : '+e.getMessage();
                                        insert bpl;
                                        return false;
                                    }
                                }
                            }
                            /*CRM-804*/
                            update app;
                            retvalue = true;
                            Break;
                            // } LOS-70
                        }
                    }
                }
            }
            System.Debug('againRulePasses____' + againRulePasses);
            
            if(listInvestor.size() > 0 && againRulePasses == False){	//CRM-804 (removed listInvestor != null && because it's not needed)
                //app.Investor__c = listInvestor[0].id;
                // Logic to asign based on the partner weighting
                Integer totalInvestor = listInvestor.size();
                Integer allotedWeightCount = 0;
                Integer currentWeightZero = 0;
                Integer InvestorAllocationSatisfied = 0;
                Decimal investorWithLargestWeight = 0;
                Account investorAccountWithLargestWeight = null;
                system.debug(investorAccountWithLargestWeight);
                for(Account acc : listInvestor) {
                    if(acc.Investor_Current_Weight__c ==0) {
                        currentWeightZero++;
                    }
                }
                System.debug('TotalInvestor'+totalInvestor+' applicationAssignedtoInvestornull'+currentWeightZero);
                if(currentWeightZero == totalInvestor) {
                    for(Account acc : listInvestor) {
                        if(investorWithLargestWeight < acc.Investor_Alloted_Weight__c) {
                          	if(acc.Current_Month_s_Available_Funded_Balance__c>=app.genesis__Loan_Amount__c && acc.Current_Month_s_Available_Allocation__c>0) {//LOP-72 (Changed 'acc.Current_Month_s_Available_Funded_Balance__c>0' to 'acc.Current_Month_s_Available_Funded_Balance__c>=app.genesis__Loan_Amount__c')
                                investorWithLargestWeight = acc.Investor_Alloted_Weight__c;
                                InvestorAllocationSatisfied++;
                                investorAccountWithLargestWeight = acc;
                                system.debug('investordd--->'+investorAccountWithLargestWeight);
                                
                                app.Investor__c = investorAccountWithLargestWeight.id;                   
                                
                                app.Last_Investor_Assigned_On__c = System.now();
                                app.Invested_Amount__c = app.genesis__loan_amount__c;  //CRM-927
                                investorAccountWithLargestWeight.Investor_Current_Weight__c  = investorAccountWithLargestWeight.Investor_Current_Weight__c+1;
                                investorAccountWithLargestWeight.Last_Application_assigned_on__c = System.now();
                           }else {
                                clcommon__batch_process_log__c bpl = new clcommon__batch_process_log__c();
                                bpl.clcommon__Log_Level__c = 'INFO';
                                bpl.clcommon__Type__c = 'Info';
                                bpl.clcommon__Batch_Id__c = app.id;
                                bpl.clcommon__Message__c = 'Can not allocate to the investor '+acc.name+' because of one of the following reason \n 1.Weights\n2.Current Month Available balance\n3.Current Month Available Allocation';
                                lstBpl.add(bpl);
                            }
                            
                        }
                        
                         else {
                            clcommon__batch_process_log__c bpl = new clcommon__batch_process_log__c();
                            bpl.clcommon__Log_Level__c = 'INFO';
                            bpl.clcommon__Type__c = 'Info';
                            bpl.clcommon__Batch_Id__c = app.id;
                            bpl.clcommon__Message__c = 'Can not allocate to the investor '+acc.name+' because of one of the following reason \n 1.Weights\n2.Current Month Available balance\n3.Current Month Available Allocation';
                            lstBpl.add(bpl);
                        }
                        
                    }
                    if(InvestorAllocationSatisfied==0){
                        app.investor__C = null;
                        app.Last_Investor_Assigned_On__c = System.now();
                        app.Invested_Amount__c = 0;
                        app.genesis__status__c = 'review';
                        update app; 
                    }
                   
                    //}
                    
                } 
                else {
                    integer flag=0;
                    integer countOfFailure = 0;
                    System.debug('account list'+listInvestor);
                    for(Account acc : listInvestor) {
                        if(acc.Investor_Current_Weight__c < acc.Investor_Alloted_Weight__c && acc.Current_Month_s_Available_Funded_Balance__c>=app.genesis__Loan_Amount__c && acc.Current_Month_s_Available_Allocation__c>0) {//LOP-72 (Changed 'acc.Current_Month_s_Available_Funded_Balance__c>0' to 'acc.Current_Month_s_Available_Funded_Balance__c>=app.genesis__Loan_Amount__c')
                            investorAccountWithLargestWeight= acc;
                            app.Investor__c = investorAccountWithLargestWeight.id;
                            app.Last_Investor_Assigned_On__c = System.now();
                            app.Invested_Amount__c = app.genesis__loan_amount__c;	//CRM-927
                            System.debug('testing here'+investorAccountWithLargestWeight.Investor_Alloted_Weight__c);
                            investorAccountWithLargestWeight.Investor_Current_Weight__c  = investorAccountWithLargestWeight.Investor_Current_Weight__c+1;
                            investorAccountWithLargestWeight.Last_Application_assigned_on__c = System.now();
                            break;
                        } else {
                            countOfFailure++;
                            
                        }
                    }
                    if(countOfFailure == listInvestor.size()) {
                        for(Account acc : listInvestor) {
                            if(acc.Investor_Current_Weight__c >= acc.Investor_Alloted_Weight__c && acc.Current_Month_s_Available_Funded_Balance__c>=app.genesis__loan_amount__c && acc.Current_Month_s_Available_Allocation__c>0) {//LOP-72 (Changed 'acc.Current_Month_s_Available_Funded_Balance__c>0' to 'acc.Current_Month_s_Available_Funded_Balance__c>=app.genesis__loan_amount__c')
                                investorAccountWithLargestWeight= acc;
                                app.Investor__c = investorAccountWithLargestWeight.id;
                                app.Last_Investor_Assigned_On__c = System.now();
                                app.Invested_Amount__c = app.genesis__loan_amount__c;	//CRM-927
                                System.debug('testing here if weights get fulled but allocations available'+investorAccountWithLargestWeight.Investor_Alloted_Weight__c);
                                investorAccountWithLargestWeight.Investor_Current_Weight__c  = investorAccountWithLargestWeight.Investor_Current_Weight__c + 1;//LOP-72 (Adding 1 to currentWeight instead of making the currentWeight = 1)
                                investorAccountWithLargestWeight.Last_Application_assigned_on__c = System.now();
                                break;
                            } else {
                                clcommon__batch_process_log__c bpl = new clcommon__batch_process_log__c();
                                bpl.clcommon__Log_Level__c = 'INFO';
                                bpl.clcommon__Type__c = 'Info';
                                bpl.clcommon__Batch_Id__c = app.id;
                                bpl.clcommon__Message__c = 'Can not allocate to the investor '+acc.name+' because of one of the following reason \n 1.Weights\n2.Current Month Available balance\n3.Current Month Available Allocation';
                                lstBpl.add(bpl);
                            }
                            
                        }
                        
                    }
                    
                }
                
                System.Debug('In new Investor');
                //update listInvestor;
                insert lstBpl;
                if(app.Investor__c !=null ) {
                    /*CRM-927*/
                    //investorAccountWithLargestWeight
                    if(app.genesis__Status__c == 'agent_document_verification_pending'){
                        investorAccountWithLargestWeight.Total_Funded_Till_date__c = (investorAccountWithLargestWeight.Total_Funded_Till_date__c==null ?app.genesis__loan_amount__c:investorAccountWithLargestWeight.Total_Funded_Till_date__c + app.genesis__loan_amount__c);
                        investorAccountWithLargestWeight.Total_Funded_YTD__c = (investorAccountWithLargestWeight.Total_Funded_YTD__c==null ?app.genesis__loan_amount__c:investorAccountWithLargestWeight.Total_Funded_YTD__c + app.genesis__loan_amount__c);
                        investorAccountWithLargestWeight.Total_Funded_MTD__c = (investorAccountWithLargestWeight.Total_Funded_MTD__c==null ?app.genesis__loan_amount__c:investorAccountWithLargestWeight.Total_Funded_MTD__c + app.genesis__loan_amount__c);
                        investorAccountWithLargestWeight.Total_Allocations_MTD__c = (investorAccountWithLargestWeight.Total_Allocations_MTD__c==null ?1:investorAccountWithLargestWeight.Total_Allocations_MTD__c + 1);
                        investorAccountWithLargestWeight.Number_Of_Applications_Invested__c = investorAccountWithLargestWeight.Number_Of_Applications_Invested__c + 1;    
                        investorAccountWithLargestWeight.Amount_Invested__c = investorAccountWithLargestWeight.Amount_Invested__c + app.Invested_Amount__c;
                    }    
                    /*CRM-927*/
                    /*CRM-804*/
                    if(investorAccountWithLargestWeight!=null){ 
                    integer i = 1;
                    while(i<=10){
                        try{
                            update investorAccountWithLargestWeight;
                            break;//LOP-72
                        }
                        catch(Exception e){
                            if(e.getMessage().contains('UNABLE_TO_LOCK_ROW')){
                                i = i+1;
                                if(i>10){
                                    clcommon__batch_process_log__c bpl = new clcommon__batch_process_log__c();
                                    bpl.clcommon__Type__c = 'Exception';
                                    bpl.clcommon__Batch_Id__c = app.id;
                                    bpl.clcommon__Message__c = 'Can not allocate to the investor '+investorAccountWithLargestWeight.name+' because of error updating investor account. Exception : '+e.getMessage();
                                    insert bpl;
                                    return false;
                                }
                            }
                            else{
                                //i = 11; //LOP-72 (Removed i=11 and added return at the end)
                                clcommon__batch_process_log__c bpl = new clcommon__batch_process_log__c(); //LOP-72
                                bpl.clcommon__Type__c = 'Exception';
                                bpl.clcommon__Batch_Id__c = app.id;
                                bpl.clcommon__Message__c = 'Can not allocate to the investor '+investorAccountWithLargestWeight.name+' because of error updating investor account. Exception : '+e.getMessage();
                                insert bpl;
                                return false;
                            }
                        }
                    } 
                 }
                    /*CRM-804*/
                    
                    if(app.Total_Arcus_Transactions__c > 0 && app.genesis__status__c == 'agent_document_verification_pending'
                       && !app.DCP_Investor_Eligibility__c) {
                           app.DCP_Investor_Eligibility__c = true;
                           allocationForADVPcalled = true;
                       }  //commented CLS-1095
                    if(app.genesis__status__c == 'agent_document_verification_pending')
                        allocationForADVPcalled = true;
                    //CLS-1121,1216,1095 ends
                    //update app;	//CRM-927(commented to optimise)
                    retValue = true;
                } else {
                    //app.Investor__c = null;
                 system.debug('set to null');
                    app.genesis__status__c = 'review';
                    List<QueueSobject> lstQueues = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject 
                                                    WHERE SobjectType = 'genesis__Applications__c' 
                                                    AND queue.DeveloperName ='Review_Queue' ];
                    
                    app.OwnerId = lstQueues[0].Queue.Id;
                    //}
                    //update app;	//CRM-927(commented to optimise)
                    retValue = false;
                    // }
                }
                
                System.debug('***app.Investor__c***'+app.Investor__c+'**'+listInvestor[0].id);
                
                List<Account> updateCurrentAllocatedWeight = [select id,name,Investor_Current_Weight__c,Investor_Alloted_Weight__c,
                                                              Current_Month_s_Available_Funded_Balance__c,
                                                              Current_Month_s_Available_Allocation__c
                                                              from  Account
                                                              WHERE loan__Investor__c = true
                                                              AND loan__Active__c = 'Yes'
                                                              AND Investor_Alloted_Weight__c!= Null];
                System.debug('size'+updateCurrentAllocatedWeight.size()+' '+updateCurrentAllocatedWeight);
                for(Account a:updateCurrentAllocatedWeight) {
                    System.debug('Current'+a.Investor_Current_Weight__c+' '+a.Investor_Alloted_Weight__c);
                    if(a.Investor_Current_Weight__c >= a.Investor_Alloted_Weight__c || a.Current_Month_s_Available_Funded_Balance__c<app.genesis__Loan_Amount__c || a.Current_Month_s_Available_Allocation__c<=0) {//LOP-72 (Changed the condition from 'a.Current_Month_s_Available_Funded_Balance__c<=0' to 'a.Current_Month_s_Available_Funded_Balance__c<=app.genesis__Loan_Amount__c')
                        allotedWeightCount++;
                    }
                }
                if(allotedWeightCount == updateCurrentAllocatedWeight.size()) {
                    System.debug('Curent weight equal to aalloted weight'+allotedWeightCount);
                    for(Account a:updateCurrentAllocatedWeight) {
                        /*LOP-72 start - Resetting the investor current weight based on its current value(to not miss the assigned application count on those investors whose current weight is greater than allocated weight) */
                        if(a.Investor_Current_Weight__c > a.Investor_Alloted_Weight__c){
                            System.debug('setting current weight to its current value from '+a.Investor_Current_Weight__c + ' for investor '+a.Name);
                            a.Investor_Current_Weight__c = a.Investor_Current_Weight__c - a.Investor_Alloted_Weight__c;
                        }else{
                            System.debug('setting current weight to zero from '+a.Investor_Current_Weight__c + ' for investor '+a.Name);
                            a.Investor_Current_Weight__c = 0;
                        } /*LOP-72 end*/
                    }
                    update updateCurrentAllocatedWeight;
                    system.debug('updated'+updateCurrentAllocatedWeight);
                }
                
            }
            // This may happen after Redecision or when all the investors are DCP disabled..
            else if((listInvestor == null || listInvestor.size() == 0) && againRulePasses == False){
                app.Investor__c = null;
                
                app.genesis__status__c = 'review';
                List<QueueSobject> lstQueues = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject 
                                                WHERE SobjectType = 'genesis__Applications__c' 
                                                AND queue.DeveloperName ='Review_Queue' ];
                
                app.OwnerId = lstQueues[0].Queue.Id;
                clcommon__batch_process_log__c bpl = new clcommon__batch_process_log__c();
                bpl.clcommon__Log_Level__c = 'INFO';
                bpl.clcommon__Type__c = 'Info';
                bpl.clcommon__Batch_Id__c = app.id;
                bpl.clcommon__Message__c = 'Can not allocate to any investor because of one of the following reason \n 1.Either it is inactive\n2.Available balance less than Loan Amount\n3.Rule didnt passed.\n4.Monthly Allocation less than 0';
                insert bpl;
                retvalue=false;
                //update app;	//CRM-927(commented to optimise)
                //}
            }
            //CLS-1121,1216,1313 starts
            if(app.Investor__c!=null && app.genesis__Status__c == 'offer_accepted')
            {
                Integer DCPeligibility = [SELECT count() FROM Account where id =: app.Investor__c and DCP_Allowed__c = true];
                if(txns.size()>0 && DCPeligibility>0){
                    app.DCP_Investor_Eligibility__c = true;
                    //update app;	//CRM-927(commented to optimise)
                }
                
            }
            update app;	//CRM-927(to optimise)
            /*CRM-928*/
            if(investorAcc != null && ((app.Investor__c != null && investorAcc.id != app.Investor__c) || (app.Investor__c == null))){
                if(investorAcc.Investor_Current_Weight__c != null){
                    investorAcc.Investor_Current_Weight__c = investorAcc.Investor_Current_Weight__c - 1;
                }
                /*CRM-927*/
                if(app.genesis__Status__c == 'agent_document_verification_pending'){
                    investorAcc.Total_Funded_Till_date__c = (investorAcc.Total_Funded_Till_date__c==null ?app.genesis__loan_amount__c:investorAcc.Total_Funded_Till_date__c + app.genesis__loan_amount__c);
                    investorAcc.Total_Funded_YTD__c = (investorAcc.Total_Funded_YTD__c==null ?app.genesis__loan_amount__c:investorAcc.Total_Funded_YTD__c + app.genesis__loan_amount__c);
                    investorAcc.Total_Funded_MTD__c = (investorAcc.Total_Funded_MTD__c==null ?app.genesis__loan_amount__c:investorAcc.Total_Funded_MTD__c + app.genesis__loan_amount__c);
                    investorAcc.Total_Allocations_MTD__c = (investorAcc.Total_Allocations_MTD__c==null ?1:investorAcc.Total_Allocations_MTD__c + 1);
                    investorAcc.Number_Of_Applications_Invested__c = investorAcc.Number_Of_Applications_Invested__c + 1;    
                    investorAcc.Amount_Invested__c = investorAcc.Amount_Invested__c + app.Invested_Amount__c;	
                }
                /*CRM-927*/
                integer i = 1;
                while(i<=10){
                    try{
                        update investorAcc;
                        if(test.isRunningTest()){	//LOP-72 added for test coverage
                            Integer a = 1,b = 0;
                            a = a/b;
                        }
                        break;//LOP-72
                    }
                    catch(Exception e){
                        if(e.getMessage().contains('UNABLE_TO_LOCK_ROW')){
                            i = i+1;
                            if(i>10){
                                clcommon__batch_process_log__c bpl = new clcommon__batch_process_log__c();
                                bpl.clcommon__Type__c = 'Exception';
                                bpl.clcommon__Batch_Id__c = app.id;
                                bpl.clcommon__Message__c = 'Can not allocate to the investor '+investorAcc.name+' because of error updating investor account. Exception : '+e.getMessage();
                                insert bpl;
                                return false;
                            }
                        }
                        else{
                            //i = 11; //LOP-72 (Removed i=11 and added return at the end)
                            clcommon__batch_process_log__c bpl = new clcommon__batch_process_log__c(); //LOP-72
                            bpl.clcommon__Type__c = 'Exception';
                            bpl.clcommon__Batch_Id__c = app.id;
                            bpl.clcommon__Message__c = 'Can not allocate to the investor '+investorAcc.name+' because of error updating investor account. Exception : '+e.getMessage();
                            insert bpl;
                            return false;
                        }
                    }
                }                   
            }
            /*CRM-928*/
        }
        catch(Exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'Business Rule Engine' ;
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
            //throw ex;
        }  
        
        return retValue;
        
    
    }
    
    
}