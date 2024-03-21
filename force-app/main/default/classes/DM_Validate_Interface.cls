Global interface DM_Validate_Interface {
	List<DM_ValidationWrapper> validateDM(List<DM_Loan_Account__c> dmList, DM_Metadata_Config_Wrapper configWrapper);
}