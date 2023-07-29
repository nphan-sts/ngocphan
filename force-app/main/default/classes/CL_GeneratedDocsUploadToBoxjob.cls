global class CL_GeneratedDocsUploadToBoxjob implements Database.Batchable<sObject>,Database.AllowsCallouts {
   String query;
   public static HttpResponse resp = new HttpResponse();
   public static CL_Document__c cs = CL_Document__c.getOrgDefaults();
   public static string credit = cs.Doc1__c;
   public string Til = cs.Doc2__c;
   public string Adverse = cs.Doc3__c;
   public string uploadbox = cs.UploadedBOX__c;    
   global Database.QueryLocator start(Database.BatchableContext BC) {
   
      query = 'SELECT Name,body,ParentId,Description,Parent.type from Attachment where (Description =: credit OR Description =: Til OR Description =: Adverse) AND ParentId != NULL AND Description !=: uploadbox Order By CreatedDate ASC';
        
        System.debug('<< Initial Query >>' +query);
        return Database.getQueryLocator(query);
        
   }
   global void execute(Database.BatchableContext BC, List<Attachment> scope) {
       
       if(!scope.IsEmpty()){
           
           List<Attachment> attlist = new  List<Attachment>(scope);
           try{
               genesis__Applications__c app = [SELECT id,BoxFolderID__c,LeadGUIDBoxFolderID__c from genesis__Applications__c where id =:attlist[0].ParentId limit 1];
               
               System.debug('***app***'+app);
               if(app != null){
               
                   if(app.LeadGUIDBoxFolderID__c != null){
                       
                       
                       resp = BoX_Integ.uploadFileToBox(attlist[0].body,attlist[0].name,app.LeadGUIDBoxFolderID__c ,app.id);
                       System.debug('****rs****'+resp.getStatusCode());
                        System.debug('****rsStatus*****'+resp.getStatus());
                        
                    }
                   
                   
                }
               
                    if(resp.getStatusCode() == 201 && resp.getStatus() == 'Created'){
                        
                        attlist[0].Description = cs.UploadedBOX__c;
                        Update attlist[0];
                        System.debug('***FileUploadedSuccessfully****');
                    }
                    if(resp.getStatusCode() == 401 && resp.getStatus() == 'Conflict')
                    {
                        System.debug('The file with same name cannot be uploaded');
                    }
               }
            
            catch(Exception ex){
                loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'CL_GeneratedDocsUploadToBoxjob';
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            System.debug('******' +ex.getMessage());
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        // update job's last run time in custom         
    }  
}