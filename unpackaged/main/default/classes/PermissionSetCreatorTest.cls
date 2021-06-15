@isTest
public class PermissionSetCreatorTest {
	@isTest static void testReadOnlyWithFields() {
        PermissionSetCreator pset = new PermissionSetCreator('test_Loan_R');
		pset.grantPackageLevelPermissions('loan','readonly',true);
	}
    
    @isTest static void testRCEWithFields() {
        PermissionSetCreator pset = new PermissionSetCreator('test_Loan_R');
		pset.grantPackageLevelPermissions('loan','complete',true);
	}
    
    @isTest static void testReadOnly() {
        PermissionSetCreator pset = new PermissionSetCreator('test_Loan_R');
		pset.grantPackageLevelPermissions('loan','readonly',false);
	}
    
    @isTest static void testRCE() {
        PermissionSetCreator pset = new PermissionSetCreator('test_Loan_R');
		pset.grantPackageLevelPermissions('loan','complete',false);
	}
    
    @isTest static void testpkglist() {
        PermissionSetCreator pset = new PermissionSetCreator('test_Loan_R');
        List<String> pckname = new List<String>();
        pckname.add('genesis');
        pckname.add('custom');
		pset.grantPackageLevelPermissions(pckname,'complete',true);
	}
    @isTest static void testpkglist3() {
        PermissionSetCreator pset = new PermissionSetCreator('test_Loan_R');
        List<String> pckname = new List<String>();
        pckname.add('genesis');
        pckname.add('custom');
		pset.grantPackageLevelPermissions(pckname,'complete',false);
	}
    @isTest static void testpkglist2() {
        PermissionSetCreator pset = new PermissionSetCreator('test_Loan_R');
        List<String> pckname = new List<String>();
        pckname.add('genesis');
        pckname.add('custom');
		pset.grantPackageLevelPermissions(pckname,'readonly',false);
	}
    @isTest static void testpkglist1() {
        PermissionSetCreator pset = new PermissionSetCreator('test_Loan_R');
        List<String> pckname = new List<String>();
        pckname.add('genesis');
        pckname.add('custom');
		pset.grantPackageLevelPermissions(pckname,'readonly',true);
	}

}