@isTest
private class TestAchDocsUploadToBoxjob{
 
     @testSetup static void methodName() {
     
         CL_Document__c CS = CL_Document__c.getOrgDefaults();
         CS.UploadedBOX__c = 'UploadedBOX';
         upsert CS;
        
        loan__Org_Parameters__c loanorg = loan.CustomSettingsUtil.getOrgParameters();
        loanorg.Manual_Payer_Lending_product_name__c = 'Manual Payer';
        loanorg.Auto_Payer_Lending_Product_Name__c = 'Auto Payer';
        upsert loanorg;
        
        //Creating loan account 
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount); 
        dummyFee.loan__Amount__c = 3;      
        dummyFee.loan__Time_Of_Charge__c = 'Other';
        upsert dummyFee;
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        System.debug('dummyOffice'+dummyOffice.name);

        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP1 = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            curr, 
                            dummyFeeSet);
        dummyLP1.name = 'Auto Payer';
        dummyLP1.loan__Pre_Bill_Days__c = 5;
        upsert dummyLP1;
                          
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            curr, 
                            dummyFeeSet);
        dummyLP.name = 'Manual Payer';
        dummyLP.loan__Pre_Bill_Days__c = 5;
        upsert dummyLP;

        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();        
        dummyLoanPurpose.loan__Loan_Purpose_Code__c = 'Refinance';
        account dummyClient = new account(); 
        dummyClient.Name = 'Payoff';
        dummyClient.peer__Last_Name__c = 'Account';
        dummyClient.peer__First_Name__c = 'Test';
        dummyClient.loan__SOCIAL_SECURITY_NUMBER__c = '123456789';
        insert dummyClient;
        
        Account invacc = new Account();
        invacc.name = 'investor';
        invacc.loan__SOCIAL_SECURITY_NUMBER__c = '123456789';
        //invacc.loan__Investor__c = 
        insert invacc;
        
        loan__Payment_Mode__c pm = new loan__Payment_Mode__c();
        pm.name = 'Wire';
        insert pm;
        
        //investor bank acc.
        loan__Bank_Account__c bainv = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__Routing_Number__c = '999999999',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Active__c = true,
                                                 Unmasked_Bank_Account_Number__c = '99999999',
                                                 loan__Account__c = invacc.id);
        insert bainv;
      
       
        loan__Automated_Payment_Configuration__c invaps = new loan__Automated_Payment_Configuration__c();
        invaps.loan__Payment_Mode__c = pm.id;
        invaps.loan__Bank_Account__c = bainv.id;
        invaps.loan__Filegen_Class__c = 'CustomLoanPaymentTxnNACHAGen';
        invaps.loan__Folder_Name__c = 'ACU';
        invaps.loan__File_Type__c = 'CSV';
        invaps.loan__Event__c = 'LOAN PAYMENT';
        invaps.loan__Active__c = True;
        invaps.Box_Folder_ID__c = '48673238292';
        insert invaps;
        
        List<Document> docs= new list<Document>();
         for(integer i=0;i<10;i++){
          Document Documents = new Document();
            Documents.Body = Blob.valueOf('Some Text');
            Documents.ContentType = 'application/pdf';
            Documents.DeveloperName = 'my_document'+i;
            Documents.IsPublic = true;
            Documents.Name = 'My Document'+i;
            Documents.FolderId = [select id from folder where name = 'ACU'].id;
            docs.add(documents);
          }
          insert docs;
        
     }
     public static testmethod void test(){
        Test.StartTest();
           List<Document> Docs =  [SELECT Id,Name,FolderId,Folder.Name,body FROM Document];
           AchDocsUploadToBoxjob AchDOC = new AchDocsUploadToBoxjob();
              
              Database.QueryLocator ql = AchDOC.start(null);
              AchDOC.execute(null,docs);
              AchDOC.Finish(null);     
             
      Test.StopTest();
    }
    public static testmethod void test1(){
        
         test.StartTest();  
              string folderid = '48673238292';      
              Blob b = Blob.valueOf('Unit Test Attachment Body');
              String namefile = 'filename';
              List<Document> Docum =  [SELECT Id,Name,FolderId,Folder.Name,body FROM Document];
              loan__Automated_Payment_Configuration__c APC = [Select id,name,
                                                                         Box_Folder_ID__c,
                                                                         loan__Folder_Name__c
                                                                    From loan__Automated_Payment_Configuration__c
                                                                    Where loan__Folder_Name__c =: Docum [0].Folder.Name 
                                                                    AND loan__Active__c = True limit 1];
              Delete APC;
              AchDocsUploadToBoxjob AchDOC = new AchDocsUploadToBoxjob();
          
              Database.QueryLocator ql = AchDOC.start(null);
              AchDOC.execute(null,Docum);
              Test.setMock(HttpCalloutMock.class,new TestBoX_IntegMock());
              BoX_Integ.uploadFileToBox(Docum[0].body,Docum[0].Name,APC.Box_Folder_ID__c,null);
              AchDOC.Finish(null); 
              
        test.StopTest();
    }
    public class TestBoX_IntegMock implements HTTPCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody('{'+
            '"total_count":1,'+
               '"entries":['+ 
                  '{'+ 
                     '"type":"file",'+
                     '"id":"284925978574",'+
                     '"file_version":{'+ 
                        '"type":"file_version",'+
                        '"id":"299801290750",'+
                        '"sha1":"5d41c94f5687eff92c9085992a19313c92a881bd"'+
                     '},'+
                     '"sequence_id":"0",'+
                     '"etag":"0",'+
                     '"sha1":"5d41c94f5687eff92c9085992a19313c92a881bd",'+
                     '"name":"TILDocument a6h2F0000004d5gQAA.pdf",'+
                     '"description":"",'+
                     '"size":5060,'+
                     '"path_collection":{'+  
                        '"total_count":2,'+
                        '"entries":['+  
                           '{'+ 
                              '"type":"folder",'+
                              '"id":"0",'+
                              '"sequence_id":null,'+
                              '"etag":null,'+
                              '"name":"All Files"'+
                           '},'+
                           '{'+ 
                              '"type":"folder",'+
                              '"id":"47383466400",'+
                              '"sequence_id":"0",'+
                              '"etag":"0",'+
                              '"name":"SampleFromOrg"'+
                           '}'+
                        ']'+
                     '},'+
                     '"created_at":"2018-03-26T05:51:55-07:00",'+
                     '"modified_at":"2018-03-26T05:51:55-07:00",'+
                     '"trashed_at":null,'+
                     '"purged_at":null,'+
                     '"content_created_at":"2018-03-26T05:51:55-07:00",'+
                     '"content_modified_at":"2018-03-26T05:51:55-07:00",'+
                     '"created_by":{'+ 
                        '"type":"user",'+
                        '"id":"3202805146",'+
                        '"name":"CLS Dev User",'+
                        '"login":"cls_dev@happymoney.com"'+
                     '},'+
                     '"modified_by":{'+  
                        '"type":"user",'+
                        '"id":"3202805146",'+
                        '"name":"CLS Dev User",'+
                        '"login":"cls_dev@happymoney.com"'+
                     '},'+
                     '"owned_by":{'+  
                        '"type":"user",'+
                        '"id":"3202805146",'+
                        '"name":"CLS Dev User",'+
                        '"login":"cls_dev@happymoney.com"'+
                     '},'+
                     '"shared_link":null,'+
                     '"parent":{'+  
                        '"type":"folder",'+
                        '"id":"47383466400",'+
                        '"sequence_id":"0",'+
                        '"etag":"0",'+
                        '"name":"SampleFromOrg"'+
                     '},'+
                     '"item_status":"active"'+
                  '}'+
               ']'+
            '}'
            );
            res.setStatusCode(201);
            res.setStatus('Created');
            res.setHeader('X-AUTH-TOKEN', 'aouthtoken12345');
            return res;
        }
    }
    public static testmethod void test2(){
        
         test.StartTest();  
              string folderid = '48673238292';      
              Blob b = Blob.valueOf('Unit Test Attachment Body');
              String namefile = 'filename';
              List<Document> Docum =  [SELECT Id,Name,FolderId,Folder.Name,body FROM Document];
              loan__Automated_Payment_Configuration__c APC = [Select id,name,
                                                                         Box_Folder_ID__c,
                                                                         loan__Folder_Name__c
                                                                    From loan__Automated_Payment_Configuration__c
                                                                    Where loan__Folder_Name__c =: Docum [0].Folder.Name 
                                                                    AND loan__Active__c = True limit 1];
              //Delete APC;
              UploadNachaToBoxJob AchDOC = new UploadNachaToBoxJob();
          
              Database.QueryLocator ql = AchDOC.start(null);
              AchDOC.execute(null,Docum);
              Test.setMock(HttpCalloutMock.class,new TestBoX_IntegMock());
              BoX_Integ.uploadFileToBox(Docum[0].body,Docum[0].Name,APC.Box_Folder_ID__c,null);
              AchDOC.Finish(null); 
              
        test.StopTest();
    }
    
}