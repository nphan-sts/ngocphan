Public with Sharing class DeleteAppDocJunAttachments{
    Public static void delAttachments(Set<Id> attmtId){
        System.debug('delAttachments... isDeleted=false');
        List<genesis__AppDocCatAttachmentJunction__c> delAttLst = new List<genesis__AppDocCatAttachmentJunction__c>();
        List<genesis__AppDocCatAttachmentJunction__c> lstAppDocCatAttachment = [Select Id, isDeleted from           genesis__AppDocCatAttachmentJunction__c where 
                    genesis__AttachmentId__c IN :attmtId and isDeleted = false];
        for(genesis__AppDocCatAttachmentJunction__c attCategory : lstAppDocCatAttachment){
                //attCategory.isDeleted = true;
                System.debug('delAttachments... Id: '+attCategory.Id);
                delAttLst.add(attCategory);
        }
        try{	//LOS-38
        if(delAttLst != null)
            delete(delAttLst);	
        }
        catch (DMLException ex){	//LOS-38
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'DeleteAppDocJunAttachments - delAttachments';
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
            Database.delete(delAttLst, false);	//LOS-38
        }
    }
}