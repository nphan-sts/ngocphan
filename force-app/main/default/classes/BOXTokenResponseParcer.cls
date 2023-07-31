public class BOXTokenResponseParcer {
    public String access_token;
    public Integer expires_in;
    public restricted_to[] restrictedTo;
    public String refresh_token;
    public String token_type;
    public String fileId;
    public String error;
    public String error_description;
    public entries[] entries; 
    
    public class restricted_to {
    } 
    
    public class entries{
    
      public String type;
      public String id;
    }       
    
    public static BOXTokenResponseParcer parse(String json) {
        return (BOXTokenResponseParcer)System.JSON.deserialize(json, BOXTokenResponseParcer.class);
    }
}