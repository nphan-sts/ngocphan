public class GetTransactionContainer{
    
  public cls_transaction[] transactions;
    
  public class cls_transaction {
        
    public String CONTAINER;
    public Long id;  
    //public String type;  
    public String subType;  
    public cls_amount amount;
    public String baseType;  
    public String categoryType; 
    public Integer categoryId; 
    public String category;  
    public String categorySource; 
    public cls_description description;
    //public String date;  
    public String postDate;  
    public Date transactionDate; 
    public boolean isManual;
    public String status;  
    public String YodleeAccount;  
    public cls_runningBalance runningBalance;
    public String checkNumber;  
    public String accountId;
    //public Integer highLevelCategoryId;  
  }
  public class cls_amount {
    public Decimal amount;  
    public String currencyAmount;  
  }
  public class cls_description {
    public String original;
    public String simple;  
  }
  public class cls_runningBalance {
    public Decimal amount;  
    public String currencyAmount;  
  }
  public Static GetTransactionContainer parse(String json){
    //transactions.addAll((GetTransactionContainer) System.JSON.deserialize(json, GetTransactionContainer.class));
    return (GetTransactionContainer) System.JSON.deserialize(json, GetTransactionContainer.class);
  }

}