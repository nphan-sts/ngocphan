global class MW_UserPackageLicense implements Database.Batchable<sobject>{
    
    global static list<MW_general_record__mdt> mwList = [select MasterLabel,Value__c, Module_Name__c from MW_general_record__mdt where Module_Name__c = 'UserPackageLicense'];
    global Database.Querylocator start (Database.BatchableContext BC) {
        
        list<string> valueList = new list<string>();
        for(MW_general_record__mdt vList: mwList){
            valueList.add(vList.Value__c);
            system.debug('valueList -----------' + valueList);
        }
        String commaSepratedList ='';
        for(String str : valueList)
        {
            commaSepratedList += str + ',' ;
        }
        commaSepratedList = commaSepratedList.subString(0,commaSepratedList.length()-1);
        system.debug('comma seprated list is---- '+commaSepratedList);
        String soqlQuery = 'select Name,'+commaSepratedList+' from user where profile.name!=null' + (Test.isRunningTest()?' LIMIT 200':'');
        system.debug('soqlQuery -------------' + soqlQuery);
        list<user> obj = database.query(soqlQuery);
        system.debug('obj -----' + obj) ;
        system.debug('obj size ------'+ obj.size());
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute (Database.BatchableContext BC, List<user> scope) {
        
        map<String,string> NameSpacePrefixFieldAPIMap = new map<String,string>();
        for(MW_general_record__mdt mr:mwList)
        {
            NameSpacePrefixFieldAPIMap.put(mr.MasterLabel,mr.Value__c);
            System.Debug('mr------------------------- mr '+ mr);
        }
        System.Debug('NameSpacePrefixFieldAPIMap------------>'+ NameSpacePrefixFieldAPIMap);
        map<string,list<string>> userAndPackageLicenseMap = new map<string,list<string>> ();
        system.debug('userAndPackageLicenseMap----'+userAndPackageLicenseMap);
        for(UserPackageLicense userRecord : [SELECT Userid,PackageLicense.NamespacePrefix from UserPackageLicense Where PackageLicense.NamespacePrefix IN:NameSpacePrefixFieldAPIMap.keySet()])
        {
            if(userAndPackageLicenseMap.containsKey(userRecord.Userid)){
                List<string> existingPrefixList = new list<string>();
                system.debug('existingPrefixList--------' +existingPrefixList);
                existingPrefixList.addAll(userAndPackageLicenseMap.get(userRecord.Userid));  
                existingPrefixList.add(userRecord.PackageLicense.NamespacePrefix) ;   
                userAndPackageLicenseMap.put(userRecord.Userid,existingPrefixList);
                system.debug('existingPrefixList--------' +existingPrefixList);
                system.debug('userAndPackageLicenseMap in If-----' + userAndPackageLicenseMap) ;
            }else{
                userAndPackageLicenseMap.put(userRecord.Userid,new list<string>{userRecord.PackageLicense.NamespacePrefix});
                system.debug('userAndPackageLicenseMap in else-----' + userAndPackageLicenseMap) ;
            }
        }
        system.debug('userAndPackageLicenseMap----'+userAndPackageLicenseMap);
        list<user> updatedUser  = new list<user>();
        system.debug('updatedUser---------'+updatedUser);
        
        for(user usr: scope)
        {
            system.debug('usr in for loop ------'+ usr );
            boolean userfieldUpdated = false;
            if(userAndPackageLicenseMap.containskey(usr.id)){
                for(string nameSpacePrefix : NameSpacePrefixFieldAPIMap.keyset()){
                    if((userAndPackageLicenseMap.get(usr.Id)).contains(nameSpacePrefix)){
                        //&& !Boolean.valueOf(usr.get(NameSpacePrefixFieldAPIMap.get(nameSpacePrefix)))
                        if((usr.get(NameSpacePrefixFieldAPIMap.get(nameSpacePrefix)))==false){
                        usr.put(NameSpacePrefixFieldAPIMap.get(nameSpacePrefix),true);
                        system.debug('usr.put(NameSpacePrefixFieldAPIMap.get(nameSpacePrefix)');
                        userfieldUpdated = true;
                        system.debug('usr1 ------'+ usr);
                        } 
                    }
                    
                    else{
                        if((usr.get(NameSpacePrefixFieldAPIMap.get(nameSpaceprefix))) == false)
                        system.debug('usr.get(NameSpacePrefixFieldAPIMap.get(nameSpacePrefix))');   
                        usr.put(NameSpacePrefixFieldAPIMap.get(nameSpaceprefix),false);
                        system.debug('usr -------- inside else'+ usr);
                        userfieldUpdated = true;
                        
                    }
                    
                }
            }
            if(userfieldUpdated){
                system.debug('inside if 3');
                updatedUser.add(usr);
                system.debug('inside if 3'+ usr);
            }
            
            else{
                
                for(string fieldAPI:NameSpacePrefixFieldAPIMap.values())
                {
                    system.debug('fieldAPI ------'+ fieldAPI);
                    if((usr.get(fieldAPI)) == true){
                    usr.put(fieldAPI,false);
                    system.debug('updatedUser2 ------'+ updatedUser);
                    updatedUser.add(usr); 
                    system.debug('final updatedUser .  list' + updatedUser);
                    }
                }
            }   
        }
        
        set<user> updatedUserSet = new set<user>(updatedUser);
        updatedUser = new list<user>(updatedUserSet);
        update updatedUser;
        system.debug('updatedUserMap ------'+ updatedUser);
        system.debug('updatedUserMap ------'+ updatedUser.size());
    }
    
    global void finish(Database.BatchableContext BC) {}
}