public class MW_Utilities {

    public static boolean isFrontEndUserUpdate(){
        List<String> userFilter = MW_Settings__c.getInstance().FE_User_Filter__c.split(',');
        return userFilter.contains(UserInfo.getUserName());
    }
}