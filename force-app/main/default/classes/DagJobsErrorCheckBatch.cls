/*----------------------------------------------------------------------------------------------------------------------------------------------------------------
   
    #JIRA ID Description Authour Date
   
    LSP-306 Batch apex is to send error codes to slack whenever a Payment-Filegen-Upload        Mohan Kiran 06/15/2021
    to Box job fails
   
    -----------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    //Start Method
   
    global class DagJobsErrorCheckBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
        public string jobName;
       
        public dagJobsErrorCheckBatch (string jobNameInput){
           
            jobName = jobNameInput;
        }
       
        public Database.QueryLocator start(Database.BatchableContext bc){
            /*Querylocator returns the list of Jobs releated to Consolidated DAG record */
           
            if (jobName == 'ConsolidatedDag'){
               
                return Database.getQueryLocator('SELECT id, name, clcommon__Label__c, clcommon__Class__c,  clcommon__DAG__r.clcommon__DAG_Name__c,clcommon__Last_Used_Query__c FROM clcommon__Job__c where clcommon__DAG__r.clcommon__DAG_Name__c = \'Consolidated DAG\'');
            }
           
            else {
               
                return Database.getQueryLocator('SELECT id, name, clcommon__Label__c, clcommon__Class__c,  clcommon__DAG__r.clcommon__DAG_Name__c,clcommon__Last_Used_Query__c FROM clcommon__Job__c where clcommon__DAG__r.clcommon__DAG_Name__c = \'Payment - Filegen - Upload to Box\'');
            }
        }    
        //Execute Method  
       
        public void execute(Database.BatchableContext bc, List<clcommon__Job__c> scope){
           
            //Declaring variables
           
            list<sObject> sobjList = new list<sObject>();
            String documentDetailsBody = null; // To hold serialized contents of documents (object) data
            List<loan__Automated_Payment_Configuration__c> apcList = new List<loan__Automated_Payment_Configuration__c>();
            list<folder> folderIds = new list<folder>();
            set<string> folderNameSet = new set<string>();
            list<document> documentList = new list<document>();
           
           
            // Getting the set of Folder names from apcList and add it to folderNameSet
            if(jobName == 'NachaJob'){
 
                for(loan__Automated_Payment_Configuration__c fs: [SELECT id,
                                                                  loan__folder_name__c FROM
                                                                  loan__Automated_Payment_Configuration__c WHERE
                                                                  loan__Folder_Name__c != null AND
                                                                  Box_Folder_ID__c != null]){
                                                                      folderNameSet.add(fs.loan__Folder_Name__c);
                                                                  }
                // Fetch the list of ids from the folderNameSet
                folderIds = [SELECT id,
                             Name FROM
                             Folder WHERE
                             Name IN:folderNameSet];
               
                documentList = [SELECT id,
                                Name,
                                FolderID,
                                CreatedDate,
                                Description FROM
                                Document WHERE
                                CreatedDate = TODAY AND
                                Description = NULL AND
                                FolderID IN:folderIds];
            }
            /*Below variables are declared to pass parameters to the
    MW_Utility_CDErrorCheck apex utility class*/
           
            string jobName;
            string jobClass;
            string query;
            string jobLabel;
            Map<String, Object> documentDetails = new Map<String, Object>();
           
           
            for(clcommon__Job__c Sc:Scope){
               
                //Code to remove Limit 0 from the query field.
               
                jobName = sc.name;          
                jobClass = sc.clcommon__Class__c;
                jobLabel = sc.clcommon__Label__c;
                query = Sc.clcommon__Last_Used_Query__c;
                string target = 'LIMIT 0';
                String replacement = '';
                string queryWithoutLimit = query.replace(target,replacement);
               
                /*Database.query is used to fetch each job's query field. */
               
                if(sc.clcommon__DAG__r.clcommon__DAG_Name__c == 'Consolidated DAG'){
                   
                    sobjList = Database.query(queryWithoutLimit);
                }
                else{  
                    if(jobLabel == 'Upload to Box'){
                        for(Document Docs: documentList){
                           
                            documentDetails.put('Name of the Document :', Docs.Name  + '\n' +
                                                'Folder ID: ' + Docs.FolderId+ '\n');
                           
                            documentDetailsBody = JSON.serialize(documentDetails);
                           
                           
                            UtilityDagJobsErrorCheck.errorLog(jobName,jobClass, documentDetailsBody);
                        }
                    }
                    else {
                        sobjList = Database.query(queryWithoutLimit);  
                       
                    }
                }
               
                /*Calls utility class and send the job name and class name only when the query returns a value*/
               
                if(sobjList.size()>0){
                   
               UtilityDagJobsErrorCheck.errorLog(jobName,jobClass, documentDetailsBody);
                }
            }
        }
       
        //Finish Method
       
        public void finish(Database.BatchableContext bc){
            system.debug('>>>>>>>>job completed');
        }
       
       
    }