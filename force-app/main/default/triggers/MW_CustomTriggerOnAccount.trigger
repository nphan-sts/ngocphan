/**
   * [MW_CustomTriggerOnAccount Trigger Sync the data with FE]
   * @date     2018-03-12
   * @datetime 2018-03-12
   * @return   
   */
trigger MW_CustomTriggerOnAccount on Account (after insert, after update,before insert,before update) {
    if(!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c && trigger.isAfter && trigger.isUpdate){
        MW_SynchronizeHandler.postAccountDetailsOnWebHook(trigger.OldMap,trigger.NewMap);
    }
}