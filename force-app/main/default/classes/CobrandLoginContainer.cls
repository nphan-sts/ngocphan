public class CobrandLoginContainer {

	public class CobrandLogin {
		public Integer cobrandId;
		public String applicationId;
		public String locale;
		public Session session;
	}

	public class Session {
		public String cobSession;
	}

	
	public static CobrandLoginContainer parse(String json) {
		return (CobrandLoginContainer) System.JSON.deserialize(json, CobrandLoginContainer.class);
	}
}