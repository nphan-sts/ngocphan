global with sharing class UploadNachaToBoxJob implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful,Schedulable {
   
   String query;
   String failedFiles;
   global List<Document> updateDoc = new List<Document>();
   global List<Document> nonUpdatedDoc = new List<Document>();
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
       Integer retryCount = 0; 
        while(nonUpdatedDoc.size() > 0 && retryCount < 5) {
            uploadFile(nonUpdatedDoc,'finish',folderIdBoxMap);
            retryCount++;
        }
        if(updateDoc.size() > 0){
            update updateDoc;
        }
        if(nonUpdatedDoc.size() > 0){            
            // Send alerts to DataDog
            MW_LogUtility.errorMessage('UploadNachaToBoxJob', 'finish', '5 Retries Exceeded For:' + failedFiles);
        }
   }  
   global void uploadFile(List<Document> documentList,String callingMethodName,Map<Id,String> folderIdBoxMap){       
       if(callingMethodName == 'finish'){
            nonUpdatedDoc = new List<Document>();
            failedFiles = 'FAILED FILES';
       }
       for(Document doc : documentList) {
           String fileName = doc.name.replaceAll(':','');
           fileName = fileName.replaceAll('-','');
           fileName = fileName + '.txt';
           String boxUrl = MW_BoxUtil1.uploadFileToBox(doc.Body,fileName,folderIdBoxMap.get(doc.folderId),null); 
           if(boxUrl != null) {
               doc.Description = 'Box Url:' + boxUrl + ' with the name as ' + fileName;
               updateDoc.add(doc);
           }else{
                nonUpdatedDoc.add(doc);
                failedFiles = failedFiles + '>>' + fileName;
           } 
       }       
   }
}