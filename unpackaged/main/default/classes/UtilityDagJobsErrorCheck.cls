/*----------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    #JIRA ID	Description 																			Authour				Date
    
    LSP-306		Utility class is to send error codes to slack whenever a(consolidated DAG) job fails	Mohan Kiran			06/15/2021
    
    -----------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    public class UtilityDagJobsErrorCheck {
        
        /*Constructor */
        
        public utilityDagJobsErrorCheck(){
            
        }
        
        /*Recieve the parameters from dagJobsErrorCheckBatch -  jobName and jobClass and document details*/
        
        public static void errorLog(string jobName, String jobClass, Object documentData){
            
            
            string jobNameToSend;
            string jobClassToSend;
            object documentDetails;
            
            /*Sending the error details to MW_LogUtility apex class
				error Details: Job name, job class and details about the document*/
            
           
            jobNameToSend = 'Job Name'+jobName;
            jobClassToSend = 'Job class'+jobClass;
            documentDetails = documentData;
            MW_LogUtility.dagError (jobNameToSend, jobClassToSend,documentDetails);
            
        }
    }