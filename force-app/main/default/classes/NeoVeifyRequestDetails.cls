public with sharing class NeoVeifyRequestDetails {
    
    public String report_id;
    public List<neoAcountDeatils> accounts;

    public Class neoAcountDeatils {
        public String type;
        public String account_number;
        public String name;
        public String balance;
        public List<transactions> transactions;
    }

    public class transactions{
        public String posted_date;
        public Decimal amount;
        public String description; 
    }

    public class registerNeoUser{
        public String ssn;
        public string birth_date; 
        public String first_name;
        public String last_name;
        public String has_ssn;
    }

    public class CheckAppStatus {
        public string birth_date; 
        public String first_name;
        public String last_name;
        public String application_date;
    }

    public String CheckApplicationStatus(Id appId){

        List<genesis__Applications__c> app = new List<genesis__Applications__c>([select Id, genesis__Account__r.Borrower_s_First_Name__c, genesis__Account__r.Borrower_s_Last_Name__c,
                                                                                genesis__Account__r.peer__Date_of_Birth__c, Neoverify_Application_Date__c
                                                                                from genesis__Applications__c where Id =:appId limit 1]);
        CheckAppStatus chkAppStatus  = new CheckAppStatus();
        chkAppStatus.first_name      = app[0].genesis__Account__r.Borrower_s_First_Name__c;
        chkAppStatus.last_name       = app[0].genesis__Account__r.Borrower_s_Last_Name__c;
        chkAppStatus.birth_date      = String.valueOf(app[0].genesis__Account__r.peer__Date_of_Birth__c);
        Date d = date.today();
        chkAppStatus.application_date= DateTime.newInstance(d.year(),d.month(),d.day()).format('d-MM-YYYY');

        return JSON.serialize(chkAppStatus);
    }

    public registerNeoUser CreateRegisterUserRequest(Id appId){

        registerNeoUser registeruser = new registerNeoUser();

        List<genesis__Applications__c> app = new List<genesis__Applications__c>([select Id, genesis__Account__r.Borrower_s_First_Name__c, genesis__Account__r.Borrower_s_Last_Name__c,
                                                                                genesis__Account__r.peer__Date_of_Birth__c, genesis__Account__r.loan__SOCIAL_SECURITY_NUMBER__c, Neoverify_Application_Date__c
                                                                                from genesis__Applications__c where Id =:appId limit 1]);
        registeruser.has_ssn     = 'n';
        
        if(app[0].genesis__Account__r.loan__SOCIAL_SECURITY_NUMBER__c!=null){
            registeruser.ssn             = app[0].genesis__Account__r.loan__SOCIAL_SECURITY_NUMBER__c.replaceAll('-','');
            registeruser.has_ssn         = 'y';
        }
        registeruser.first_name      = app[0].genesis__Account__r.Borrower_s_First_Name__c;
        registeruser.last_name       = app[0].genesis__Account__r.Borrower_s_Last_Name__c;
        registeruser.birth_date      = String.valueOf(app[0].genesis__Account__r.peer__Date_of_Birth__c);
        
        return registeruser;
    }


    public String linkAccountTransactions(Id appId, String reportId) {
        
            Map<String, List<transactions>> transactionMap = new Map<String,List<transactions>>();

            for(Yodlee_User_Transaction__c useTrans:[Select Transaction_Date__c, Transaction_Amount__c,Description__c, postDate__c, YodleeBankAccountId__c,Credit__c, Debit__c
                                                    from Yodlee_User_Transaction__c where Yodlee_Application__c=:appId order by YodleeBankAccountId__c desc]){

                if(transactionMap.get(useTrans.YodleeBankAccountId__c)==null){
                    List<transactions> listofTans = new List<transactions>();  
                    if(useTrans.postDate__c!=null && (useTrans.Credit__c!=null || useTrans.Debit__c!=null))
                    { 
                        transactions trans = new transactions();
                        trans.posted_date  = useTrans.postDate__c;
                        if(useTrans.Credit__c==null) {trans.amount = useTrans.Debit__c * -1; } else {trans.amount = useTrans.Credit__c;}
                        trans.description  = useTrans.Description__c;
                        listofTans.add(trans);
                        transactionMap.put(useTrans.YodleeBankAccountId__c, listofTans);
                    }
                }else{
                    List<transactions> listofTans = transactionMap.get(useTrans.YodleeBankAccountId__c);
                    if(useTrans.postDate__c!=null && (useTrans.Credit__c!=null || useTrans.Debit__c!=null))
                    {
                        transactions trans = new transactions();
                        trans.posted_date  = useTrans.postDate__c;
                        if(useTrans.Credit__c==null) { trans.amount = useTrans.Debit__c * -1;  } 
                        else { trans.amount = useTrans.Credit__c;}
                        trans.description  = useTrans.Description__c;
                        listofTans.add(trans);
                        transactionMap.put(useTrans.YodleeBankAccountId__c, listofTans);
                    }
                }
            } 

            List<neoAcountDeatils> accdetaillist = new List<neoAcountDeatils> ();

            for(Yodlee_User_Account__c useAcc:[Select Account_Holder_Name__c, name, Account_Number__c, Account_Type__c, Current_Balance__c, Yodlee_Application__r.Name,YodleeBankAccountId__c
                                                    from Yodlee_User_Account__c where Yodlee_Application__c=:appId order by YodleeBankAccountId__c desc]){
                
                if(transactionMap.get(useAcc.YodleeBankAccountId__c)!=null && transactionMap.get(useAcc.YodleeBankAccountId__c).size()>0){
                    neoAcountDeatils  newad =new neoAcountDeatils();
                    //CLS-1033 
                    if(useAcc.Account_Type__c!='CHECKING' && useAcc.Account_Type__c!='SAVINGS' && useAcc.Account_Type__c!='MONEYMRKT' && useAcc.Account_Type__c!='RECURRINGDEPOSIT'
                       && useAcc.Account_Type__c!='CD' && useAcc.Account_Type__c!='CASHMANAGEMENT' && useAcc.Account_Type__c!='OVERDRAFT' && useAcc.Account_Type__c!='CREDITCARD'
                       && useAcc.Account_Type__c!='LINEOFCREDIT' && useAcc.Account_Type__c!='LOAN AUTO' && useAcc.Account_Type__c!='COMMERCIAL' && useAcc.Account_Type__c!='CONSTR'
                       && useAcc.Account_Type__c!='CONSUMER' && useAcc.Account_Type__c!='HOMEEQUITY' && useAcc.Account_Type__c!='MILITARY' && useAcc.Account_Type__c!='MORTGAGE'
                       && useAcc.Account_Type__c!='SMB' && useAcc.Account_Type__c!='STUDENT' && useAcc.Account_Type__c!='TAXABLE' && useAcc.Account_Type__c!='401K'
                       && useAcc.Account_Type__c!='BROKERAGE' && useAcc.Account_Type__c!='IRA' && useAcc.Account_Type__c!='403B' && useAcc.Account_Type__c!='KEOGH'
                       && useAcc.Account_Type__c!='TRUST' && useAcc.Account_Type__c!='TDA' && useAcc.Account_Type__c!='SIMPLE' && useAcc.Account_Type__c!='NORMAL'
                       && useAcc.Account_Type__c!='SARSEP' && useAcc.Account_Type__c!='UGMA')
                    {
                       newad.type='OTHER';
                    }
                    else
                    {
                       newad.type=useAcc.Account_Type__c;
                    }
                    newad.account_number    = useAcc.Account_Number__c;
                    if(useAcc.name != null && useAcc.name != '')
                    {
                        newad.name              =useAcc.name;
                    }
                    else
                    {newad.name              ='No Name';}
                    newad.balance           =String.valueOf(useAcc.Current_Balance__c);
                    newad.transactions      =transactionMap.get(useAcc.YodleeBankAccountId__c);
                    accdetaillist.add(newad);
                }
            }
            //CLS-1033
            List<neoAcountDeatils> accDetailsFilteredList = new List<neoAcountDeatils> ();
            for(neoAcountDeatils nvAcc: accdetaillist)
            {
                    if(nvAcc!=null && nvAcc.transactions!=null && nvAcc.transactions.size()>0)
                    {
                        accDetailsFilteredList.add(nvAcc);
                    }           
            
            }
 
            NeoVeifyRequestDetails nvrequest = new NeoVeifyRequestDetails();
            nvrequest.report_id              = reportId;
            nvrequest.accounts               = accDetailsFilteredList;

            return JSON.serialize(nvrequest);
    }
}