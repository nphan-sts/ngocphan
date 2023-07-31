public with sharing class InvokeDCPController 
{
    public List<genesis__Applications__c> eligibleApps{get;set;}
    public ApexPages.StandardSetController standardController;
    
    public InvokeDCPController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
        eligibleApps = new List<genesis__Applications__c>();
    }
     public PageReference invokeDCP()
    { 
        List<genesis__Applications__c> getSelectedApps = (List<genesis__Applications__c>) standardController.getSelected();
        List<genesis__Applications__c> selectedApps = [Select id,name,
                                                            genesis__Status__c,
                                                            OwnerID,
                                                            genesis__account__r.name
                                                        from genesis__Applications__c
                                                        where id in: getSelectedApps ];
        QueueSobject fundedQueue;
         try{
            fundedQueue = [Select queue.id,queue.name,QueueID 
                                            from QueueSobject 
                                            where SobjectType ='genesis__Applications__c'                                   
                                            AND queue.DeveloperName  =: 'Funding_Queue'];
                    
            }       
        catch(Exception e){
            System.debug('Exception'+ e);
            throw new ints.IntegrationException('Funded Queue is not setup');
        }
         if(selectedApps != null && selectedApps.size() > 0){      
            for(integer i = 0;i < selectedApps.size(); i++)
            {
                genesis__Applications__c selectedApp = selectedApps.get(i);
                
                if(selectedApp.genesis__Status__c == 'funded' && selectedApp.OwnerId == fundedQueue.Queue.Id){
                    eligibleApps.add(selectedApp);
                }
                else{
                    
                }
            }       
        }
        return null;   
		
    }
    public PageReference callDCP()
    {       
        // Call StandardSetController 'save' method to update (optional, you can use your own DML)
        if(eligibleApps != null && eligibleApps.size() > 0){
            for(integer i = 0; i<eligibleApps.size();i++){
                InvokeDCP.InvokeDCP(eligibleApps[0].id);
            }
        }
        return standardController.save();   
    }
}