/*
 * @author :- Pallavi
* Generate TIL status changes to docusign_loan_docs_sent
* JIRA : CRM-135
*/
public class GenerateTILatDocusisgn {
    @InvocableMethod
    public static void invoke_Generate_TIL(List<String> appIds){
        try{
            System.debug('GenerateTILatDocusisgn');
            genesis__applications__c app = [Select id,Total_Arcus_Transactions__c from genesis__applications__c where id =: appIds[0]];
            String status = '';
            if(app.Total_Arcus_Transactions__c > 0)
                status = 'TILDocument_forDCP';
            else
                status = 'TIL';
            System.debug(status);
            GenerateTILatDocusisgn.Generate_TIL(appIds[0],status);
        }catch(Exception ex){
            System.debug('Exception:Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString());
        } 
    }
    public static void Generate_TIL(Id appId, String status){
        try{
            List<genesis__applications__c> app = [SELECT Id,Name,genesis__Status__c,Investor__c,Investor__r.Name
                                                  FROM genesis__applications__c WHERE Id=:appId LIMIT 1];
            System.debug('Application :'+app);
            ApplicationAttachmentHandler.attachmentHandler(appId,app[0].Investor__r.Name,status);
            
        }catch(Exception ex){
            System.debug('Exception:Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString());
        }
    }
}