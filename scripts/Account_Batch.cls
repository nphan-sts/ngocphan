//Datamasking scripts
global class Account_Batch implements Database.Batchable<SObject>{ 
    private static final Id MemberRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Member').getRecordTypeId();
    global Database.QueryLocator start(Database.BatchableContext bc){ 

        String query = 'SELECT id, NAME, peer__First_Name__c,peer__Last_Name__c,Account_Payload_History__c, Phone, Address_1__c, Alternate_Phone__c,BillingStreet, Bureau_Date_of_Birth__c, peer__Date_of_Birth__c, loan__SOCIAL_SECURITY_NUMBER__c, Bureau_Social_Security__c, social_security_number_uniqueness_field__c, ints__SSN__c, Encrypted_SSN__c, ints__Email__c, cnotify__Email__c,peer__Email__c, clcommon__Email__c, Employer__c, peer__FB_Access_Token__c, peer__FB_Image__c,peer__Nickname__c, TALX_Employer__c, TALX_Position__c, website,Work_Email__c, Work_Phone__c FROM Account where RecordTypeId =:MemberRecordTypeID AND cnotify__Email__c != null  AND (Not cnotify__Email__c Like '+'\'%example.com\''+')';
        return Database.getQueryLocator(query);
    }     
    global void execute(Database.BatchableContext bc, List<Account> scope){
        List<Account> accsToUpdate = new List<Account>();
        for(Account a : scope){

            String FName = generateRandom.generateFirstName();
            String LName = generateRandom.generateLastName();
            a.Name = FName +' '+LName;
            if(a.peer__First_Name__c != null) a.peer__First_Name__c = FName;
            if(a.peer__First_Name__c != null) a.peer__Last_Name__c = LName;
            a.Account_Payload_History__c = null;
            if(a.phone!=null) a.phone=generateRandom.generateIntegerString(10);
            if(a.Address_1__c!=null) a.Address_1__c = generateRandom.randomStreetAddress();
            if(a.Alternate_Phone__c!=null) a.Alternate_Phone__c = generateRandom.generateIntegerString(10);
            if(a.BillingStreet!=null) a.BillingStreet = generateRandom.randomStreetAddress();
            Date dob = generateRandom.randomDate(date.newInstance(1960,01,01) , date.newInstance(2000,01,01));
            if(a.Bureau_Date_of_Birth__c == a.peer__Date_of_Birth__c){
                a.Bureau_Date_of_Birth__c = dob;
                a.peer__Date_of_Birth__c = dob;
            } else {
                a.Bureau_Date_of_Birth__c = dob;
                a.peer__Date_of_Birth__c = generateRandom.randomDate(date.newInstance(1960,01,01) , date.newInstance(2000,01,01));
            }
            String social =generateRandom.generateIntegerStringIncluding0(9);
            if(a.loan__SOCIAL_SECURITY_NUMBER__c == a.Bureau_Social_Security__c){
                if(a.loan__SOCIAL_SECURITY_NUMBER__c !=null) a.loan__SOCIAL_SECURITY_NUMBER__c = social;
                if(a.Bureau_Social_Security__c !=null) a.Bureau_Social_Security__c = social;
                if(a.social_security_number_uniqueness_field__c  !=null) a.social_security_number_uniqueness_field__c = social;
                if(a.ints__SSN__c!=null) a.ints__SSN__c = social;
                if(a.Encrypted_SSN__c!=null) a.Encrypted_SSN__c = social;
            }
            else{
                if(a.loan__SOCIAL_SECURITY_NUMBER__c !=null) a.loan__SOCIAL_SECURITY_NUMBER__c = social;
                if(a.Bureau_Social_Security__c !=null) a.Bureau_Social_Security__c = generateRandom.generateIntegerString(9);
                if(a.social_security_number_uniqueness_field__c  !=null) a.social_security_number_uniqueness_field__c = social;
                if(a.ints__SSN__c!=null) a.ints__SSN__c = social;
                if(a.Encrypted_SSN__c!=null) a.Encrypted_SSN__c = social;
                
            }
            String rndEmail = generateRandom.generateEmail();
            if(a.ints__Email__c!=null) a.ints__Email__c = rndEmail;
            if(a.cnotify__Email__c!=null) a.cnotify__Email__c = rndEmail;
            if(a.peer__Email__c!=null) a.peer__Email__c = rndEmail;
            if(a.clcommon__Email__c!=null) a.clcommon__Email__c = rndEmail;
            if(a.Employer__c!=null) a.Employer__c = generateRandom.generateRandomString(10);
            a.peer__FB_Access_Token__c = null;
            a.peer__FB_Image__c = null;
            a.peer__Nickname__c = Fname.charAt(0) + LName;
            if(a.TALX_Employer__c!=null) a.TALX_Employer__c= generateRandom.generateRandomString(10);
            if(a.TALX_Position__c!=null) a.TALX_Position__c= generateRandom.generateRandomString(8);
            if(a.website!=null) a.website= generateRandom.randomWebsite();
            if(a.Work_Email__c!=null) a.Work_Email__c = generateRandom.generateEmail();
            if(a.Work_Phone__c!=null) a.Work_Phone__c=generateRandom.generateIntegerString(10);

            accsToUpdate.add(a);
        } 
        
        update accsToUpdate; 
    }     
    global void finish(Database.BatchableContext bc){     
    } 
 }