/**
* Description: Document Category related logic.
*
*   Modification Log :
---------------------------------------------------------------------------
Developer               Date                Description
---------------------------------------------------------------------------
Mohseen Begum           07/04/2017          Created
******************************************************************************************/
public class DocumentAttachmentTriggerHandler {
    
    public static boolean isTrgExecuting=false;
    
    /**
* Constructor to initialize
*
* @param isExecuting    Has value of which context it is executing.
*/
    public DocumentAttachmentTriggerHandler(boolean isExecuting){
        isTrgExecuting = isExecuting;
    }
    
    
    /**
* Description: Below method is used to create document category
*
* @param attDetails     Attachment records.
* 
*/
    public static void createDocumentCategory(dsfs__DocuSign_Status__c dsStatus){
        System.debug('.... createDocumentCategory ....' );
                     
        try{            
            if(dsStatus != null && dsStatus.dsfs__Envelope_Status__c == 'Completed'){  
                
                system.debug('status....'+dsStatus.dsfs__Envelope_Status__c + 'ParentId' + dsStatus.Id);
                CreateAppDocCategory(dsStatus.dsfs__Envelope_Status__c);
            }                         
        }catch (Exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c(loan__Origin__c = 'Promissory Note' ,loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString(),loan__Type__c = 'Exception',loan__Time__c = DateTime.now());
            
            insert bplog;
            
            throw ex;
        }
    }
        
    @future
        public static void createAppDocCategory(String dsStatus){
            
            List<genesis__Application_Document_Category__c> lstAppDocCat;
            genesis__AppDocCatAttachmentJunction__c lstAppDocCatAttachment; 
            
            list<attachment> attachmentLst = [select Id, Name from attachment where ParentId = :dsStatus and
                                               IsDeleted = False];
                    
            if(! attachmentLst.isEmpty()){
                if(attachmentLst[0].Name.contains('Promissory')){
                    //exOrigin = 'Promissory';                   
                    system.debug('Prommissory Document');
                    //System.debug('.... Attachment Name ' + attachmentLst[0].Name + '..' + attachmentLst[0].Id +'parentId:' +
                     //            attachmentLst[0].ParentId );
                    
                    lstAppDocCatAttachment = new genesis__AppDocCatAttachmentJunction__c();   
                    Id appId = getApplicationId(attachmentLst[0].Name);
                    system.debug('********appId*****'+appId);
                    lstAppDocCat = [Select Id from genesis__Application_Document_Category__c where genesis__Application__c =: appId 
                                    and Name = 'Promissory Note' and IsDeleted = false];
                    System.debug('hello' +lstAppDocCat + ' ,  ' +appId );
                    if(! lstAppDocCat.isEmpty()){
                        System.debug('.... Attachment Name ' +  '..' + attachmentLst[0].Id );
                        system.debug('... ApplicationDocCategory Id' + lstAppDocCat[0].Id);  
                        lstAppDocCatAttachment.genesis__Application_Document_Category__c = lstAppDocCat[0].Id;
                        lstAppDocCatAttachment.genesis__AttachmentId__c = attachmentLst[0].Id;                             
                        Insert lstAppDocCatAttachment; 
                    }
                }                  
            }
        }  

    /**
* Description: Below method is used to get attachmnet record ID from attachment name.
*
* @param attName     Attachment record name.
* 
*/
    public static Id getApplicationId(string attName){        
        string strAppId = attName.substringBefore('.');
        Id appId = strAppId.substring(strAppId.length()-15, strAppId.length());
        system.debug('... Application Id ' + appId);
        return appId;
    }
}