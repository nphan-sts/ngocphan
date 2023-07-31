/*
* Regerate TIL whenever DCP Arcus Transaction is updated 
* JIRA : CLS-1272,1189
*/
public class RegenerateTIL {
    @InvocableMethod
    public static void WF_tilRegenerate(List<Id> appIds){
        try{
            RegenerateTIL.onUpdateRegenerateTIL(appIds[0]); 
        }catch(Exception ex){
            System.debug('Exception:Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString());
        } 
    }
    
    public static void onUpdateRegenerateTIL(Id appId){
        try{
            List<genesis__applications__c> app = [SELECT Id,Name,genesis__Status__c,Investor__c,Investor__r.Name
                                                  FROM genesis__applications__c WHERE Id=:appId LIMIT 1];
            System.debug('Application :'+app);
            ApplicationAttachmentHandler.attachmentHandler(appId,app[0].Investor__r.Name,'TILDocument_forDCP');	//CLS-1189
            /*Application_Tags__c at = new Application_Tags__c();
            at.Application__c = app[0].id;
            at.Application_Tag__c ='Re allocation';
            insert at;*/
            
        }catch(Exception ex){
            System.debug('Exception:Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString());
        } 
    } 
}