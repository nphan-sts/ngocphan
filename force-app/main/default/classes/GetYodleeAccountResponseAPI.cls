public class GetYodleeAccountResponseAPI {
    public yodleeAccount[] bankAccounts;
    public class yodleeAccount {
        public Refreshinfo refreshinfo;
        public String CONTAINER;
        public Boolean isManual;
        public Boolean isAsset;
        public String lastUpdated;
        public CurrentBalance currentBalance;
        public CurrentBalance availableBalance;
        public Integer id;
        public CurrentBalance balance;
        public String accountName;
        public String accountNumber;
        public String aggregationSource;
        public String providerName;
        public String accountStatus;
        public String accountType;
        public String providerId;
        public Boolean includeInNetWorth;
        public List<HolderProfile> holderProfile;
        public String createdDate;
        public Integer providerAccountId;
    }

    /*public class GetYodleeAccountResponseAPI {
        public List<Account> account;
    }*/

    public class HolderProfile {
        public Name name;
    }

    public class CurrentBalance {
        public Double amount;
        public String currencyAmount;
    }

    public class Refreshinfo {
        public Integer statusCode;
        public String lastRefreshAttempt;
        public String lastRefreshed;
        public String nextRefreshScheduled;
        public String statusMessage;
    }

    public class Name {
        public String displayed;
    }

    
    public static GetYodleeAccountResponseAPI parse(String json) {
        return (GetYodleeAccountResponseAPI) System.JSON.deserialize(json, GetYodleeAccountResponseAPI.class);
    }
}