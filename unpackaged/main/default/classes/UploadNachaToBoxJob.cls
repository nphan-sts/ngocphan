global with sharing class UploadNachaToBoxJob implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful,Schedulable {
   
   String query;
   list<loan__Automated_Payment_Configuration__c> apcs = new List<loan__Automated_Payment_Configuration__c>();
   global List<Document> updateDoc = new List<Document>();
   Map<String,String> folderBoxMap = new Map<String,String>();
   List<String> folderName = new List<String>();
   global UploadNachaToBoxJob() {
       
       apcs = [Select id,name,loan__Folder_Name__c,Box_Folder_ID__c  from loan__Automated_Payment_Configuration__c where loan__Folder_Name__c!=null and Box_Folder_ID__c!=null];
       for(loan__Automated_Payment_Configuration__c apc : apcs) {
           folderName.add(apc.loan__Folder_Name__c);
           //folderBoxMap.put(apc.loan__Folder_Name__c,apc.Box_Folder_ID__c);
           folderBoxMap.put(apc.loan__Folder_Name__c,apc.Box_Folder_ID__c);
       }
       
       query = 'select id,name,Description,FolderId,Folder.Name,Body from Document where Folder.Name in:folderName and Description=null';
   }
   
   global Database.QueryLocator start(Database.BatchableContext BC) {
       System.debug(query);
        return Database.getQueryLocator(query);
   }

   global void execute(SchedulableContext sc) {
       UploadNachaToBoxJob j =new UploadNachaToBoxJob();
       Database.executebatch(j,1);
   }
   global void execute(Database.BatchableContext BC, List<Document> scope) {
       /*List<String> folderName = new List<String>();
       Map<String,String> folderBoxMap = new Map<String,String>();
       
       for(loan__Automated_Payment_Configuration__c apc:apcs) {
           folderName.add(apc.loan__Folder_Name__c);
           folderBoxMap.put(apc.loan__Folder_Name__c,apc.Box_Folder_ID__c);
       }*/
       Map<Id,String> folderIdBoxMap = new Map<Id,String>();
       Map<Id,Folder> folderMap = new Map<Id,Folder>([Select id,name from Folder where name in:folderName]);
       for(Id ids : foldermap.keySet()) {
           if(folderBoxMap.containsKey(foldermap.get(ids).name) && folderBoxMap.get(foldermap.get(ids).name) !=null) {
               folderIdBoxMap.put(ids,folderBoxMap.get(foldermap.get(ids).name));
           }
       }
       //List<Document> docs = [select id,name,Description,FolderId,Body from Document where folderId in:folderMap.keySet() and Description=null];
       
       //List<Document> updateDoc = new List<Document>();
       for(Document d:scope) {
           //System.debug('Document details'+d.name+' folder Id'+folderIdBoxMap.get(d.folderId));
           String g = d.name.replaceAll(':','');
           g = g.replaceAll('-','');
           //g = g.replaceAll('_','');
           g = g+'.txt';
           System.debug(g);
           String boxUrl = MW_BoxUtil1.uploadFileToBox(d.Body,g,/*folderBoxMap.get(d.Folder.Name)*/folderIdBoxMap.get(d.folderId),null); 
           if(boxUrl!=null) {
               System.debug('boxUrl'+boxUrl);
               d.Description = 'Box Url:'+boxUrl+' with the name as '+g;
               updateDoc.add(d);
           } 
       }
       
      // Added by Snehal while reviewing --> 12/6 --> Please call this class function here to update the refresh token in case expired while updates
      MW_BoxUtil1.insertAccessToken();
 
       
   }


   global void finish(Database.BatchableContext BC) {
        
       if(updateDoc.size()>0) {
           update updateDoc;
       }         
   }  
}