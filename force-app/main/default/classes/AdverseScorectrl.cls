public class AdverseScorectrl {
     public static boolean isADVTrgExecuting = true;
    public AdverseScorectrl(boolean isExecuting){
        isADVTrgExecuting = isExecuting;
    }    
    
    public Static Void Adversefuturemethod(Id ApplicationId){
        if(isADVTrgExecuting){            
            System.debug('isADVTrgExecuting....'+ isADVTrgExecuting);
            Adversemethodcall(ApplicationId); 
            isADVTrgExecuting = false;
        }
    }
  /*  @InvocableMethod
    public static void AdvMethod(List<ID> AppId){
        
        Adversefuturemethod(AppId);
    }
    */
    
    @future(callout=true)
    public static void Adversemethodcall(Id AppId){
        List<Adverse__c> lstNoHitData=new List<Adverse__c>();
        List<Adverse_Actions__c> lstAdvData=new List<Adverse_Actions__c>();
        List<Score_Factors__c>  lstSFData=new List<Score_Factors__c>();
        genesis__Applications__c app = [SELECT Id,genesis__Account__c,
                                              genesis__Account__r.Payoff_UID__c,
                                              genesis__Status__c
                                              FROM genesis__Applications__c 
                                              WHERE id =:AppId LIMIT 1];
        
        if(app != null) {
            system.debug(app);
            
            AdverseScoreResponse res = new AdverseScoreResponse();            
            AdverseScoreIntegration adv=new AdverseScoreIntegration();
            try{
                res=adv.getAdvScData(app.genesis__Account__r.Payoff_UID__c,app.genesis__Account__c,app.id);
                
                lstSFData= res.scf;
                lstAdvData=res.adv;
                lstNoHitData=res.no_hit;
                /*insert lstAdvData;
                insert lstSFData;
                insert lstNoHitData;*/
                            
                List<Adverse_Actions__c> advActionData = [Select Id from Adverse_Actions__c where Application__c = :app.Id and
                                                Account__c = :app.genesis__Account__c];
                System.debug('....Delete List... '+ advActionData );
                if(! advActionData.isEmpty())
                    delete advActionData ;
                insert lstAdvData;
                
                List<Score_Factors__c> SFData = [Select Id from Score_Factors__c where Application__c = :app.Id and
                                                Account__c = :app.genesis__Account__c];
                System.debug('....Delete SFData List... '+ SFData );
                if(! SFData.isEmpty())
                    delete SFData ;
                insert lstSFData;            
                
                List<Adverse__c> advr = [Select Id from Adverse__c where Application__c = :app.Id and
                                                Account__c = :app.genesis__Account__c]; 
                System.debug('....Delete adv List... '+ advr );
                if(! advr.isEmpty())
                    delete advr;
                insert lstNoHitData; 
            }
            catch(Exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in Adverse Action:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
            insert logs;
            System.debug('Exception: '+ex.getMessage());
        } 
        }
    }
    
}