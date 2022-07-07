/* ****************Modification History*****************************************************************
* Modified by      Date            JIRA number
*Bhavya Maliwal  2022/07/07    LSP-881 If Bank Account gets Inactive update the APS and mark it inactive.
******************Modification History*****************************************************************/
public with sharing class CustomBankAccountHandler {
    /*Created By : Bhavya Maliwal
Method name : updateAPSInactive
Purpose : Deactivate (mark inactive) the APS if Bank Account gets Inactive.
*/
    public void updateAPSInactive(List<loan__Bank_Account__c> newList, Map<id,loan__Bank_Account__c> oldMapData){
         set<id> bankAccountID=new set<id>();
            List<loan__Automated_Payment_Setup__c> apsList=new List<loan__Automated_Payment_Setup__c>();
            for(loan__Bank_Account__c ba: newList){
                if(!ba.loan__Active__c && oldMapData.get(ba.id).loan__Active__c ==true) 
                    bankAccountID.add(ba.id);
            }
            if(bankAccountID!=null){
            for( loan__Automated_Payment_Setup__c aps :[Select id,loan__Active__c from loan__Automated_Payment_Setup__c 
                                                        where loan__Bank_Account__c in: bankAccountID 
                                                        and loan__Active__c=true ]){
                                                            aps.loan__Active__c=false;
                                                            apsList.add(aps);
                                                        }
            if(apsList.size()>0)
                update apsList;
            } 
    }

}