public without sharing class AssignMeController {
    
    public genesis__Applications__c app {get;set;}
    public List<genesis__Applications__c> eligibleApps{get;set;}
    public ApexPages.StandardSetController standardController;
    
    public AssignMeController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
        eligibleApps = new List<genesis__Applications__c>();
        app = (genesis__Applications__c) standardController.getRecord();
    }
    
    public PageReference onLoad(){
        
        String Appid = PayOffUtilities.AssignToMe();   
        PageReference appPage = Appid !=null ? new PageReference('/'+Appid): null ;
        appPage.setRedirect(true);
        return appPage;       
    }
}