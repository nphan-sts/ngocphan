public with sharing class ObjectIterable implements Iterable<CustomObjectWrapper>{

    static String managedPackage = 'Managed Package Object: ';
    public Iterator<CustomObjectWrapper> iterator() {

        List<CustomObjectWrapper> customObjectWrapper = new List<CustomObjectWrapper>();
        Integer count = 0;

        Map<String, List<CustomObjectWrapper>> objectWrapperMap = new Map<String, List<CustomObjectWrapper>>();
        objectWrapperMap.put('Standard_Object', new List<CustomObjectWrapper>());
        objectWrapperMap.put('Custom_Object', new List<CustomObjectWrapper>());
        objectWrapperMap.put('Custom_Setting', new List<CustomObjectWrapper>());
        objectWrapperMap.put('Custom_Metadata_Types', new List<CustomObjectWrapper>());

        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
            String name = objTyp.getDescribe().getName();
            String label = objTyp.getDescribe().getLabel();

            if(!name.containsignorecase('history') && !name.containsignorecase('tag') &&
               !name.containsignorecase('share') && !name.containsignorecase('feed') && 
               !name.containsignorecase('group') && !name.containsignorecase('public') &&
               !name.equalsIgnoreCase('profile') && !name.equalsIgnoreCase('PermissionSetAssignment') &&
               !name.equalsIgnoreCase('QueueSobject') && !name.equalsIgnoreCase('UserRole') &&
               !name.equalsIgnoreCase('ContentDocumentLink') && !name.equalsIgnoreCase('Vote') &&
               !name.equalsIgnoreCase('ContentVersion') &&
               !name.equalsIgnoreCase('FieldPermissions') &&
               !name.equalsIgnoreCase('ScorecardAssociation') &&
               !name.equalsIgnoreCase('Scorecard') &&
               !name.equalsIgnoreCase('ScorecardMetric') &&
               !name.equalsIgnoreCase('IdeaComment') &&
               !name.equalsIgnoreCase('PermissionSetTabSetting') &&
               !name.equalsIgnoreCase('SetupEntityAccess') &&
               !name.equalsIgnoreCase('Event') &&
               !name.equalsIgnoreCase('Seller') &&
               !name.equalsIgnoreCase('Customer') &&
               !name.equalsIgnoreCase('VideoCall') &&
               !name.equalsIgnoreCase('VideoCallParticipant') &&
               !name.equalsIgnoreCase('BusinessBrand') &&
               !name.equalsIgnoreCase('PromptError') &&
               !name.equalsIgnoreCase('ProcessExceptionEvent') &&
               !name.equalsIgnoreCase('RecommendationResponse') &&
               !name.equalsIgnoreCase('FlowOrchestrationEvent') &&
               !name.equalsIgnoreCase('ProcessException') &&
               !name.equalsIgnoreCase('SetupAssistantStep') &&
               !name.equalsIgnoreCase('BriefcaseAssignment') &&
               !name.equalsIgnoreCase('LocationTrustMeasure') &&
               !name.equalsIgnoreCase('OauthCustomScopeApp') &&
               objTyp.getDescribe().isCreateable() && 
               !name.endsWithIgnoreCase('__b') &&
               !name.endsWithIgnoreCase('__e') 
              ){    

                
                    // if (count == 200) {//for testing
                    //     break;
                    // } 

                    if(name.countMatches('__') == 2) { 

                        //check if managed package object
                        String namespacePrefix = name.substring(0,name.indexOf('__'));

                        if (objectWrapperMap.get(namespacePrefix) == null) {
                            objectWrapperMap.put(namespacePrefix, new List<CustomObjectWrapper>{new CustomObjectWrapper(name, label, managedPackage + namespacePrefix, 0)});
                        }
                        else {
                            objectWrapperMap.get(namespacePrefix).add(new CustomObjectWrapper(name, label, managedPackage + namespacePrefix, 0));
                        }
                    }
                    else {
                        if (name.endsWith('__c')){
                            if (objTyp.getDescribe().isCustomSetting()) {
                                objectWrapperMap.get('Custom_Setting').add(new CustomObjectWrapper(name, label, 'Custom Setting',  0));
                            }
                            else {
                                objectWrapperMap.get('Custom_Object').add(new CustomObjectWrapper(name, label, 'Custom Object', 0));
                            }
                        }
                        else if (name.endsWith('__mdt')) {
                            objectWrapperMap.get('Custom_Metadata_Types').add(new CustomObjectWrapper(name, label, 'Custom Metadata Type', 0));
                        }
                        else{
                            objectWrapperMap.get('Standard_Object').add(new CustomObjectWrapper(name, label, 'Standard Object', 0));
                        }

                    }
                    count++;
               }
        }

        for(String key : objectWrapperMap.keySet()){ 
            List<CustomObjectWrapper> item = objectWrapperMap.get(key);
            customObjectWrapper.addAll(item);
        }

        return new ObjecIterator(customObjectWrapper);

    }
}