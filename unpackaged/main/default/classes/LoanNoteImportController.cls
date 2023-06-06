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
        try
        {
            csvAsString = csvFileBody.toString();
            csvFileLines = csvAsString.split('\n');

            for(Integer i=1; i<csvFileLines.size(); i++)
            {
                string[] csvRecordData = csvFileLines[i].split(',');

                String loanId = csvRecordData[0];
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
            
            for(loan__Loan_Account__c loan : [SELECT Id, Payoff_Loan_ID__c FROM loan__Loan_Account__c
                                              WHERE Payoff_Loan_ID__c IN : noteList.keyset()])
            {
                Note note = noteList.get(loan.Payoff_Loan_ID__c);

                note.ParentId = loan.Id;

                noteList.put(loan.Payoff_Loan_ID__c, note);
            }

            insert noteList.values();
        }
        catch (Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'An error has occured while importing data. Please make sure input CSV file is correct');
            ApexPages.addMessage(errorMessage);
            System.debug('Error Message: ' + e.getMessage());
        }
    }
}