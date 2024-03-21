public Class checkRecursive{
    private static boolean isInvestorAllocationFieldsUpdate = true;
    
    public static boolean runInvestorAllocationFieldsUpdate(){
        if(isInvestorAllocationFieldsUpdate ){
             isInvestorAllocationFieldsUpdate =false;
             return true;
        }
        else{
            return isInvestorAllocationFieldsUpdate ;
        }
    }
    
    private static boolean isInvestorAllocation = true;
    
    public static boolean runInvestorAllocation(){
        if(isInvestorAllocation){
            isInvestorAllocation =false;
            return true;
        }
        else{
            return isInvestorAllocation;
        }
    }    
    
    private static boolean isApplicationAttachmentHandler  = true;
    
    public static boolean runApplicationAttachmentHandler(){
        if(isApplicationAttachmentHandler ){
            isApplicationAttachmentHandler  =false;
            return true;
        }
        else{
            return isApplicationAttachmentHandler ;
        }
    }
}