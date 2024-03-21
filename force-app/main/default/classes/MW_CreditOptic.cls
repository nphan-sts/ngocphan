public with sharing class MW_CreditOptic {

    public class CreditOptic {
        public Integer IdScore;
    }

    public static CreditOptic ParseCreditOptic(String rawXml) {

        /*String rawXml = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                + '<soap:Body><api:Response xmlns:api="http://idanalytics.com/core/api"><api:Solution>Standard/MultiProduct</api:Solution><api:RequestID>77cfcab24034362f:272cd76e-1e0d-44b9-9714-b51e646d730f</api:RequestID>'
                + '<api:View>MultiProduct/FINISHED</api:View><api:Body><api:Item key="CreditOpticsAcquisitionsFAB1.0Response">'
                + '<OutputRecord xmlns="http://idanalytics.com/products/idscore/result" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:internal="http://idanalytics.com/internal/api" schemaVersion="3.0">'
                + '<IDAStatus>100</IDAStatus><AppID>11402459-55e0-4d61-8d75-ba59c08618ff</AppID><Designation>A1</Designation><IDASequence>117445880782143</IDASequence>'
                + '<IDATimeStamp>2019-05-07T16:49:24</IDATimeStamp><IDScore>500</IDScore><IDScoreResultCode1>386</IDScoreResultCode1><IDScoreResultCode2>411</IDScoreResultCode2>'
                + '<IDScoreResultCode3>413</IDScoreResultCode3><IDScoreResultCode4>435</IDScoreResultCode4><IDScoreResultCode5>702</IDScoreResultCode5></OutputRecord>'
                + '</api:Item></api:Body></api:Response></soap:Body></soap:Envelope>';
        */
        CreditOptic co = new CreditOptic();

        if (!String.isEmpty(rawXml)) {
			//<IDScore>500</IDScore>
			co.IDScore = Integer.valueOf(rawXml.substringBetween('<IDScore>', '</IDScore>'));
        }

        return co;
    }

    public static void UpdateApplication(genesis__Applications__c app, CreditOptic co) {
        if (app != null && co.IdScore != null) {
            app.CreditOptic_IdScore__c = co.IdScore;
            update app;
        }
    }
}