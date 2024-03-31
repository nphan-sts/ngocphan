public class GetAccountContainer{
	public cls_account[] account;
	public class cls_account {
		public String CONTAINER;	//bank
		public Integer providerAccountId;	//10351594
		public String accountName;	//TESTDATA1
		public String accountStatus;	//ACTIVE
		public String accountNumber;	//503-5623xxx
		public boolean isAsset;
		public cls_balance balance;
		public Integer id;	//10792196
		public String lastUpdated;	//2017-08-08T02:36:17Z
		public boolean includeInNetWorth;
		public String providerId;	//8995
		public String providerName;	//DagBank
		public cls_availableBalance availableBalance;
		public boolean isManual;
		public cls_currentBalance currentBalance;
		public String accountType;	//SAVINGS
		public String createdDate;	//2017-08-08T02:36:17Z
		public cls_refreshinfo refreshinfo;
		public cls_holderProfile[] holderProfile;
	}
	public class cls_balance {
		public Double amount;	//9044.78
		public String currencyAmount;	//USD
	}
	public class cls_availableBalance {
		public Double amount;	//65454.78
		public String currencyAmount;	//USD
	}
	public class cls_currentBalance {
		public Double amount;	//9044.78
		public String currencyAmount;	//USD
	}
	public class cls_refreshinfo {
		public Integer statusCode;	//0
		public String statusMessage;	//OK
		public Datetime lastRefreshed;	//2017-08-08T02:36:17Z
		public String lastRefreshAttempt;	//2017-08-08T02:36:17Z
		public String nextRefreshScheduled;	//2017-08-09T09:07:23Z
	}
	public class cls_holderProfile {
		public cls_name name;
	}
	public class cls_name {
		public String displayed;	//accountHolder
	}
	public static GetAccountContainer parse(String json){
		return (GetAccountContainer) System.JSON.deserialize(json, GetAccountContainer.class);
	}

}