public with sharing class CreditPolicyController {
    public List<Credit_Policy__c> creditPolicyRec { get; set; }
    public Decimal fico { get; set; }
    public Date cpBureauInquiryDate { get; set; }

    public CreditPolicyController(){   
        Id appId = ApexPages.currentPage().getParameters().get('Id'); 
        
        if(appId != null){  
            creditPolicyRec = [SELECT FICO__C, Bureau_Inquiry_Date__c 
                FROM Credit_Policy__c 
                WHERE Application__c =: appId 
                AND request_intent__c = 'application' 
                ORDER BY CreatedDate DESC 
                LIMIT 1
            ];
            
            if(creditPolicyRec != null && !creditPolicyRec.isEmpty() && creditPolicyRec[0].FICO__C != null) {
                try {
                    Credit_Policy__c cpRecord = creditPolicyRec[0];

                    //Set FICO
                    cpRecord.FICO__C = cpRecord.FICO__C.setScale(0);
                    fico = cpRecord.FICO__C.setScale(0);
                    
                    //Set Date
                    if (cpRecord.Bureau_Inquiry_Date__c != null) {

                        Datetime bureuDatetime = convertTimezone(cpRecord.Bureau_Inquiry_Date__c);
                        cpBureauInquiryDate = bureuDatetime.date();
                    }
                } catch (Exception ex) {
                    System.debug(LoggingLevel.ERROR, 'Error resolving Bureau Values: ' + ex.getMessage());
                    setBureauValuesToNull();
                }           
            } else {
                setBureauValuesToNull();
            }
        }                
    }

    private Datetime convertTimezone(String bureauDate ) {
        System.debug(bureauDate);

        String timezoneString = bureauDate.substring(bureauDate.length() - 6);

        
        String formattedString = bureauDate.substring(0,19) + 'Z';

        DateTime utcDatetime = (DateTime)JSON.deserialize('"' + formattedString + '"', DateTime.class);
        
        TimeZone sourceTz = TimeZone.getTimeZone('GMT' + timezoneString);
        TimeZone targetTz = TimeZone.getTimeZone('America/Los_Angeles'); // PST is typically UTC-8

        DateTime dt = Datetime.now();

        // Get the offset in milliseconds from GMT for each timezone
        Integer offset1 = sourceTz.getOffset(dt);
        Integer offset2 = targetTz.getOffset(dt);

        Integer timeDifference = offset2 - offset1;

        // Calculate the difference in hours
        Integer differenceInHours = (offset2 - offset1) / (1000 * 60 * 60);
        System.debug('The time difference in hours is: ' + differenceInHours);

        Datetime sourceDatetime = utcDatetime.addSeconds(sourceTz.getOffset(utcDatetime) / 1000);

        System.debug(sourceDatetime);

        Datetime targetDatetime = sourceDatetime.addHours(differenceInHours);
       
        System.debug(targetDatetime);
        return targetDatetime;
    }

    private void setBureauValuesToNull() {
        this.fico = null;
        this.cpBureauInquiryDate = null;
    }
}