public class MW_Utilities {

    public static boolean isFrontEndUserUpdate(){
        List<String> userFilter = MW_Settings__c.getInstance().FE_User_Filter__c.split(',');
        return userFilter.contains(UserInfo.getUserName());
    }

    public static List<String> getPicklistValues(SObjectField field){
        List<String> toList = new List<String>();
        Schema.DescribeFieldResult fieldResult = field.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry value : values) {
            toList.add(value.getLabel());
        }
        return toList;
    }

    public static void clearDCPForEBP(Approved_Offer__c offer) {
        if (getPicklistValues(Pricing_Offer__c.EBP_Offer_Code__c).contains(offer.EBP_Offer_Code__c)) {
            CustomTriggerOnApplicationHandler.payAtFundingForUpdate(offer.Application__r.Id);
        }
    }
}