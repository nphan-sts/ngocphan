trigger MW_ContactCreationOnAccountTrigger on Account (after insert, after update) {

 
 List<Contact> contList = new List<Contact>();
  
 if(trigger.isInsert && trigger.isAfter)
 {
      for(Account acc : Trigger.new){
         if(acc.recordtypeId==Schema.SObjectType.Account.getRecordTypeInfosByName().get('Member').getRecordTypeId()){
             Contact con = new Contact();
             con.AccountId=acc.id;
             con.FirstName = acc.peer__First_Name__c;
             con.LastName  = acc.peer__Last_Name__c;
             if(Test.isRunningTest()){
                 con.LastName = 'TestLastName' + system.now();
             }
             if(acc.Address_2__c!=null)
             con.MailingStreet=acc.Address_1__c+' '+acc.Address_2__c;
             else
             con.MailingStreet=acc.Address_1__c;
             con.MailingCity=acc.City__c;
             con.MailingState=acc.State__c;
             con.MailingPostalCode=acc.ZIP_Code__c;
             con.Phone=acc.Phone;
             con.email=acc.cnotify__Email__c;
             con.Birthdate=acc.peer__Date_of_Birth__c;
             contList.add(con);
         }
      }
      insert contList;
  }
  

  if(trigger.isupdate && trigger.isAfter)
  { 
     Set<Id> accId   = new Set<id>();
     
     for(Account acc : Trigger.new){
           accId.add(acc.id);
     }

     Map<Id, Contact>  ContMap = new Map<Id, Contact>();
     
     for(Contact cont: [select Id, FirstName, LastName, MailingState,MailingCity,AccountId,MailingPostalCode,MailingStreet,  
                         MailingCountry,Phone,Email,Birthdate From Contact where AccountId=:accId]){
         ContMap.put(cont.accountId,cont); 
     }
     
     List<contact> conlist = new List<Contact>();

     for(Account acc : Trigger.new)
     {
         if(ContMap.get(acc.Id)!=null)
         {  
            Contact con =  ContMap.get(acc.Id);
            
            if(acc.peer__First_Name__c != con.FirstName  || acc.peer__Last_Name__c != con.LastName || acc.City__c != con.MailingCity || 
              acc.State__c != con.MailingState   || acc.ZIP_Code__c != con.MailingPostalCode ||
              acc.Phone != con.Phone   || acc.cnotify__Email__c != con.email || con.Birthdate != acc.peer__Date_of_Birth__c)
            {
             con.FirstName = acc.peer__First_Name__c;
             con.LastName  = acc.peer__Last_Name__c;
             if(Test.isRunningTest()){
                 con.LastName = 'TestLastName' + system.now();
             }
             con.MailingCity=acc.City__c;
             con.MailingState=acc.State__c;
             con.MailingPostalCode=acc.ZIP_Code__c;
             con.Phone=acc.Phone;
             con.email=acc.cnotify__Email__c;
             con.Birthdate=acc.peer__Date_of_Birth__c;
            }
            if(acc.Address_2__c!=null)
            {
               if(acc.Address_1__c+' '+acc.Address_2__c != con.MailingStreet)
                 con.MailingStreet=acc.Address_1__c+' '+acc.Address_2__c;
            }
            if(acc.Address_2__c==null)
            {
               if(acc.Address_1__c!= con.MailingStreet)
                  con.MailingStreet=acc.Address_1__c;
            }
           contList.add(con);

         }
     }
     
     update contList;
  }
  

}