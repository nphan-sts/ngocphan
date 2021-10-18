/*  This handler will fire when the Dag job and Nacha job gets completed and a new job logging record is created.
    *  This trigger will invoke dagJobsErrorCheckBatch batch class.
    *  /* ****************Modification History*****************************************************************
    
    * Created by      Date            JIRA number
    *  Mohan Kiran 	 10/08/2021	   LSP-306- Consolidated DAG
    
    ******************Modification History*****************************************************************
    *****************************************************************************/
public class DagLoggingTriggerHandler {
        
        final List<clcommon__DAG_Logging__c> dagLoggingRecord;

        //Constructor
        public DagLoggingTriggerHandler(List<clcommon__DAG_Logging__c> newDagRecord) {
            this.dagLoggingRecord = newDagRecord;
        }
        
        public void afterInsert() {
  
            if(dagLoggingRecord[0].clcommon__Status__c == 'Success'){ // trigger works only when the job status is success
                //Send the job name details to the batch class
                if(dagLoggingRecord[0].DAG_Name__c	 == 'Consolidated DAG'){
                    Database.executeBatch(new DagJobsErrorCheckBatch('ConsolidatedDag'),1);
                }
                else if (dagLoggingRecord[0].DAG_Name__c == 'Payment - Filegen - Upload to Box'){
                    system.debug('$$##$$##$$## ESLE IF IS CALLED');
                        Database.executeBatch(new DagJobsErrorCheckBatch('NachaJob'),1);
                    }
                
                
            }
        }
        
    }