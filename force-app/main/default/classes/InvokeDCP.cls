/*
* 
* JIRA : CLS-1082
*/
public class InvokeDCP{
    public static void InvokeDCP(Id applicationId){
        
        System.debug(logginglevel.error, 'IN InvokeDCP :: App ID '+applicationId);
        
        try{
            List<DCp_Arcus_Transactions__c> dcpTrans = [select id,name,Credit_Card_Name__c,
                                                        Paid_Amount__c,Status__c,Transaction_Id__c,
                                                        DCP_Callout_done__c
                                                        from DCp_Arcus_Transactions__c
                                                        where Transaction_Id__c!=null and Pay_at_Funding__c=true 
                                                        and application__c=:applicationId /*and DCP_Callout_done__c = false*/];
            
            List<DCp_Arcus_Transactions__c> updatedcpTrans = new List<DCp_Arcus_Transactions__c>();
                                                        
            for(DCp_Arcus_Transactions__c dcpTransaction : dcpTrans) {
                
                httpResponse res = DCPIntegration.patchTransactions(dcpTransaction.Transaction_Id__c);                   
                System.debug(logginglevel.error, 'AFTER CALLING DCPIntegration :: RES ::' +res );
                //System.debug('AFTER CALLING DCPIntegration :: RES ::' +res );
                dcpTransaction.DCP_Callout_done__c = true;
                if(res.getStatusCode()==200 || res.getStatusCode() == 202)
                    dcpTransaction.DCP_Callout_successful__c = true;
                System.debug('status---' + res.getStatus());
                updatedcpTrans.add(dcpTransaction);
            }
            
            if(updatedcpTrans.size()>0)
                update updatedcpTrans;
            
        }catch(Exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'Invoke DCP Integration' ;
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            System.debug('Exception:'+bplog.loan__Message__c);
            insert bplog;
        }
    }
}