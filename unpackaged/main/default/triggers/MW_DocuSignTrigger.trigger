trigger MW_DocuSignTrigger on dsfs__DocuSign_Status__c (after insert, after update,before insert,before update) 
{ 
   /*
    * Set the ApplicationId on the DocuSign_Status Record Insert.
    *
    */
   
   if(trigger.isBefore && (trigger.isUpdate || trigger.isInsert)){
      for(dsfs__DocuSign_Status__c status: Trigger.new){
          Id ApplicationId = MW_DocuSignTriggerHandler.getApplicationId(status.dsfs__Subject__c);
          if(status.Application__c == null && ApplicationId!=null){
              status.Application__c = ApplicationId;
          }
       }
   }
   
   if(trigger.isAfter && trigger.isUpdate)
   {
       List<dsfs__DocuSign_Status__c> listDocs = new List<dsfs__DocuSign_Status__c>();
         
       for(dsfs__DocuSign_Status__c status: Trigger.new){
           if(status.dsfs__Envelope_Status__c == 'Completed'){
              listDocs.add(status);
          }
       }
       
       /**
        * Method will post the Signed document details to FE.
        * Update Anniversary_Date__c, Loan_Doc_Signed_On__c Fields. 
        */
       if(listDocs.size()>0) MW_DocuSignTriggerHandler.createDocumentCategory(listDocs);
   }
}