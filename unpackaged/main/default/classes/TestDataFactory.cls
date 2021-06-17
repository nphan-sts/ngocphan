public class TestDataFactory {

    public static Account createTestAccount() {
        return new Account(Name = 'Test Account',
        					loan__Investor__c = false,
                           	cnotify__Email__c = 'test@test.com',
                           	loan__SOCIAL_SECURITY_NUMBER__c = '123456789',
                            social_security_number_uniqueness_field__c = '123456789');
    }

    public static Account createTestInvestor() {
    	return new Account(Name = 'TEST',
        					loan__Investor__c = true,
            			   	Amount_Invested__c = 1000,
            			   	Number_Of_Applications_Invested__c = 3,
            			   	Total_No_of_Application_Limit__c = 30,
            			   	Last_Application_assigned_on__c = System.now() - 7,
			               	Total_Investment_Limit__c = 1000000,
			               	loan__Undeployed_Funds__c = 500000,
			               	cnotify__Email__c = 'no-reply@testorganization.com',
			               	peer__First_Name__c = 'TestFirstName',
			               	peer__Last_Name__c='TestLastName',
			               	loan__Active__c = 'YES',
			               	City__c='CANADA',
			               	State__c='CA',
			               	ZIP_Code__c='123456',
                            loan__SOCIAL_SECURITY_NUMBER__c = '987654321',
                            social_security_number_uniqueness_field__c = '987654321');
    }

    public static genesis__Applications__c createTestApplication(Id acctId, Id invId, String leadId, Date originationDate, String status) {
    	return new genesis__Applications__c(Lead_ID__c = leadId,
    										genesis__Due_Day__c = 20,
                                        	genesis__Expected_First_Payment_Date__c = System.today(),
                                        	genesis__Expected_Start_Date__c = System.today(),
                                        	genesis__Funding_in_Tranches__c = true,
                                        	Borrower_s_Email__c = null,
                                        	genesis__Account__c = acctId,
                                        	Investor__c  = invId,
                                        	Application_Start_DateV2__c = System.today(),
                                        	DocuSignFlag__c = true,
                                        	genesis__Status__c = String.isBlank(status) ? 'agent_verified' : status,
                                        	genesis__Draw_Period_End_Date__c = System.today(),
                                        	Loan_Origination_Date__c = originationDate == null ? Date.today().addDays(2) : originationDate);
    }


    public static clcommon__Party_Type__c createTestPartyType(String name) {
    	return new clcommon__Party_Type__c(name = name);
    }

    public static genesis__Document_Category__c createTestDocumentCategory(Id partyTypeId, String code) {
    	return new genesis__Document_Category__c(genesis__Responsible_Party_Type__c = partyTypeId,
    											genesis__Applicable_For__c = 'PARTY',
    											Code_FF__c = code);
    }

    public static genesis__Document_Category__c createTestDocumentCategory(Id partyTypeId, String catName, String code) {
        	return new genesis__Document_Category__c(genesis__Responsible_Party_Type__c = partyTypeId,
        											genesis__Applicable_For__c = 'PARTY',
    												genesis__Category_Name__c = catName,
        											Code_FF__c = code);
    }
    
    public static genesis__Application_Document_Category__c createTestApplicationDocumentCategory(String name, Id appId, Id catId,
    		String boxUrl, String status) {
    	return new genesis__Application_Document_Category__c(name = name,
        													genesis__Active__c = true,
        													genesis__Application__c = appId,
        													genesis__Document_Category__c = catId,
        													Box_URl__c = boxUrl,
        													genesis__Status__c = status);
    }

}