/* ****************Modification History******************
 * Created By        Date          JIRA number
 * 		
 * 		1. Neha          2021/01/10        LOP-4
 * Modified By        Date          JIRA number
 *      1. Pallavi       2021/01/25        LOP-4
 *      
 ******************Modification History******************/
public class YodleeDeactivateAccounts {
    
    public static String cobSession;
    public static String userToken;
    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
     
    public void deactivateAccount(String YodleeAccId, Id accountId) {
        
        System.debug('In deactivateAccount Method : Yodlee Account Id :'+YodleeAccId +'Account Id :'+accountId);        
        
        cobSession = YodleeTransactionAPICallOut.getCobSession();
        System.debug(logginglevel.error,'cobSession ::'+cobSession);
        UserToken = YodleeTransactionAPICallOut.UserToken(accountId);
        System.debug(logginglevel.error,'UserToken ::'+UserToken);               
        
        list<Yodlee_User_Account__c> yodleeAccDetails = new list<Yodlee_User_Account__c>();    
        ints__Yodlee_Cobrand_Credentials__c cobrand = ints__Yodlee_Cobrand_Credentials__c.getInstance();
        String url = cobrand.ints__Rest_URL__c+'accounts/'+YodleeAccId;
        System.debug(logginglevel.error,'URL yodleebankaccount :: '+url);
        String response;

        try {

            HttpRequest req = new HttpRequest();
            req.setMethod('DELETE');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', '{cobSession=' + cobSession + ',userSession=' + userToken + '}');
            
            System.debug(logginglevel.error,'URL ::' + url);
            req.setEndpoint(url);
            
            if(Test.isRunningTest()) {
                System.debug('Test: Fake Response');
            }
               
            Http http = new Http();
            HTTPResponse res = http.send(req);
            response = res.getBody();
            Integer responseCode = res.getStatusCode();	//pallavi
            system.debug(LoggingLevel.ERROR,'Response ::' +response);
            /*LOP-4 update*/
            if(responseCode == 200 || responseCode == 204){
                List<Yodlee_User_Account__c> deactivateYodleeAcc = [Select id,status__c from Yodlee_User_Account__c where YodleeBankAccountId__c =: YodleeAccId];
                for(Yodlee_User_Account__c updateYodlee : deactivateYodleeAcc)
                    updateYodlee.status__c = 'INACTIVE';
                if(deactivateYodleeAcc.size()>0)
                    update deactivateYodleeAcc;
            }
            else{
                MW_LogUtility.info('YodleeDeactivateAccounts', YodleeAccId, '', 'deactivateAccount',yodleeAccDetails , res);	//LOP-4 update need to check with HM
            }
            /*LOP-4 update*/
        }
        catch(Exception e){
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            MW_LogUtility.error('YodleeDeactivateAccounts', YodleeAccId, '', 'deactivateAccount', e);	//LOP-4 update
        }
           
        System.debug('Get Response--> ' + response);       
    
    }

}