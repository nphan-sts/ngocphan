/* ****************Modification History******************
 * Updated By        Date				Jira Number		 
 *1. Bhanupriya       2022/03/30     	LSP-634	(add test.start() and test.stop() methods)
 ******************Modification History******************/

@isTest
public class TestAccessTokenContainer {
    //testmethod
    public static testMethod void testParse() {
		String json=		'{'+
		'    "user": {'+
		'        "accessTokens": ['+
		'            {'+
		'                "appId": "10003600",'+
		'                "value": "df870754576c002e12199674887f71d6be378f6edde6b242bfd512c74fea72a8",'+
		'                "url": "https://192.168.57.139:7100/authenticate/nodesmb/"'+
		'            }'+
		'        ]'+
		'    }'+
		'}';
        test.startTest();
        AccessTokenContainer obj = AccessTokenContainer.parse(json);
        test.stopTest();
        System.assert(obj.user != null);
        }
}