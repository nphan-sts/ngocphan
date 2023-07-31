/* ****************Modification History*****************************************************************
 * Modified by      Date        JIRA number
 *    Anusha       2020/07/07     CRM-543 (Schema changes)Display link to 3rd party data portal
 *    Anusha       2020/07/24     CRM-748 Update TLO URL when PII changed (rematch)
 *    Neha         2020/11/12     CRM-963 Enable Dynamic TLO URL to reflect current UserId.
 ******************Modification History*****************************************************************/
Public class TLOLinkConfig{

    public void updateLinkonApps(List<genesis__applications__c> app){
        
        System.debug(logginglevel.error, 'In TLOLink.cls');
        
        Id appID = app[0].Id;
        
        // commented part of CRM-963
        //TLO_Link__c field update not required on IDV record creation. Created TLO_Link_formula__c.
        /*String TLOurl = null; 
        TLO_URL_Config__c tlo = [select id,name,TLO_URL__c, TLOURLappname__c from TLO_URL_Config__c];*/
        List<Identity_Verification__c> IdentityRecord = [select id,name, TLO_Link__c                                                          
                                                        from Identity_Verification__c 
                                                        where Application__c =:appID 
                                                        order by createddate desc limit 1]; 
                                                        
        //new changes - start
        if(IdentityRecord == null || IdentityRecord.size() == 0){
            //CRM-963
            /*TLOurl ='https://' + tlo.TLO_URL__c +'/'+ tlo.TLOURLappname__c + '/tlo?lead_id=' + 
                                        app[0].LEAD_ID_ExtKey__c +'&member_id='+ 
                                        app[0].Member_ID__c +'&user_id='+ UserInfo.getUserId() ;
            
            System.debug(logginglevel.error,'TLOurl created :'+TLOurl);*/
            
            Identity_Verification__c IDVnewRecord = new Identity_Verification__c();
            IDVnewRecord.Application__c = appID;
            //IDVnewRecord.TLO_Link__c = TLOurl; //CRM-963
            
            insert IDVnewRecord;                               
        //new changes - end
        
        /*}else if (IdentityRecord != null && IdentityRecord.size() != 0 && IdentityRecord[0].TLO_Link__c == null){
        
            TLOurl= 'https://' + tlo.TLO_URL__c +'/'+ tlo.TLOURLappname__c + '/tlo?lead_id=' + app[0].LEAD_ID_ExtKey__c +'&member_id='+ app[0].Member_ID__c +'&user_id='+ UserInfo.getUserId() ;
    
            System.debug(logginglevel.error,'TLOurl :'+TLOurl);
            
            IdentityRecord[0].TLO_Link__c = TLOurl;
            
            update IdentityRecord;*/ //CRM-963
        
        }
    
    }
  //CRM-748 start
    public void updateTLOLink(List<Id> appIdList){
        
        System.debug('Inside updateTLOLink..'+ appIdList);
        List<Identity_Verification__c> updateTLOLinkOnIDV = new List<Identity_Verification__c>();
            List<Identity_Verification__c> identityRecord = [select id, name, check_match__c                                                          
                                                            from Identity_Verification__c 
                                                            where Application__c IN:appIdList];
            
            if(identityRecord != null && identityRecord.size() > 0){
                System.debug('identityRecord list is not null..');
                for(Identity_Verification__c idvRecord:identityRecord){
                
                    String tloLinkToUpdate = null;
                    if(idvRecord.check_match__c == null){
                       //CRM-963 
                       //System.debug('idvRecord.TLO_Link__c: '+idvRecord.TLO_Link__c);                       
                       // if((idvRecord.TLO_Link__c).indexOf('&check_match=true') == -1){
                            //tloLinkToUpdate = idvRecord.TLO_Link__c + '&check_match=true';
                            
                        tloLinkToUpdate = '&check_match=true';
                        idvRecord.check_match__c = tloLinkToUpdate;
                        updateTLOLinkOnIDV.add(idvRecord); 
                        //CRM-963
                        /*}else{
                            System.debug('TLO_Link__c is already updated with &check_match=true..');
                        }*/    
                    }else{
                        //System.debug('TLO Link does not exist for update'); // CRM-963
                        System.debug('TLO_Link__c is already updated with &check_match=true..');
                    }
                }
            }

        if(updateTLOLinkOnIDV.size()>0){
             System.debug('Number of identity verification records updated: '+updateTLOLinkOnIDV.size());
            update updateTLOLinkOnIDV;
        }
   }
  //CRM-748 end
}