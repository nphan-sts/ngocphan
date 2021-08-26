@isTest(seeAllData = false)
public class MW_MemberMatchingDeactivation_Test {
	    private static testmethod void testMethod1(){
            MW_Settings__c testSettings= new MW_Settings__c(MemberMatchingDeactivationTool__c = 'https://sfapi-dev.payoff.com/ms/api/admin/member_match_resolver');
            insert testSettings;
            Lead testLead = new Lead(LastName = 'TestLastName',
                                    FirstName = 'TestFirstName',
                                    Company = 'TestCompany',
                                    lead_guid__c= 'a257adc0-70e7-1b50-4300-ecf90e617d09');
            insert testLead;
            

        Test.setMock(HttpCalloutMock.class, new MW_MemberMatchingDeactivation_HttpMock());
        Test.startTest();
        	MW_MemberMatchingDeactivation.makeCallout(testLead.id);
        Test.stopTest();
            
        }
    	private static testmethod void testMethod2(){
            MW_Settings__c testSettings= new MW_Settings__c(MemberMatchingDeactivationTool__c = 'https://sfapi-dev.payoff.com/ms/api/admin/member_match_resolver');
            insert testSettings;
            Lead testLead = new Lead(LastName = 'TestLastName',
                                    FirstName = 'TestFirstName',
                                    Company = 'TestCompany',
                                    lead_guid__c= 'a257adc0-70e7-1b50-4300-ecf90e617d09');
            insert testLead;
            

        Test.setMock(HttpCalloutMock.class, new MW_MemberMatchingDeactivation_HttpMock());
        Test.startTest();
        	MW_MemberMatchingDeactivation.makeCallout('234242');
        Test.stopTest();
            
        }
}