/* ****************Modification History******************
 * Created By       	 Date          JIRA number
 *1. Pallavi/Anusha		2020/11/19 	   CRM-1022 Status 500 responses causing missing data in CLS - CLS Case #02456279
 ******************Modification History******************/

global class SelectOfferFromUI {
    
   global static Account sameInvestor = null;//CRM-1022 (pallavi)
   global static decimal oldLoanAmount = 0;	//CRM-1022 (pallavi) 
   global static Id oldInvestorId = null; // CRM-1022
   webservice static String selectOffer(String applicationID,String offerID){
        
        system.debug('application id'+applicationID);
        system.debug('offerID'+offerID);

        List<Pricing_Offer__c> offerForDel=new List<Pricing_Offer__c>();
        List<Pricing_Offer__c> pOffer;
        list<Pricing_Offer__c> pOfferDel=[select id from Pricing_Offer__c
                                         where Application__c=:applicationID and Is_Offer_Selected__c=true];
       String oldAppStatus = '';	//CRM-1022 (pallavi)
                                           
        system.debug(pOfferDel);

        Savepoint sp = Database.setSavepoint();
       
        for(Pricing_Offer__c pdel:pOfferDel){
            pdel.Is_Offer_Selected__c=false;
            offerForDel.add(pdel);
        }

        try{
          update offerForDel;
        }catch(System.Exception ex){
          System.debug(ex.getStackTraceString());
          loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
          bplog.loan__Origin__c = 'SelectOfferUI' ;
          bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
          bplog.loan__Type__c = 'Exception';
          bplog.loan__Time__c = DateTime.now();
          insert bplog;
        }
                    
        Approved_Offer__c approve = new Approved_Offer__c();
        List<Approved_Offer__c> approve1;
        genesis__Applications__c app =[select id,
                                       genesis__Term__c,
                                       genesis__APR__c,
                                       Origination_fee__c,
                                       genesis__Monthly_Debt_Payments__c,
                                       genesis__Interest_Rate__c,
                                       genesis__Loan_Amount__c,
                                       genesis__Financed_Amount__c,
                                       genesis__Status__c,
                                       Investor__c,
                                       Investor__r.name	//remove
                                       from genesis__Applications__c
                                       where id=:applicationID 
                                       limit 1];
        
        system.debug('app'+app);
        oldAppStatus = app.genesis__Status__c;	//CRM-1022 (pallavi)
        oldLoanAmount = app.genesis__Loan_Amount__c;	//CRM-1022 (pallavi)
       	oldInvestorId = app.Investor__c; //CRM-1022
        
        pOffer=[select id,
                Above_prime_max__c,
                Amount__c,
                Application__c,
                APR__c,
                Interest_Rate__c,
                Is_Offer_Selected__c,
                Key__c,
                Monthly_Payment__c,
                Origination_fee__c,
                Origination_fee_rate__c,
                Pricing_Tier__c,
                Segment__c,
                Term__c,
                Type__c,
                EBP_Offer_Code__c,
                EBP_Parent_Offer_Key__c
                from Pricing_Offer__c
                where Application__c=:applicationID 
                and id=:offerID ];

        system.debug(pOffer);
        
        approve1=[select id,
                  Above_prime_max__c,
                  Amount__c,
                  Application__c,
                  APR__c,
                  Interest_Rate__c,
                  Key__c,
                  Monthly_Payment__c,
                  Origination_fee__c,
                  Origination_fee_rate__c,
                  Pricing_Tier__c,
                  Segment__c,
                  Term__c,
                  Type__c,
                  EBP_Offer_Code__c,
                  EBP_Parent_Offer_Key__c
                  from Approved_Offer__c
                  where Application__c=:applicationID];
        system.debug('approve1'+approve1);
        
        delete approve1;
        
        if(pOffer.size()>0){
            
            for (Pricing_Offer__c p: pOffer){
                
                approve.Above_prime_max__c=p.Above_prime_max__c;
                system.debug(approve.Above_prime_max__c);
                approve.Amount__c=p.Amount__c;
                approve.Application__c=p.Application__c;
                approve.APR__c=String.valueOf(p.APR__c);
                approve.Interest_Rate__c=String.ValueOf(p.Interest_Rate__c);
                approve.Key__c=String.valueOf(p.Key__c);
                approve.Monthly_Payment__c=p.Monthly_Payment__c;
                approve.Origination_fee__c=String.valueOf(p.Origination_fee__c);
                approve.Origination_fee_rate__c=String.valueOf(p.Origination_fee_rate__c);
                approve.Pricing_Tier__c=p.Pricing_Tier__c;
                approve.Segment__c=p.Segment__c;
                approve.Term__c=p.Term__c;
                approve.Type__c=p.Type__c;
                approve.EBP_Offer_Code__c=p.EBP_Offer_Code__c;
                approve.EBP_Parent_Offer_Key__c=p.EBP_Parent_Offer_Key__c;

                insert approve;
                
                system.debug('approve'+approve);
                
                app.genesis__Loan_Amount__c=p.Amount__c;
                app.genesis__APR__c=p.APR__c;
                app.genesis__Term__c=p.Term__c;
                app.Origination_fee__c=p.Origination_fee__c;
                app.genesis__Monthly_Debt_Payments__c=p.Monthly_Payment__c;
                app.genesis__Interest_Rate__c=p.Interest_Rate__c;
                if(p.EBP_Offer_Code__c == null || p.EBP_Offer_Code__c.length() == 0) {
                    app.genesis__Status__c='offer_accepted';
                }
                else {
                    app.genesis__Status__c='offer_shown';
                }
                Decimal financeamount= Decimal.valueOf(string.valueof(p.Amount__c - p.Origination_fee__c)); // change by Saryu to capture decimal value and round to 2
                app.genesis__Financed_Amount__c=genesis.ValueUtil.round(financeamount);
                system.debug('finance amount'+financeamount);
                
                try{

                    if(app.Investor__c!=null && oldAppStatus.equalsIgnoreCase('offer_accepted')) {	//CRM-1022 (pallavi) added status condition
                        
                        //update app; //CRM-1022 (pallavi) (moving inside if block)                      
                        String res = runInvestorAllocationBasedOnWeighting(app); //CRM-1022 (pallavi) changed app.id to app
                        
                        if(res.equalsIgnoreCase('Success')) {
                          
                          integer i = 1;
                            if(sameInvestor != null){
                            while(i<=10){
                                try{
                                    Update sameInvestor;
                                    break;
                                }
                                catch(Exception e){
                                    if(e.getMessage().contains('UNABLE_TO_LOCK_ROW')){
                                        i = i+1;
                                    }
                                    else{
                                        //CRM-1022 new
                                        loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
                                        bplog.loan__Origin__c = 'SelectOfferUI' ;
                                        bplog.loan__Message__c = 'Error: ' + e.getLineNumber() + 'selectOffer' + ':: Desc. ' + e.getMessage()+' :: Stack: '+e.getStackTraceString();
                                        bplog.loan__Type__c = 'Exception';
                                        bplog.loan__Time__c = DateTime.now();
                                        insert bplog;
                                        return e.getMessage();
                                    }
                                }
                            }
                                //CRM-1022 new
                                if(i == 11){
                                     loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
                                        bplog.loan__Origin__c = 'SelectOfferUI' ;
                                        bplog.loan__Message__c = 'Error: ' + 'UNABLE_TO_LOCK_ROW for investor : '+app.Investor__r.name;
                                        bplog.loan__Type__c = 'Exception';
                                        bplog.loan__Time__c = DateTime.now();
                                        insert bplog;
                                    return 'Error updating investor';
                                }
                                        
                          }      
                          
                          update app;
                            
                          system.debug('appupdated'+app);
                          p.Is_Offer_Selected__c=true;                          
                          update p;   

                          system.debug('offerupdated'+p);
                          if(!test.isRunningTest())//CRM-1022 - added this condition only to handle test case
                          	ApplicationAttachmentHandler.savePdfAttachment(app.Id);

                          return 'Offer is been successfully approved/selected';

                        } else {
                            
                            Database.rollback(sp);
                            return res;
                        }

                    } else {

                        update app;
                        system.debug('appupdated'+app);
                        p.Is_Offer_Selected__c=true;
                        update p; 

                    }
                    MW_Utilities.clearDCPForEBP(approve);
                    
                } catch(System.Exception err){
                    Database.rollback(sp);
                    System.debug(err.getStackTraceString());
                    loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
                    bplog.loan__Origin__c = 'SelectOfferUI' ;
                    bplog.loan__Message__c = 'Error: ' + err.getLineNumber() + 'RunInvestorAllocationBasedOnWeightingValue' + ':: Desc. ' + err.getMessage()+' :: Stack: '+err.getStackTraceString();
                    bplog.loan__Type__c = 'Exception';
                    bplog.loan__Time__c = DateTime.now();
                    insert bplog;
                    System.debug(err.getStackTraceString());
                    return err.getMessage();
                }
                
            }
        }
       return 'Offer is been successfully approved/selected';
        
    }

    webservice static void getselectedoffer(string appID){
        
        List<Approved_offer__c> approve1=[select id,name                  
                                          from Approved_Offer__c
                                          where Application__c=:appID];
        
        if(approve1 == null || approve1.size() == 0){
            throw new ints.IntegrationException('You are not allowed to select the Initial offer');
            
        }                                  
                                          
    }
    
    public static String runInvestorAllocationBasedOnWeighting (genesis__Applications__c app) {	//CRM-1022(pallavi) changed parameter
        
        String returnResponse = '';
        Account investorAcc;
      
      try{

            /*genesis__Applications__c app = [Select id,name,	//CRM-1022(pallavi) commented
                                            Investor__c,
                                            genesis__status__c,
                                            genesis__loan_amount__c,
                                            Invested_Amount__c,
                                            genesis__Lending_Product__c,
                                            Last_Investor_Assigned_On__c
                                            FROM genesis__Applications__c
                                            WHERE id =: appiD];*/
            
            //Check if the Applicastions has already assigned investor.                                        
            
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

            List<Account> activeInvestor = [Select id,name,loan__Investor__c,loan__Active__c
                                            FROM Account
                                            WHERE loan__Investor__c = true
                                            AND loan__Active__c = 'Yes'];
            
            List<Account> listInvestor = new List<Account>();

            if(activeInvestor==null || activeInvestor.size()==0) {

                 returnResponse = 'No active investors available';

            }/* else if((activeInvestor!=null && activeInvestor.size()==1) /*|| app.Investor__c==null*//*) {
                
                listInvestor = [Select id,name,
                                          Investment_Rules__c,
                                          loan__Investor__c,
                                          Last_Application_assigned_on__c,
                                          Amount_Invested__c,
                                          Number_Of_Applications_Invested__c,
                                          Investor_Alloted_Weight__c,
                                          Investor_Current_Weight__c,Current_Month_s_Available_Funded_Balance__c
                                          FROM Account
                                          WHERE loan__Investor__c = true
                                          AND loan__Active__c = 'Yes'
                                          AND Investment_Rules__c not in: setruleIDs
                                          AND Remaining_Amount__c >=: app.genesis__loan_amount__c
                                          AND Remaining_Applications__c >=: 1
                                          order by Investor_Alloted_Weight__c desc
                                          ];
            }*/	//CRM-1022(pallavi) removing the unnecessary condition
			else {
                listInvestor = [Select id,name,
                                          Investment_Rules__c,
                                          loan__Investor__c,
                                          Last_Application_assigned_on__c,
                                          Amount_Invested__c,
                                          Number_Of_Applications_Invested__c,
                                          Investor_Alloted_Weight__c,
                                          Investor_Current_Weight__c,Current_Month_s_Available_Funded_Balance__c,
                                		  Current_Month_s_Available_Allocation__c,	//CRM-1022 
                                		  Total_Funded_Till_date__c,	//CRM-1022 
                                		  Total_Funded_YTD__c,	//CRM-1022 
                                		  Total_Funded_MTD__c	//CRM-1022 	
                                          FROM Account
                                          WHERE loan__Investor__c = true
                                          AND loan__Active__c = 'Yes'
                                          AND Investment_Rules__c not in: setruleIDs
                                          /*AND Remaining_Amount__c >=: app.genesis__loan_amount__c	//CRM-1022 pallavi (wrong conditions)
                                          AND Remaining_Applications__c >=: 1*/
                                          //and id !=:app.Investor__c      commenting as we should not skip the already assigned investor
                                          AND Current_Month_s_Available_Funded_Balance__c >=: app.genesis__loan_amount__c //CRM-1022 pallavi (added the correct conditions)
                                		  AND Current_Month_s_Available_Allocation__c >0 
                                          order by Investor_Alloted_Weight__c desc
                                          
                                         ];
            }
            
            if(listInvestor != null && listInvestor.size() > 0 ){
                
                // Logic to asign based on the partner weighting
                Integer totalInvestor = listInvestor.size();
                Integer allotedWeightCount = 0;
                Integer currentWeightZero = 0;
                Decimal investorWithLargestWeight = 0;
                Account investorAccountWithLargestWeight = null;
                for(Account acc : listInvestor) {
                    if(app.Investor__c!=null && acc.id==app.Investor__c) {
                        /*CRM-1022*/
                        if(oldLoanAmount != app.genesis__loan_amount__c){
                            if(app.Invested_Amount__c != null)
                                acc.Amount_Invested__c = acc.Amount_Invested__c - app.Invested_Amount__c;
                            app.Invested_Amount__c = app.genesis__loan_amount__c;
                            acc.Amount_Invested__c = acc.Amount_Invested__c + app.Invested_Amount__c;
                            acc.Last_Application_assigned_on__c = system.now();
                            app.Last_Investor_Assigned_On__c = acc.Last_Application_assigned_on__c;
                            acc.Total_Funded_Till_date__c = (acc.Total_Funded_Till_date__c==null ?app.genesis__loan_amount__c:acc.Total_Funded_Till_date__c + app.genesis__loan_amount__c-oldLoanAmount);
                    		acc.Total_Funded_YTD__c = (acc.Total_Funded_YTD__c==null ?app.genesis__loan_amount__c:acc.Total_Funded_YTD__c + app.genesis__loan_amount__c-oldLoanAmount);
                    		acc.Total_Funded_MTD__c = (acc.Total_Funded_MTD__c==null ?app.genesis__loan_amount__c:acc.Total_Funded_MTD__c + app.genesis__loan_amount__c-oldLoanAmount);
                            sameInvestor = acc;
                        }
                        /*CRM-1022*/
                        return 'Success';
                    }
                    if(acc.Investor_Current_Weight__c ==0) {
                        currentWeightZero++;
                    }
                }
                System.debug('TotalInvestor'+totalInvestor+' applicationAssignedtoInvestornull'+currentWeightZero);
                if(currentWeightZero == totalInvestor) {
                    for(Account acc : listInvestor) {
                        if(investorWithLargestWeight < acc.Investor_Alloted_Weight__c && acc.Current_Month_s_Available_Funded_Balance__c>0 && acc.Current_Month_s_Available_Allocation__c>0) {	//CRM-1022(added last condition)
                            investorWithLargestWeight = acc.Investor_Alloted_Weight__c;
                            investorAccountWithLargestWeight = acc;
                        }
                    }
                    System.debug('testing here'+investorAccountWithLargestWeight.Investor_Alloted_Weight__c);
                    app.Investor__c = investorAccountWithLargestWeight.id;
                    app.Last_Investor_Assigned_On__c = System.now();
                    app.Invested_Amount__c = app.genesis__loan_amount__c;	//CRM-1022 syncing up with InvestorAllocation
                    investorAccountWithLargestWeight.Investor_Current_Weight__c  = investorAccountWithLargestWeight.Investor_Current_Weight__c+1;
                    investorAccountWithLargestWeight.Last_Application_assigned_on__c = System.now();
                    
                } else {
                    integer flag=0;
                    System.debug('account list'+listInvestor);
                    for(Account acc : listInvestor) {
                        if(acc.Investor_Current_Weight__c < acc.Investor_Alloted_Weight__c && acc.Current_Month_s_Available_Funded_Balance__c>0) {
                            investorAccountWithLargestWeight= acc;
                            app.Investor__c = investorAccountWithLargestWeight.id;
                            app.Last_Investor_Assigned_On__c = System.now();
                            System.debug('testing here'+investorAccountWithLargestWeight.Investor_Alloted_Weight__c);
                            investorAccountWithLargestWeight.Investor_Current_Weight__c  = investorAccountWithLargestWeight.Investor_Current_Weight__c+1;
                            investorAccountWithLargestWeight.Last_Application_assigned_on__c = System.now();
                            break;
                        }
                    }
                    
                }
                
                System.Debug('In new Investor');
                //update listInvestor;
                /*CRM-1022*/
                if(investorAccountWithLargestWeight == null){
                    for(Account acc : listInvestor) {
                                if(acc.Investor_Current_Weight__c >= acc.Investor_Alloted_Weight__c && acc.Current_Month_s_Available_Funded_Balance__c>0 && acc.Current_Month_s_Available_Allocation__c>0) {
                                    investorAccountWithLargestWeight= acc;
                                    app.Investor__c = investorAccountWithLargestWeight.id;
                                    app.Last_Investor_Assigned_On__c = System.now();
                                    app.Invested_Amount__c = app.genesis__loan_amount__c;
                                    investorAccountWithLargestWeight.Investor_Current_Weight__c  = 1;
                                    investorAccountWithLargestWeight.Last_Application_assigned_on__c = System.now();
                                    returnResponse = 'Success';
                                    break;
                               }
                    }
                 }   
                /*CRM-1022*/  
                if(investorAccountWithLargestWeight !=null) {
                    update investorAccountWithLargestWeight;
                    update app;
                    returnResponse = 'Success';
                } else {		
                    returnResponse = 'No other investors have allocations left';
                }    
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
                    if(a.Investor_Current_Weight__c >= a.Investor_Alloted_Weight__c || a.Current_Month_s_Available_Funded_Balance__c<=0 || a.Current_Month_s_Available_Allocation__c<=0) {	//CRM-1022 (syncing up with InvestorAllocation)
                        allotedWeightCount++;
                    }
                }
                if(allotedWeightCount == updateCurrentAllocatedWeight.size()) {
                    System.debug('Curent weight equal to aalloted weight'+allotedWeightCount);
                    for(Account a:updateCurrentAllocatedWeight) {
                        System.debug('setting value to zero'+a.Investor_Current_Weight__c);
                        a.Investor_Current_Weight__c = 0;
                    }
                    update updateCurrentAllocatedWeight;
                    system.debug('updated'+updateCurrentAllocatedWeight);
                }
                
            }
            // This may happen after Redecision..
            else if((listInvestor == null || listInvestor.size() == 0) && app.Investor__c != null){
                returnResponse = 'No such investors available';
            }
            
        }catch(Exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'Business Rule Engine' ;
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
            
            returnResponse = 'Error '+ ex.getMessage()+ ' Occured at line number:'+ex.getLineNumber();
        } 
        //CRM-1022 -- start -- update old investor current weight(decrement the weight by 1 if investor is changed)
        if(oldInvestorId != null && app.Investor__c != oldInvestorId){
            Account oldInvestor = [select id, name, Investor_Current_Weight__c from Account where id =:oldInvestorId limit 1];
            oldInvestor.Investor_Current_Weight__c = oldInvestor.Investor_Current_Weight__c -1;
            
            Integer i = 1;
            if(oldInvestor != null){
                while(i<=10){
                    try{
                        Update oldInvestor;
                        break;
                    }
                    catch(Exception e){
                        if(e.getMessage().contains('UNABLE_TO_LOCK_ROW')){
                            i = i+1;
                        }
                        else{
                            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
                            bplog.loan__Origin__c = 'SelectOfferUI' ;
                            bplog.loan__Message__c = 'Error: ' + e.getLineNumber() + 'selectOffer' + ':: Desc. ' + e.getMessage()+' :: Stack: '+e.getStackTraceString();
                            bplog.loan__Type__c = 'Exception';
                            bplog.loan__Time__c = DateTime.now();
                            insert bplog;
                            return e.getMessage();
                        }
                    }
                }
                if(i == 11){
                    loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
                    bplog.loan__Origin__c = 'SelectOfferUI' ;
                    bplog.loan__Message__c = 'Error: ' + 'UNABLE_TO_LOCK_ROW for investor : '+oldInvestor.name;
                    bplog.loan__Type__c = 'Exception';
                    bplog.loan__Time__c = DateTime.now();
                    insert bplog;
                    return 'Error updating previous investor current weight';
                }
                
            }
        }//CRM-1022 -end
        
        return returnResponse;
    }
}