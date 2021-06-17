public class MW_DocuSignTriggerHandler {

    public static void createDocumentCategory(List<dsfs__DocuSign_Status__c> listDocs)
    {
        try{

            Map<ID,Date> SignedCompleteMap = new Map<ID,Date>();
            Map<String,String> EnvelopeMap = new Map<String,String>();

            for(dsfs__DocuSign_Status__c dsStatus :listDocs){
                SignedCompleteMap.put(dsStatus.Application__c,dsStatus.dsfs__Completed_Date_Time__c.date());
            }

            if(SignedCompleteMap.size()>0)
                updatSignedDates(SignedCompleteMap);

            for(dsfs__DocuSign_Status__c dsStatus :listDocs){
                MW_DocuSigneSignedDocuments.postDocumentDetails(dsStatus.dsfs__DocuSign_Envelope_ID__c, dsStatus.Application__c, dsStatus.Lead_Id__c);
            }

        }catch (Exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'Docusign Status' ;
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
            throw ex;
        }
    }

    /*
        Method update the Anniversary_Date DocuSign_Sign_Date on Application.
     */
    public static void updatSignedDates(Map<ID,Date> SignedCompleteMap){


        List<genesis__Applications__c> lstApp  = new List<genesis__Applications__c>();
        for(genesis__Applications__c app :[SELECT Id, Anniversary_Date__c, DocuSign_Sign_Date__c, Loan_Doc_Signed_On__c
        FROM genesis__Applications__c where Id=:SignedCompleteMap.keySet()]){
            if(SignedCompleteMap.get(app.Id)!=null){
                Date signedDate  = SignedCompleteMap.get(app.Id);
                CustomTriggerOnApplicationHandler ctdh = new CustomTriggerOnApplicationHandler();
                Date orignationDt      = ctdh.addWorkingDaysTodate(signedDate,3);
                system.debug('orignationDt=' + orignationDt);
                Date anniversaryDate      = orignationDt.addMonths(1);
                system.debug('anniversaryDate=' + anniversaryDate);
                //Set anniversary date March 1st instead of Feb 28.
                if(orignationDt.month() == 1 && (orignationDt.day() == 29 || orignationDt.day() == 30 || orignationDt.day() == 31))
                {
                    anniversaryDate = anniversaryDate.addDays(1);
                    system.debug('anniversaryDate inside if=' + anniversaryDate);
                }
                app.Anniversary_Date__c   = anniversaryDate.addDays(calcdate(anniversaryDate));
                system.debug('app.Anniversary_Date__c=' + app.Anniversary_Date__c);
                app.DocuSign_Sign_Date__c = signedDate;
                app.Loan_Doc_Signed_On__c = signedDate;
                if(app.Id!='a6h4F0000004ZzSQAU' || app.Id!='a6h4F0000004ZzXQAU'|| app.Id!='a6h4F0000004ZzcQAE' || app.Id!='a6h4F0000004ZzhQAE'){
                    app.genesis__Status__c    =  'docusign_loan_docs_complete';
                }
                lstApp.add(app);
            }
        }
        if(lstApp.size()>0) update lstApp;
    }

    public static Id getApplicationId(string attName){
        if(attName!=null & attName!='') {
            string strAppId = attName.substringBefore('.');
            Id appId        = strAppId.substring(strAppId.length()-18, strAppId.length());
            system.debug('... Application Id >> ' + appId);
            return appId;
        }
        return null;
    }

    public static Integer calcdate(Date SignDate){
        Integer numberofDays = 0;
        while(SignDate.day() == 29 || SignDate.day() == 30 || SignDate.day() == 31) {
            numberofDays++;
            SignDate = SignDate.adddays(1);
        }
        return numberofDays;
    }
}