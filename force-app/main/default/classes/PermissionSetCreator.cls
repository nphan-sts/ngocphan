public class PermissionSetCreator {
    PermissionSet ps;
    boolean flag = true;
    public PermissionSetCreator(String PermissionSetName) {
        if (String.isNotBlank(PermissionSetName)) {
            try {
                ps = [SELECT Id, Name, label FROM PermissionSet WHERE Name = :PermissionSetName LIMIT 1];
            } catch (Exception e) {
                // Create new permissionSet
                System.debug('Creating new PermissionSet with the name ' + PermissionSetName);
                ps = new PermissionSet();
                ps.Name = PermissionSetName;
                ps.label = PermissionSetName;
                insert ps;
            }
            System.debug('PS -> ' + ps);
        }
    }
    
    public void grantReadOnlyPermissions(List<String> sObjList) {
        if (ps != null && sObjList.size() > 0) {
            List<ObjectPermissions> permissionList =  new List<ObjectPermissions>();
            for(String sObj : sObjList) {
                //insert Object permission for Addenda Record
                ObjectPermissions op = new ObjectPermissions();
                op.parentId = ps.Id;
                op.SobjectType = sObj;
                op.PermissionsRead = true;
                permissionList.add(op);
            }
            insert permissionList;
        }
    }
    
    public void grantRCEPermissions(List<String> sObjList) {
        if (ps != null && sObjList.size() > 0) {
            List<ObjectPermissions> permissionList =  new List<ObjectPermissions>();
            for(String sObj : sObjList) {
                //insert Object permission for Addenda Record
                ObjectPermissions op = new ObjectPermissions();
                op.parentId = ps.Id;
                op.SobjectType = sObj;
                op.PermissionsCreate = true;
                op.PermissionsRead = true;
                op.PermissionsEdit = true;
                permissionList.add(op);
            }
            insert permissionList;
        }
    }
    
    public void grantReadOnlyPermissionsWithFields(List<String> sObjList) {
        if (ps != null && sObjList.size() > 0) {
            List<ObjectPermissions> permissionList =  new List<ObjectPermissions>();
            List<fieldPermissions> fieldPermisstionList =  new List<fieldPermissions>();
            for(String sObj : sObjList) {
                ObjectPermissions op = new ObjectPermissions();
                op.parentId = ps.Id;
                op.SobjectType = sObj;
                op.PermissionsRead = true;
                //op.PermissionsViewAllRecords = true;
                permissionList.add(op);
                
                SObjectType currentObject = Schema.getGlobalDescribe().get(sObj);
                Map<String, Schema.SObjectField> fieldMap = currentObject.getDescribe().fields.getMap();
                //System.debug('SObj - > '+sObj+ ' Map -> '+fieldMap);
                
                if (fieldMap != null) {
                    for(Schema.SObjectField field : fieldMap.values()) {
                    Schema.DescribeFieldResult dscField = field.getDescribe();
                    if (dscField.isCustom() && dscField.isPermissionable()) {
                        fieldPermissions fp = new fieldPermissions();
                        fp.ParentId = ps.Id;
                        fp.SobjectType = sObj;
                        fp.Field = sObj + '.' + field;
                        fp.PermissionsRead = true;
                        fieldPermisstionList.add(fp);
                    }
                 }
                }
             }
            insert permissionList;
            insert fieldPermisstionList;
        }
    }
    
    public void grantRCEPermissionsWithFields(List<String> sObjList) {
        if (ps != null && sObjList.size() > 0) {
            List<ObjectPermissions> permissionList =  new List<ObjectPermissions>();
            List<fieldPermissions> fieldPermisstionList =  new List<fieldPermissions>();
            for(String sObj : sObjList) {
                ObjectPermissions op = new ObjectPermissions();
                op.parentId = ps.Id;
                op.SobjectType = sObj;
                op.PermissionsCreate = true;
                op.PermissionsDelete = true;
                op.PermissionsEdit = true;
                op.PermissionsModifyAllRecords = true;
                op.PermissionsRead = true;
                op.PermissionsViewAllRecords = true;
                
                permissionList.add(op);
                
                SObjectType currentObject = Schema.getGlobalDescribe().get(sObj);
                Map<String, Schema.SObjectField> fieldMap = currentObject.getDescribe().fields.getMap();
                //System.debug('SObj - > '+sObj+ ' Map -> '+fieldMap);
                for(Schema.SObjectField field : fieldMap.values()) {
                    Schema.DescribeFieldResult dscField = field.getDescribe();
                    if (dscField.isCustom() && dscField.isPermissionable()) {
                        fieldPermissions fp = new fieldPermissions();
                        fp.ParentId = ps.Id;
                        fp.SobjectType = sObj;
                        fp.Field = sObj + '.' + field;
                        fp.PermissionsRead = true;
                        if (dscField.isUpdateable()) {
                            fp.PermissionsEdit = true;
                        }
                        fieldPermisstionList.add(fp);
                    }
                 }
            }
            insert permissionList;
            insert fieldPermisstionList;
        }
    }  
    
    
    public void grantPackageLevelPermissions(List<String> packageList, String permissionType, boolean isToApplyFieldlevel) {
        for(String packageNameSpace : packageList) {
            if('custom'.equalsIgnoreCase(packageNameSpace)) {
                grantPackageLevelPermissionsForNonManagedPackageObjects(permissionType, isToApplyFieldlevel);
            } else {
                grantPackageLevelPermissions(packageNameSpace, permissionType, isToApplyFieldlevel);
            }
        }
    }
    
    public void grantPackageLevelPermissions(String packageNamespace, String permissionType, boolean isToApplyFieldlevel) {
        if(String.isNotBlank(packageNamespace) && String.isNotBlank(permissionType)) {
            
            List<String> sObjList = new List<String>();
           if(flag) {
               sObjList.add('Account');
               flag = false;
           }
           
           // if(packageNamespace.equals('loan')) {
           //     sObjList.add('Account');
           // }
            
            for ( Schema.SObjectType typ : Schema.getGlobalDescribe().values() ) {
                Schema.DescribeSObjectResult objResult = typ.getDescribe();
                String sobjAPIName = String.valueOf(objResult.getName());
                
                if ( sobjAPIName.startsWith(packageNamespace+'__') && !objResult.isCustomSetting() && objResult.isCustom()) {
                    if(sobjAPIName.endsWith('__c')) {
                        sObjList.add(sobjAPIName);
                        //System.debug(sobjAPIName);
                    }
                }
            }
            System.debug('Package ' + packageNamespace + ' Object count is ' + sObjList.size());
            if (sObjList.size() > 0) {
                if(permissionType.equalsIgnoreCase('readonly')) {
                    if(isToApplyFieldlevel) {
                        // Fields level read only permissions.  
                        grantReadOnlyPermissionsWithFields(sObjList);
                    } else {
                        // Only object level read only permissions.
                        grantReadOnlyPermissions(sObjList);
                    }
                } else if (permissionType.equalsIgnoreCase('complete')) {
                    if(isToApplyFieldlevel) {
                        // Fields level RCE(Read,Create,Edit) permissions.  
                        grantRCEPermissionsWithFields(sObjList);
                    } else {
                        // Only object level RCE(Read,Create,Edit) permissions.
                        grantRCEPermissions(sObjList);
                    }
                }
            }
            
        }
    }
    
    public void grantPackageLevelPermissionsForNonManagedPackageObjects(String permissionType, boolean isToApplyFieldlevel) {
        List<String> sObjList = new List<String>();
            
            sObjList.add('Opportunity');
           // sObjList.add('Account');
            
            for ( Schema.SObjectType typ : Schema.getGlobalDescribe().values() ) {
                Schema.DescribeSObjectResult objResult = typ.getDescribe();
                String sobjAPIName = String.valueOf(objResult.getName());
                
                if ( !(sobjAPIName.indexOf('__') < (sobjAPIName.length()-4)) && !objResult.isCustomSetting() && objResult.isCustom()) {
                    if(sobjAPIName.endsWith('__c')) {
                        sObjList.add(sobjAPIName);
                        //System.debug(sobjAPIName);
                    }
                }
            }
            
            if (sObjList.size() > 0) {
                if(permissionType.equalsIgnoreCase('readonly')) {
                    if(isToApplyFieldlevel) {
                        // Fields level read only permissions.  
                        grantReadOnlyPermissionsWithFields(sObjList);
                    } else {
                        // Only object level read only permissions.
                        grantReadOnlyPermissions(sObjList);
                    }
                } else if (permissionType.equalsIgnoreCase('complete')) {
                    if(isToApplyFieldlevel) {
                        // Fields level RCE(Read,Create,Edit) permissions.  
                        grantRCEPermissionsWithFields(sObjList);
                    } else {
                        // Only object level RCE(Read,Create,Edit) permissions.
                        grantRCEPermissions(sObjList);
                    }
                }
            }
    }
    
}