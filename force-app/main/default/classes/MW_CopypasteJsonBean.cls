global class MW_CopypasteJsonBean {
    
    global List<Data> data;

    global class Data {
        global String track_text_refocuses;
        global String track_other_refocuses;
        global String track_paste;
        global String applicationId;
    }
    
    global  static String parse(String json, String accId, String appId) {
        MW_CopypasteJsonBean cpData = (MW_CopypasteJsonBean) System.JSON.deserialize(json, MW_CopypasteJsonBean.class);
        String result = null;
        try{
           result = mappingOfFields(cpData, accId, appId);
        }catch(Exception e){
            throw new ints.IntegrationException(' API call failure Message: '+e.getMessage());
        }
        return result;
    }
    
    global static String mappingOfFields(MW_CopypasteJsonBean cpData, String accId, String appId)
    {
        List<KBA_Details__c>  kbaInfo = new List<KBA_Details__c>([select Id, KBA_Attempts__c, Account__c, Application__c from KBA_Details__c where Application__c=:appId limit 1]);
        
        KBA_Details__c obj;
        if(kbaInfo.size()==0) obj = new KBA_Details__c(); else obj = kbaInfo[0];
        obj.Account__c=accId;
        obj.Application__c=appId;
        if(cpData.Data!=null) obj.Paste_Count__c= Integer.Valueof(cpData.Data[0].track_paste);
        
        upsert obj;
        return 'Success';
    }
    
}