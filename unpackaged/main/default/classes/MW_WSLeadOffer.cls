@RestResource(urlMapping='/LeadOffer')
global with sharing class MW_WSLeadOffer  {

    public class LeadClass {
        public String lead_guid;
        public List<OfferClass> offers;
    }

    public class OfferClass {
        public String above_prime_max;
        public Integer amount;
        public Double apr;
        public Double interest_rate;
        public Integer key;
        public Double monthly_payment;
        public Double origination_fee;
        public Double origination_fee_discount;
        public Double origination_fee_rate;
        public Double origination_fee_rate_discount;
        public String pricing_tier;
        public String segment;
        public Integer term_months;
        public String type;
    }

    @HttpPost
    global static String create() {
        RestRequest req = Restcontext.request;
        String jsonData = req.requestBody.toString();
        LeadClass leadObj = (LeadClass) JSON.deserialize(jsonData, LeadClass.class);
        try {
            List<Lead_Offer__c> newOffers = new List<Lead_Offer__c>();
            Lead currentLead = [Select id, lead_guid__c, status From Lead Where lead_guid__c =: leadObj.lead_guid limit 1];
            currentLead.status = 'partner_offer_estimates';
            if(currentLead != null) {
                for(OfferClass offer: leadObj.offers) {
                    Lead_Offer__c offerObj = new Lead_Offer__c();
                    offerObj.Above_Prime_Max__c = offer.above_prime_max;
                    offerObj.Amount__c = offer.amount;
                    offerObj.APR__c = offer.apr;
                    offerObj.Interest_Rate__c = offer.interest_rate;
                    offerObj.Key__c = offer.key;
                    offerObj.Lead__c = currentLead.id;
                    offerObj.Monthly_Payment__c = offer.monthly_payment;
                    offerObj.Origination_Fee__c = offer.origination_fee;
                    offerObj.Origination_Fee_Discount__c = offer.origination_fee_discount;
                    offerObj.Origination_Fee_Rate__c = offer.origination_fee_rate;
                    offerObj.Origination_Fee_Rate_Discount__c = offer.origination_fee_rate_discount;
                    offerObj.Pricing_Tier__c = offer.pricing_tier;
                    offerObj.Segment__c = offer.segment;
                    offerObj.Term__c = offer.term_months;
                    offerObj.Type__c = offer.type;
                    newOffers.add(offerObj);
                }
            }
            if(newOffers.size() > 0) {
                insert newOffers;
                update currentLead;
            }
            return 'Success';
        }
        catch(Exception e){
            MW_LogUtility.error('MW_WSLeadOffer', '', leadObj.lead_guid, 'create', e);
            System.debug('Error: ' + e.getLineNumber() + ' Desc. ' + e.getMessage()+' Stack: '+e.getStackTraceString());
            System.debug(logginglevel.error,'line number'+e.getLineNumber());
            System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());
            return 'Error: ' + e.getLineNumber() + ' Desc. ' + e.getMessage()+' Stack: '+e.getStackTraceString();
        }
    }
}