public abstract class MW_DataFactoryTest {
    
    public static String SIFT = '{\"status\": 0,\"error_message\": \"OK\",\"time\": 1520875573,\"score_response\": {\"status\": 0,\"error_message\": \"OK\",\"score\":0.6077443824203552,\"reasons\": [  {\"name\": \"Number of users with the same billing address\",\"value\": \"3\",\"details\": {\"users\": \"6352ca07-d2ff-4c45-a290-71a85f8e88fb,c2f38cee-75a2-449b-8e61-77bf044395e2\"}},  {\"name\": \"Account phone number is aphone number\",\"value\": \"false\"},  {\"name\": \"Email username number of digits\",\"value\": \"0\"},  {\"name\": \"Latest promotionscount\",\"value\": \"0\"},  {\"name\": \"Estimated email address age\",\"value\": \"23.93 days\"},  {\"name\": \"Create accounts in the lasthour \",\"value\": \"1\"}, {\"name\":\"Account age\",\"value\": \"0.25 minutes\"},  {\"name\": \"Number of users with similar email address\",\"value\":\"4\",\"details\": {\"users\":\"6352ca07-d2ff-4c45-a290-71a85f8e88fb,11223333,c2f38cee-75a2-449b-8e6177bf044395e2\"}}, {\"name\": \"Latest billingaddress name\",\"value\": \"Bill Jones\"}],\"user_id\": \"6352ca07-d2ff-4c45-a290-71a85f8e88f1\"}}';
 
    public static List<Account> createAccounts( Integer numberOfAccounts) {
        List<Account> accounts = new List<Account>();
        for ( Integer i = 0 ; i < numberOfAccounts ; i++ ) {
            Account account = new Account(Name='DocuSign Document Allocation',
                                          peer__First_Name__c='VANESSA',
                                          peer__Last_Name__c='RAYMOND',
                                          Suffix__c='Mr',
                                          Person_UID__c='optional_metadata',
                                          ZIP_Code__c='02831',
                                          Monthly_Housing_Payment__c=1000,
                                          Annual_Individual_Income__c=70000,
                                          BillingStreet='6 Charles St',
                                          Alternate_Phone__c='1234567890',
                                          loan__Investor__c=false,
                                          City__c='JAMESTOWN',
                                          ints__SSN__c='123119434',
                                          State__c='GA',
                                          Payoff_UID__c='c9149473-e69f-ee12-38a7-d18b0cba847d',
                                          peer__Email__c='notify@testOrg.com'+ Math.random(),
                                          cnotify__Email__c='notify@testOrg.com'+ Math.random(), 
                                          Phone = '1234554321', 
                                          peer__Date_of_Birth__c=system.Today()-365);
                
            accounts.add( account);
        }
            return accounts;
    }


    public static List<genesis__Applications__c> createApplication( Integer numberOfApp, Id accId) 
    {
        List<clcommon__CL_Product__c> productlist  = new List<clcommon__CL_Product__c>([SELECT Id,Name from clcommon__CL_Product__c where clcommon__Product_Name__c='Auto Payer' limit 1]);
   
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
    
        for ( Integer i = 0 ; i < numberOfApp ; i++ ) {
            genesis__Applications__c app = new genesis__Applications__c(
                                                   genesis__Days_Convention__c='ACTUAL/ACTUAL',
                                                   genesis__Account__c=accId,
                                                   genesis__Interest_Calculation_Method__c='Declining Balance',
                                                   genesis__Interest_Rate__c=10.0000,
                                                   Estimated_Amount_needed__c=2000.00,
                                                   genesis__Payment_Frequency__c='WEEKLY',
                                                   genesis__Product_Type__c='LOAN',
                                                   genesis__Term__c=24,
                                                   Estimated_credit_card_balances__c=3000.00,
                                                   genesis__Loan_Amount__c=22120.00,
                                                   Employment_Status__c='Retired',
                                                   Application_Start_DateV2__c = system.Today(),
                                                   genesis__Draw_Period_End_Date__c = system.Today(),
                                                   genesis__Expected_First_Payment_Date__c = system.Today(),
                                                   genesis__Expected_Start_Date__c = system.Today(),
                                                   Monthly_Housing_Payment_App__c = 900,
                                                   Annual_Individual_Income_App__c = 90000,
                                                   LEAD_ID__C='c9149473-e69f-ee12-38a7-d18b0cba847d'
                                                );
                applicationList.add( app);
        }   
            return applicationList;
    }


     public static List<dsfs__DocuSign_Status__c> createDocusignStatus(Integer numberOfApp, Id accId) 
    {
        List<dsfs__DocuSign_Status__c> docList = new List<dsfs__DocuSign_Status__c>();
        
        for ( Integer i = 0 ; i < numberOfApp ; i++ ) {
            dsfs__DocuSign_Status__c sobj = new dsfs__DocuSign_Status__c();
            sobj.dsfs__Subject__c = 'Action Required - Please eSign your ESign Documents '+accId;
            sobj.dsfs__Sender_Email__c='cpalapala@happymoney.com';
            sobj.dsfs__DocuSign_Envelope_ID__c='50E4E71B-7CF8-43B5-8750-78D4DABB14F7';
            sobj.dsfs__Envelope_Status__c = 'Send';
            docList.add( sobj);
        }   
            return docList;
    }


    public static List<genesis__Application_Document_Category__c> createDocuCategory(Integer numberOfApp, Id accId, Id docCat) 
    {
        List<genesis__Application_Document_Category__c> docList = new List<genesis__Application_Document_Category__c>();
        
        for ( Integer i = 0 ; i < numberOfApp ; i++ ) {
            genesis__Application_Document_Category__c adc = new genesis__Application_Document_Category__c();
            adc.name = 'ID Card';
            adc.genesis__Active__c = true;
            adc.genesis__Document_Category__c =  docCat;
            adc.genesis__Application__c =accId;
            docList.add(adc);
        }   
            return docList;
    }
}