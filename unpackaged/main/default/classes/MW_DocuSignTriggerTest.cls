@isTest
public with sharing class MW_DocuSignTriggerTest
{
    static testMethod void TestUpdateDocusignStatus()
    {
         try
       {
        list<account> accList                  = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);

        insert appList;

        List<dsfs__DocuSign_Status__c>  docstatus = MW_DataFactoryTest.createDocusignStatus(1, appList[0].Id);
       Test.startTest();
        insert docstatus;

        docstatus[0].dsfs__Envelope_Status__c = 'Completed';
       docstatus[0]. dsfs__Completed_Date_Time__c= system.Today();

        update docstatus;
         Test.stopTest();
       }
         catch(Exception e)
         {
         }
    }

    static testMethod void TestCreateDocumentCategoryException(){
      try{
        Test.startTest();
        list<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;
        List<dsfs__DocuSign_Status__c>  docstatus = MW_DataFactoryTest.createDocusignStatus(1, appList[0].Id);
        insert docstatus;

        docstatus[0].dsfs__Envelope_Status__c = 'Completed';
        docstatus[0]. dsfs__Completed_Date_Time__c= system.Today();
        docstatus[0].dsfs__Completed_Date_Time__c = null;
        update docstatus;

        Test.stopTest();
      }
      catch(Exception e){
        Exception expectedException = new DmlException();
        System.assertEquals(StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, e.getDmlType(0));
      }
    }
 
    static testMethod void TestDocumentCategoryHandler()
    {
        list<account> accList                  = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);

        insert appList;
        
        genesis__Document_Category__c docType = new genesis__Document_Category__c(
            genesis__Category_Name__c='ESign Documents',
            Application_Status__c=appList[0].genesis__Status__c
         );
        
    
        MW_DataFactoryTest.createDocuCategory(1, accList[0].Id, docType.Id);

    }
 /*
    static testMethod void TestDocumentCategoryHandler_1()
    {
        //Create an Account
        list<account> accList                  = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        accList[0].phone ='1234567893';
        update accList;

        //Create an Application
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        appList[0].genesis__Status__c = 'kba_success';
        update appList[0];
        appList[0].Required_Docs_Count__c = 0;
        update appList[0];
    }
    */

}