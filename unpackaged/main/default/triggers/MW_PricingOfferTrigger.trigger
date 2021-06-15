trigger MW_PricingOfferTrigger on Pricing_Offer__c (after insert, after update) {
    if(!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c) {
        Map<id,string> mapPricingOffers = New Map<id,string>();
        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            for(Pricing_Offer__c pricingOffer : Trigger.New){
                if(pricingOffer.Is_Offer_Selected__c == true){
                    mapPricingOffers.put(pricingOffer.Application__c,pricingOffer.Pricing_Tier__c );
                }
            }
            if(!mapPricingOffers.isEmpty()){
                List<genesis__applications__c> apps = [select id, Pricing_Tier__c from genesis__applications__C where Id IN :mapPricingOffers.keySet()];
                for(genesis__applications__c app :apps ){
                    app.Pricing_Tier__c = mapPricingOffers.get(app.id);
                }
                
                update apps;
            }
        }
    }
}