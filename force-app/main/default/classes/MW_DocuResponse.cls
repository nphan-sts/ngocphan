public class MW_DocuResponse
{
     public String envelopeId;   
     public String uri;  
     public String statusDateTime;   
     public String status;
        
     public static MW_DocuResponse parse(String json){
            return (MW_DocuResponse) System.JSON.deserialize(json, MW_DocuResponse.class);
     }
}