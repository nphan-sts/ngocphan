/* ****************Modification History******************
 * Created By        Date          JIRA number
 *1. Pallavi        2020/01/29     LOS-242(Generate CL Loan Payoff Quote PDF Document)
 *      
 ******************Modification History******************/
global class GeneratePayoffQuoteCntrl {
    
    webService static void GeneratePayoffQuoteCntrl(String quoteId) {
        System.debug('GeneratePayoffQuoteCntrl');
        System.debug('----quoteId----' + quoteId);
        GeneratePayoffQuoteCntrl payoffQuote = new GeneratePayoffQuoteCntrl();
        payoffQuote.generatePayoffQuote(quoteId);
    }
    public void generatePayoffQuote(String quoteId){
        
        loan__Payoff_Quote__c payoff = [Select id,name from  loan__Payoff_Quote__c where id =: quoteId];
        
        PageReference pdfDocument = null;
        Attachment attach = new Attachment();
        pdfDocument = Page.GeneratePayoffQuote;
        pdfDocument.getParameters().put('id',quoteId);
        string curTime = String.valueOf(System.NOW());
        Blob body;
        if(!test.isRunningTest())
            body = pdfDocument.getContent();
        else
            body=blob.valueOf('Test String');
        attach.Body = body;
        attach.Name = 'Payoff Quote'+ ' '+curTime+'.pdf';
        attach.Description = 'test';
        attach.IsPrivate = false;
        attach.ContentType = 'application/pdf';
        attach.ParentId = quoteId; 
        System.debug('Attachment:...' + attach);
        insert attach;
    }
}