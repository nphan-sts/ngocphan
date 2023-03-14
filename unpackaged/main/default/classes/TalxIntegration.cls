/* ****************Modification History******************************************************************
 * Last Modified by    Date    		JIRA number
 *     Pallavi      2019/12/03    	LOS-168(Spike: 3rd Party - Increase of WorkNumber cost in August)
 * 	   Anusha		2020/11/20		CRM-980 Capture and Store All TALX Responses for Each TALX API Request
 ******************Modification History*****************************************************************/
global class TalxIntegration {
    public static boolean isTalxExecuting=true;
    public TalxInt__c TalxIntegrationSetting = TalxInt__c.getInstance(); // custom setting and set in Remote site setting
    public static boolean callingTalx=false;	//LOS-168
    global static Id requestId = null; //CRM-980

    public static void CallTalxResponse(Id appId, Id accId){
        System.debug('Before isTalxExecuting ....'+ isTalxExecuting );
        if(isTalxExecuting) {
            isTalxExecuting = false;
            System.debug('After isTalxExecuting ....'+ isTalxExecuting);
            System.debug('Check the call callTalxResponse');
            TalxIntegration.CallTalxIntegration(appId, accId, 'CustomTriggerOnApplication');/*Parameter 3 - Event introduced for LOS-168(Snehal)*/
        }
    }

    public static void CallTalx(Id appId, Id accId){
        if(!callingTalx){	//LOS-168
            callingTalx = true;	//LOS-168
            System.debug('Check the call callTalx');
            TalxIntegration.CallTalxIntegration(appId, accId, 'CustomAccountTrigger');/*Parameter 3 - Event introduced for LOS-168(Snehal)*/
        }
    }

    @InvocableMethod
    public static void CallTalx(list<id> appId){
        if(!callingTalx){	//LOS-168
            callingTalx = true;	//LOS-168
            genesis__applications__c app = [SELECT id,Lead_ID__c,
                                            genesis__account__c,
                                            genesis__Status__c
                                            FROM genesis__applications__c
                                            WHERE id=: appId LIMIT 1];
            System.debug('Check the call invocable');
            TalxIntegration.CallTalxIntegration(app.Id, app.genesis__account__c,'CustomAccountTrigger');/*Parameter 3 - Event introduced for LOS-168(Snehal)*/
        }
    }

    @Future(callout=true)
    webservice Static Void CallTalxIntegration(Id appId, Id accId, String event){
        genesis__applications__c app = [SELECT id, Lead_ID__c,
                                        genesis__account__c,
                                        genesis__Status__c
                                        FROM genesis__applications__c
                                        WHERE id=: appId LIMIT 1];
        System.debug('Talx Int Class before Call : ' + app.genesis__Status__c);
        System.debug('Talx Integration Call...');
        string response = null;
        TalxInt__c integrtn = TalxInt__c.getInstance();
        string endpoint = integrtn.Endpoint__c;
        String certName = integrtn.TalxCertificateName__c;   
        try {
            HttpRequest req = new HttpRequest();

            req.setMethod('POST');

            req.setHeader('Content-Type', 'application/x-ofx');
            req.setHeader('Cache-Control', 'no-cache');
            if(!Test.isRunningTest())
            req.setClientCertificateName(certName);
            req.setTimeout(120000);
            req.setEndpoint(endpoint);
            System.debug('Account Id' + accId);
            string reqbody = TaxIntRequest.getRequestbody(accId, appId);
            req.setbody(reqbody);

            System.debug('Request --> ' + reqBody);
            Http http = new Http();
            HTTPResponse res = http.send(req);

            //To return fake response in case of Test.
            if(Test.isRunningTest()) {
                System.debug('Test: Fake Response');	
            }

            MW_LogUtility.info('TalxIntegration', String.valueOf(appId), app.Lead_ID__c, 'CallTalxIntegration', res.getBody().replaceALL('<SSN>[0-9]+</SSN>','<SSN>*********</SSN>'), res);
            System.debug('Response --> ' + res.getBody());
            
            //////LOS-168 Logging for Talx start((Snehal))
            TalxRequestLogging__c talxrequesLogging = new TalxRequestLogging__c();
            talxrequesLogging.Application__c = appId;
            talxrequesLogging.Event__c = event;
            talxrequesLogging.requestBody__c = reqBody;
            insert talxrequesLogging;
            TalxRequestLogging__c talxRequestId = [select id from TalxRequestLogging__c where Application__c = :appId order by createdDate desc limit 1];
            requestId = talxRequestId.Id; //CRM-980 - Storing the request id in a variable (to use when talx__c record is inserted)
            System.debug('Talx Request id: '+requestId);
            //////LOS_168 Logging for Talx End
	
			//Parse the reponse only when the response status code is 200
            if(res.getStatusCode() == 200) {
                response = res.getBody();
                System.debug(logginglevel.error,'TALX Raw Response: '+ response);

                Map<String, Object> talxResponse = parseTalxResponse(response);

                List<Talx__c> talxes = [SELECT Id, Name FROM Talx__c WHERE Application__c = :appId];
                if(talxes != null && talxes.size()>0) { 
                	//delete talxes; //CRM-980 - instead of deleting older talx reponses, update is_active__c on those records to false(deactivate those)
                	List<Talx__c> updatePreviousTalx = new List<Talx__c>();
                    for(Talx__c previousResponse: talxes){
                        previousResponse.is_active__c = false;
                        updatePreviousTalx.add(previousResponse);
                    }
                    if(updatePreviousTalx != null && updatePreviousTalx.size()>0){
                        update updatePreviousTalx;  
                    }
                } 

                TalxVerification talxVerification  = (TalxVerification) talxResponse.get('talx_verification');

                System.debug('>>>>>>>>>>'+talxVerification);

                if(!talxVerification.verifications.isEmpty()) { insertTalxData(appId, accId, talxResponse,response); }//CRM-980 sending entire talx response to insertTalxData method so that it can be stored when talx record is inserted there
                else {
                    Talx__c talx = new Talx__C();
                    talx.Employeer__c = ' No Hit -'+talxVerification.status.message;
                    if(talx.Employeer__c.length()>254) talx.Employeer__c = talx.Employeer__c.substring(1, 250);
                    talx.Account__c = accId;
                    talx.application__c = appId;
                    talx.Is_Active__c = true; //CRM-980
                    talx.TalxRequestLogging__c = requestId; //CRM-980
                    talx.Talx_Response__c = response; //CRM-980
                    insert talx;
                }
                
                String talxName = 'talx_' + app.Lead_ID__c + '.json';
                List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE parentId = :appId and Name = :talxName];
                if(!attachments.isEmpty()) { delete attachments; }

                Attachment a = new Attachment(parentid=appId, Name=talxName, Body= Blob.valueOf(JSON.serialize(talxResponse)), ContentType='application/json');
                insert a;
            }
            //CRM-980 - start - capture response when status code is anything other than 200
            else{
                Talx__c talx = new Talx__c();
                talx.Account__c = accId;
                talx.application__c = appId;
            	talx.API__c = true;
                talx.Is_Active__c = true;
                talx.TalxRequestLogging__c = requestId;//requestId created/inserted above is stored in its respective response record
                talx.Talx_Response__c = response;
                insert talx;
            }
            //CRM-980 - end
        }
        catch(Exception e){
            System.debug('Error -> ' + e.getMessage());
            MW_LogUtility.error('TalxIntegration', String.valueOf(appId), app.Lead_ID__c, 'CallTalxIntegration', e);
            //loan__batch_process_log__c bpl = new loan__batch_process_log__c();
            //bpl.loan__message__c = 'Error in Talx Class ' + e.getStackTraceString();
        }
    }

    public static void insertTalxData(Id appId, Id accId, Map<String, Object> talxResponse, String response){ //new method parameter is added(HTTPResponse res)
        try {
            list<Talx__c> talxList = new List<Talx__c>();
           
            TalxVerification talxVerification = (TalxVerification) talxResponse.get('talx_verification');
            for (Verification verification : talxVerification.verifications) {
                if(verification.employee.active == true)
                {
                    Talx__c talx = new Talx__C();
                    talx.Employeer__c = verification.employer.name;
                    talx.Salary__c = verification.compensation.projected;
                    talx.Length_of_Employement__c = String.valueOf(verification.employee.employed_months);
                    talx.Account__c = accId;
                    talx.Hire_Date__c = verification.employee.hired_at;
                    talx.Term_Date__c = verification.employee.terminated_at;
                    talx.API__c = true;
                    talx.Position__c = verification.employee.position;
                    talx.application__c = appId;
                    talx.Is_Active__c = true; //CRM-980
                    talx.TalxRequestLogging__c = requestId; //CRM-980
                    talx.Talx_Response__c = response; //CRM-980
                    talxList.add(talx);
                }
            }
            if(talxList!=null && talxList.size()>0)
                insert talxList;
            else
            {
                Talx__c talx = new Talx__C();
                talx.Employeer__c = ' No Hit - No Active Employment records found';
                if(talx.Employeer__c.length()>254) talx.Employeer__c = talx.Employeer__c.substring(1, 250);
                talx.Account__c = accId;
                talx.application__c = appId;
                talx.Is_Active__c = true; //CRM-980
                talx.TalxRequestLogging__c = requestId; //CRM-980
                talx.Talx_Response__c = response; //CRM-980
                insert talx;
            }
        }
        catch(Exception e){
            System.debug('No Application Found');
            //loan__batch_process_log__c bpl = new loan__batch_process_log__c();
            //bpl.loan__message__c = 'Error in Talx Integration ' + e.getStackTraceString();
        }
    }

    public static Map<String, Object> parseTalxResponse(String xml) {
        Status status;
        List<Verification> verifications = new List<Verification>();
        Metadata metadata = new Metadata();

        Boolean inOFX = false;
        Boolean inSIGNONMSGSRSV1 = false;
        Boolean inSONRS = false;
        Boolean inTSVERMSGSRSV1 = false;
        Boolean inTSVTWNSELECTTRNRS = false;
        Boolean inTSVTWNSELECTRS = false;

        try {
            XmlStreamReader reader = new XmlStreamReader(xml);
            reader.setCoalescing(true);
            Boolean isSafeToGetNextXmlElement = true;
            while(isSafeToGetNextXmlElement) {
                if (reader.getEventType() == XmlTag.START_ELEMENT) {
                    String tag = reader.getLocalName();
                    if ('OFX' == tag)
                        inOFX = true;
                    else if ('SIGNONMSGSRSV1' == tag)
                        inSIGNONMSGSRSV1 = true;
                    else if ('SONRS' == tag)
                        inSONRS = true;
                    else if ('STATUS' == tag) {
                        if (inOFX && inSIGNONMSGSRSV1 && inSONRS)
                            status = parseTalxStatus(reader);
                        else if (inTSVTWNSELECTTRNRS)
                            status = parseTalxStatus(reader);
                    }
                    else if ('TSVERMSGSRSV1' == tag)
                        inTSVERMSGSRSV1 = true;
                    else if ('TSVTWNSELECTTRNRS' == tag)
                        inTSVTWNSELECTTRNRS = true;
                    else if ('TSVTWNSELECTRS' == tag)
                        inTSVTWNSELECTRS = true;
                    else if ('TSVRESPONSE_V100' == tag) {
                        if (inTSVERMSGSRSV1 && inTSVTWNSELECTTRNRS) {
                            if ('ERROR' == status.severity) {
                                metadata.status = 400;
                                break;
                            }
                            else {
                                Verification verification = parseTalxVerification(reader);
                                verifications.add(verification);
                            }
                        }
                    }
                }
                else if (reader.getEventType() == XmlTag.END_ELEMENT) {
                    if ('TSVTWNSELECTRS' == reader.getLocalName())
                        break;
                }

                if (reader.hasNext())
                    reader.next();
                else {
                    isSafeToGetNextXmlElement = false;
                    break;
                }
            }
            metadata.status = verifications.size() > 0 ? 200 : 404;
        }
        catch (Exception e) {
            System.debug('Parsing exception -> ' + e.getStackTraceString());
            metadata.status = 500;
        }

        TalxVerification talxVerification = new TalxVerification();
        talxVerification.status = status;
        talxVerification.verifications = verifications;
        talxVerification.created_at = DateTime.now();

        Map<String, Object> talxResponse = new Map<String, Object>();
        talxResponse.put('talx_verification', talxVerification);
        talxResponse.put('_metadata', metadata);

        System.debug('Parsing status -> ' + metadata.status);

        return talxResponse;
    }

    public static Status parseTalxStatus(XmlStreamReader reader) {
        Status status = new Status();

        String content;
        Boolean isSafeToGetNextXmlElement = true;
        while (isSafeToGetNextXmlElement) {
            if (reader.getEventType() == XmlTag.END_ELEMENT) {
                String tag = reader.getLocalName();
                if ('CODE' == tag)
                    status.code = String.isBlank(content) ? 0 : Integer.valueOf(content);
                else if ('SEVERITY' == tag)
                    status.severity = content;
                else if ('MESSAGE' == tag)
                    status.message = content;
                else if ('STATUS' == tag)
                    break;
                content = null;
            }
            else if (reader.getEventType() == XmlTag.CHARACTERS)
                content = reader.getText();

            if (reader.hasNext())
                reader.next();
            else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        return status;
    }

    public static Verification parseTalxVerification(XmlStreamReader reader) {
        Verification verification = new Verification();

        Employer employer;
        Employee employee;
        BaseCompensation base;
        List<AnnualCompensation> annuals = new List<AnnualCompensation>();
        Compensation compensation = new Compensation();

        String content;
        Boolean inTSVPROJINCOME = false;
        Boolean isSafeToGetNextXmlElement = true;
        while (isSafeToGetNextXmlElement) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                String tag = reader.getLocalName();
                if ('TSVEMPLOYER_V100' == tag)
                    employer = parseEmployer(reader);
                else if ('TSVEMPLOYEE_V100' == tag)
                    employee = parseEmployee(reader);
                else if ('TSVBASECOMP' == tag)
                    base = parseBaseComp(reader);
                else if ('TSVANNUALCOMP' == tag) {
                    AnnualCompensation annual = parseAnnualComp(reader);
                    annuals.add(annual);
                }
                else if ('TSVPROJINCOME' == tag)
                    inTSVPROJINCOME = true;
            }
            else if (reader.getEventType() == XmlTag.CHARACTERS && inTSVPROJINCOME)
                content = reader.getText();
            else if (reader.getEventType() == XmlTag.END_ELEMENT) {
                String tag = reader.getLocalName();
                if ('TSVPROJINCOME' == tag && inTSVPROJINCOME)
                    compensation.projected = String.isBlank(content) ? 0 : Decimal.valueOf(content);
                else if ('TSVRESPONSE_V100' == tag)
                    break;
            }

            if (reader.hasNext())
                reader.next();
            else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        compensation.base = base;
        compensation.annual = annuals;
        compensation.estimated_annual_income = compensation.projected > 0 ? compensation.projected : base.estimated_annual_income;

        verification.employer = employer;
        verification.employee = employee;
        verification.compensation = compensation;

        return verification;
    }

    public static AnnualCompensation parseAnnualComp(XmlStreamReader reader) {
        AnnualCompensation annual = new AnnualCompensation();

        String content;
        Boolean isSafeToGetNextXmlElement = true;
        while (isSafeToGetNextXmlElement) {
            if (reader.getEventType() == XmlTag.END_ELEMENT) {
                String tag = reader.getLocalName();
                if ('TSVYEAR' == tag)
                    annual.year = String.isBlank(content) ? 0 : Integer.valueOf(content);
                else if ('TSVBASE' == tag)
                    annual.base = String.isBlank(content) ? 0 : Decimal.valueOf(content);
                else if ('TSVOVERTIME' == tag)
                    annual.overtime = String.isBlank(content) ? 0 : Decimal.valueOf(content);
                else if ('TSVCOMMISSION' == tag)
                    annual.commission = String.isBlank(content) ? 0 : Decimal.valueOf(content);
                else if ('TSVBONUS' == tag)
                    annual.bonus = String.isBlank(content) ? 0 : Decimal.valueOf(content);
                else if ('TSVOTHER' == tag)
                    annual.other = String.isBlank(content) ? 0 : Decimal.valueOf(content);
                else if ('TSVTOTAL' == tag)
                    annual.total = String.isBlank(content) ? 0 : Decimal.valueOf(content);
                else if ('TSVANNUALCOMP' == tag)
                    break;

                content = null;
            }
            else if (reader.getEventType() == XmlTag.CHARACTERS)
                content = reader.getText();

            if (reader.hasNext())
                reader.next();
            else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        return annual;
    }

    public static BaseCompensation parseBaseComp(XmlStreamReader reader) {
        Map<Integer, Integer> PAY_FREQUENCY_PERIODS = new Map<Integer, Integer>{
            1 => 1, // Annual
            2 => 2, // Semi-annual
            4 => 12, // Monthly
            5 => 24, // Semi-monthly
            6 => 26, // Bi-weekly
            7 => 52, // Weekly
            8 => 260, // Daily
            9 => 2080, // Hourly
            10 => 13, // 13 Times/year
            11 => 1, // Commission Only
            12 => 10, // 10 Times/year
            13 => 0, // Guaranteed Income
            14 => 11, // 11 Times/year
            15 => null, // Owner Base Pay
            16 => 2080, // Hourly w/o Commission
            17 => 2080, // Hourly + Commission
            18 => 4, // Quarterly
            19 => 12, // Monthly Pension
            20 => 12, // Monthly-2X Jan, no pay Dec
            21 => 2080, // Hourly or Commission
            22 => null, // Per Trip (typically used by airlines)
            23 => null, // Per Task
            24 => null, // Academic 9 Month
            25 => null, // Academic 10 month
            26 => null // Academic per semester
        };
        Set<Integer> HOURLY_PAY_FREQUENCIES = new Set<Integer>{9, 16, 17, 21};

        BaseCompensation base = new BaseCompensation();

        Boolean inTSVPAYFREQUENCY = false;

        String content;
        Boolean isSafeToGetNextXmlElement = true;
        while (isSafeToGetNextXmlElement) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                if ('TSVPAYFREQUENCY' == reader.getLocalName())
                    inTSVPAYFREQUENCY = true;
            }
            else if (reader.getEventType() == XmlTag.END_ELEMENT) {
                String tag = reader.getLocalName();
                if ('CODE' == tag && inTSVPAYFREQUENCY)
                    base.frequency_code = String.isBlank(content) ? null : Integer.valueOf(content);
                else if ('MESSAGE' == tag && inTSVPAYFREQUENCY)
                    base.frequency = content;
                else if ('TSVRATEOFPAY' == tag)
                    base.rate = String.isBlank(content) ? 0 : Decimal.valueOf(content);
                else if ('TSVAVGHRSWORKED' == tag)
                    base.hours = String.isBlank(content) ? 0 : Decimal.valueOf(content);
                else if ('TSVBASECOMP' == tag)
                    break;

                content = null;
            }
            else if (reader.getEventType() == XmlTag.CHARACTERS)
                content = reader.getText();

            if (reader.hasNext())
                reader.next();
            else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        base.pay_periods = PAY_FREQUENCY_PERIODS.get(base.frequency_code);
        base.estimated_annual_income = HOURLY_PAY_FREQUENCIES.contains(base.frequency_code) ? base.hours * base.rate * 52 :
                                       (base.rate * (base.pay_periods > 1 ? base.pay_periods : 1));
        return base;
    }

    public static Employer parseEmployer(XmlStreamReader reader) {
        Employer employer = new Employer();
        employer.address = new Address();

        String content;
        Boolean isSafeToGetNextXmlElement = true;
        while (isSafeToGetNextXmlElement) {
            if (reader.getEventType() == XmlTag.END_ELEMENT) {
                String tag = reader.getLocalName();
                if ('EMPLOYERCODE' == tag)
                    employer.code = String.isBlank(content) ? null : Integer.valueOf(content);
                else if ('FEDIDNUMBER' == tag)
                    employer.fedid = content;
                else if ('NAME1' == tag)
                    employer.name = content;
                else if ('NAME2' == tag)
                    employer.name2 = content;
                else if ('ADDR1' == tag)
                    employer.address.addr = content;
                else if ('ADDR2' == tag)
                    employer.address.addr2 = content;
                else if ('ADDR3' == tag)
                    employer.address.addr3 = content;
                else if ('CITY' == tag)
                    employer.address.city = content;
                else if ('STATE' == tag)
                    employer.address.state = content;
                else if ('POSTALCODE' == tag)
                    employer.address.postal = content;
                else if ('ISOCOUNTRYCODE' == tag)
                    employer.address.country = content;
                else if ('TSVEMPLOYER_V100' == tag)
                    break;

                content = null;
            }
            else if (reader.getEventType() == XmlTag.CHARACTERS)
                content = reader.getText();

            if (reader.hasNext())
                reader.next();
            else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        return employer;
    }

    public static Employee parseEmployee(XmlStreamReader reader) {
        Set<Integer> STATUSES = new Set<Integer>{1, 2, 3, 5, 6, 9, 10, 11, 13, 14, 17, 18, 19, 42, 43, 52, 53, 54, 58};
        Employee employee = new Employee();
        employee.address = new Address();

        String content;
        Boolean inEMPLOYEESTATUS = false;

        Boolean isSafeToGetNextXmlElement = true;
        while (isSafeToGetNextXmlElement) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                if ('EMPLOYEESTATUS' == reader.getLocalName())
                    inEMPLOYEESTATUS = true;
            }
            else if (reader.getEventType() == XmlTag.END_ELEMENT) {
                String tag = reader.getLocalName();
                if ('SSN' == tag)
                    employee.ssn = content;
                else if ('ALTERNATEID' == tag)
                    employee.altid = content;
                else if ('FIRSTNAME' == tag)
                    employee.first_name = content;
                else if ('MIDDLENAME' == tag)
                    employee.middle_name = content;
                else if ('LASTNAME' == tag)
                    employee.last_name = content;
                else if ('ADDR1' == tag)
                    employee.address.addr = content;
                else if ('ADDR2' == tag)
                    employee.address.addr2 = content;
                else if ('ADDR3' == tag)
                    employee.address.addr3 = content;
                else if ('CITY' == tag)
                    employee.address.city = content;
                else if ('STATE' == tag)
                    employee.address.state = content;
                else if ('POSTALCODE' == tag)
                    employee.address.postal = content;
                else if ('ISOCOUNTRYCODE' == tag)
                    employee.address.country = content;
                else if ('PHONENUMBER' == tag)
                    employee.phone = content;
                else if ('DTBIRTH' == tag)
                    employee.date_of_birth = parseDate(content);
                else if ('CODE' == tag && inEMPLOYEESTATUS)
                    employee.status_code = String.isBlank(content) ? null : Integer.valueOf(content);
                else if ('MESSAGE' == tag && inEMPLOYEESTATUS)
                    employee.status = content;
                else if ('POSITION-TITLE' == tag)
                    employee.position = content;
                else if ('DIVISIONCODE' == tag)
                    employee.division = content;
                else if ('DTINFO' == tag)
                    employee.updated_at = parseDate(content);
                else if ('DTORIGINALHIRE' == tag)
                    employee.first_hired_at = parseDate(content);
                else if ('DTMOSTRECENTHIRE' == tag)
                    employee.hired_at = parseDate(content);
                else if ('DTENDEMPLOYMENT' == tag)
                    employee.terminated_at = parseDate(content);
                else if ('TERMINATIONREASON' == tag)
                    employee.termination_reason = content;
                else if ('TOTALLENGTHOFSVC' == tag)
                    employee.employed_months = Integer.valueOf(content);
                else if ('DTMOSTRECENTPAY' == tag)
                    employee.last_paid_at = parseDate(content);
                else if ('TSVEMPLOYEE_V100' == tag)
                    break;

                content = null;
            }
            else if (reader.getEventType() == XmlTag.CHARACTERS)
                content = reader.getText();

            if (reader.hasNext())
                reader.next();
            else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        employee.active = STATUSES.contains(employee.status_code);
        return employee;
    }

    public static Date parseDate(String dateStr) {
        if (String.isBlank(dateStr))
            return null;

        return Date.newInstance(Integer.valueOf(dateStr.substring(0, 4)), Integer.valueOf(dateStr.substring(4, 6)), Integer.valueOf(dateStr.substring(6, 8)));
    }

    public class Status {
        public Integer code;
        public String severity;
        public String message;
    }

    public class Address {
        public String addr;
        public String addr2;
        public String addr3;
        public String city;
        public String state;
        public String postal;
        public String country;
    }

    public class Employer {
        public Integer code;
        public String fedid;
        public String name;
        public String name2;
        public Address address;
    }

    public class Employee {
        public String ssn;
        public String altid;
        public String first_name;
        public String middle_name;
        public String last_name;
        public String phone;
        public Date date_of_birth;
        public Integer status_code;
        public String status;
        public String position;
        public String division;
        public Integer employed_months;
        public Date first_hired_at;
        public Date hired_at;
        public Date terminated_at;
        public String termination_reason;
        public Date updated_at;
        public Date last_paid_at;
        public Boolean active;
        public Address address;
    }

    public class Compensation {
        public BaseCompensation base;
        public List<AnnualCompensation> annual;
        public Decimal projected;
        public Decimal estimated_annual_income;
    }

    public class BaseCompensation {
        public String frequency;
        public Integer frequency_code;
        public Decimal rate;
        public Decimal hours;
        public Integer pay_periods;
        public Decimal estimated_annual_income;
    }

    public class AnnualCompensation {
        public Integer year;
        public Decimal base;
        public Decimal overtime;
        public Decimal commission;
        public Decimal bonus;
        public Decimal other;
        public Decimal total;
    }

    public class Verification {
        public Employer employer;
        public Employee employee;
        public Compensation compensation;
    }

    public class TalxVerification {
        public Status status;
        public List<Verification> verifications;
        public DateTime created_at;
    }

    public class Metadata {
        public Integer status;
    }
}