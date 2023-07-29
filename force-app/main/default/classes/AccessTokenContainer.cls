public class AccessTokenContainer{
	public cls_user user;
	class cls_user {
		public cls_accessTokens[] accessTokens;
	}
	class cls_accessTokens {
		public String appId;	//10003600
		public String value;	//df870754576c002e12199674887f71d6be378f6edde6b242bfd512c74fea72a8
		public String url;	//https://192.168.57.139:7100/authenticate/nodesmb/
	}
	public static AccessTokenContainer parse(String json){
		return (AccessTokenContainer) System.JSON.deserialize(json, AccessTokenContainer.class);
	}
}