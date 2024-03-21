public class WF_ReduceBankStatement {
    
    @InvocableMethod
    public static void reduceBankStatement(List<Id> appIds) { 
        try{
             List<genesis__Application_Document_Category__c> lstUpdateCat = new List<genesis__Application_Document_Category__c>();
             List<genesis__Application_Document_Category__c> BankdocCategory = [SELECT ID, genesis__Required__c FROM genesis__Application_Document_Category__c where genesis__Application__c=:appIds[0] and genesis__Required__c =true and Name like '%Bank Statement%'];
             System.debug('docCategory SIZE ::'+BankdocCategory.size());
             if(!BankdocCategory.isEmpty() && BankdocCategory.size()>1){
                 Integer i = 1;  //pallavi
                 for(genesis__Application_Document_Category__c appDocCat : BankdocCategory){
                     if(i==1)  //pallavi
                         appDocCat.genesis__Required__c = true;  //pallavi
                     else                    //pallavi
                         appDocCat.genesis__Required__c = false;
                     lstUpdateCat.add(appDocCat);           
                     i++;  //pallavi
                        }
             }
             updateDocReduction(lstUpdateCat);
            
        }catch(Exception ex){
            System.debug('Exception:Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString());
        } 
    }
    public static void updateDocReduction(List<genesis__Application_Document_Category__c> lstUpdateCat){        
        if(!lstUpdateCat.isEmpty()){            
            System.debug('lstUpdateCat.....'+ lstUpdateCat);  
            update lstUpdateCat;
        }        
    }

}