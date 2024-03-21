/*CRM-867/LSP-14 chages by Neha*/
public class UpdatePreBillDaysController {
    
    public Blob csvFileBody{get;set;}
    public String csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public Map<String,String> loanlist{get;set;}
    public Integer loanSize{get;set;}
        
    public Integer preBillDays{get;set;}
    
    loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
    Date systemDate = util.getCurrentSystemDate();
        
      public UpdatePreBillDaysController(){
        csvFileLines = new String[]{};
        loanlist = new Map<String,String>();
                
        preBillDays = 0;     
        loanSize = 0;
        
      }
      
      public void importCSVFile(){
          
           try{
               csvAsString = csvFileBody.toString();
               System.debug(logginglevel.error,'Loan List : '+csvAsString);
               csvFileLines = csvAsString.split('\n');
               System.debug(logginglevel.error,'Loan List : '+csvFileLines);
               for(Integer i=1; i<csvFileLines.size(); i++){
                   string[] csvRecordData = csvFileLines[i].split(',');
                   loanlist.put(csvRecordData[0],csvRecordData[1]);//key=loan name and value = number of pre-billDays
                }
               loanSize = loanlist.size();
               
               updatePreBillDays();
               System.debug(logginglevel.error,'Loan List : '+loanlist);
              
            }
            catch (Exception e){
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data. Please make sure input csv file is correct');
                ApexPages.addMessage(errorMessage);
            }
      }
    
    public void updatePreBillDays(){
           
        try{
            System.debug(logginglevel.error,'IN Try : Loan List : '+loanlist);
            PreBillUpdateBatch batch = new PreBillUpdateBatch(loanlist);
            Database.executeBatch(batch, 1);
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO,'Loans are queued up for processing.');
            ApexPages.addMessage(errorMessage);
            
        }catch(Exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
            ApexPages.addMessage(errorMessage);
        }
                               
        //upload the document once processing is complete
        Document uploadDoc = new Document();
        uploadDoc.Body = csvFileBody;
        if(!Test.isRunningTest()){
          uploadDoc.FolderId = [select id from folder where name = 'Update PreBill Days'].Id;
            uploadDoc.Name = 'UpdatePre-BillDays'+systemDate.format();
        }
        uploadDoc.Description = 'File uploaded for Update Pre-BillDays action on '+systemDate.format()+'. Loans Processed : '+loanSize+'.';
        uploadDoc.IsPublic = true;
        uploadDoc.Type = 'csv';
        if(!Test.isRunningTest()){
            insert uploadDoc;
        }
    }
}