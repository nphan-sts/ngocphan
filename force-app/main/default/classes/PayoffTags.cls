public class PayoffTags {
 public class TagsParameter{
        @InvocableVariable(label='apps' required=true)
        public Id apps;
        @InvocableVariable(label='tag'required=true)
        public String tag;
    }
    @invocablemethod(label='PayoffTags' description='trigger tags')
    Public static void appToPayoffTags(List<TagsParameter> tagList){
         System.debug(logginglevel.error,'-------------PayoffTags-----------');    //remove
         ID appID=tagList[0].apps;
         String TagCheck = tagList[0].tag;
                       
              
        //Add/Delete New Documents tag based on status of document category
        Boolean DocumentCheck=TagCheck.contains('Document');
        if(DocumentCheck)
        {List<genesis__Application_Document_Category__c> docList = new List<genesis__Application_Document_Category__c>();
         
         /*pallavi LOS-32*/
            //List<Application_Tags__c> SubmittedAppTags = new List<Application_Tags__c>();
            /*String currentUser = UserInfo.getName();
            User profileName = [SELECT profile.name from user where name =: currentUser LIMIT 1];
            System.debug(profileName.profile.name);*/
         /*pallavi LOS-32*/
        
        docList = [SELECT id,genesis__Status__c, genesis__Document_Category__c
                   from genesis__Application_Document_Category__c where genesis__Application__c =: appID and genesis__Status__c='SUBMITTED']; 
        
        
        List<Application_Tags__c> SubmittedAppTags = new List<Application_Tags__c>();
        SubmittedAppTags = [SELECT ID, Application_Tag__c, softDelete__c FROM Application_Tags__c where Application__c =: appID and Application_Tag__c = 'New Documents' and softDelete__c =false]; //LOS-121 
        
        /*if(!profileName.profile.name.equals('Verification Specialist')
          && !profileName.profile.name.equals('Verification Team Mgr')&& !profileName.profile.name.equals('Verification Team Specialist')
          && !profileName.profile.name.equals('Verification Team Sr Specialist')){ */   //LOS-32
            if(docList != null && !docList.isEmpty() && SubmittedAppTags != null && SubmittedAppTags.isEmpty()){
                
                
                Application_Tags__c at = new Application_Tags__c();
                at.Application_Tag__c = 'New Documents';
                at.Application__c = appID;
                Insert at;}
         //}
        
        if(SubmittedAppTags != null && !SubmittedAppTags.isEmpty() && docList != null && docList.isEmpty()){
            //delete [SELECT Id FROM Application_Tags__c WHERE Application__c =: appID AND Application_Tag__c =:'New Documents']; 
            For (Application_Tags__c Tapp : SubmittedAppTags){
            Tapp.softDelete__c = True;
              }
            update SubmittedAppTags;  
            }
        }
        //add New Interaction tag based on addition of application note
              
        Boolean InteractionCheck=TagCheck.contains('Interaction');
        if(InteractionCheck) 
        {List<Application_Tags__c> InteractionAppTags = new List<Application_Tags__c>();
        InteractionAppTags = [SELECT ID, Application_Tag__c FROM Application_Tags__c where Application__c =: appID and Application_Tag__c = 'New Interaction' and softDelete__c =false];    //LOS-121
        if(InteractionAppTags != null && InteractionAppTags.isEmpty()){
            Application_Tags__c at = new Application_Tags__c();
            at.Application_Tag__c = 'New Interaction';
            at.Application__c = appID;
            Insert at;}
        }
    }}