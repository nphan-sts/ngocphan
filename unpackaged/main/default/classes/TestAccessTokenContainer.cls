@isTest
public class TestAccessTokenContainer {

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
		AccessTokenContainer obj = AccessTokenContainer.parse(json);
		System.assert(obj != null);
	}
}