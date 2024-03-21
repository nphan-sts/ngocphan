/* ****************Modification History******************
 * Created By        Date          JIRA number
 *1. Pallavi        2020/01/29     LOS-243(Create CL Loan Current Loan Statement)
 *      
 ******************Modification History******************/
global class GenerateLoanStatementCntrl {
    webService static void GenerateLoanStatementCntrl(String loanId) {
        System.debug('GenerateLoanStatementCntrl');
        System.debug('----loanId----' + loanId);
        GenerateLoanStatementCntrl loanStatement = new GenerateLoanStatementCntrl();
        loanStatement.generateStatement(loanId);
    }
    public void generateStatement(String loanId){
        loan__loan_account__c contract = [Select id,name from loan__loan_account__c where id =: loanId];
        PageReference pdfDocument = null;
        Attachment attach = new Attachment();
        pdfDocument = Page.GenerateLoanStatement;
        pdfDocument.getParameters().put('id',loanId);
        Blob body;
        if(!test.isRunningTest())
            body = pdfDocument.getContent();
        else
            body=blob.valueOf('Test String');
        attach.Body = body;
        string curTime = String.valueOf(System.NOW());
        attach.Name = 'Loan Statement'+ ' '+curTime+'.pdf';
        attach.Description = 'test';
        attach.IsPrivate = false;
        attach.ContentType = 'application/pdf';
        attach.ParentId = loanId; 
        System.debug('Attachment:...' + attach);
        insert attach;
    }
}