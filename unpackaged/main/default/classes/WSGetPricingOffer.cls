@RestResource(urlMapping='/offers/*')
global with sharing class WSGetPricingOffer {
   
    public String applicationId {get;set;} 
    public List<Offers> offers {get;set;} 
    genesis__Applications__c application;
    global class Response{
        public String status;
        public String errorCode;
        public String errorMessage;
        public String httpStatusCode;
        public Response(){
            errorCode = PayoffConstants.NO_ERROR;
            status = PayoffConstants.SUCCESS;
        }
    }
    
    public static void consumeObject(JSONParser parser) {
        system.debug('insideconsume');
        Integer depth = 0;
        do {
            JSONToken curr = parser.getCurrentToken();
            if (curr == JSONToken.START_OBJECT || 
                curr == JSONToken.START_ARRAY) {
                    depth++;
                } else if (curr == JSONToken.END_OBJECT ||
                           curr == JSONToken.END_ARRAY) {
                               depth--;
                           }
        } while (depth > 0 && parser.nextToken() != null);
    }
    
    
    
    public void WSGetPricingOfferMethod(JSONParser parser) {
        system.debug('Inside pricingoffermethod');
        
        while (parser.nextToken() != JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                    if (text == 'applicationId') {
                        applicationId = parser.getText();
                         application= [Select genesis__Status__c
                                       from genesis__Applications__c 
                                       where id=:applicationId];
                        application.genesis__Status__c='offer_shown';
                        update application;
                        
                        system.debug(applicationId);
                        
                    } else if (text == 'offers') {
                        offers = new List<Offers>();
                        while (parser.nextToken() != JSONToken.END_ARRAY) {
                            system.debug('offermethodcalled');
                            offers.add(new Offers(parser,applicationId));
                           system.debug(offers);
                            
                        }
                    }
                    
                    else {
                        System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
        
        
    } 
    
    
    public class Offers {
        
        public String key {get;set;} 
        public String amount {get;set;} 
        public Integer term_months {get;set;} 
        public String apr {get;set;} 
        public String interest_rate {get;set;} 
        public String origination_fee_rate {get;set;} 
        public String monthly_payment {get;set;} 
        public String origination_fee {get;set;} 
        public String segment {get;set;} 
        public String pricing_tier {get;set;} 
        public String above_prime_max {get;set;} 
        public String type1 {get;set;} 
        public Boolean Is_Offer_Selected {get;set;}
        public String ebp_offer_code {get;set;}
        public String ebp_parent_offer_key {get;set;}
        public String score {get;set;}

        public Offers(JSONParser parser,String applicationId) {
            
            Pricing_Offer__c pOffer =new Pricing_Offer__c(); 
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'key') {
                            key = parser.getText();
                            pOffer.Key__c=Integer.valueof(key);
                            
                        }
                        else if (text == 'amount') {
                            amount = parser.getText();
                            pOffer.Amount__c=Decimal.ValueOf(amount);
                            
                        }
                        else if (text == 'term_months') {
                            term_months = parser.getIntegerValue();
                            pOffer.Term__c=term_months;
                            
                        }
                        else if (text == 'apr') {
                            apr = parser.getText();
                            pOffer.APR__c=Decimal.valueOf(apr);
                            
                        } 
                        else if (text == 'interest_rate') {
                            interest_rate = parser.getText();
                            pOffer.Interest_Rate__c=Decimal.valueOf(interest_rate);
                            
                        } 
                        else if (text == 'origination_fee_rate') {
                            origination_fee_rate = parser.getText();
                            pOffer.Origination_fee_rate__c=Decimal.valueOf(origination_fee_rate);
                            
                        } 
                        else if (text == 'monthly_payment') {
                            monthly_payment = parser.getText();
                            pOffer.Monthly_Payment__c=Decimal.ValueOf(monthly_payment);
                            
                        } 
                        else if (text == 'origination_fee') {
                            origination_fee = parser.getText();
                            pOffer.Origination_fee__c=Decimal.valueOf(origination_fee);
                            
                        }
                        else if (text == 'segment') {
                            segment = parser.getText();
                            pOffer.Segment__c=segment;
                            
                        }
                        else if (text == 'pricing_tier') {
                            pricing_tier = parser.getText();
                            pOffer.Pricing_Tier__c=pricing_tier;
                            
                        }
                        else if (text == 'above_prime_max') {
                            above_prime_max = parser.getText();
                            pOffer.Above_prime_max__c=above_prime_max;
                            
                        } 
                        else if (text == 'type1') {
                            type1 = parser.getText();
                            pOffer.Type__c = type1;
                            
                        } 
                        else if (text == 'ebp_offer_code') {
                            ebp_offer_code = parser.getText();
                            pOffer.EBP_Offer_Code__c = ebp_offer_code;
                        }
                        else if (text == 'ebp_parent_offer_key') {
                            ebp_parent_offer_key = parser.getText();
                            pOffer.EBP_Parent_Offer_Key__c = ebp_parent_offer_key;
                        }
                        else if (text == 'score'){
                            score = parser.getText();
                            pOffer.Score__c = Decimal.valueOf(score);
                        }
                        else {
                            System.debug(LoggingLevel.WARN, 'Offers consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                        pOffer.Application__c=applicationId;
                        pOffer.active__c = true;
                   
                    }
                }
               
                
                
            }
            insert pOffer;
           
        }
    }
      
    
    @HttpPost
    global static Response parse(){
        RestResponse restRes = Restcontext.response;
        RestRequest req = Restcontext.request;
        Response res = new Response();
        String jsondata = req.requestBody.toString();
        try{
            system.debug('postmethod');
            WSGetPricingOffer wsoffer=new WSGetPricingOffer();
            wsoffer.WSGetPricingOfferMethod(System.JSON.createParser(jsondata));
            
        }catch(Exception e){
            res.status = e.getMessage();
            res.errorCode = PayoffConstants.NO_ERROR;
            res.httpStatusCode = PayoffConstants.ERROR_HTTP_CODE;
            return res;        
        }
        return res;
    }
    
}