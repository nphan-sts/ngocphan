global class verifyBankAccount {
     webservice static void Verify(String applicationID){
        system.debug('application id'+applicationID);
        //system.debug('yodleeID'+yodleeID);
        List<Yodlee_User_Account__c> yodleeUser = new List<Yodlee_User_Account__c>();
        List<genesis__Application_Document_Category__c> docCat = new list<genesis__Application_Document_Category__c>();
        List<genesis__Application_Document_Category__c> docCatToUpdate = new list<genesis__Application_Document_Category__c>();
        yodleeUser = [select id,name, verified__c, Yodlee_Account__c 
                      from Yodlee_User_Account__c 
                      where Yodlee_Application__c =: applicationID and verified__c=true ];
        if(yodleeUser.size()>0){
            docCat = [select id, name, Cleared_Reason__c, genesis__Status__c,   genesis__Application__c from genesis__Application_Document_Category__c 
                      where genesis__Application__c =: applicationID and name like 'Bank Statement %' and genesis__Required__c= true];
            for(genesis__Application_Document_Category__c doc: docCat){
                doc.genesis__Status__c = 'cleared';
                doc.Cleared_Reason__c = 'satisfied by yodlee bank account';
                docCatToUpdate.add(doc);
            }
            try{
                update docCatToUpdate;
            } 
            catch(System.Exception err){
                System.debug(err.getStackTraceString());
            }
                
        }             
         
                      
     }
        
}