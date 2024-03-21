public class RequestBodyParser {
    public class RequestBodyParams {
        Map<String, Object> params;
        
        public Map<String, Object> getParams() {
            return params;
        }
        
        public RequestBodyParams() {
            this.params = new Map<String, Object>();
        }
        
        public RequestBodyParams(Map<String, Object> params) {
            this.params = params;
        }
    }
    public static RequestBodyParams getJsonParamsFromRequest(RestRequest req) {
        if(req != null && req.requestBody != null && (req.requestBody.toString().trim().length() != 0)) {
            try {
                return new RequestBodyParams((Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString()));
            } catch(Exception e) {
                System.debug('Exception : ' + e);
                //return null;
                throw e;      // Raise the exception for invalid JSON
            }
        } 
        return null;
    }
}