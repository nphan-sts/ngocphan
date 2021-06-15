/* ****************Modification History******************
 * Last Modified by        Date          JIRA number
 *      1. Pallavi     2020/11/09      CRM-966(Consider Manual KBA Process for ID Reduction Logic)  
 *      2. Anusha     2020/11/26      CRM-881 Add Retirement Document to CLS
 
 ******************Modification History******************/
@isTest
Private Class DocumentReductionRulesTest{
    @testSetup
    static void setup(){
       test.startTest();
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com',
            Annual_Individual_Income__c = 10000 
        );
        Insert acc;
        genesis__Applications__c app = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = acc.Id,        
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'agent_verified',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time',
            Sift_Status__c=30
        );      
        Insert app; 
        
        
         genesis__Applications__c app1 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = acc.Id,        
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'agent_verified',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time',
            Sift_Status__c=30
        );      
        Insert app1;
        genesis__Employment_Information__c empInfo = new genesis__Employment_Information__c(
            genesis__Application__c = app.Id,
            Income_Include_Bonuses_or_Commissions__c = false    
        );
        insert empInfo;
        
         
        Talx__c talx = new Talx__c(
            Application__c = app1.Id,
            Employeer__c = 'Test',
            Salary__c = 18500,
            Hire_Date__c = System.Today()
        );
        Insert talx;
        
        MW_Settings__c leadsEndPoint = new MW_Settings__c ();
        leadsEndPoint.LEADS_FE_EndpointURL__c = 'https://sfapi-dev.payoff.com/ms/api/cls/update_user';
        insert leadsEndPoint ;
        
        CL_Document__c clDocs = new CL_Document__c();
        clDocs.Doc1__c = 'Credit Score Notice';
        clDocs.Doc2__c = 'TIL Document';
        clDocs.Doc3__c = 'Adverse Action Notice';
        clDocs.UploadedBOX__c = 'UploadedBOX';
        insert clDocs ;
        
        genesis__Document_Category__c docCat = new genesis__Document_Category__c(
            genesis__Category_Name__c = 'Test_Paystub_ID',
            genesis__Required__c = true
        );
        Insert docCat;
        genesis__Application_Document_Category__c appDocCat = new genesis__Application_Document_Category__c(
            Name = 'Test_paystub_ID_doc',
            genesis__Document_Category__c = docCat.Id,
            genesis__Application__c = app.Id
        );
        Insert appDocCat;
        Credit_Policy__c cPolicy = new Credit_Policy__c(
            Name='TestPolicy',
            Application__c =app.Id,
            Net_Disposable_Income_NDI__c='2000'
        );
        Insert cPolicy; 
        
        Application_Tags__c apptag = new Application_Tags__c(
        Application_Tag__c = 'Soft Pull Requested.',
        Application__c = app.id);
        insert apptag;
        KBA_Details__c kbaObj = new KBA_Details__c(
            Application__c = app.Id,
            Precise_ID_Overall_SCore__c = 901, 
            Precise_ID_First_Payment_Default__c = 9012, 
            Precise_ID_ID_Theft__c = 9012,  
            Precise_ID_Validation__c = 9012, 
            Precise_ID_Adverse_Action_Code__c = 'I', 
            Precise_ID_Decision__c = 'Accept',
            Precise_ID_Decision_KIQ__c = 'Accept', 
            Precise_ID_General_Fraud_Shield_Indicat__c = 'F04', 
            Id_Analytics_Score__c = 500, 
            Consistency_Snapd_score__c = 30, 
            Paste_Count__c = 1,
            Public_Records__c=0,
            Accept_Refer_Code__c= 'ACC'  //CRM-966
        );
        Insert kbaObj;
        test.stopTest();
    }
    //PayStub Reduction
    Static testMethod Void payStubReduction_UseCase1(){
        
        Account acc = [select Id, Annual_Individual_Income__c from Account  where Name = 'Test' LIMIT 1];
        System.assertEquals(true, acc!=Null);        
        
        genesis__Applications__c app = [SELECT Id, Employment_Status__c from genesis__Applications__c WHERE genesis__Account__c =: acc.Id LIMIT 1];
        System.assertEquals(true, app!=Null);
        
        genesis__Employment_Information__c empInfo = [select id,Income_Include_Bonuses_or_Commissions__c from genesis__Employment_Information__c  WHERE genesis__Application__c =: app.Id LIMIT 1];
        System.assertEquals(true, empInfo!=Null);
                
       // Talx__c talx = [SELECT Id, Salary__c FROM Talx__c WHERE Application__c =: app.Id LIMIT 1];
        //System.assertEquals(true, talx!=Null);  
        
        Id docCatID = [SELECT Id FROM genesis__Document_Category__c WHERE genesis__Category_Name__c LIKE '%PayStub%'].Id;
        System.assertEquals(true, docCatID!=Null);
                
        genesis__Application_Document_Category__c appDocCatObj = [SELECT Id FROM genesis__Application_Document_Category__c WHERE Name Like '%Test%'];
        System.assertEquals(true, appDocCatObj!=Null);
        //List<Id> appid = new List<Id>();
        //appid.add(app.id);
        DocumentReductionRules.payStubReduction(app.id);
        List<genesis__Application_Document_Category__c> docCategory = [SELECT Id FROM genesis__Application_Document_Category__c where genesis__Application__c=:app.Id and genesis__Required__c = false];
        System.assertEquals(true, docCategory.Size()>0);
        Credit_Policy__c cPolicy = [SELECT Net_Disposable_Income_NDI__c FROM Credit_Policy__c WHERE Application__c =: app.Id LIMIT 1]; 
        System.assertEquals(true, cPolicy!=Null); 
        Decimal NDIncome = decimal.valueOf(cPolicy.Net_Disposable_Income_NDI__c);                  
        System.assertEquals(true, (NDIncome>1000 && NDIncome<8000));
        System.assertEquals(true, ((app.Employment_Status__c == 'Full Time' || app.Employment_Status__c == 'Part Time') && !(empInfo.Income_Include_Bonuses_or_Commissions__c)));
        //System.assertEquals(true, (app.Employment_Status__c == 'Self Employed'));
        //System.assertEquals(true, (((talx.Salary__c - acc.Annual_Individual_Income__c) / acc.Annual_Individual_Income__c) * 100)>=85);                            
                
    }
    
    //ID Reduction
    Static testMethod Void payStubReduction_UseCase2(){
        
        Account acc = [select Id from Account  where Name = 'Test' LIMIT 1];
        System.assertEquals(true, acc!=Null);
        genesis__Applications__c app = [SELECT Id,Sift_Status__c from genesis__Applications__c WHERE genesis__Account__c =: acc.Id LIMIT 1];
        System.assertEquals(true, app!=Null);
        
        //List<Id> appid = new List<Id>();
        //appid.add(app.id);
        DocumentReductionRules.payStubReduction(app.id);
        List<genesis__Application_Document_Category__c> docCategory = [SELECT Id FROM genesis__Application_Document_Category__c where genesis__Application__c=:app.Id and genesis__Required__c = false];
        System.assertEquals(true, !docCategory.isEmpty());
        
        KBA_Details__c kba = [SELECT Precise_ID_Overall_SCore__c,Precise_ID_First_Payment_Default__c, 
                              Precise_ID_ID_Theft__c, Precise_ID_Validation__c, 
                              Phone_Verification_Result__c, Precise_ID_Adverse_Action_Code__c, 
                              Precise_ID_Decision__c,Precise_ID_Decision_KIQ__c, 
                              Precise_ID_General_Fraud_Shield_Indicat__c,Id_Analytics_Score__c, 
                              Consistency_Snapd_score__c, Paste_Count__c, 
                              Public_Records__c FROM KBA_Details__c WHERE Application__c =: app.Id LIMIT 1];
        System.assertEquals(true, kba!=Null);  
        System.assertEquals(true, docCategory.Size()>0);
        System.assertEquals(true, app.Sift_Status__c < 40);
        System.assertEquals(true, kba.Precise_ID_Validation__c > 400);
        System.assertEquals(true, kba.Precise_ID_ID_Theft__c > 400);
        System.assertEquals(true, kba.Precise_ID_Adverse_Action_Code__c.contains('I'));
        System.assertEquals(true, kba.Precise_ID_Decision__c.contains('Accept'));
        System.assertEquals(true, kba.Precise_ID_Decision_KIQ__c.contains('Accept'));
        System.assertEquals(true, kba.Precise_ID_General_Fraud_Shield_Indicat__c == 'F04');
        System.assertEquals(true, kba.Id_Analytics_Score__c < 700);
        System.assertEquals(true, kba.Consistency_Snapd_score__c > 15);
        System.assertEquals(true, kba.Paste_Count__c < 2);
        System.assertEquals(true, kba.Public_Records__c == 0);
        Id docCatID = [SELECT Id FROM genesis__Document_Category__c WHERE genesis__Category_Name__c LIKE '%ID%'].Id;
        System.assertEquals(true, docCatID!=Null);
        genesis__Application_Document_Category__c appDocCatObj = [SELECT Id FROM genesis__Application_Document_Category__c WHERE Name Like '%Test%'];
        System.assertEquals(true, appDocCatObj!=Null);
    }
    
     Static testMethod Void payStubReduction_UseCase3(){
        
        Account acc = [select Id from Account  where Name = 'Test' LIMIT 1];
        System.assertEquals(true, acc!=Null);
        genesis__Applications__c app = [SELECT Id,Sift_Status__c from genesis__Applications__c WHERE genesis__Account__c =: acc.Id LIMIT 1];
        System.assertEquals(true, app!=Null);
        Talx__c talx = new Talx__c(
            Application__c = app.Id,
            Employeer__c = 'Test',
            Salary__c = 18500,
            Hire_Date__c = System.Today()
        );
        Insert talx;
         KBA_Details__c kba = [SELECT Precise_ID_Overall_SCore__c,Precise_ID_First_Payment_Default__c, 
                              Precise_ID_ID_Theft__c, Precise_ID_Validation__c, 
                              Phone_Verification_Result__c, Precise_ID_Adverse_Action_Code__c, 
                              Precise_ID_Decision__c,Precise_ID_Decision_KIQ__c, 
                              Precise_ID_General_Fraud_Shield_Indicat__c,Id_Analytics_Score__c, 
                              Consistency_Snapd_score__c, Paste_Count__c, 
                              Public_Records__c FROM KBA_Details__c WHERE Application__c =: app.Id LIMIT 1];
         kba.Precise_ID_Overall_SCore__c = 9012;
         update kba;
        //List<Id> appid = new List<Id>();
        //appid.add(app.id);
        DocumentReductionRules.payStubReduction(app.id);
     }
    
    //CRM-881 - start
    Static testMethod Void reduce1040EnableRetirement(){
                
        Account acc = [select Id/*, Annual_Individual_Income__c*/ from Account  where Name = 'Test' LIMIT 1];  //CRM-1025
        System.assertEquals(true, acc!=Null);        
        genesis__Document_Category__c docCat = new genesis__Document_Category__c(
            genesis__Category_Name__c = '1040',
            genesis__Required__c = true
        );
        Insert docCat;
        genesis__Document_Category__c docCat2 = new genesis__Document_Category__c(
            genesis__Category_Name__c = 'Retirement',
            genesis__Required__c = false
        );
        Insert docCat2;
        
        genesis__Applications__c app = [SELECT Id, Employment_Status__c from genesis__Applications__c WHERE genesis__Account__c =: acc.Id LIMIT 1];
        genesis__Application_Document_Category__c appDocCat = new genesis__Application_Document_Category__c(
            Name = '1040',
            genesis__Document_Category__c = docCat.Id,
            genesis__Application__c = app.Id,
            genesis__Required__c = true
        );
        Insert appDocCat;
        genesis__Application_Document_Category__c appDocCat2 = new genesis__Application_Document_Category__c(
            Name = 'Retirement',
            genesis__Document_Category__c = docCat2.Id,
            genesis__Application__c = app.Id,
            genesis__Required__c = false
        );
        Insert appDocCat2;
        app.Employment_Status__c = 'Retired';
        update app;
    
    genesis__Application_Document_Category__c idDocCatObj = [SELECT ID,name, genesis__Required__c FROM genesis__Application_Document_Category__c where genesis__Application__c=:app.Id and name LIKE '%ID%' limit 1];
    idDocCatObj.genesis__Application__c = null;
        update idDocCatObj;
        
        //List<genesis__Application_Document_Category__c> docCategoryy = [SELECT Id FROM genesis__Application_Document_Category__c where genesis__Application__c=:app.Id and Name Like '%1040%'];
        DocumentReductionRules.payStubReduction(app.id);
        List<genesis__Application_Document_Category__c> docCategory = [SELECT Id FROM genesis__Application_Document_Category__c where genesis__Application__c=:app.Id and Name Like '%1040%' and genesis__Required__c = false];
        System.assertEquals(true, docCategory.Size()>0);
        List<genesis__Application_Document_Category__c> docCategory2 = [SELECT Id FROM genesis__Application_Document_Category__c where genesis__Application__c=:app.Id and Name = 'Retirement' and genesis__Required__c = true];
        System.assertEquals(true, docCategory2.Size()>0);
    }
    
    Static testMethod Void retirementDocReduction(){
                
        Account acc = [select Id/*, Annual_Individual_Income__c*/ from Account  where Name = 'Test' LIMIT 1];  //CRM-1025
        System.assertEquals(true, acc!=Null);        
        
        genesis__Document_Category__c docCat = new genesis__Document_Category__c(
            genesis__Category_Name__c = 'Retirement',
            genesis__Required__c = true
        );
        Insert docCat;
        
        genesis__Applications__c app = [SELECT Id, Employment_Status__c from genesis__Applications__c WHERE genesis__Account__c =: acc.Id LIMIT 1];
        genesis__Application_Document_Category__c appDocCat = new genesis__Application_Document_Category__c(
            Name = 'Retirement',
            genesis__Document_Category__c = docCat.Id,
            genesis__Application__c = app.Id,
            genesis__Required__c = true
        );
        Insert appDocCat;
        app.Employment_Status__c = 'Self Employed';
        update app;
        System.assertEquals(true, app!=Null);
        
        genesis__Application_Document_Category__c idDocCatObj = [SELECT ID,name, genesis__Required__c FROM genesis__Application_Document_Category__c where genesis__Application__c=:app.Id and name LIKE '%ID%' limit 1];
    idDocCatObj.genesis__Application__c = null;
        update idDocCatObj;
                
        DocumentReductionRules.payStubReduction(app.id);
        List<genesis__Application_Document_Category__c> docCategory = [SELECT Id FROM genesis__Application_Document_Category__c where genesis__Application__c=:app.Id and Name = 'Retirement' and genesis__Required__c = false];
        System.assertEquals(true, docCategory.Size()>0);
    }
    //CRM-881 - end
    
}