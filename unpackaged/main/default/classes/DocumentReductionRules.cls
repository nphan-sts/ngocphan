/* ****************Modification History******************
* Last Modified by        Date          JIRA number

*     4. Anusha     2020/11/26      CRM-881 Add Retirement Document to CLS
*      3. Pallavi     2020/11/09      LOP-48/CRM-966(Consider Manual KBA Process for ID Reduction Logic)  
*     2. Neha          2019/06/20        CLS-1281
*      1. Pallavi        2019/06/13        CLS-1270
*      
******************Modification History******************/
public with Sharing class DocumentReductionRules{
    
    @InvocableMethod    
    public static void callDocReduction(List<Id> applicationIds) {
        System.debug('hello');
        if(applicationIds!=null && applicationIds.size()>0)
            payStubReduction(applicationIds[0]);
    }
    
    public Static void payStubReduction(Id applicationId){
        Boolean bonusFlag = false, selfempFlag = false, annualIncomeFlag = false, creditTradeFlag = false, FraudTagFlag = false, employmentflag = false;
        List<genesis__Application_Document_Category__c> lstUpdateCat = new List<genesis__Application_Document_Category__c>();
        try{
            //----PayStub Reduction
            genesis__Applications__c app = [SELECT  Total_Stated_Income__c,genesis__Loan_Amount__c,Employment_Status__c,genesis__Account__c, 
                                            Payment_Mode__c,Sift_Status__c,genesis__status__c, Manual_KBA__c,                                            
                                            (select id,name,Income_Include_Bonuses_or_Commissions__c from genesis__Employment_Information__r order by createddate limit 1),
                                            (Select Net_Disposable_Income_NDI__c,Unsecured_Installment_Loans_Count__c from Credit_Policy__r Order By createddate LIMIT 1),
                                            (SELECT Precise_ID_Overall_SCore__c, Precise_ID_First_Payment_Default__c,Precise_ID_ID_Theft__c,  
                                             Precise_ID_Validation__c,Phone_Verification_Result__c, Precise_ID_Adverse_Action_Code__c, 
                                             Precise_ID_Decision__c,Precise_ID_Decision_KIQ__c, Precise_ID_General_Fraud_Shield_Indicat__c, 
                                             Id_Analytics_Score__c,Consistency_Snapd_score__c,Paste_Count__c,Accept_Refer_Code__c,
                                             Public_Records__c FROM KBA_Details__r Order By createddate desc Limit 1),Annual_Individual_Income_App__c  
                                             FROM genesis__Applications__c where Id=:applicationId];
            if(null != app){ 
                
                if(app.Credit_Policy__r!= null && app.Credit_Policy__r.size() > 0 && app.Credit_Policy__r[0].Net_Disposable_Income_NDI__c != null){
                    Decimal NDIncome = decimal.valueOf(app.Credit_Policy__r[0].Net_Disposable_Income_NDI__c);                  
                    if(NDIncome > 1000 && NDIncome < 8000)
                        creditTradeFlag = true;
                }
                
                if(app.Annual_Individual_Income_App__c != null){
                    List<Talx__c> talxInfo = [SELECT Salary__c, Employeer__c from Talx__c 
                                                where Application__c =: applicationId and (NOT Employeer__c LIKE '%No Hit%') LIMIT 1];
                    if(! talxInfo.isEmpty() && talxInfo[0].Salary__c != null){
                        List<AggregateResult> groupedResults = [SELECT SUM(Salary__c)SumSal from Talx__c where Application__c =: applicationId];
                        Decimal talxSal = 0 ;
                        String str = '' + groupedResults[0].get('SumSal') ;
                        talxSal = Decimal.ValueOf(str) ;
                        Decimal indvIncome = app.Annual_Individual_Income_App__c;
                        System.debug('.. talxSal.. '+ talxSal );
                        System.debug('.. indvIncome .. '+ indvIncome );
                        Decimal deviationIncome = (talxSal / indvIncome) * 100;
                        System.debug('.. deviationIncome .. '+ deviationIncome );
                        if(deviationIncome >= 85)
                            annualIncomeFlag = true;
                        System.debug('.. annualIncomeFlag .. '+ annualIncomeFlag );    
                    }
                    System.debug('.. talxInfo.. '+ talxInfo);
                    System.debug('.. talxInfo.isEmpty().. '+ talxInfo.isEmpty());
                    if(talxInfo.isEmpty()) {
                        System.debug(logginglevel.error,'app.genesis__Employment_Information__r SIZE ::'+app.genesis__Employment_Information__r.size());   
                        Boolean IncomeIncludeBonusesOrCommissions;
                        if(app.genesis__Employment_Information__r.size() == 0){
                            System.debug(logginglevel.error,'no emp info');
                            IncomeIncludeBonusesOrCommissions = False;                               
                        }else if (app.genesis__Employment_Information__r.size() > 0){
                            List<genesis__Employment_Information__c> BonusCheck = [select Income_Include_Bonuses_or_Commissions__c from genesis__Employment_Information__c
                                                                                    where genesis__Application__c=:applicationID Order By createddate DESC LIMIT 1];
                            IncomeIncludeBonusesOrCommissions = BonusCheck[0].Income_Include_Bonuses_or_Commissions__c;
                            System.debug('..  App IncomeIncludeBonusesOrCommissions.. '+ BonusCheck[0].Income_Include_Bonuses_or_Commissions__c);
                        }
                        if((app.Employment_Status__c != null && (app.Employment_Status__c == 'Full Time' || app.Employment_Status__c == 'Part Time')) && !(IncomeIncludeBonusesOrCommissions))
                            bonusFlag = true;
                        System.debug('.. IncomeIncludeBonusesOrCommissions.. '+ IncomeIncludeBonusesOrCommissions);
                        System.debug('.. bonusFlag.. '+ bonusFlag);
                    }
                    if(app.Employment_Status__c != null && app.Employment_Status__c == 'Self Employed') selfempFlag = true;
                    System.debug('.. selfempFlag .. '+ selfempFlag );
                } 
                //Modified by Pallavi on 2019/06/13 for CLS-1270 
                if((app.Employment_Status__c != null && (app.Employment_Status__c == 'Retired' || app.Employment_Status__c == 'Investment' || app.Employment_Status__c == 'Other' || app.Employment_Status__c == 'Seasonal' || app.Employment_Status__c == 'Self Employed'))){
                    employmentflag = true;
                    System.debug('** employmentflag** '+ employmentflag);
                }
                //Modified by Pallavi on 2019/06/13 for CLS-1270
                // --- ID Reduction----
                Boolean siftFlag= false, pRecordsFlag= false, pidScoreFlag= false, pidFPDFlag= false, pidValidationFlag= false, pidShieldFlag= false, pidAdvActionFlag= false, pidDecisionFlag= false, pidKIQDecisionFlag= false, pidVerificationFlag= false, pidAnalyticsFlag= false, pidConsistencyFlag= false, pidPCountFlag = false;
                
                if(! app.KBA_Details__r.isEmpty()){ 
                    System.debug('KBA...' + app.KBA_Details__r);
                    
                    //changing ID Reduction rules per revised requirements on CLS-040  09/04/2018  
                    //LOP-563
                    if((app.KBA_Details__r[0].Precise_ID_Overall_SCore__c != 9012 && app.KBA_Details__r[0].Precise_ID_Overall_SCore__c != null)//LOP-574
                       || (app.genesis__Status__c == 'kba_success' 
                           && app.KBA_Details__r[0].Precise_ID_Overall_SCore__c != 9012
                           && (app.KBA_Details__r[0].Accept_Refer_Code__c == null || app.KBA_Details__r[0].Accept_Refer_Code__c == 'ACC' || app.KBA_Details__r[0].Accept_Refer_Code__c =='REF'))){  //CRM-966(added one condition)
                               System.debug('eligible for reduction');
                               pidScoreFlag = true;                        
                           }
                    
                    
                    System.debug('... pidScoreFlag...'+pidScoreFlag);
                    
                }
                
                //changing ID Reduction rules per revised requirements on CLS-040  09/04/2018
                List<Application_Tags__c> FraudTags = [SELECT Application_Tag__c FROM Application_Tags__c where Application__c = :app.Id and Application_Tag__c LIKE '%Fraud%' and softDelete__c = false];  //pallavi LOS-212
                if(FraudTags.isEmpty()){                           
                    FraudTagFlag = true;   }
                
                System.debug('... FraudTagFlag...'+FraudTagFlag);
                
                //-- ID Reduction Conditions
                //changing ID Reduction rules per revised requirements on CLS-040  09/04/2018
                //if(pidFPDFlag && pidValidationFlag && pidVerificationFlag && pidScoreFlag && FraudTagFlag ){
                //if(pidFPDFlag && pidValidationFlag && pidVerificationFlag && pidScoreFlag && pidShieldFlag && pidAdvActionFlag && pidDecisionFlag && pidPCountFlag && pidKIQDecisionFlag && siftFlag && creditTradeFlag && pidAnalyticsFlag  && pidConsistencyFlag ){
                if(pidScoreFlag && FraudTagFlag ){  
                    System.debug('... ID Reduction Conditions...');
                    List<genesis__Application_Document_Category__c> docCategory = [SELECT ID, genesis__Required__c FROM genesis__Application_Document_Category__c where genesis__Application__c=:applicationId and name LIKE '%ID%' ];
                    
                    if(!docCategory.isEmpty()){
                        System.debug('docCategory.....'+ docCategory); 
                        for(genesis__Application_Document_Category__c appDocCat : docCategory){
                            appDocCat.genesis__Required__c = false;
                            lstUpdateCat.add(appDocCat);
                        }
                    }                   
                }
                //LOP-574
                if(!pidScoreFlag || !FraudTagFlag ){  
                    System.debug('... ID Reduction Conditions...');
                    List<genesis__Application_Document_Category__c> docCategory = [SELECT ID, genesis__Required__c FROM genesis__Application_Document_Category__c where genesis__Application__c=:applicationId and name LIKE '%ID%' ];
                    
                    if(!docCategory.isEmpty()){
                        System.debug('docCategory.....'+ docCategory); 
                        for(genesis__Application_Document_Category__c appDocCat : docCategory){
                            appDocCat.genesis__Required__c = true;
                            lstUpdateCat.add(appDocCat);
                        }
                    }                   
                }
                
                //-- PayStub Conditions
                if(bonusFlag || annualIncomeFlag || selfempFlag || employmentflag){    
                    System.debug('... PayStub Conditions...');
                    System.debug('updateDocReduction.....'+ applicationId);       
                    List<genesis__Application_Document_Category__c> docCategory = [SELECT ID, genesis__Required__c FROM genesis__Application_Document_Category__c where genesis__Application__c=:applicationId and name LIKE  '%paystub%'];
                    
                    if(!docCategory.isEmpty()){
                        System.debug('docCategory.....'+ docCategory); 
                        for(genesis__Application_Document_Category__c appDocCat : docCategory){
                            appDocCat.genesis__Required__c = false;
                            lstUpdateCat.add(appDocCat);
                        }
                    }   
                }
                //Modified by BG for CLS-1270  -- Bank Statement reduction
                if((app.Employment_Status__c != null && (app.Employment_Status__c == 'Retired' || app.Employment_Status__c == 'Investment'|| app.Employment_Status__c == 'Other'|| app.Employment_Status__c == 'Seasonal'))){
                    System.debug('... BankStatement Conditions...');
                    List<genesis__Application_Document_Category__c> BankdocCategory = [SELECT ID, genesis__Required__c FROM genesis__Application_Document_Category__c where genesis__Application__c=:applicationId and genesis__Required__c =true and Name like '%Bank Statement%'];             
                    System.debug('BankdocCategory SIZE ::'+BankdocCategory.size());
                    if(!BankdocCategory.isEmpty() && BankdocCategory.size()>1){
                        System.debug('...in Bank State Loop... ');
                        Integer i = 1;  //pallavi
                        for(genesis__Application_Document_Category__c appDocCat : BankdocCategory){
                            if(i==1)  //pallavi
                                appDocCat.genesis__Required__c = true;  //pallavi
                            else                    //pallavi
                                appDocCat.genesis__Required__c = false;
                            lstUpdateCat.add(appDocCat);           
                            i++;  //pallavi
                        }                        
                    }
                }
                //CRM-881 - start
                if(app.Employment_Status__c != null && app.Employment_Status__c != 'Retired'){
                    System.debug('Employment_Status__c is not retired. Hence reducing retirement documents');
                    List<genesis__Application_Document_Category__c> retirementDocCategory = [Select ID, genesis__Required__c FROM genesis__Application_Document_Category__c where genesis__Application__c=:applicationId and genesis__Required__c =true and Name = 'Retirement'];
                    if(retirementDocCategory!= null && retirementDocCategory.size()>0){
                        for(genesis__Application_Document_Category__c appCategory:retirementDocCategory){
                            appCategory.genesis__Required__c = false;
                            lstUpdateCat.add(appCategory);
                        }
                    }
                }else if(app.Employment_Status__c != null && app.Employment_Status__c == 'Retired'){
                    System.debug('Employment_Status__c is retired. Hence reducing 1040 requirement and enabling retirement document category');
                    List<genesis__Application_Document_Category__c> doc1040Category = [Select ID, genesis__Required__c FROM genesis__Application_Document_Category__c where genesis__Application__c=:applicationId and genesis__Required__c = true and Name like '%1040%'];
                    if(doc1040Category!= null && doc1040Category.size()>0){
                        for(genesis__Application_Document_Category__c appCategory:doc1040Category){
                            appCategory.genesis__Required__c = false;
                            lstUpdateCat.add(appCategory);
                        }
                    }
                    List<genesis__Application_Document_Category__c> retirementDocCategory = [Select ID, genesis__Required__c FROM genesis__Application_Document_Category__c where genesis__Application__c=:applicationId and genesis__Required__c = false and Name = 'Retirement'];
                    if(retirementDocCategory!= null && retirementDocCategory.size()>0){
                        for(genesis__Application_Document_Category__c retirementCategory:retirementDocCategory){
                            retirementCategory.genesis__Required__c = true;
                            lstUpdateCat.add(retirementCategory);
                        }
                    }
                }
                //CRM-881 - end
                updateDocReduction(lstUpdateCat);
            }
        }
        catch(Exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__origin__c = 'DocumentReductionRules',loan__Type__c = 'Exception', loan__Batch_Id__c = applicationId, loan__Message__c = 'Error in DocumentReductionRules: '+ ex.getlinenumber() + 'Error: ' + ex.getMessage());
            insert logs;
        }
    }
    
    public static void updateDocReduction(List<genesis__Application_Document_Category__c> lstUpdateCat){        
        if(!lstUpdateCat.isEmpty()){  
            try{           
                update lstUpdateCat;
            }catch(Exception ex){
                MW_LogUtility.ExceptionDO expRex = new MW_LogUtility.ExceptionDO(ex);
                MW_DataDogCallOut.futureSend(JSON.serialize(MW_LogUtility.getLogRecord('MW_ApplicationService', lstUpdateCat[0].Id, null, 'UpdateAccount',JSON.serialize(expRex),'Error',null)), new List<String>());
            }
        }        
    }
}