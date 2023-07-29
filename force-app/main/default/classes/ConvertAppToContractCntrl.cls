public with sharing class ConvertAppToContractCntrl{

    private ApexPages.StandardSetController setCon;
    public Set<genesis__Applications__c> eligibleApps{get;set;}
    public Set<genesis__Applications__c> notEligibleApps{get;set;}
    public List<genesis__Applications__c> eligibleAppsLst{get;set;}
    public List<genesis__Applications__c> notEligibleAppsLst{get;set;}
    public List<genesis__Applications__c> selectedAppList{get;set;}
    Public Set<ID> eligibleAppSet;
    public List<Errors> listErrors{get;set;}
    Set<Id> appIdSet;
    public Integer count {get;set;}
    public static Id jobId{get;set;}
    public string callfunc{get;set;} 
    public static AsyncApexJob job {get;set;}
    public ConvertAppToContractCntrl(){
        jobId = System.currentPageReference().getParameters().get('jobId');
        count=1;
    }
    public ConvertAppToContractCntrl(ApexPages.StandardSetController controller){
        setCon = controller;
        eligibleApps = new Set<genesis__Applications__c>();
        notEligibleApps = new Set<genesis__Applications__c>();
        count = 1;
        eligibleAppSet = new Set<ID>();
        jobId = System.currentPageReference().getParameters().get('jobId');
    }    
    public PageReference convertApps(){
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date systemDate = util.getCurrentSystemDate();                                           
        selectedAppList = (List<genesis__Applications__c>)setCon.getSelected();
        List<genesis__Applications__c> queryAppsList = [Select id,name,
                                                            genesis__Status__c,
                                                            genesis__account__r.name,
                                                            Investor__c,
                                                            Investor__r.name,
                                                            Payment_Mode__c,
                                                            genesis__CL_Product__c,
                                                            genesis__CL_Product__r.name,
                                                            genesis__CL_Product__r.loan__Lending_Product__r.name,
                                                            OwnerID
                                                        From genesis__Applications__c
                                                        Where id in : selectedAppList];
                                                        
        QueueSobject pendingForFundingque;        
        try{
            pendingForFundingque = [Select queue.id,queue.name,QueueID 
                                        from QueueSobject 
                                        where SobjectType ='genesis__Applications__c'                                   
                                        AND queue.Name =: 'Pending for Funding' limit 1];
                                        
        }
        catch(Exception e){
            System.debug('Exception'+ e);
            throw new ints.IntegrationException('Pending for Funding is not setup');        
        }                                                        
        for(genesis__Applications__c app : queryAppsList){            
            if(app.genesis__Status__c == 'Approved for funding' 
            && app.OwnerId == pendingForFundingque.queue.Id
            //&& app.Payment_Mode__c != null
            && app.Investor__c != null
            && app.genesis__CL_Product__c != null){            
                //appIdSet = new Set<Id>();
                //appIdSet.add(app.Id);
                eligibleApps.add(app);
                eligibleAppSet.add(app.Id);
            }
            else {
                notEligibleApps.add(app);            
            } 
                               
        }  
        eligibleAppsLst = new List<genesis__Applications__c>();
        notEligibleAppsLst = new List<genesis__Applications__c>();
        eligibleAppsLst.addAll(eligibleApps);
        notEligibleAppsLst.addAll(notEligibleApps);
        return null;
    } 
    
    
    public void checkJobStatus() {
        jobId = System.currentPageReference().getParameters().get('jobId');
        job = [SELECT TotalJobItems, JobItemsProcessed, CompletedDate, Status FROM AsyncApexJob WHERE Id = :jobId];
        callfunc = job.status;
        System.debug('checkJobStatus' +job.status);
        if(job!=null && job.status!=null) {
            System.debug('checkJobStatus if statement' +job.status);
            if(job.status=='Completed') {
                   count=0;
            } else {
                count=1;
            }
        }
        
    }
    
    public PageReference direct() {
        return setCon.save(); 
    }
    
    public Boolean getIsEnabled() { 
        System.debug('inside'+jobId);
        if(jobId!=null && count==1) {
            System.debug('return true');
            return true;
        } else  {
            System.debug('return false');
            return false;
        }
        //return flag;
        
    }
    
       
    public pageReference updateApps(){       
        // Call StandardSetController 'save' method to update (optional, you can use your own DML)  
        /*for(genesis__Applications__c app : eligibleApps){
            Set<ID> singleAppIDSet = new Set<ID>();
            singleAppIDSet.add(app.ID);
            try{
                ApptoContractConverterBatchJob conv = new ApptoContractConverterBatchJob(singleAppIDSet);
                Database.executeBatch(conv,1);
            }           
            Catch(Exception e){                
                System.Debug('<<Exception>>' + appIdSet + e.getMessage() + e.getlineNumber());   
                Errors err = new Errors();
                err.appName = app.Name;
                err.error = '<<Exception>>' + appIdSet + e.getMessage() + e.getlineNumber();
                if(listErrors == null && listErrors.size() <= 0){
                    listErrors = new List<Errors>();                    
                }
                listErrors.add(err);
                //apexpages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,app.Name +' Exception '+ e.getMessage())); 
                                   
            }          
        }*/ 
        
        ApptoContractConverterBatchJob conv = new ApptoContractConverterBatchJob(eligibleAppSet);
        jobId = Database.executeBatch(conv,1);
        
        /*if(listErrors != null && listErrors.size() > 0){
             pageReference pg = new pageReference('/apex/Errors'); 
             return pg;
        }  */ 
        PageReference nextpage = new PageReference('/apex/ConvertApplication?jobId='+jobId);
        return nextpage;        
        //return setCon.save();   
       // return null;
    }
    public class Errors{
        public String appName{get;set;}
        public String error{get;set;}  
    }
    
}