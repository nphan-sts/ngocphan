public with sharing class IDAnalyticsIntegrationJSONBean {
    
   /* public class Fraud_attributes {
        public String name;
        public String value;
    }
*/
    public String status;
    public Result result;

    public class Sift_attributes {
        public String id_consistency_snapd_cat;
        public String id_consistency_snapd_int;
        public String id_idscore_cat;
        public String id_idscore_int;
    }

    public class Result {
        public String id_score;
        public String snapd;
        public String id_score_cat;
        public String snapd_cat;
        public Sift_attributes sift_attributes;
        //public List<Fraud_attributes> fraud_attributes;
        public String raw_response_xml;
    }
    
    public static IDAnalyticsIntegrationJSONBean parse(String json) {
        return (IDAnalyticsIntegrationJSONBean) System.JSON.deserialize(json, IDAnalyticsIntegrationJSONBean.class);
    }

}