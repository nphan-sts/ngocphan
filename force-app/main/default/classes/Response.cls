global class Response {
    
    global String status {get; set;}
    global String errorCode {get; set;}
    // Added variable errorMessage to store 
    // multi-lingual message 
    global String errorMessage {get; set;}
    //errorNumber specifies the root cause
    global Integer errorNumber {get;set;}
    //In case of multiple rows as input, rowNumber gives exact number of the errorneous row  
    global Integer rowNumber {get;set;}
    
    global List<String> content {get;set;}
    global String LPTName{get;set;}
    //global List<CustomResponse> response {get;set;}
    
    global Response() {
        status = null;
        errorCode = 'NO_ERROR';
        errorMessage = null;
        content = new List<String>();
        LPTName = '';
        //response = new List<CustomResponse>();
    }
    
    global Response(String status, String errorCode, String errorMessage) {
        this.status = status;
        this.errorCode = errorCode;
        this.errorMessage = errorMessage;
        contents = new List<SObject>();
    }

    global List<SObject> contents {
        get;
        set;
    }
}