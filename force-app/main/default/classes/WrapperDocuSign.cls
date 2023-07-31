public class WrapperDocuSign { 

    public String envelopeId;
    public String uri;
    public String statusDateTime;
    public String status;
    
    public static WrapperDocuSign parse(String json){
        return (WrapperDocuSign) System.JSON.deserialize(json, WrapperDocuSign.class);
    }
}