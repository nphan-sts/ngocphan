/**
* Description: Attachment related logic.
*
*   Modification Log :
---------------------------------------------------------------------------
    Developer               Date                Description
---------------------------------------------------------------------------
    Mohseen Begum           07/04/2017          Created
******************************************************************************************/
trigger AttachmentTrigger on Attachment (after insert) {
    System.debug('AttachmentTrg...');
    if (!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c) {    
        if('Active'.equalsIgnoreCase(system.Label.AttachmentTrg)){
            AttachmentTriggerHandler attachmentTrgHandler = new AttachmentTriggerHandler(Trigger.isExecuting);
            if(trigger.isInsert){
                system.debug('.... Trigger:  AttachmentTrg....');
                attachmentTrgHandler.AttachmentDocumentCategory(Trigger.new);
                //Adding this code to Attach a Document under Deal Room in case FE is using standard salesforce id to upload documents---Jandeep
                //Need to add this code in handler waiting for Mohseen don't want to edit her code.
                // I am assuming that FE will pass ADC id in Description of Attachment.
                Map<String,String> adcToDocMap = new Map<String,String>();
                List<genesis__AppDocCatAttachmentJunction__c> adcajList = new List<genesis__AppDocCatAttachmentJunction__c>();
                for(Attachment ath : trigger.new){
                    adcToDocMap.put(ath.description,ath.id);                    
                }
                List<genesis__Application_Document_Category__c> adcList = [Select id,name 
                                                                            from genesis__Application_Document_Category__c
                                                                            where id in : adcToDocMap.keySet()];
                                                                            
                if(adcList != null && adcList.size() > 0){
                    for(genesis__Application_Document_Category__c adc : adcList ){
                        genesis__AppDocCatAttachmentJunction__c adcaj = new genesis__AppDocCatAttachmentJunction__c();
                        adcaj.genesis__Application_Document_Category__c = adc.id;
                        adcaj.genesis__AttachmentId__c = adcToDocMap.get(adc.id);  
                        adcajList.add(adcaj);
                    }
                    if(adcajList != null && adcajList.size() > 0){
                        insert adcajList;
                    }
                }
            }
        }
        
    }   
    
}