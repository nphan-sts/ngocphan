public class BorrowersEmailIDonDocumentObject {

 /*public static list<genesis__Application_Document_Category__c> getBorrowersEmailId(list<ID> Ids){
     List<String> BorrowerEmial = new List<String>();
     list<genesis__Application_Document_Category__c> doclist = [select id,
                                                                     Application_Email__c,
                                                                     Borrower_s_Email__c 
                                                                     FROM genesis__Application_Document_Category__c 
                                                                     WHERE id in:ids];
     for(genesis__Application_Document_Category__c doc: doclist){
         doc.Borrower_s_Email__c = doc.Application_Email__c;
     }  
     update doclist;
        return doclist;
    }*/
    @invocablemethod()
    public static void getBorrowersEmailId(list<ID> Ids){
         genesis__Application_Document_Category__c doclist = [select id, Borrower_s_Email__c,
                                                                         Application_Email__c
                                                                         FROM genesis__Application_Document_Category__c 
                                                                         WHERE id =:ids limit 1];
         if(doclist != Null && doclist.Borrower_s_Email__c == Null){                                                                  
             doclist.Borrower_s_Email__c = doclist.Application_Email__c;   
             update doclist;
             System.debug('Borrower Email...' +   doclist.Borrower_s_Email__c);    
         } 
     }
}