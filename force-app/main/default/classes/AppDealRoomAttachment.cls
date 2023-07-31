Public With Sharing class AppDealRoomAttachment{
    public static void DealroomAttachment(Id applicationId, Set<Id> attachmentId){
        Map<Id,String> attachCategory = new Map<Id,String>();
        try{         
            List<Attachment> attachments = [Select Id,Name,Description from Attachment where id in:attachmentId];
            for(Attachment attachId : attachments){
                attachCategory.put(attachId.id,attachId.Description);
            }
            List<genesis__Application_Document_Category__c> lstAppDocCat = [Select Id,Name from genesis__Application_Document_Category__c where genesis__Application__c =: applicationId and Name like: attachCategory.values() and IsDeleted = false];
            List<genesis__AppDocCatAttachmentJunction__c> appDocCatAttInsert = new List<genesis__AppDocCatAttachmentJunction__c>();
            for(genesis__Application_Document_Category__c appDoc : lstAppDocCat) {
                for(Id attachId : attachmentId){
                    if(appDoc.name.equalsIgnoreCase(attachCategory.get(attachId))) {
                        genesis__AppDocCatAttachmentJunction__c lstAppDocCatAttachment = new genesis__AppDocCatAttachmentJunction__c();  
                        lstAppDocCatAttachment.genesis__Application_Document_Category__c = appDoc.Id;
                        lstAppDocCatAttachment.genesis__AttachmentId__c = attachId;  
                        appDocCatAttInsert.add(lstAppDocCatAttachment); 
                    }
                }
            }
            if(!appDocCatAttInsert.isEmpty())
            	insert appDocCatAttInsert;
            
            /*for(Id attachId : attachmentId){
            	if(!lstAppDocCat.isEmpty()){
                    system.debug('---lstAppDocCat----'+lstAppDocCat); 
                    System.debug('.... Attachment Id ..' + attachId );
                    
                    for(genesis__Application_Document_Category__c genesisAppIterate : lstAppDocCat){
                        genesis__AppDocCatAttachmentJunction__c lstAppDocCatAttachment = new genesis__AppDocCatAttachmentJunction__c();  
                        
                        lstAppDocCatAttachment.genesis__Application_Document_Category__c = genesisAppIterate.Id;
                        lstAppDocCatAttachment.genesis__AttachmentId__c = attachId;  
                        appDocCatAttInsert.add(lstAppDocCatAttachment); 
                    }
                    if(!appDocCatAttInsert.isEmpty())
                        insert appDocCatAttInsert;
                }
            }*/
        }catch (Exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c(loan__Origin__c = 'Adverse Action Dealroom',loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString(),loan__Type__c = 'Exception',loan__Time__c = DateTime.now());
            insert bplog;  throw ex;
        } 
     }
}