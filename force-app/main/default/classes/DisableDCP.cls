/*
* Disable DCP for an Application having 2 or more failed cards
* JIRA : CLS-1290
*/
public class DisableDCP {
    
    public static void disableDCP(Id appId){
        Integer givenFailedCount = 2;
        Integer disabledDCP;
        Integer failedCards;
        Integer DCPTagCount;
        try{
            System.debug('disableDCP');
            failedCards = [SELECT count() FROM DCp_Arcus_Transactions__c WHERE Application__c =: appId AND 
                           Braintree_Verification_Failed__c = true];
            
            disabledDCP = [SELECT count() FROM DCp_Arcus_Transactions__c WHERE Application__c =: appId AND
                           pay_at_funding__c = false];
            
            List<DCp_Arcus_Transactions__c> totalDCPcount = [SELECT id,Name,Pay_at_Funding__c FROM DCp_Arcus_Transactions__c 
                                                             WHERE Application__c =: appId];
            
            DCPTagCount = [SELECT count() from Application_Tags__c where Application__c =: appId and 
                           Application_Tag__c = 'DCP Card Verifications Failed' and softDelete__c = false];   // added softDelete__c for LOS-121 by pallavi
            
            
            if(failedCards>= givenFailedCount){
               // System.debug('inside if');
                List<DCp_Arcus_Transactions__c> updateDCPTrans = new List<DCp_Arcus_Transactions__c>();
                
                /*System.debug('before tag');
                System.debug(disabledDCP);
                System.debug(totalDCPcount.size());
                System.debug(DCPTagCount);*/
                
                if(!((disabledDCP==totalDCPcount.size() || disabledDCP==totalDCPcount.size()-1) && DCPTagCount > 0)){
                    Application_Tags__c newTag = new Application_Tags__c();
                    newTag.Application__c = appId;
                    newTag.Application_Tag__c = 'DCP Card Verifications Failed';
                    insert newTag;
                }
                for(DCp_Arcus_Transactions__c dcp:totalDCPcount){
                    //System.debug('inside for');
                    dcp.Pay_at_Funding__c = false;
                    updateDCPTrans.add(dcp);
                }
                update updateDCPTrans;
            }
        }catch(Exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'Disable DCP' ;
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            System.debug('Exception:'+bplog.loan__Message__c);
            insert bplog;
        }
    }
}