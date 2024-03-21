public class WorkEmailKeyCode{

@invocablemethod()
    Public static void GenerateWorkEmailKeyCode(List<ID> appID){
     if(appID!=null && appID.size()>0)
            GenerateWorkEmailKey(appID[0]);
    }
    
    public Static void GenerateWorkEmailKey(Id WEappID){
    
    List<genesis__Employment_Information__c > WorkEmailApp = [Select id, WorkEmailKeyCode__c from genesis__Employment_Information__c WHERE  id =: WEappID];   
    
    if(WorkEmailApp!= null && WorkEmailApp.size() > 0){                                          
            for(genesis__Employment_Information__c app : WorkEmailApp){ 
    
Blob blobKey = crypto.generateAesKey(128);
String key1 = EncodingUtil.convertToHex(blobKey);
String keycd1 = key1.substring(0,20);
Blob blobKey1 = crypto.generateAesKey(128);
String key2 = EncodingUtil.convertToHex(blobKey1);
String keycd2 = key2.substring(0,20);
string keycode = keycd1+keycd2;
System.debug('****key1******** '+key1);
System.debug('****key2******** '+key2);
System.debug('****keycd1****** '+keycd1);
System.debug('****keycd2****** '+keycd2);
System.debug('****keycode***** '+keycode);

app.WorkEmailKeyCode__c = keycode;
}
}
update WorkEmailApp;
}
}