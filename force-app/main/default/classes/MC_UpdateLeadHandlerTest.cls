@isTest
private class MC_UpdateLeadHandlerTest {

	@isTest static void checkLeadAppField() {
		Lead newLead = new Lead();
		newLead.LastName = 'test';
		newLead.Company = 'test company';
		newLead.Status = 'open';
		newLead.lead_guid__c = 'c9149473-e69f-ee12-38a7-d18b0cba847d';
		newLead.Application__c = null;
		insert newLead;

		List<Account> accountList = MW_DataFactoryTest.createAccounts(1);
		insert accountList;

		List<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accountList[0].id);
		insert appList;

		//Test start
		MC_UpdateLeadHandler.updateLead(appList);

		Lead afterUpdateLead = [Select id, Application__c From Lead Where id =: newLead.id];

		System.assertEquals(appList[0].id, afterUpdateLead.Application__c);
	}

}