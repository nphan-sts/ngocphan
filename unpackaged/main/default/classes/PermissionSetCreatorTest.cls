@isTest
public class PermissionSetCreatorTest {
    /*Created By : Bhavya Maliwal
Method name : testReadOnlyWithFields
Purpose : to cover code satisfying PermissionSetCreator where Read Only permission is to be provided to all the fields.
    @isTest static void testReadOnlyWithFields() {
        test.startTest();
        PermissionSetCreator pset = new PermissionSetCreator('test_Loan_R');
        pset.grantPackageLevelPermissions('loan','readonly',true);
        test.stopTest();
        List<ObjectPermissions> permissionList=[Select id from ObjectPermissions];
        system.assert(permissionList.size()>=1);
    }*/
    /*Created By : Bhavya Maliwal
Method name : testRCEWithFields
Purpose : to cover code satisfying PermissionSetCreator where full permission(RCE) is to be provided to all the fields.
*/ 
    @isTest static void testRCEWithFields() {
        test.startTest();
        PermissionSetCreator pset = new PermissionSetCreator('test_Loan_R');
        pset.grantPackageLevelPermissions('loan','complete',true);
        test.stopTest();
        List<ObjectPermissions> permissionList=[Select id from ObjectPermissions];
        system.assert(permissionList.size()>=1);
    }
    /*Created By : Bhavya Maliwal
Method name : testReadOnly
Purpose : to cover code satisfying PermissionSetCreator where Read Only is to be provided to object but not fields.
*/ 
    @isTest static void testReadOnly() {
        test.startTest();
        PermissionSetCreator pset = new PermissionSetCreator('test_Loan_R');
        pset.grantPackageLevelPermissions('loan','readonly',false);
        test.stopTest();
        List<ObjectPermissions> permissionList=[Select id from ObjectPermissions];
        system.assert(permissionList.size()>=1);
    }
    /*Created By : Bhavya Maliwal
Method name : testRCE
Purpose : to cover code satisfying PermissionSetCreator where RCE is to be provided to object but not fields.
*/   
    @isTest static void testRCE() {
        test.startTest();
        PermissionSetCreator pset = new PermissionSetCreator('test_Loan_R');
        pset.grantPackageLevelPermissions('loan','complete',false);
        test.stopTest();
        List<ObjectPermissions> permissionList=[Select id from ObjectPermissions];
        system.assert(permissionList.size()>=1);
    }
    /*Created By : Bhavya Maliwal
Method name : testpkglistwithReadOnly
Purpose : to cover code satisfying PermissionSetCreator where Read Only is to be provided to fields under the package objects.
*/  
    @isTest static void testpkglistwithReadOnly() {
        test.startTest();
        PermissionSetCreator pset = new PermissionSetCreator('test_Loan_R');
        List<String> pckname = new List<String>();
        pckname.add('genesis');
        pset.grantPackageLevelPermissions(pckname,'readonly',true);
        test.stopTest();
        List<ObjectPermissions> permissionList=[Select id from ObjectPermissions];
        system.assert(permissionList.size()>=1);
    }
    
    /*Created By : Bhavya Maliwal
Method name : testpkglistwithRCE
Purpose : to cover code satisfying PermissionSetCreator where RCE is to be provided to fields under the package objects.
*/
    @isTest static void testpkglistwithRCE() {
        test.startTest();
        PermissionSetCreator pset = new PermissionSetCreator('test_Loan_R');
        List<String> pckname = new List<String>();
        pckname.add('genesis');
        
        pset.grantPackageLevelPermissions(pckname,'complete',true);
        test.stopTest();
        List<ObjectPermissions> permissionList=[Select id from ObjectPermissions];
        system.assert(permissionList.size()>=1);
    }
    /*Created By : Bhavya Maliwal
Method name : testpkglistwithRead
Purpose : to cover code satisfying PermissionSetCreator where ReadOnly is to be provided to objects under the package objects.
*/
    @isTest static void testpkglistwithRead() {
        test.startTest();
        PermissionSetCreator pset = new PermissionSetCreator('test_Loan_R');
        List<String> pckname = new List<String>();
        pckname.add('genesis');
        pset.grantPackageLevelPermissions(pckname,'readonly',false);
        test.stopTest();
        List<ObjectPermissions> permissionList=[Select id from ObjectPermissions];
        system.assert(permissionList.size()>=1);
    }
    /*Created By : Bhavya Maliwal
Method name : testpkglistRCE
Purpose : to cover code satisfying PermissionSetCreator where RCE is to be provided to objects under the package objects.
*/
    @isTest static void testpkglistRCE() {
        test.startTest();
        PermissionSetCreator pset = new PermissionSetCreator('test_Loan_R');
        List<String> pckname = new List<String>();
        pckname.add('genesis');
        pset.grantPackageLevelPermissions(pckname,'complete',false);
        test.stopTest();
        List<ObjectPermissions> permissionList=[Select id from ObjectPermissions];
        system.assert(permissionList.size()>=1);
    }
    
    
}