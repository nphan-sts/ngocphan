public with sharing class BatchAssignController {
    
    public genesis__Applications__c app {get;set;}
    public List<genesis__Applications__c> eligibleApps{get;set;}
    public ApexPages.StandardSetController standardController;
    
    public BatchAssignController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
        eligibleApps = new List<genesis__Applications__c>();
        app = (genesis__Applications__c) standardController.getRecord();
    }
    
    public PageReference addUser()
    {       
        // Get the selected records (optional, you can use getSelected to obtain ID's and do your own SOQL)
        List<genesis__Applications__c> getSelectedApps = (List<genesis__Applications__c>) standardController.getSelected();
        List<genesis__Applications__c> selectedApps = [Select id,name,
                                                       User_Approver__c,
                                                       User_Outbounder__c,
                                                       User_PreChecker__c,
                                                       User_Processor__c,
                                                       OwnerID
                                                       from genesis__Applications__c
                                                       where id in: getSelectedApps ];
        
        
        // Update records 
        try{
            if(selectedApps != null && selectedApps.size() > 0){      
                for(integer i = 0;i < selectedApps.size(); i++)
                {
                    genesis__Applications__c selectedApp = selectedApps.get(i);
                    
                    if(app.User_PreChecker__c != null){
                         selectedApp.User_PreChecker__c = app.User_PreChecker__c;
                    }
                    if(app.User_Processor__c != null){
                         selectedApp.User_Processor__c = app.User_Processor__c;
                    }
                    if(app.User_Outbounder__c != null){
                         selectedApp.User_Outbounder__c = app.User_Outbounder__c;
                    }
                    if(app.User_Approver__c != null){
                         selectedApp.User_Approver__c = app.User_Approver__c;
                    }
                    if(app.User_PreChecker__c != null){
                         selectedApp.User_PreChecker__c = app.OwnerID;
                    }
                   
                    eligibleApps.add(selectedApp);
                }       
            }
            
            
        }catch(Exception e){
            System.debug('Exception'+ e.getMessage());
            throw new ints.IntegrationException('No input from user.');
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
    
    public PageReference cancel()
    {       
        return standardController.save();   
    }
    
}