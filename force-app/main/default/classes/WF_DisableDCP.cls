/*
 * Invocalbe Method from Precess builder 'ForFailedCards_DisableDCP'
*/
public class WF_DisableDCP {
    @InvocableMethod
    public static void disableDCP(List<Id> appIds) { 
        try{
            DisableDCP.disableDCP(appIds[0]); 
        }catch(Exception ex){
            System.debug('Exception:Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString());
        } 
    } 
}