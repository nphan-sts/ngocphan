@isTest

private class TestCobrandLoginContainer{
        Testmethod static void method1(){
            String json='{'+
                        '"CobrandLogin": {'+
                        '"cobrandId": "123",'+
                        '"applicationId": "23",'+
                        '"locale":"ABC"'+
                      '}'+
                    '}';
            CobrandLoginContainer.parse(json);
        }
}