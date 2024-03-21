public class MW_NeoVerifyTransactionsCalloutQueue implements Queueable, Database.AllowsCallouts {
	private Set<Id> applicationIds {get; set;}

	public MW_NeoVerifyTransactionsCalloutQueue(Set<Id> applicationIds){
		this.applicationIds = applicationIds;
	}

	public void execute(QueueableContext context) {
		MW_NeoVerifyIntegration.postRegNeoVerify(applicationIds);
		ID JobID = context.getJobId();
		List<MW_Callout__c> newCalloutJob = new list<MW_Callout__c>([Select id from MW_Callout__c where JobID__c=: JobID LIMIT 1]);
		if(newCalloutJob.size()>0) {
			newCalloutJob[0].Application__c= new list<Id>(applicationIds)[0];
			newCalloutJob[0].Status__c = 'processed';
			update newCalloutJob;
		}
	}
}