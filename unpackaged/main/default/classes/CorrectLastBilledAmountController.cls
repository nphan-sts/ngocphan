/*
 * author: Anusha
 * This controller is to correct last billed amount on loans before holiday season commences
 * This change is for LSP-284
 *
 *****************Modification History*****************************************************************
 * 
 ******************Modification History*****************************************************************/

public class CorrectLastBilledAmountController {
    public boolean isButtonDisabled{get;set;}
    public date fromDate{get;set;}
    public date toDate{get;set;}
    public date systemDate{get;set;}
    
    public CorrectLastBilledAmountController(){
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        systemDate = util.getCurrentSystemDate();
    }
    
    public void performAmountCorrection(){//2021-08-27, 2021-08-30
        try{
           	CorrectLastBilledAmountBatch batch = new CorrectLastBilledAmountBatch(fromDate,toDate);
        	Database.executeBatch(batch,200);
           	ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO,'Loans are queued up for processing. You will be notified with an email.');
           	ApexPages.addMessage(errorMessage); 
        }catch(Exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
            ApexPages.addMessage(errorMessage);
        }
        isButtonDisabled = true;       
    }
    public PageReference reset(){
        PageReference newpage = new PageReference(System.currentPageReference().getURL());
    	newpage.setRedirect(true);
    	return newpage;
    }
}