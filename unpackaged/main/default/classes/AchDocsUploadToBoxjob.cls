global class AchDocsUploadToBoxjob implements Database.Batchable<sObject>,Database.AllowsCallouts {
   String query;
   public static HttpResponse resp = new HttpResponse();
   global CL_Document__c docs = CL_Document__c.getOrgDefaults();
   String uploadbox = docs.UploadedBOX__c; 
   global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Set<String> foldersName = new Set<String>();
        List<loan__Automated_Payment_Configuration__c> listAPC = [
                SELECT Id,
                       Name,
                       Box_Folder_ID__c,
                       loan__Folder_Name__c
                FROM   loan__Automated_Payment_Configuration__c
                WHERE  Box_Folder_ID__c != NULL
                AND    loan__Active__c = TRUE
        ];
        System.debug('****listAPC****'+listAPC);
        if(!listAPC.IsEmpty()){                                                                     
            for(loan__Automated_Payment_Configuration__c APC : listAPC){
                    
                foldersName.add(APC.loan__Folder_Name__c);  
                
                }
        }
                                                                        
                                                                
        query = 'SELECT Id,Name,FolderId,Folder.Name,body FROM Document WHERE Folder.Name IN : foldersName AND Description !=: uploadbox';       
        System.debug('<< Initial Query >>' +query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Document> scope) {
       if(!scope.isEmpty()){ 
            list<Document> Documentlist = new list<Document>(scope);
             try{
                  loan__Automated_Payment_Configuration__c APC = [
                          SELECT Id,
                                 Name,
                                 Box_Folder_ID__c,
                                 loan__Folder_Name__c
                          FROM   loan__Automated_Payment_Configuration__c
                          WHERE  loan__Folder_Name__c = :Documentlist[0].Folder.Name
                          AND    loan__Active__c = TRUE
                          LIMIT  1
                  ];
               
              
                resp = BoX_Integ.uploadFileToBox(Documentlist[0].body,Documentlist[0].name,APC.Box_Folder_ID__c,null);
                
                System.debug('****rs****'+resp.getStatusCode());
                System.debug('****rsStatus*****'+resp.getStatus());
                if(resp.getStatusCode() == 201 && resp.getStatus() == 'Created'){
                    
                    Documentlist[0].Description = docs.UploadedBOX__c; 
                    Update Documentlist[0];
                    System.debug('***FileUploadedSuccessfully****');
                }
                if(resp.getStatusCode() == 401 && resp.getStatus() == 'Conflict')
                {
                    System.debug('The file with same name cannot be uploaded');
                }
              
             }
             catch(exception ex){
                  loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
                    bplog.loan__Origin__c = 'AchDocsUploadToBoxjob';
                    bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
                    bplog.loan__Type__c = 'Exception';
                    bplog.loan__Time__c = DateTime.now();
                    insert bplog;
                 
             }
        }
            
    }
        
    /*global void execute(SchedulableContext ctx) {
        Id batchJobId = Database.executeBatch(new AchDocsUploadToBoxjob(), 40);
    }*/
    
    global void finish(Database.BatchableContext BC) {
        // update job's last run time in custom         
    }  
   
}