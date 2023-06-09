/*
 * author: Vitor
 * This controller is to parse CSV file thats uploaded for note creation
 *
 *****************Modification History*****************************************************************
 * Modified by      Date            JIRA number
 * 	  Vitor		  2023/06/05	    LPC-798 Automate bulk note creation for ACU notes daily
 ******************Modification History*****************************************************************/

public with sharing class LoanNoteImportController 
{
    public Blob csvFileBody{get;set;}
    public String csvAsString{get;set;}
    public String successMessage{get;set;}
    public String[] csvFileLines{get;set;}
    public Map<String,Note> noteList{get;set;}
    
    public LoanNoteImportController()
    {
      csvFileLines = new String[]{};
      noteList = new Map<String,Note>();
    }
      
    /*
    * Method to parse input csv file
    * 
    */ 
    public void importCSVFile()
    {
        Integer line = 1;
        successMessage = '';
        ApexPages.getMessages().clear();
        
        try
        {
            csvAsString = csvFileBody.toString();
            csvFileLines = csvAsString.split('\n');

            if(csvFileLines.size() <= 1)
                throw new FailureException();

            for(Integer i=1; i<csvFileLines.size(); i++)
            {
                line = i + 1;
                string[] csvRecordData = csvFileLines[i].split(',');

                String loanId = 'P' + csvRecordData[0].substring(1).toLowerCase();
                String title = csvRecordData[1];
                String body = csvRecordData[2];

                if(String.isBlank(title))
                    title = body;

                if(title.length() > 79)
                    title = title.substring(0, 79);

                Note note = new Note();
                note.Body = body;
                note.Title = title;
                note.IsPrivate = false;
                noteList.put(loanId,note);
            }
            
            line = 0;

            for(loan__Loan_Account__c loan : [SELECT Id, Payoff_Loan_ID__c FROM loan__Loan_Account__c
                                            WHERE Payoff_Loan_ID__c IN : noteList.keyset()])
            {
                Note note = noteList.get(loan.Payoff_Loan_ID__c);

                note.ParentId = loan.Id;

                noteList.put(loan.Payoff_Loan_ID__c, note);

            }

            insert noteList.values();

            successMessage = (csvFileLines.size() -1) + ' notes imported successfully.';
        }
        catch (Exception e)
        {
            String strError;
            if(e.getMessage().contains('Parent'))
                strError = 'There is at least one incorrect Loan Id. Please make sure input CSV file is correct';
            	
            else
                strError = 'An error has occured on line '+ line + ' while importing data. Please make sure input CSV file is correct';
            
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, strError);
            ApexPages.addMessage(errorMessage);
            System.debug('Error Message: ' + e.getMessage() + ' Line: [' + e.getLineNumber() + ']');
        }
    }

	class FailureException extends Exception {}

}