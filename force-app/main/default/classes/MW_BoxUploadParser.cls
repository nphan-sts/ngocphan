public class MW_BoxUploadParser{
	public Integer total_count;	//5476
	public cls_entries[] entries;
	//public Integer limit;	//30
	public Integer offset;	//0

	class cls_entries {
		public String type;	//folder
		public String id;	//0
		public String sequence_id;
		public String etag;
		public String name;	//All Files
		public cls_created_by created_by;
		public cls_modified_by modified_by;
		public cls_trashed_at trashed_at;
		public cls_purged_at purged_at;
		public String content_created_at;	//2018-04-23T11:47:41-07:00
		public String content_modified_at;	//2018-04-23T11:51:07-07:00
		public cls_owned_by owned_by;
		public cls_shared_link shared_link;
		public cls_folder_upload_email folder_upload_email;
		public cls_parent parent;
		public String item_status;	//active
	}
	class cls_path_collection {
		public Integer total_count;	//3
		public cls_entries[] entries;
	}
	class cls_sequence_id {
	}
	class cls_etag {
	}
	class cls_created_by {
		public String type;	//user
		public String id;	//2359085860
		public String name;	//Box Dev User
		public String login;	//box_dev@happymoney.com
	}
	class cls_modified_by {
		public String type;	//user
		public String id;	//2359085860
		public String name;	//Box Dev User
		public String login;	//box_dev@happymoney.com
	}
	class cls_trashed_at {
	}
	class cls_purged_at {
	}
	class cls_owned_by {
		public String type;	//user
		public String id;	//222716347
		public String name;	//Team Payoff - DEV Account
		public String login;	//tech2@happymoney.com
	}
	class cls_shared_link {
	}
	class cls_folder_upload_email {
	}
	public class cls_parent {
		public String type;	//folder
		public String id;	//48771341809
		public String sequence_id;	//2
		public String etag;	//2
		public String name;	//Individual Loans V2
	}

	public static MW_BoxUploadParser parse(String json){
		return (MW_BoxUploadParser) System.JSON.deserialize(json, MW_BoxUploadParser.class);
	}
}