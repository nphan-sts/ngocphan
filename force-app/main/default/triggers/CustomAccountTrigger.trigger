/* ****************Modification History*****************************************************************
 * Created by      Date        JIRA number
 *    Pallavi      2020/05/15      CRM-619 if first name or last name changes, account name will also change
 *     Anusha     2020/07/24     CRM - 748 Update TLO URL when PII changed (rematch)
 *    Pallavi      2020/10/30      CRM-979 Remove test class condition from CustomAccountTrigge
 ******************Modification History*****************************************************************/
trigger CustomAccountTrigger on Account(after insert, after update, before insert, before update) {
    if (!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c) {
        /*|| ! TestTriggerParameter.disableTriggerTest*/
        // CRM-979 (commented TestTriggerParameter.disableTriggerTest because it's not needed)

        if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
            for (Account acc : Trigger.new) {
                if (acc.loan__SOCIAL_SECURITY_NUMBER__c != null) {
                    acc.ints__SSN__c = '*******' + acc.loan__SOCIAL_SECURITY_NUMBER__c.right(4);
                    acc.Encrypted_SSN__c = '*******' + acc.loan__SOCIAL_SECURITY_NUMBER__c.right(4);
                }
                /*CRM-619*/
                if (Trigger.isUpdate) {
                    if (
                        (acc.peer__First_Name__c != null) &&
                        ((acc.peer__First_Name__c != Trigger.oldMap.get(acc.id).peer__First_Name__c) ||
                        (acc.peer__Last_Name__c != Trigger.oldMap.get(acc.id).peer__Last_Name__c))
                    ) {
                        if (acc.peer__Last_Name__c == null)
                            acc.name = acc.peer__First_Name__c;
                        else
                            acc.name = acc.peer__First_Name__c + ' ' + acc.peer__Last_Name__c;
                    }
                } else if (Trigger.isInsert) {
                    acc.name = acc.peer__First_Name__c + ' ' + acc.peer__Last_Name__c;
                }

                /*CRM-619*/
                /*
                if(Test.isRunningTest()) {
                    acc.loan__social_security_number__c = string.valueOf(math.random()).right(9);  //LOS-63
                    acc.peer__First_Name__c ='test';
                    acc.peer__Last_Name__c = 'account';
                }
                */
            }
        }

        if (Trigger.isAfter) {
            /*
             *Redecision Logic for Account
             *
             */
            if (Trigger.isUpdate) {
                RedecisionCntrl.accRedecisionTrigger(Trigger.oldMap, Trigger.newMap);

                //CRM-748 start
                Map<id, Account> oldAccMap = Trigger.oldMap;
                List<Id> accIdList = new List<Id>();
                for (Account acc : Trigger.New) {
                    Account oldAcc = oldAccMap.get(acc.Id);
                    if (
                        (oldAcc.Name != null &&
                        acc.Name != oldAcc.Name) ||
                        (oldAcc.peer__First_Name__c != null &&
                        acc.peer__First_Name__c != oldAcc.peer__First_Name__c) ||
                        (oldAcc.peer__Last_Name__c != null &&
                        acc.peer__Last_Name__c != oldAcc.peer__Last_Name__c) ||
                        (oldAcc.City__c != null &&
                        acc.City__c != oldAcc.City__c) ||
                        (oldAcc.State__c != null &&
                        acc.State__c != oldAcc.State__c) ||
                        (oldAcc.ZIP_Code__c != null &&
                        acc.ZIP_Code__c != oldAcc.ZIP_Code__c) ||
                        (oldAcc.Phone != null &&
                        acc.Phone != oldAcc.Phone) ||
                        (oldAcc.peer__Date_of_Birth__c != null &&
                        acc.peer__Date_of_Birth__c != oldAcc.peer__Date_of_Birth__c) ||
                        (oldAcc.Bureau_Date_of_Birth__c != null &&
                        acc.Bureau_Date_of_Birth__c != oldAcc.Bureau_Date_of_Birth__c) ||
                        (oldAcc.ints__SSN__c != null &&
                        acc.ints__SSN__c != oldAcc.ints__SSN__c) ||
                        (oldAcc.Encrypted_SSN__c != null &&
                        acc.Encrypted_SSN__c != oldAcc.Encrypted_SSN__c)
                    ) {
                        accIdList.add(acc.Id);
                    }
                }
                System.debug('Account ids for which one or more records are updated: ' + accIdList);

                List<genesis__applications__c> appForAcc = [
                    SELECT id, name
                    FROM genesis__applications__c
                    WHERE genesis__account__c IN :accIdList
                ];
                if (appForAcc != null && appForAcc.size() > 0) {
                    System.debug('Calling TLOLinkConfig method to update TLO Link on Identity Verification Record');
                    List<Id> appIdList = new List<Id>();
                    for (genesis__applications__c application : appForAcc) {
                        appIdList.add(application.Id);
                    }
                    TLOLinkConfig tloLinkConfigObj = new TLOLinkConfig();
                    tloLinkConfigObj.updateTLOLink(appIdList);
                }
                //CRM-748 end
            }

            List<Id> acclist = new List<Id>();
            for (Account acc : Trigger.New) {
                if (!String.isBlank(acc.ints__SSN__c)) {
                    acclist.add(acc.Id);
                }
            }

            Map<String, String> appAccMap = new Map<String, String>();

            for (genesis__applications__c appList : [
                SELECT id, Name, genesis__account__c, genesis__status__c
                FROM genesis__applications__c
                WHERE
                    genesis__account__c IN :acclist
                    AND (genesis__status__c != :'REJECTED'
                    OR genesis__status__c != :'declined'
                    OR genesis__status__c != :'pre_funding'
                    OR genesis__status__c != :'funded')
            ]) {
                appAccMap.put(String.valueOf(appList.genesis__account__c), String.valueOf(appList.id));
            }

            if (appAccMap.size() > 0) {
                System.debug('Inside the Condition ...........');
                if (Trigger.isInsert) {
                    for (String accId : appAccMap.keySet()) {
                        System.debug('Inside the trigger' + appAccMap.get(accId) + ' also the accountId' + accId);
                        if (appAccMap.get(accId) != null) {
                            TalxIntegration.CallTalx(appAccMap.get(accId), accid);
                        }
                    }
                }
                if (Trigger.isUpdate) {
                    for (Account acc : Trigger.New) {
                        if (Trigger.oldMap.get(acc.Id).ints__SSN__c != Trigger.newMap.get(acc.Id).ints__SSN__c) {
                            System.debug('Inside the trigger' + appAccMap.get(acc.Id) + ' also the accountId' + acc.Id);
                            if (appAccMap.get(acc.Id) != null) {
                                TalxIntegration.CallTalx(appAccMap.get(acc.Id), acc.Id);
                            }
                        }
                    }
                }
            }

            //LPC-1120 notify LPC team when the amount of Available Fund field goes lower than $1 M
            if (!TriggerLocks.triggerAccount_afterUpdate) {
                AccountTriggerHandler.sendSlackNotification(Trigger.New);
                TriggerLocks.triggerAccount_afterUpdate = true;
            }
        }
    }
}