public class GenerateAppDocCategory {
	public static void createDocumentCategory(Id lstDocuSignStatusId){
        
        dsfs__DocuSign_Envelope__c lstDocuSignEnv;
        genesis__Application_Document_Category__c lstAppDocCat;
        Attachment lstAttachments;        
        
        try{            
            if(lstDocuSignStatusId != null){  
                
                    system.debug('////// DocuSign Status Id' + lstDocuSignStatusId);
                    lstAttachments = [Select Id, Name from Attachment where ParentId = : lstDocuSignStatusId and 
                                      Name like '%Promissory%' and IsDeleted = false];
                    
                    system.debug('////// Attachment Id' + lstAttachments.Id); 
                
            }      
            
            if(lstAttachments != null){                  
                genesis__AppDocCatAttachmentJunction__c lstAppDocCatAttachment = new genesis__AppDocCatAttachmentJunction__c();                
                lstAppDocCatAttachment.genesis__AttachmentId__c = lstAttachments.Id; 
                
                string strAppId = lstAttachments.Name.substringBefore('.');
                Id appId = strAppId.substring(strAppId.length()-15, strAppId.length());
                system.debug('... Application Id ' + appId);
                
            	lstAppDocCat = [Select Id, Name from genesis__Application_Document_Category__c where genesis__Application__c= :appId and Name = 'Promissory Category' and IsDeleted = false];
                                
                if(lstAppDocCat != null){
                    system.debug('... ApplicationDocCategory Id' + lstAppDocCat.Id);                                   
                    lstAppDocCatAttachment.genesis__Application_Document_Category__c = lstAppDocCat.Id;
                    Insert(lstAppDocCatAttachment); 
                }                  
            }            
        }
        
        catch (Exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'GenerateDocumentCategory Class' ;
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
            
            throw ex;
        }
        
    }
}