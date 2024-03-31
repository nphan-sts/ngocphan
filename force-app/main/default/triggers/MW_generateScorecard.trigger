trigger MW_generateScorecard on Neo_Verify__c (after insert, after update) {

    if (!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c) {
        if (trigger.isAfter) {
            if (trigger.isInsert || trigger.isUpdate) {
                for (Neo_Verify__c neo : trigger.new) {
                    if (neo.NSF_OD__c != null && neo.Application__c != null) {
                        String res = genesis.ScorecardAPI.generateScorecard(neo.Application__c);
                    }
                }
            }
        }
    }
}