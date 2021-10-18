/*****************************************************************************
    
    *  This trigger will fire when the Dag job and Nacha job gets completed and a new job logging record is created.
    *  This trigger will invoke DagLoggingTriggerHandler class.
    *  /* ****************Modification History*****************************************************************
    
    * Created by      Date            JIRA number
    *  Mohan Kiran 	 10/08/2021	   LSP-306- Consolidated DAG
    
    ******************Modification History*****************************************************************
    *****************************************************************************/
    
    
    trigger DagLoggingTrigger on clcommon__DAG_Logging__c (after insert) {
        if(!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c) { 
            if(trigger.new.size() == 1){ 
                
                DagLoggingTriggerHandler handler = new DagLoggingTriggerHandler(trigger.new);
                if (trigger.isAfter)
                {
                    if(trigger.isInsert){
                        handler.afterInsert();
                    }  
                    
                }
            }
        }
    }