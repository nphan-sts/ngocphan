public with Sharing class WSKBAUpdateInfo{
    
    public static void updateKBAInfo(ID applicationID, String jSONRequestBody){
        
        WSKBARequestParcer reqDataParcer = (WSKBARequestParcer)JSON.deserialize(jSONRequestBody, WSKBARequestParcer.class);
          
        system.debug('--jSONRequestBody--' +jSONRequestBody);
        system.debug('--reqDataParcer --' +reqDataParcer );
        Integer IDScore=0, ConsistencySNAPD=0, PublicRecords=0;
        try{
            if(null != reqDataParcer)       
            { 
                if(null != reqDataParcer.IDScore)
                    IDScore = reqDataParcer.IDScore;
                if(null != reqDataParcer.ConsistencySNAPD)
                    ConsistencySNAPD = reqDataParcer.ConsistencySNAPD;
                if(null != reqDataParcer.PublicRecords)
                    PublicRecords = reqDataParcer.PublicRecords; 
                          
                // Change made order by createddate desc
                List<KBA_Details__c> fraudDetails = [SELECT Id_Analytics_Score__c, Consistency_Snapd_score__c, Public_Records__c FROM KBA_Details__c where application__c=:applicationId order by createddate desc Limit 1];
                
                if(!fraudDetails.isEmpty()){
                    fraudDetails[0].Id_Analytics_Score__c = IDScore;
                    fraudDetails[0].Consistency_Snapd_score__c = ConsistencySNAPD;
                    fraudDetails[0].Public_Records__c = PublicRecords;
                    update fraudDetails;
                }    
                else{
                    KBA_Details__c kbaDetails = new KBA_Details__c();
                    kbaDetails.Id_Analytics_Score__c = IDScore;
                    kbaDetails.Consistency_Snapd_score__c = ConsistencySNAPD;
                    kbaDetails.Public_Records__c = PublicRecords;
                    kbaDetails.application__c=applicationID;
                    insert kbaDetails;
                }
                   
            }     
        } catch(exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in wsKBAUpdateInfo:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
            insert logs;
            System.debug('Exception : ' + ex);
            throw ex;
        }
    }
    public class WSKBARequestParcer {
        public Integer IDScore;
        public Integer ConsistencySNAPD;
        public Integer PublicRecords;
    }
}