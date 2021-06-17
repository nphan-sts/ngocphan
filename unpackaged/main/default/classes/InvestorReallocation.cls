global Class InvestorReallocation{

    public static void ResetDoc(id appId){
    
        List<Id> app = new List<Id>();
        app.add(appId);
        InvestorReallocation.ResetDocument(app);
    }
    @InvocableMethod
    public static void ResetDocument(List<id> idVal){
        
        list<genesis__Application_Document_Category__c> docCategory = [SELECT id, Name,
                                                                        genesis__Active__c,
                                                                        genesis__Application__c,
                                                                        Box_URl__c 
                                                                        FROM genesis__Application_Document_Category__c
                                                                        WHERE genesis__Application__c in :idVal
                                                                        AND genesis__Active__c = TRUE 
                                                                        AND (Name like 'TIL%'
                                                                        OR Name like 'Cred%')];
                                                                        
        For(genesis__Application_Document_Category__c doc : docCategory){
            doc.genesis__Active__c = FALSE;
            doc.Box_URl__c='';
        }             
        update docCategory;
  //reset Anniversary date to null after reallocation
    list<genesis__Applications__c> ResetAnniv = [SELECT id, Anniversary_Date__c from genesis__Applications__c where id=:idVal AND Anniversary_Date__c != null];
    if(ResetAnniv != null && !ResetAnniv.isEmpty()){
    ResetAnniv[0].Anniversary_Date__c =null;   }
    system.debug('... AppId>> ' + idVal);
    //system.debug('... Anniversary >> ' + ResetAnniv[0].Anniversary_Date__c);
    update ResetAnniv;    
  /*  //to clear out loan documents after reallocation
        //find Esign doc category ID
        String ESignID;
        list<genesis__Application_Document_Category__c> EsignCategory = [SELECT id, genesis__Document_Category__c 
                                                                        FROM genesis__Application_Document_Category__c
                                                                        WHERE genesis__Application__c in :idVal
                                                                        AND genesis__Active__c = TRUE 
                                                                        AND Name like 'Esign%'];
        ESignID = ESignCategory[0].genesis__Document_Category__c;
        //clear out all doc categories with parent category = Esgn Documents ID
        list<genesis__Application_Document_Category__c> docEsignCategory = [SELECT id, Name,
                                                                        genesis__Active__c,
                                                                        genesis__Application__c,
                                                                        Box_URl__c 
                                                                        FROM genesis__Application_Document_Category__c
                                                                        WHERE genesis__Application__c in :idVal
                                                                        AND genesis__Active__c = TRUE 
                                                                        AND genesis__Parent_Application_Document_Category__c= :ESignID];
                                                                        
        For(genesis__Application_Document_Category__c docE : docEsignCategory){
            docE.genesis__Active__c = FALSE;
            docE.Box_URl__c='';
        }             
        update docEsignCategory; */                                            
    }
}