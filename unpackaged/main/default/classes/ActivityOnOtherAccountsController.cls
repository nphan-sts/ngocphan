public with sharing class ActivityOnOtherAccountsController {
    public String AcctId { get; set; }
    public Boolean IsSsnExist {get; set;}
    public Boolean IsAcctActivitiesExist { get; set; }
    public List<AcctActivity> AcctActivities {get; set;}
    
    public class AcctActivity{
        public Account Acct {get; set;}
        public List<genesis__Applications__c> Apps {get; set;}
        public List<loan__loan_account__c> Loans {get; set;}
        public Boolean IsAppsExist {get; set;}
        public Boolean IsLoansExist {get; set;}
    }

    public ActivityOnOtherAccountsController() {
        AcctId = ApexPages.currentPage().getParameters().get('id');
        PopulateAcctActivities();
    }

    public ActivityOnOtherAccountsController(ApexPages.StandardController controller) {
        AcctId = controller.getId();
        PopulateAcctActivities();
    }

    public void PopulateAcctActivities()
    {
        System.debug('AcctId=' + AcctId);
        IsSsnExist = true;
        IsAcctActivitiesExist = false;
        
        IF (string.isEmpty(AcctId) == false) {
            Set<String> setDuplicateSsn = new Set<String>();
            Map<Id, genesis__Applications__c> mapCurrentApps = new Map<Id, genesis__Applications__c>();
            List<AcctActivity> tempAcctActivities = new List<AcctActivity>();

            List<genesis__Applications__c> listApps = [
                SELECT Id, Name, Lead_ID__c, Applicant_Name__c, CreatedDate, Bureau_SSN__c, 
                Bureau_DOB__c, genesis__Status__c, genesis__Account__c 
                FROM genesis__Applications__c 
                WHERE 
                genesis__Account__c = :AcctId
            ];

            For(genesis__Applications__c app : listApps) {
                        mapCurrentApps.put(app.genesis__Account__c, app);
                        
                        if(string.isEmpty(app.Bureau_SSN__c) == false){
                            setDuplicateSsn.Add(app.Bureau_SSN__c);
                        }
            }
            
            if(setDuplicateSsn.size() == 0)
            {
                IsSsnExist = false;
                return;
            }

            System.debug('setDuplicateSsn=' + setDuplicateSsn);

            Map<Id, Account> mapPreExistAccts = new Map<Id, Account>(
                [
                        SELECT Id, Name, social_security_number_uniqueness_field__c, 
                        loan__SOCIAL_SECURITY_NUMBER__c, cnotify__Email__c, peer__Date_of_Birth__c
                        FROM Account 
                        WHERE 
                        (
                            social_security_number_uniqueness_field__c IN :setDuplicateSsn
                            OR
                            loan__SOCIAL_SECURITY_NUMBER__c IN :setDuplicateSsn
                        )
                        AND Id != :AcctId
                ]);

            List<genesis__Applications__c> listPreExistAcctsActiveApps = [
                SELECT Id, Name, Lead_ID__c, Applicant_Name__c, CreatedDate, Bureau_SSN__c, 
                Bureau_DOB__c, genesis__Status__c, genesis__Account__c
                FROM genesis__Applications__c 
                WHERE 
                genesis__Account__c IN :mapPreExistAccts.keySet()
            ];

            List<loan__Loan_Account__c> preExistLoanAccts = [
                SELECT Id, Name, loan__Account__c,lead_Guid__c, loan__Loan_Status__c, CreatedDate
                FROM loan__Loan_Account__c 
                WHERE loan__Account__c IN :mapPreExistAccts.keySet()
            ];

            For (Id acctId : mapPreExistAccts.keySet()) {
                Account preExistAcct = mapPreExistAccts.get(acctId);
                System.debug('preExistAcct.loan__SOCIAL_SECURITY_NUMBER__c=' + preExistAcct.loan__SOCIAL_SECURITY_NUMBER__c);
                AcctActivity acctActy = new AcctActivity();
                acctActy.Acct = preExistAcct;
                acctActy.Apps = getAcctApps(acctId, listPreExistAcctsActiveApps);
                acctActy.IsAppsExist = acctActy.Apps.size() > 0 ? true: false;
                System.debug('acctActy.Apps=' + acctActy.Apps);
                acctActy.Loans = getAcctLoans(acctId, preExistLoanAccts);
                acctActy.IsLoansExist = acctActy.Loans.size() > 0 ? true: false;
                System.debug('acctActy.Loans=' + acctActy.Loans);
                
                System.debug('acctActy=' + acctActy);
                tempAcctActivities.Add(acctActy);
            }

            IsAcctActivitiesExist = mapPreExistAccts.size()>0 ? true : false;

            AcctActivities = tempAcctActivities;
        }
    }

    private List<genesis__Applications__c> getAcctApps(Id acctId, List<genesis__Applications__c> apps)
    {
        List<genesis__Applications__c> acctApps = new List<genesis__Applications__c>();
        for(genesis__Applications__c app: apps)
        {
            if(app.genesis__Account__c == acctId)
            {
                acctApps.Add(app);
            }
        }

        return acctApps;
    }

    private List<loan__Loan_Account__c> getAcctLoans(Id acctId, List<loan__Loan_Account__c> loans)
    {
        List<loan__Loan_Account__c> acctLoans = new List<loan__Loan_Account__c>();
        for(loan__Loan_Account__c loan: loans)
        {
            if(loan.loan__Account__c == acctId)
            {
                acctLoans.Add(loan);
            }
        }

        return acctLoans;
    }
}