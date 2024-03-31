public abstract with sharing class CalloutClient {
    protected final String HEADER_CONTENT_TYPE = 'Content-Type';
    protected final String HEADER_CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    protected final String HEADER_AUTHORIZATION = 'Authorization';
    protected final String HEADER_BEARER_AUTHORIZATION = 'Bearer';
    protected final String HTTP_METHOD_GET = 'GET';
    protected final String HTTP_METHOD_POST = 'POST';
    protected final Integer DEFAULT_TIMEOUT = 60000;
    protected HttpRequest request;
    protected HttpResponse response;
    protected void doCallout() {
        this.response = new Http().send(request);
    }
    protected Boolean isStatusCodeOk() {
        System.debug(response.getStatus());
        System.debug(response.getStatusCode());
        
        return response.getStatusCode() == 200;
    }
    protected Integer getResponseStatusCode() {
        return response.getStatusCode();
    }
    protected String getResponseBody() {
        System.debug(response.getBody());
        return response.getBody();
    }
    protected virtual HttpRequest createRequest(String method) {
        request = new HttpRequest();
        request.setMethod(method);
        request.setTimeout(DEFAULT_TIMEOUT);
        return request;
    }
    
    public class CalloutClientException extends Exception {}
}