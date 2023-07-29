public with sharing class AppDeclineCntrl{

    public List<genesis__Applications__c> eligibleApps{get;set;}
    public ApexPages.StandardSetController standardController;
    
    public AppDeclineCntrl(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
        eligibleApps = new List<genesis__Applications__c>();
    }

    public PageReference changeStatus()
    {       
        // Get the selected records (optional, you can use getSelected to obtain ID's and do your own SOQL)
        List<genesis__Applications__c> getSelectedApps = (List<genesis__Applications__c>) standardController.getSelected();
        List<genesis__Applications__c> selectedApps = [Select id,name,
                                                            genesis__Status__c,
                                                            OwnerID,
                                                            genesis__account__r.name,
                                                            investor__c
                                                        from genesis__Applications__c
                                                        where id in: getSelectedApps ];
        QueueSobject financeQue;
        QueueSobject pendingForFundingque;
        QueueSobject reviewQue;
        try{
            reviewQue = [Select queue.id,queue.name,QueueID 
                                            from QueueSobject 
                                            where SobjectType ='genesis__Applications__c'                                   
                                            AND queue.Name =: 'Review Queue'];
        }
        catch(Exception e){
            System.debug('Exception'+ e);
            throw new ints.IntegrationException('Finance Queue is not setup');
        }
        try{
            financeQue = [Select queue.id,queue.name,QueueID 
                                            from QueueSobject 
                                            where SobjectType ='genesis__Applications__c'                                   
                                            AND queue.Name =: 'Pre-Funding Queue'];
            
        }
        catch(Exception e){
            System.debug('Exception'+ e);
            throw new ints.IntegrationException('Finance Queue is not setup');
        }
        try{
            pendingForFundingque = [Select queue.id,queue.name,QueueID 
                                        from QueueSobject 
                                        where SobjectType ='genesis__Applications__c'                                   
                                        AND queue.Name =: 'Pending for Funding'];
                                        
        }
        catch(Exception e){
            System.debug('Exception'+ e);
            throw new ints.IntegrationException('Pending for Funding is not setup');
        
        }

        // Update records 
        if(selectedApps != null && selectedApps.size() > 0){      
            for(integer i = 0;i < selectedApps.size(); i++)
            {
                genesis__Applications__c selectedApp = selectedApps.get(i);
                System.debug('Hello'+selectedApp.genesis__Status__c+'Test'+selectedApp.OwnerId);
                if((selectedApp.genesis__Status__c == 'pre_funding' && selectedApp.OwnerId == financeQue.Queue.Id) || (selectedApp.genesis__Status__c == 'Approved for funding' && selectedApp.OwnerId == pendingForFundingque.Queue.Id)){
                    selectedApp.OwnerId = reviewQue.Queue.Id;
                    selectedApp.genesis__Status__c = 'review';
                    eligibleApps.add(selectedApp);
                }
                else{
                    
                }
            }       
        }
        return null;        
    }

    public PageReference updateApps()
    {       
        // Call StandardSetController 'save' method to update (optional, you can use your own DML)
        if(eligibleApps != null && eligibleApps.size() > 0){
            update eligibleApps;
        }
        return standardController.save();   
    }
    

}