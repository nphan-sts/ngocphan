public class AdverseActionController{

    public adverseActionResults adverseResults {get;set;}
    public List<Adverse_Actions__c> lstAdverseReasons {get; set;}
    public List<Score_Factors__C> lstScoreFactors {get; set;}
    public List<Score_Factors__C> lstScoreFactorsPart1 {get; set;}
    public Id appId {get; set;}
    public boolean oln {get;set;}
    public List<String> olnReasons {get;set;}
    private ApexPages.StandardController stdCtrl {get; set;}
    public String borrowersFirstName{get;set;}
    public List<Credit_union_list__c> cuList {get;set;} //added as part of CRM-617
    public boolean IsUnableToVerifyEmpInfo {get; set;}

    /*public AdverseActionController(ApexPages.StandardController std) {
      stdCtrl = std;
      getadverseResults ();
    }*/

    public AdverseActionController(){
        MW_Settings__c mwsetting = MW_Settings__c.getOrgDefaults();
        appId = ApexPages.currentPage().getParameters().get('id');
        System.debug('...Constructor.... ' +appId );
        IsUnableToVerifyEmpInfo = false;

        if(adverseResults == null && appId != null){
            System.debug('...App Not null....' );
            //app.OLN_Stacker_Status__c >= mwsetting.OLN_Stacker_Threshold__c
            List<genesis__Applications__c> apps = [Select id,name,OLN_Stacker_Status__c from genesis__applications__c where id=:appId];

            if(apps!=null && apps.size()>0) {
                if(apps[0].OLN_Stacker_Status__c !=null && apps[0].OLN_Stacker_Status__c>=mwsetting.OLN_Stacker_Threshold__c) {
                    oln = true;
                    MW_Settings__c mw = MW_Settings__c.getOrgDefaults();
                    if(mw.OLN_Stacker_Decline_reasons__c !=null) {
                        olnReasons = mw.OLN_Stacker_Decline_reasons__c.split('&&');
                    }
                } else {
                    oln = false;
                }
                adverseResults = new adverseActionResults(
                [Select id, name, //genesis__Account__r.Borrower_s_First_Name__c,
                        //genesis__Account__r.Borrower_s_Last_Name__c,
                        genesis__Account__r.Name,
                        genesis__Account__r.address_1__c,
                        genesis__Account__r.address_2__c,
                        genesis__Account__r.City__c,
                        genesis__Account__r.State__c,genesis__Account__r.ZIP_Code__c, genesis__Loan_Amount__c,
                        Manual_Adverse_Action_Decline__r.Name,
                        manual_adverse_action_decline__r.reason__c,
                (SELECT Id, No_Hit__c FROM Adverse__r),
                (select FICO__C, Bureau_Inquiry_Date__c from Credit_Policy__r)
                from genesis__Applications__c
                where id =: appId ]);

                System.debug('...Results....' +adverseResults  );
                System.debug('...Results....' +adverseResults.app.manual_adverse_action_decline__c  );
                if(adverseResults.app.genesis__Account__r.Name != null){
                    String[] nameArr = adverseResults.app.genesis__Account__r.Name.split(' ');
                    borrowersFirstName = nameArr[0];
                }

                if(string.isNotEmpty(adverseResults.app.Manual_Adverse_Action_Decline__r.Name) &&
                        adverseResults.app.Manual_Adverse_Action_Decline__r.Name == 'manual_decline_unable_to_verify_employment_empinfo') {
                    IsUnableToVerifyEmpInfo = true;
                }
            }
        }

        //CRM-617 change starts from here
        Map<String,Credit_union_list__c> allCUs = Credit_union_list__c.getAll();
        cuList = allCUs.values();
        //CRM-617 change ends here

    }

    public String getmanualDecline () {
        return getadverseResults(appId).app.manual_adverse_action_decline__r.reason__c ;

    }

    public boolean getolnValue () {
        boolean res = false;
        MW_Settings__c mw = MW_Settings__c.getOrgDefaults();
        List<genesis__Applications__c> apps = [Select id,name,OLN_Stacker_Status__c from genesis__applications__c where id=:appId];
        if(apps!=null && apps.size()>0) {
            if(apps[0].OLN_Stacker_Status__c !=null && apps[0].OLN_Stacker_Status__c>=mw.OLN_Stacker_Threshold__c) {
                res = true;

                if(mw.OLN_Stacker_Decline_reasons__c !=null) {
                    olnReasons = mw.OLN_Stacker_Decline_reasons__c.split('&&');
                }
            } else {
                res = false;
            }
        }
        return res;

    }

    public adverseActionResults getadverseResults (Id appId) {
        //appId = ApexPages.currentPage().getParameters().get('id');
        System.debug('...Constructor.... ' +appId );
        if(adverseResults == null && appId != null){
            System.debug('...App Not null....' );
            adverseResults = new adverseActionResults(
            [Select id, name, //genesis__Account__r.Borrower_s_First_Name__c,
                    //genesis__Account__r.Borrower_s_Last_Name__c,
                    genesis__Account__r.Name,
                    genesis__Account__r.City__c,
                    manual_adverse_action_decline__c,
                    Manual_Adverse_Action_Decline__r.Name,
                    manual_adverse_action_decline__r.reason__c,
                    genesis__Account__r.State__c,genesis__Account__r.ZIP_Code__c, genesis__Loan_Amount__c,
            (SELECT Id, No_Hit__c FROM Adverse__r),
            (select FICO__C, Bureau_Inquiry_Date__c from Credit_Policy__r)
            from genesis__Applications__c
            where id =: appId LIMIT 1]);
            System.debug('...Results....' +adverseResults  );
            if(adverseResults.app.genesis__Account__r.Name != null){
                String[] nameArr = adverseResults.app.genesis__Account__r.Name.split(' ');
                borrowersFirstName = nameArr[0];
            }
        }
        return adverseResults ;
    }

    public List<Adverse_Actions__c> getAdverseActionReasons(){
        lstAdverseReasons = new List<Adverse_Actions__c>();
        if(appId != null){
            String reason = 'Your current credit score doesn’t meet our minimum score requirement.';
            if(lstScoreFactorsPart1 != null && lstScoreFactorsPart1.size() > 0){
                lstAdverseReasons = [Select id, Description__c, Adverse_action_name__c,Reason__c
                from Adverse_Actions__c where Application__c=: appId LIMIT 4];    //pallavi
                integer itr = 0;
                /*while(itr < lstAdverseReasons.size()){  //pallavi(commented for PSPS-4662)
                    System.debug('lstAdverseReasons[itr].Reason__c: ...'+ lstAdverseReasons[itr].Reason__c);
                    List<String> rs = lstAdverseReasons[itr].Reason__c.split(' ');

               /*     if(lstAdverseReasons[itr].Reason__c == reason
                        ||
                        lstAdverseReasons[itr].Reason__c.equalsIgnoreCase(reason)
                        ){  */

                /* if((rs[0] == 'Your' && rs[1] == 'credit' && rs[2] == 'score' && rs[3] == 'does') || (rs[0] == 'Your' && rs[1] == 'current' && rs[2] == 'credit' && rs[3] == 'score')){
                     System.debug('InsideIFAdverseReasons : ...'+ lstAdverseReasons );
                     lstAdverseReasons.remove(itr);

                 }
                 itr++;
             }*/
            }
            else {
                lstAdverseReasons = [Select id, Description__c, Adverse_action_name__c, Reason__c
                from Adverse_Actions__c where Application__c=: appId LIMIT 4];    //pallavi
                System.debug('InsideElseAdverseReasons : ...'+ lstAdverseReasons );

            }


        }

        System.debug('AdverseReasons : ...'+ lstAdverseReasons );
        return lstAdverseReasons;
    }

    public List<Score_Factors__c> getScoreFactorsPart1(){
        boolean flag= false;
        //List<Adverse_Actions__c> lstAdverseReasons = getAdverseActionReasons();
        List<Adverse_Actions__c> lstAdverseActions = [Select id, Description__c, Adverse_action_name__c,Reason__c
        from Adverse_Actions__c
        where Application__c=: appId
        and Reason__c != 'Your current credit score doesn’t meet our minimum score requirement.'];

        for(Adverse_Actions__c adverse:lstAdverseActions ) {
            if(adverse.Adverse_action_name__c.equalsIgnoreCase('post_bureau_fico_score_below_min') || adverse.Adverse_action_name__c.equalsIgnoreCase('risk_model_fico_score_low') || adverse.Adverse_action_name__c.equalsIgnoreCase('expiration_decline_insufficient_fico_counteroffer') )
                flag = true;
        }
        /*for(Adverse_Actions__c adverse:lstAdverseReasons) {
            if(adverse.Adverse_action_name__c.equalsIgnoreCase('post_bureau_fico_score_below_min') || adverse.Adverse_action_name__c.equalsIgnoreCase('risk_model_fico_score_low') || adverse.Adverse_action_name__c.equalsIgnoreCase('expiration_decline_insufficient_fico_counteroffer') )
                flag = true;
        }*/
        lstScoreFactorsPart1 = new List<Score_Factors__c>();
        if(appId != null && flag ){

            lstScoreFactorsPart1 = [Select id, Code__c, Description__c, Rank__c from Score_Factors__c where Application__c =: appId and description__c!='Too many recent inquiries.'];
        }
        System.debug('ScoreFactors : ...'+ lstScoreFactorsPart1 );
        return lstScoreFactorsPart1;
    }

    public List<Score_Factors__c> getScoreFactors(){
        lstScoreFactors = new List<Score_Factors__c>();
        if(appId != null){

            lstScoreFactors = [Select id, Code__c, Description__c, Rank__c from Score_Factors__c where Application__c =: appId];
        }
        System.debug('ScoreFactors : ...'+ lstScoreFactors );
        return lstScoreFactors;
    }




    /**
    * Adverse Action Wrapper class
    * */
    public class adverseActionResults {
        public genesis__Applications__c app{get; set;}
        public Decimal ficoScore{get; set;}
        public String bureauDate{get;set;}
        public Boolean isHit{get; set;}
        public String AdverseFactor{get; set;}

        public adverseActionResults(genesis__Applications__c app){
            this.app = app;
            if(app.Credit_Policy__r!=null && app.Credit_Policy__r.size() > 0){
                ficoScore = app.Credit_Policy__r[0].FICO__C;
                bureauDate = app.Credit_Policy__r[0].Bureau_Inquiry_Date__c;
                System.debug('FICO Score: ...'+ ficoScore );
            } else {
                ficoScore = 0;
                bureauDate = String.valueOf(Date.today());
            }
            if(app.Adverse__r!=null && app.Adverse__r.size() > 0){
                isHit = app.Adverse__r[0].No_Hit__c;
            }
            List<Adverse_Actions__c> advFactor = [Select id, Description__c, Adverse_action_name__c, Reason__c
            from Adverse_Actions__c where Application__c=: app.Id];
            if(advFactor.size() > 0){
                AdverseFactor = advFactor[0].Adverse_action_name__c;
                System.debug('Adverse Action Name:....' + AdverseFactor);
            }
        }
    }
}