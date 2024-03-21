/* ****************Modification History*****************************************************************
 * Modified by      Date            JIRA number
 *Bhavya Maliwal  2022/07/07    LSP-881 If Bank Account gets Inactive update the APS and mark it inactive.
 ******************Modification History*****************************************************************/
public with sharing class CustomBankAccountHandler {
    /*Created By : Bhavya Maliwal
Method name : updateAPSInactive
Purpose : Deactivate (mark inactive) the APS if Bank Account gets Inactive.
*/

    List<loan__Bank_Account__c> newRecords;
    List<loan__Bank_Account__c> oldRecords;
    Map<Id, loan__Bank_Account__c> oldMap;
    Map<Id, loan__Bank_Account__c> newMap;

    public CustomBankAccountHandler(
        List<loan__Bank_Account__c> pNewRecords,
        List<loan__Bank_Account__c> pOldRecords,
        Map<Id, loan__Bank_Account__c> pNewMap,
        Map<Id, loan__Bank_Account__c> pOldMap
    ) {
        this.newRecords = pNewRecords;
        this.oldRecords = pOldRecords;
        this.oldMap = pOldMap;
        this.newMap = pNewMap;
    }
    public void beforeInsert() {
        applyDefault();
    }
    public void beforeUpdate() {
        applyDefault();
    }
    public void afterUpdate() {
        Savepoint spDML = Database.setSavepoint();
        try {
            List<loan__Bank_Account__c> baList = new List<loan__Bank_Account__c>();
            List<loan__Automated_Payment_Setup__c> apsList = new List<loan__Automated_Payment_Setup__c>();
            for (loan__Bank_Account__c ba : newRecords) {
                if (!ba.loan__Active__c && oldMap.get(ba.id).loan__Active__c == true)
                    baList.add(ba);
            }
            if (baList.size() > 0) {
                deactivateBankAccount(baList);
            }
            //end LSP-881
            MW_SynchronizeHandler.postBankAccountDetailsOnWebHook(oldMap, newMap);
        } catch (Exception e) {
            system.debug(e + '    ' + e.getMessage() + '      ' + e.getLineNumber());
            MW_LogUtility.error('CustomBankAccountHandler', '', '', 'afterUpdate', e);

            Database.rollback(spDML);
        }
    }

    public void beforeDelete() {
        Savepoint spDML = Database.setSavepoint();
        try {
            deactivateBankAccount(oldRecords);
            MW_BankAccountUpdateSync.sendDeletesToMatcha(oldMap);
        } catch (Exception e) {
            system.debug(e + '    ' + e.getMessage() + '      ' + e.getLineNumber());
            MW_LogUtility.error('CustomBankAccountHandler', '', '', 'beforeDelete', e);

            Database.rollback(spDML);
        }
    }
    private void applyDefault() {
        for (loan__Bank_Account__c ba : newRecords) {
            if (ba.Unmasked_Bank_Account_Number__c != null) {
                ba.loan__Bank_Account_Number__c = '*******' + ba.Unmasked_Bank_Account_Number__c.right(4);
            } else {
                ba.loan__Bank_Account_Number__c = ba.Unmasked_Bank_Account_Number__c;
            }
            if (ba.Account_Number__c != null) {
                ba.Account_Number_Con_Info__c = '*******' + ba.Account_Number__c.right(4);
            } else {
                ba.Account_Number_Con_Info__c = ba.Account_Number__c;
            }
        }
    }

    private void deactivateBankAccount(List<loan__Bank_Account__c> baList) {
        List<loan__Automated_Payment_Setup__c> apsList = [
            SELECT id, loan__Active__c
            FROM loan__Automated_Payment_Setup__c
            WHERE loan__Bank_Account__c IN :baList AND loan__Active__c = TRUE
        ];
        for (loan__Automated_Payment_Setup__c aps : apsList) {
            aps.loan__Active__c = false;
        }
        update apsList;
    }
}