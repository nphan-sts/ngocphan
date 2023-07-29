@isTest
public with sharing class MW_BoxUploadParserTest {
    
    static testmethod void test() {        
       
        StaticResource sr = [select Body from StaticResource where Name='BoxResposne' limit 1];
        String xmlString = sr.Body.toString();
           
        MW_BoxUploadParser.parse(xmlString);
    }
}