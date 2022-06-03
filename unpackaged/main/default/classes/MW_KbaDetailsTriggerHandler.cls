public class MW_KbaDetailsTriggerHandler {

    final List<KBA_Details__c> newRecords;
    final Map<Id, KBA_Details__c> oldMap;
    final Map<Id, KBA_Details__c> newMap;
    

    public static boolean avoidrecursive = true;

    public MW_KbaDetailsTriggerHandler(List< KBA_Details__c> pNewRecords, Map<Id, KBA_Details__c> pNewMap, Map<Id, KBA_Details__c> pOldMap) {
        this.newRecords = pNewRecords;
        this.oldMap = pOldMap;
        this.newMap = pNewMap;
    }

    /*
    public void beforeInsert() {
    }
    public void beforeUpdate() {
    }
    */
    public void afterUpdate() {
          
        
        Boolean isUpdateAppRequired = false;
        for (KBA_Details__c kba : newRecords) {
            Id appId; 
            KBA_Details__c oldKba = oldMap.get(kba.Id);
            appId = kba.Application__c ;
            //LOP-597
             if (kba.Precise_ID_Overall_SCore__c == 9012 && ( kba.Precise_ID_Overall_SCore__c != oldKba.Precise_ID_Overall_SCore__c) ){
              DocumentReductionRules.payStubReduction(appId);   
            }
            
            if (kba.Precise_ID_First_Payment_Default__c != oldKba.Precise_ID_First_Payment_Default__c
                    || kba.Precise_ID_Decision_KIQ__c != oldKba.Precise_ID_Decision_KIQ__c
                    || kba.Precise_ID_Overall_SCore__c != oldKba.Precise_ID_Overall_SCore__c) {

                isUpdateAppRequired = true;
                break;
            }
        }

        If (isUpdateAppRequired == true) {
            
            UpdateApplications(newRecords, newMap, oldMap, null, null, null);
        }
    }

    public void afterInsert() {
        
         //LOP-597
         for (KBA_Details__c kba : newRecords) {
             Id appId;
             appId = kba.Application__c ;
             If(kba.Precise_ID_Overall_SCore__c == 9012){
                DocumentReductionRules.payStubReduction(appId);   
             }
        }
         
        UpdateApplications(newRecords, newMap, oldMap, null, null, null);
        
    }

    Public static void UpdateApplications(List<KBA_Details__c> pListKba, Map<Id, KBA_Details__c> pMapNewKbaDetails,
            Map<Id, KBA_Details__c> pMapOldKbaDetails, List<genesis__Employment_Information__c> pListEmpInfo,
            Map<Id, genesis__Employment_Information__c> pMapNewEmpInfo, Map<Id, genesis__Employment_Information__c> pMapOldEmpInfo) {

        If (pListKba == null && pListEmpInfo == null) {
            return;
        }

        Set<Id> setAppIds = new Set<Id>();

        If (pListKba != null) {
            For (KBA_Details__c kba : pListKba) {
                setAppIds.Add(kba.Application__c);
            }
        } Else {
            For (genesis__Employment_Information__c emp : pListEmpInfo) {
                setAppIds.Add(emp.genesis__Application__c);
            }
        }

        Map<Id, KBA_Details__c> mapKba = new Map<Id, KBA_Details__c>();

        If (pListKba != null) {
            for (KBA_Details__c kba : pListKba) {
                mapKba.put(kba.Application__c, kba);
            }
        } Else {
            List<KBA_Details__c> listKba = [
                    SELECT Id, Name, CreatedDate, Account__c, Application__c, Id_Analytics_Score__c, IsKBA_06__c,
                            IsKBA_18__c, Precise_ID_Decision_KIQ__c, Precise_ID_Decision__c, Precise_ID_Overall_SCore__c,
                            Precise_ID_Validation__c, Precise_ID_First_Payment_Default__c, Application__r.TalxSalary__c,
                            Application__r.Fraud_Tag_Count__c, Application__r.Monthly_Housing_Payment_App__c
                    FROM KBA_Details__c
                    WHERE Application__c IN :setAppIds
            ];

            for (KBA_Details__c kba : listKba) {
                mapKba.put(kba.Application__c, kba);
            }
        }

        List<genesis__Applications__c> apps = [
                SELECT Id, Verification_Complexity__c, Employment_Status__c, Pricing_Tier__c, TalxSalary__c,
                        Annual_Individual_Income_App__c, Monthly_Housing_Payment_App__c, Fraud_Tag_Count__c
                FROM genesis__Applications__c
                WHERE Id IN :setAppIds
        ];

        Map<Id, genesis__Employment_Information__c> mapEmpInformations = new Map<Id, genesis__Employment_Information__c>();

        If (pMapNewEmpInfo != null) {
            for (genesis__Employment_Information__c emp : pListEmpInfo) {
                mapEmpInformations.put(emp.genesis__Application__c, emp);
            }
        } Else {
            List<genesis__Employment_Information__c> listEmpInformations = [
                    SELECT Id, genesis__Number_of_years_on_job__c, genesis__Application__c, Income_Include_Bonuses_or_Commissions__c
                    FROM genesis__Employment_Information__c
                    WHERE genesis__Application__c IN :setAppIds AND Neo_Verify__c = NULL
            ];

            for (genesis__Employment_Information__c emp : listEmpInformations) {
                mapEmpInformations.put(emp.genesis__Application__c, emp);
            }
        }

        for (genesis__Applications__c app : apps) {
            /*
            Hard: if Precise ID score is 9012 or 9013 OR Precise ID FPD score <= 10 OR Employment Status is not Full-Time
            OR KIQ result is not "pass"
            (OR Employer is categorized as "high risk" industry - future)
            Very Easy: Pricing Tier is T1/T2/T3 AND TALX salary >= 0.85 * stated income AND Income does not include bonus or commission
            AND Stated housing payment >= $500 AND No automated fraud tag AND Employment status is Full Time
            AND Tenure >= 1 year AND Precise ID score is not 9012 or 9013 AND KIQ result is "pass"
            (AND Employer is not categorized as "high risk" industry - future)
            Easy: Pricing Tier is T1/T2/T3 AND Income does not include bonus or commission
            AND No automated fraud tag AND Employment status is Full Time AND
            Tenure >= 1 year AND Precise ID score is not 9012 or 9013 AND KIQ result is "pass"
            (AND Employer is not categorized as "high risk" industry - future)
            Regular: Any applications not categorized as "very easy", "easy" or "hard"
            */

            KBA_Details__c kba = mapKba.get(app.Id);
            genesis__Employment_Information__c empInfo = mapEmpInformations.get(app.Id);

            Decimal tenure = 0;
            Boolean incomeIncludeBnsOrComsn = false;
            if (empInfo != null) {
                tenure = empInfo.genesis__Number_of_years_on_job__c;
                incomeIncludeBnsOrComsn = empInfo.Income_Include_Bonuses_or_Commissions__c;
            }

            If (app != null && kba != null) {
                If (string.isEmpty(app.Employment_Status__c)
                        || (kba.Precise_ID_First_Payment_Default__c == null
                        && kba.Precise_ID_Decision_KIQ__c == null
                        && kba.Precise_ID_Overall_SCore__c == null)
                        ) {
                    continue;
                }
                
              If (kba.Precise_ID_Overall_SCore__c == 9012 || kba.Precise_ID_Overall_SCore__c == 9013
                        || kba.Precise_ID_First_Payment_Default__c <= 10 || app.Employment_Status__c != 'Full Time'
                        || kba.Precise_ID_Decision_KIQ__c != 'Accept') {
                                  
                    app.Verification_Complexity__c = 'Hard';
                            

                } Else If (
                        (app.Pricing_Tier__c == 't1' || app.Pricing_Tier__c == 't2' || app.Pricing_Tier__c == 't3')
                                && app.TalxSalary__c >= (0.85 * app.Annual_Individual_Income_App__c)
                                && incomeIncludeBnsOrComsn == false
                                && app.Monthly_Housing_Payment_App__c >= 500
                                && app.Fraud_Tag_Count__c == 0
                                && app.Employment_Status__c == 'Full Time'
                                && tenure >= 1 //Tenure
                                && (kba.Precise_ID_Overall_SCore__c != 9012 || kba.Precise_ID_Overall_SCore__c != 9013)
                                && kba.Precise_ID_Decision_KIQ__c == 'Accept'
                        ) {
                     
                    app.Verification_Complexity__c = 'Very Easy';
                } Else If (
                        (app.Pricing_Tier__c == 't1' || app.Pricing_Tier__c == 't2' || app.Pricing_Tier__c == 't3')
                                && incomeIncludeBnsOrComsn == false
                                && app.Fraud_Tag_Count__c == 0
                                && app.Employment_Status__c == 'Full Time'
                                && tenure >= 1 //Tenure
                                && (kba.Precise_ID_Overall_SCore__c != 9012 || kba.Precise_ID_Overall_SCore__c != 9013)
                                && kba.Precise_ID_Decision_KIQ__c == 'Accept'
                        ) {
                        
                    app.Verification_Complexity__c = 'Easy';
                } Else {
             
                    app.Verification_Complexity__c = 'Regular';
                }
            } //End of If (app != null && empInfo != null)
        }

        if (apps.size() > 0) {
            update apps;
        }
    }
}