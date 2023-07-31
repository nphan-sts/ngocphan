public with sharing class OAuthController {
    Private String authID = Null;
    Private String authCode = Null;
    
    public OAuthController(){
        authID = ApexPages.currentPage().getParameters().get('state');
        authCode = ApexPages.currentPage().getParameters().get('code');
        System.debug('...auth Details...'+ authID+'...'+authCode);
        insertTokenId();
    }
    Public Void insertTokenId(){
        String applicationID = Null, oAuthSettingsID =Null;
        if(authID != Null && authID.contains('_')){
            String[] authStr = authID.split('_');
            oAuthSettingsID = authStr[0];
            applicationID = authStr[1];
            
            System.debug('...applicationID ...'+applicationID +'... oAuthSettingsID...'+oAuthSettingsID);
        }
        BoxAPI_Integration.getBoxToken(applicationID, oAuthSettingsID, authCode);
        //SendEnvDocuSignAPI.sendDocuSignEnvelope(applicationID);  
    }
}