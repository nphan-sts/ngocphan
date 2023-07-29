@isTest
private class MW_WSLeadOfferTest {

  @isTest static void testLeadOfferPostRequest() {
    Lead leadObj = new Lead();
    leadObj.lead_guid__c = 'abcde-12345';
    leadObj.lastName = 'lastNameTest';
    leadObj.Company = 'testCompany';
        leadObj.lead_id__c = 'abcde-12345';  //pallavi(test class was failing in UAT and prod)
    insert leadObj;

    StaticResource sr = [Select Body From StaticResource Where Name='LeadOffers' limit 1];
    String testJSON = sr.Body.toString();

    Test.setMock(HttpCalloutMock.class, new TestWSLeadOfferMock());
    RestRequest req    = new RestRequest();
    RestResponse res   = new RestResponse();
    req.requestURI = '/services/apexrest/LeadOffer';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueof(testJSON);

    RestContext.request = req;
    RestContext.response = res;

    String response = MW_WSLeadOffer.create();
    try {
      Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
      System.assertEquals('SUCCESS', jsonResponse.get('status'));
    }
    catch(exception ex){
      System.assertEquals('System.JSONException', ex.getTypeName());
    }
    List<Lead_Offer__c> newLeadOffers = [Select id, Lead__c From Lead_Offer__c Where Lead__c =: leadObj.id];
    System.assertEquals(2, newLeadOffers.size());
    //Check Lead Status Update
    Lead checkLeadStatus = [Select id, status, lead_guid__c From Lead Where lead_guid__c =: leadObj.lead_guid__c];
    System.assertEquals('partner_offer_estimates', checkLeadStatus.status);

    //Test Selected Lead Offer
    StaticResource sr2 = [Select Body From StaticResource Where Name='LeadOffersSelected' limit 1];
    String testJSON2 = sr2.Body.toString();
    req.requestURI = '/services/apexrest/SelectedLeadOffer';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueof(testJSON2);

    RestContext.request = req;
    RestContext.response = res;
    response = MW_WSSelectedLeadOffer.create();
    try {
      Map<String, Object> jsonResponse2 = (Map<String, Object>)JSON.deserializeUntyped(response);
      System.assertEquals('SUCCESS', jsonResponse2.get('status'));
    }
    catch(exception ex){
      System.assertEquals('System.JSONException', ex.getTypeName());
    }
    List<Lead_Offer__c> updatedLeadOffer = [Select id, Lead__c, Selected_Offer__c From Lead_Offer__c Where Key__c = 1];
    System.assertEquals(true, updatedLeadOffer[0].Selected_Offer__c);
    List<Lead> updatedLeadStatus = [Select id, status From Lead Where id =: updatedLeadOffer[0].Lead__c];
    System.assertEquals('partner_pre_qual_shown', updatedLeadStatus[0].status);
    //Test Delete Lead should trigger to delete it's offers
    delete leadObj;
    List<Lead_Offer__c> deletedLeadOffers = [Select id, Lead__c From Lead_Offer__c Where Lead__c =: leadObj.id];
    System.assertEquals(0, deletedLeadOffers.size());
    //Test Offer Not Found since the offer is deleted
    //delete updatedLeadOffer;
    response = MW_WSSelectedLeadOffer.create();
    System.assertEquals('Offer Not Found', response);

  }

  public class TestWSLeadOfferMock implements HTTPCalloutMock {
    public HTTPResponse respond(HTTPRequest req){
      HttpResponse res = new HTTPResponse();
      res.setHeader('Content-Type', 'application/JSON');
      res.setStatusCode(200);
      res.setStatus('SUCCESS');
      return res;
    }
  }

}