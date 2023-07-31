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
            peer__First_Name__c = 'TestFirstName',
            peer__Last_Name__c = 'TestLastName',
            loan__Investor__c = False,
            cnotify__Email__c = 'no-reply@testorganization.com'
        );
       
        Insert acc;
         //LOP-563
            Account acc1 = new Account(
            Name = 'Test1',
            peer__First_Name__c = 'TestFirstName1',
            peer__Last_Name__c = 'TestLastName1',
            loan__Investor__c = False,
            cnotify__Email__c = 'no-reply@testorganization1.com'
        );
        Insert acc1;
        

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
            Sift_Status__c=30,
            Annual_Individual_Income_App__c = 10000 
        );      
        Insert app; 
        
        
         genesis__Applications__c app1 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = acc1.Id,        
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'kba_success',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time',
            Sift_Status__c=30,
            Annual_Individual_Income_App__c = 10000
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
        //LOP_563
          genesis__Document_Category__c docCat1 = new genesis__Document_Category__c(
            genesis__Category_Name__c = 'Test_Paystub_ID',
            genesis__Required__c = true
        );
        Insert docCat1;
        genesis__Application_Document_Category__c appDocCat1 = new genesis__Application_Document_Category__c(
            Name = 'Test_paystub_ID_doc',
            genesis__Document_Category__c = docCat1.Id,
            genesis__Application__c = app1.Id
        );
        Insert appDocCat1;
        Credit_Policy__c cPolicy1 = new Credit_Policy__c(
            Name='TestPolicy',
            Application__c =app1.Id,
            Net_Disposable_Income_NDI__c='2000'
        );
        Insert cPolicy1; 
        
        Application_Tags__c apptag = new Application_Tags__c(
        Application_Tag__c = 'Soft Pull Requested.',
        Application__c = app.id);
        insert apptag;
        // for Accept_Refer_Code__c= Accept
        KBA_Details__c kbaObj = new KBA_Details__c(
            Application__c = app1.Id,
            Precise_ID_Overall_SCore__c = 9012, 
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
        //LOP-563 for  Accept_Refer_Code__c= NULL  
         KBA_Details__c kbaObj1 = new KBA_Details__c(
            Application__c = app1.Id,
            Precise_ID_Overall_SCore__c = 254, 
            Precise_ID_First_Payment_Default__c = 394, 
            Precise_ID_ID_Theft__c = 259,  
            Precise_ID_Validation__c = 397, 
            Precise_ID_Adverse_Action_Code__c = ' ', 
            Precise_ID_Decision__c = 'Priority 10 Referal' ,
            Precise_ID_Decision_KIQ__c = NULL, 
            Precise_ID_General_Fraud_Shield_Indicat__c = 'F04', 
            Id_Analytics_Score__c = 500, 
            Consistency_Snapd_score__c = 30, 
            Paste_Count__c = 1,
            Public_Records__c=0,
            Accept_Refer_Code__c= NULL  //CRM-966
        );
        //Insert kbaObj1;
       //  //LOP-563 for  Accept_Refer_Code__c= 'REF'
        KBA_Details__c kbaObj2 = new KBA_Details__c(
            Application__c = app1.Id,
            Precise_ID_Overall_SCore__c = 318, 
            Precise_ID_First_Payment_Default__c = 399, 
            Precise_ID_ID_Theft__c = 349,  
            Precise_ID_Validation__c = 417, 
            Precise_ID_Adverse_Action_Code__c = ' ', 
            Precise_ID_Decision__c = 'Priority 10 Referal' ,
            Precise_ID_Decision_KIQ__c = NULL, 
            Precise_ID_General_Fraud_Shield_Indicat__c = 'F04', 
            Id_Analytics_Score__c = 500, 
            Consistency_Snapd_score__c = 30, 
            Paste_Count__c = 1,
            Public_Records__c=0,
            Accept_Refer_Code__c= 'REF' //CRM-966
        );
        //Insert kbaObj2;
        test.stopTest();
    }
    //PayStub Reduction
    Static testMethod Void payStubReduction_UseCase1(){
        
        Account acc = [select Id, Annual_Individual_Income__c from Account  where peer__First_Name__c = 'TestFirstName' LIMIT 1];
        System.assertEquals(true, acc!=Null);        
        
        genesis__Applications__c app = [SELECT Id, Employment_Status__c from genesis__Applications__c WHERE genesis__Account__c =: acc.Id LIMIT 1];
        System.assertEquals(true, app!=Null);
        
        genesis__Employment_Information__c empInfo = [select id,Income_Include_Bonuses_or_Commissions__c from genesis__Employment_Information__c  WHERE genesis__Application__c =: app.Id LIMIT 1];
        System.assertEquals(true, empInfo!=Null);
        
        Id docCatID = [SELECT Id FROM genesis__Document_Category__c WHERE genesis__Category_Name__c LIKE '%PayStub%' LIMIT 1].Id;
        System.assertEquals(true, docCatID!=Null);
                
        genesis__Application_Document_Category__c appDocCatObj = [SELECT Id FROM genesis__Application_Document_Category__c WHERE Name Like '%Test%' LIMIT 1];
        System.assertEquals(true, appDocCatObj!=Null);
        DocumentReductionRules.payStubReduction(app.id);
        List<genesis__Application_Document_Category__c> docCategory = [SELECT Id FROM genesis__Application_Document_Category__c where genesis__Application__c=:app.Id and genesis__Required__c = false];
        System.assertEquals(true, docCategory.Size()>0);
        Credit_Policy__c cPolicy = [SELECT Net_Disposable_Income_NDI__c FROM Credit_Policy__c WHERE Application__c =: app.Id LIMIT 1]; 
        System.assertEquals(true, cPolicy!=Null); 
        Decimal NDIncome = decimal.valueOf(cPolicy.Net_Disposable_Income_NDI__c);                  
        System.assertEquals(true, (NDIncome>1000 && NDIncome<8000));
        System.assertEquals(true, ((app.Employment_Status__c == 'Full Time' || app.Employment_Status__c == 'Part Time') && !(empInfo.Income_Include_Bonuses_or_Commissions__c)));
   }
    
    //ID Reduction
    Static testMethod Void payStubReduction_UseCase2(){
        
        // LOP-563 use case 2 and 3 where Accept_Refer_Code__c != 'accept'
        
         Account acc = [select Id from Account  where peer__First_Name__c = 'TestFirstName1' LIMIT 1];
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
        Id docCatID = [SELECT Id FROM genesis__Document_Category__c WHERE genesis__Category_Name__c LIKE '%ID%' LIMIT 1].Id;
        System.assertEquals(true, docCatID!=Null);
        genesis__Application_Document_Category__c docIDL = [SELECT ID, genesis__Required__c FROM genesis__Application_Document_Category__c where genesis__Application__c=:app.Id AND name LIKE '%ID%'];
        System.assertEquals(false,docIDL.genesis__Required__c==True);

        genesis__Application_Document_Category__c appDocCatObj = [SELECT Id FROM genesis__Application_Document_Category__c WHERE Name Like '%Test%' LIMIT 1];
        System.assertEquals(true, appDocCatObj!=Null);  
      
        // LOP-563 existing version use case 1
        /*
        Account acc = [select Id from Account  where peer__First_Name__c = 'TestFirstName' LIMIT 1];
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
        //LOP-563
        genesis__Application_Document_Category__c docIDL = [SELECT ID, genesis__Required__c FROM genesis__Application_Document_Category__c where genesis__Application__c=:app.Id AND name LIKE '%ID%'];
        System.assertEquals(true,docIDL.genesis__Required__c==False);
        genesis__Application_Document_Category__c appDocCatObj = [SELECT Id FROM genesis__Application_Document_Category__c WHERE Name Like '%Test%'];
        System.assertEquals(true, appDocCatObj!=Null); */
    }
    
     Static testMethod Void payStubReduction_UseCase3(){
        
        Account acc = [select Id from Account  where peer__First_Name__c = 'TestFirstName1' LIMIT 1];
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
                
        Account acc = [select Id from Account  where peer__First_Name__c = 'TestFirstName' LIMIT 1];  //CRM-1025
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
        
        DocumentReductionRules.payStubReduction(app.id);
        List<genesis__Application_Document_Category__c> docCategory = [SELECT Id FROM genesis__Application_Document_Category__c where genesis__Application__c=:app.Id and Name Like '%1040%' and genesis__Required__c = false];
        System.assertEquals(true, docCategory.Size()>0);
        List<genesis__Application_Document_Category__c> docCategory2 = [SELECT Id FROM genesis__Application_Document_Category__c where genesis__Application__c=:app.Id and Name = 'Retirement' and genesis__Required__c = true];
        System.assertEquals(true, docCategory2.Size()>0);
    }
    
    Static testMethod Void retirementDocReduction(){
                
        Account acc = [select Id from Account  where peer__First_Name__c = 'TestFirstName' LIMIT 1];  //CRM-1025
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