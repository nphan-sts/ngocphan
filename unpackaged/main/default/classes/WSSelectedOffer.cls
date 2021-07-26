@RestResource(urlMapping='/selectedoffer/*')
global with sharing class WSSelectedOffer{
   
    global class Response{
        public String status;
        public String errorCode;
        public String errorMessage;
        public String successMessage;
        public String httpStatusCode;
        public Response(){
            errorCode = PayoffConstants.ERROR;
            status = PayoffConstants.FAIL;
        }
    }
    
    global class ApprovePricingOffer{
        public String applicationId;
        public String Key;
        
    }
    
    @HttpPost
    global static Response markTentativeOfferSelected(){
        List<Pricing_Offer__c> pOffer;
        Pricing_Offer__c pOffer1;
        List<Approved_Offer__c> approve1;
        Approved_Offer__c approve = new Approved_Offer__c();
        RestResponse restRes = Restcontext.response;
        RestRequest req = Restcontext.request;
        Response res = new Response();
        
        String jsondata = req.requestBody.toString();
        ApprovePricingOffer approvedOffers;
        
        try{
            approvedOffers = (ApprovePricingOffer)JSON.deserialize(jsondata, ApprovePricingOffer.class);
        }catch(Exception e){
            res.status = e.getMessage();
            res.errorCode = PayoffConstants.INVALID_INPUT_FORMAT;
            res.httpStatusCode = PayoffConstants.ERROR_HTTP_CODE;
            return res;            
        }
        
        if(approvedOffers.applicationID == null || String.isEmpty(approvedOffers.applicationID)){
            res.errorCode = PayoffConstants.SYSTEM_ERROR;
            res.status = PayoffConstants.ERROR;
            res.errorMessage = PayoffConstants.APP_ID_CANNOT_BE_NULL;
            return res;
        }
        
        if(approvedOffers.Key == null || String.isEmpty(approvedOffers.Key)){
            res.errorCode = PayoffConstants.SYSTEM_ERROR;
            res.status = PayoffConstants.ERROR;
            res.errorMessage = PayoffConstants.KEY_CANNOT_BE_NULL;
            return res;
        }
        
        
        
        if(!(approvedOffers.applicationID instanceOf Id)) {
            res.errorCode = PayoffConstants.INVALID_INPUT_FORMAT;
            res.status = PayoffConstants.ERROR;
            res.errorMessage = PayoffConstants.APP_ID_INCORRECT_FORMAT;
            return res;
        }
        genesis__Applications__c app =[select id,
                                       genesis__Term__c,
                                       genesis__APR__c,
                                       Origination_fee__c,
                                       genesis__Monthly_Debt_Payments__c,
                                       genesis__Interest_Rate__c,
                                       genesis__Loan_Amount__c,
                                       genesis__Financed_Amount__c,
                                       genesis__Status__c
                                       from genesis__Applications__c 
                                       where id=:approvedOffers.applicationID 
                                      limit 1];
                                      
        poffer= [select id,name ,Is_Offer_Selected__c
                 from Pricing_Offer__c
                 where Application__c=:approvedOffers.applicationID and
                 Is_Offer_Selected__c=:true ];
        if(poffer.size()>0){
            for(Pricing_Offer__c p : pOffer){
                if(p.EBP_Offer_Code__c == null || p.EBP_Offer_Code__c.length() == 0) {
                    res.errorCode = PayoffConstants.ERROR;
                    res.status = PayoffConstants.FAIL;
                    res.errorMessage = 'One loan offer is already selected . Contact the support team for any queries';
                    return res;
                }
            }
        }
                                      
        pOffer = [select id,
                 Above_prime_max__c,
                 Amount__c,
                 Application__c,
                 APR__c,
                 Interest_Rate__c,
                 Is_Offer_Selected__c,
                 Key__c,
                 Monthly_Payment__c,
                 Origination_fee__c,
                 Origination_fee_rate__c,
                 Pricing_Tier__c,
                 Segment__c,
                 Term__c,
                 Type__c
                 from Pricing_Offer__c
                 where Application__c=:approvedOffers.applicationID and
                (Key__c=:Integer.valueOf(approvedOffers.Key) or Is_Offer_Selected__c=:true)];
        system.debug(pOffer);
        if(pOffer != Null){
            List<Pricing_Offer__c> updateOffer=new List<Pricing_Offer__c>();
            try{
                for(Pricing_Offer__c p : pOffer){
                    if(p.Key__c == Integer.valueOf(approvedOffers.Key) && p.Is_Offer_Selected__c == true)
                        res.successMessage=PayoffConstants.THIS_OFFER_IS_ALREADY_APPROVED; 
                        system.debug('p1' + p);
                    if( p.Is_Offer_Selected__c == true && p.Key__c != Integer.valueOf(approvedOffers.Key) ){                    
                        p.Is_Offer_Selected__c = false;
                        update p;
                        system.debug('p2' + p);
                        approve1 =[select id,
                                  Above_prime_max__c,
                                  Amount__c,
                                  Application__c,
                                  APR__c,
                                  Interest_Rate__c,
                                  Key__c,
                                  Monthly_Payment__c,
                                  Origination_fee__c,
                                  Origination_fee_rate__c,
                                  Pricing_Tier__c,
                                  Segment__c,
                                  Term__c,
                                  Type__c
                                  from Approved_Offer__c
                                  where Application__c =:approvedOffers.applicationID and
                                  Key__c =:String.valueOf(p.Key__c)];
                        delete approve1;
                    }
                    if(p.Key__c == Integer.valueOf(approvedOffers.Key) && p.Is_Offer_Selected__c == false){
                        approve.Above_prime_max__c=p.Above_prime_max__c;
                        system.debug(approve.Above_prime_max__c);
                        approve.Amount__c=p.Amount__c;
                        approve.Application__c=p.Application__c;
                        approve.APR__c=String.valueOf(p.APR__c);
                        approve.Interest_Rate__c=String.valueOf(p.Interest_Rate__c);
                        approve.Key__c=String.valueOf(p.Key__c);
                        approve.Monthly_Payment__c=p.Monthly_Payment__c;
                        approve.Origination_fee__c=String.valueOf(p.Origination_fee__c);
                        approve.Origination_fee_rate__c=String.valueOf(p.Origination_fee_rate__c);
                        approve.Pricing_Tier__c=p.Pricing_Tier__c;
                        approve.Segment__c=p.Segment__c;
                        approve.Term__c=p.Term__c;
                        approve.Type__c=p.Type__c;
                        insert approve;
                        app.genesis__Loan_Amount__c=p.Amount__c;
                        app.genesis__APR__c=p.APR__c;
                        app.genesis__Term__c=p.Term__c;
                        app.Origination_fee__c=p.Origination_fee__c;
                        app.genesis__Monthly_Debt_Payments__c=p.Monthly_Payment__c;
                        app.genesis__Interest_Rate__c=p.Interest_Rate__c;
                        app.genesis__Financed_Amount__c= (p.Amount__c - p.Origination_fee__c);
                        app.genesis__Status__c='offer_accepted';
                        update app;
                        p.Is_Offer_Selected__c=true;
                        updateOffer.add(p);
                        system.debug('poffer'+p);
                    }
                    if(!updateOffer.isEmpty())
                        update updateOffer;
                    system.debug('updated offer'+updateOffer);
                } 
            } catch(exception e){
                System.debug('Error -> ' + e.getMessage());
                loan__batch_process_log__c bpl = new loan__batch_process_log__c();
                bpl.loan__message__c = 'Error in Offer Selected Class ' + e.getStackTraceString();
            }
        }
        res.errorCode = PayoffConstants.NO_ERROR;
        res.status = PayoffConstants.SUCCESS;                           
        
        return res;
    }    
}