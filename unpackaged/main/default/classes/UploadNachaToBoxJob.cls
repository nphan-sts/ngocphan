global with sharing class UploadNachaToBoxJob implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful,Schedulable {

   String query;
   Integer totalCount;
   global List<Document> updateDoc = new List<Document>();
   global set<Id> nonUpdatedDocsId = new set<Id>();
   global set<Id> updatedDocsId = new set<Id>();
   Map<String,String> folderBoxMap = new Map<String,String>();
   List<String> folderName = new List<String>();
   global Map<Id,String> folderIdBoxMap = new Map<Id,String>();

   global UploadNachaToBoxJob(){
       for(loan__Automated_Payment_Configuration__c apc : [ SELECT Id,name,loan__Folder_Name__c,Box_Folder_ID__c  FROM loan__Automated_Payment_Configuration__c
                                                            WHERE loan__Folder_Name__c != null and Box_Folder_ID__c != null])
       {
           folderName.add(apc.loan__Folder_Name__c);
           folderBoxMap.put(apc.loan__Folder_Name__c,apc.Box_Folder_ID__c);
       }
       Map<Id,Folder> folderMap = new Map<Id,Folder>([Select id,name from Folder where name in : folderName]);
        for(Id ids : foldermap.keySet()) {
            if(folderBoxMap.containsKey(foldermap.get(ids).name) && folderBoxMap.get(foldermap.get(ids).name) != null) {
                folderIdBoxMap.put(ids,folderBoxMap.get(foldermap.get(ids).name));
            }
        }
       query = 'SELECT Id,name,Description,FolderId,Folder.Name,Body FROM Document WHERE Folder.Name IN : folderName AND Description = null';
       String queryString = 'SELECT count() FROM Document WHERE Folder.Name IN : folderName AND Description = null'; 
       totalCount = Database.countQuery(queryString);
   }

   global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
   }

   global void execute(SchedulableContext sc) {
       UploadNachaToBoxJob j = new UploadNachaToBoxJob();
       Database.executebatch(j,1);
   }

   global void execute(Database.BatchableContext BC, List<Document> scope) {
       uploadFile(scope,'execute',folderIdBoxMap);
       MW_BoxUtil1.insertAccessToken();
   }
   global void finish(Database.BatchableContext BC) {  
        
        /* Update the documents with the box URLs for the NACHA files uploaded to the BOX folders */
        if(updateDoc.size() > 0){
            update updateDoc;
        }
        /* Send alerts to Slack channel and DataDog  */
           LogsCalloutBatch logBatch = new LogsCalloutBatch(folderName,totalCount,updatedDocsId,nonUpdatedDocsId);
           Database.executeBatch(logBatch);            
   }
   
   /* Call to this method is made from execute() for 1st upload attempt and finish() for upload retry */
   global void uploadFile(List<Document> documentList,String callingMethodName,Map<Id,String> folderIdBoxMap){
       
       for(Document doc : documentList) {
           /* Rename the NACHA file to match the naming convention required for upload job */
           String fileName = doc.name.replaceAll(':','');
           fileName = fileName.replaceAll('-','');
           fileName = fileName + '.txt';
           
           /* Make a call to the box file upload endpoint with the filename and other required details */
           String boxUrl = MW_BoxUtil1.uploadFileToBox(doc.Body,fileName,folderIdBoxMap.get(doc.folderId),null);
           
           /* If there's a boxUrl then add it to the Description field of the Document record */
           if(boxUrl != null) {               
               doc.Description = 'Box Url:' + boxUrl + ' with the name as ' + fileName;
               updateDoc.add(doc);
               updatedDocsId.add(doc.Id);
           }else{
               /* If there's no boxUrl then prepare a list of missing documents for further notifications */
                nonUpdatedDocsId.add(doc.Id);
           }
       }
   }
}