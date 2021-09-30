public class MW_ApplicationTriggerHandler {

	final List<genesis__Applications__c> newRecords;
	final Map<Id, genesis__Applications__c> oldMap;
	final Map<Id, genesis__Applications__c> newMap;

	public static boolean avoidrecursive = true;

	public MW_ApplicationTriggerHandler(List<genesis__Applications__c> newRecords, Map<Id, genesis__Applications__c> newMap, Map<Id, genesis__Applications__c> oldMap)
	{
		this.newRecords = newRecords;
		this.oldMap = oldMap;
		this.newMap = newMap;
	}

	public void beforeInsert()
	{
		MW_ApplicationService.updateBoxFolder(newRecords);
	}

	public void beforeUpdate()
	{
		MW_ApplicationService.UpdateApplicationFlags(newRecords, oldMap);
	}

	public void afterUpdate()
	{
		if(avoidrecursive) {
			MW_ApplicationService.postDealRoomStructure(newRecords, oldMap);
			MW_SynchronizeHandler.postAppDetailsOnWebHook(oldMap, newMap);
			MW_SynchronizeHandler.preventIsAfterRecursionOnApplication = true;
			MW_SynchronizeHandler.createOrgniationRecords(newRecords);
			MW_ApplicationService.pifLoanUpdates(newRecords, newMap, oldMap);
			MW_ApplicationService.updateAppAndOtherValues(newRecords, newMap, oldMap);
		}
	}

	public void afterInsert()
	{

	}
}