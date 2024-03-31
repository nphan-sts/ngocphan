public with sharing class EnvironmentHelper {

   public static String getSandbox(){
       String hostName = URL.getOrgDomainURL().toExternalForm();
       system.debug('hostName:' + hostName);
       return hostName;
   }
    
   public static String getPageDetailUrl(Id recordId) {
       String recordURL = getSandbox() + '/' + recordId;
       System.debug('URL of a particular account: ' + recordURL);    
       return recordURL;
   }  
}