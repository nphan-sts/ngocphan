@isTest
public class TestOAuthController{
   testmethod static void method1(){
        test.startTest();
        PageReference pageRef = Page.OAuth2VFLoginPage;
        pageRef.getParameters().put('state', 'Test_state');
        pageRef.getParameters().put('code', 'a1h2F0000003yzu');
        Test.setCurrentPage(pageRef);
        OAuthController obj = new OAuthController();
        test.stopTest();
   }
}