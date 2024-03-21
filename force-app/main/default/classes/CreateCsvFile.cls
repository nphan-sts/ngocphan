public with sharing class CreateCsvFile {

    /**
    @description create a CSV file from a list of Object Lists each Object List is a row in a list of lists. Each Object is a cell in the CSV
    */
    public static void createCSV(List<String> csvHeaders, List<List<String>> csvRowList, String title){
        String headerRow = String.join(csvHeaders,',') + '\n';
        String concantenatedStr = headerRow;
        Integer i = 0;
        Integer rowListSize = csvRowList.size();
        for(List<String> row :csvRowList){
            if(csvHeaders.size() != row.size()) throw new FileMakerException('The row size needs to be the same size as the header');//check the row list is the same size as the header list
            concantenatedStr += String.join(row, ',');
            i++;
            if(i != rowListSize) concantenatedStr += '\n';//add new line
        }
        title += '.csv';
        createFile(concantenatedStr, title);
    }

    /**
    @description create a file - generic
    */
    public static void createFile(String versionData, String title) {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; //denotes it resides on Salesforce
        cv.Title = title; //title of the file
        cv.PathOnClient = title; // full path within Salesforce this can just be the name of file to be in the library
        cv.VersionData = Blob.valueOf(versionData); //file data
        insert cv;
    }

    public class FileMakerException extends Exception{}
}