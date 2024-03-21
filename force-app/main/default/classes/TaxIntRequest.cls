public class TaxIntRequest {
    public static string getRequestbody(id accId, id appid){
        System.debug('App id ' + appId + ' AccId ' + accId);
        
        String requestBody = '<?xml version="1.0" encoding="UTF-8"?>'+
            '<?OFX OFXHEADER="200" VERSION="201" SECURITY="NONE" OLDFILEUID="NONE" NEWFILEUID="NONE"?>'+
            '<OFX>'+
            '<SIGNONMSGSRQV1>'+
            '<SONRQ>'+
            +Getusernamepassword()+
            ' </SONRQ>'+
            ' </SIGNONMSGSRQV1>'+
            '<TSVERMSGSRQV1>'+
            '<TSVTWNSELECTTRNRQ>'+
            ' <TRNUID>'+appId+'</TRNUID>'+
            ' <TRNPURPOSE>'+
            '             <CODE>PPCREDIT</CODE>'+
            ' </TRNPURPOSE>'+
            ' <TSVTWNSELECTRQ>'+
            +GetAccountInfo(accId)+
            '        <TEMPLATE_NAME>AutoGold</TEMPLATE_NAME>'+
            ' </TSVTWNSELECTRQ>'+
            '</TSVTWNSELECTTRNRQ>'+
            ' </TSVERMSGSRQV1>'+
            '</OFX>';
        return requestbody;
    }
    public static String Getusernamepassword(){
        TalxInt__c integrtn = TalxInt__c.getInstance();
        string USERID = integrtn.USERID__c;
        string USERPASS = integrtn.USERPASS__c;
        String DTCLIENT = integrtn.DTCLIENT__c;
        String LANG = integrtn.LANGUAGE__c;
        String APPID = integrtn.APPID__c;
        String APPVER = String.valueOf(integrtn.APPVER__c);
        
        XmlStreamWriter w = new XmlStreamWriter();
        // <DTCLIENT>20170612131212</DTCLIENT>
        w.writeStartElement(null,'DTCLIENT',null);
        Datetime now = Datetime.now();
        w.writeCharacters(now.format('yyyyMMddhhmmss'));
        w.writeEndElement();
        //   <USERID>PayoffIntUsrTest@50005</USERID>
        w.writeStartElement(null, 'USERID', null);
        w.writeCharacters(USERID);
        w.writeEndElement();
        
        //  <USERPASS>vQS4iNmTGawu7btqqMJNO2Bq4hQmdzOhlBd8</USERPASS>   
        w.writeStartElement(null, 'USERPASS', null);
        w.writeCharacters(USERPASS);
        w.writeEndElement();
        
        // <LANGUAGE>ENG</LANGUAGE>
        w.writeStartElement(null, 'LANGUAGE', null);
        w.writeCharacters(LANG);
        w.writeEndElement();
        
        //  <APPID>PAYOFF</APPID>
        w.writeStartElement(null, 'APPID', null);
        w.writeCharacters(APPID);
        w.writeEndElement();
        
        //  <APPVER>0001</APPVER>
        w.writeStartElement(null, 'APPVER', null);
        w.writeCharacters(APPVER);
        w.writeEndElement();
        
        String xmlOutput = w.getXmlString();
        w.close();
        return xmlOutput;
    }
    
    public static String GetAccountInfo(id accId){
        Account acc = [select id,
                        ints__SSN__c, loan__SOCIAL_SECURITY_NUMBER__c
                        FROM Account
                        WHERE id =: accId];
        XmlStreamWriter w = new XmlStreamWriter();
        //  <TSVEMPLOYEEID>799005153</TSVEMPLOYEEID>
        w.writeStartElement(null, 'TSVEMPLOYEEID', null);
        w.writeCharacters(String.valueOf(acc.loan__SOCIAL_SECURITY_NUMBER__c).replaceAll('-',''));
        w.writeEndElement();
        
        String xmlOutput = w.getXmlString();
        w.close();
        return xmlOutput;
    }
}