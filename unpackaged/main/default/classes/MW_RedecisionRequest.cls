public with sharing class MW_RedecisionRequest {

	public static Redecision_Request__c redecisionreq = new Redecision_Request__c();

	@TestVisible
	private static red_request redeci;

	@InvocableMethod
	public static void invokeRedecisionRequest(List<Redecision_Request__c> genid)
	{
		if(genid[0].Body__c !=null  && genid[0].Triggered_From__c !=null) {
			redecisionreq = genid[0];
			System.debug('****************&&*'+redecisionreq);
			redecisionRequest();
		}
	}

	/*
	    {
	    "type": "redecision",
	    "data": [{
	                "lead_guid": ""
	                "first_name": ""
	                "last_name": ""
	                "state": ""
	                "city": ""
	                "street1": ""
	                "street2": ""
	                "postal_code": ""
	                "date_of_birth": ""
	                "monthly_housing_payment": ""
	                "income_annual": ""
	                "social_security_number": ""
	                "requested_loan_amount": ""
	            }]
	    }
	 */

	public Static void redecisionRequest(){

		System.debug('********************'+redecisionreq);
		if(redecisionreq.Triggered_From__c == 'Account')
		{
			List<String> accFields              = redecisionreq.Body__c.split(',');
			Map<String, String>  accdetailMap   = new Map<String, String>();
			Map<String, String>  detailMapValue = new Map<String, String>();
			String applicationId                = redecisionreq.Application__c;//r.genesis__Account__c;

			List<genesis__Applications__c> applnlist = [Select id, genesis__Account__c from genesis__Applications__c where id=:applicationId LIMIT 1];
			String aplicationId = applnlist[0].genesis__Account__c;
			System.debug('-------------------------apid'+redecisionreq.Body__c);
			String soql = 'Select id, name, '+ redecisionreq.Body__c +' from Account where Id =\'' + aplicationId + '\' limit 1';

			List<Account> appList =  Database.query(soql);

			if(appList.size()>0)
			{
				Account record = appList[0];

				for(String redecisionFields:accFields) {

					redecisionFields = redecisionFields.trim();

					System.debug('redecisionFields ' +redecisionFields  );
					System.debug('redecisionFields ' +record.get(redecisionFields));

					detailMapValue.put(redecisionFields, String.valueOf(record.get(redecisionFields)));
					accdetailMap.put('aad.'+String.valueOf(redecisionFields.split('__c')[0]).toLowerCase(),redecisionFields);
				}

				redeci = new red_request(getFieldInformation(accdetailMap, detailMapValue, String.valueOf(redecisionreq.lead_guid__c), String.valueOf(redecisionreq.lead_id__c), String.valueOf(redecisionreq.member_id__c)),'redecision');
				String str = JSON.serialize(redeci, true);
				System.debug(' >>>> '+str);
				MW_WebhookHandler.CallWebHookIntegration1(str, String.valueOf(applnlist[0].id), '');
			}

		}
		else if(redecisionreq.Triggered_From__c == 'Application')
		{
			List<String> accFields              = redecisionreq.Body__c.split(',');
			Map<String, String>  accdetailMap   = new Map<String, String>();
			Map<String, String>  detailMapValue = new Map<String, String>();
			String aplicationId                = redecisionreq.Application__c;

			String soql = 'Select id, name, '+ redecisionreq.Body__c +' from genesis__Applications__c where Id =\'' + aplicationId + '\' limit 1';
			System.debug('Soql'+soql);
			List< genesis__Applications__c> appList =  Database.query(soql);

			if(appList.size()>0) {

				genesis__Applications__c record = appList[0];

				for(String redecisionFields:accFields) {

					redecisionFields = redecisionFields.trim();

					System.debug('redecisionFields ' +redecisionFields  );
					System.debug('redecisionFields ' +record.get(redecisionFields));

					detailMapValue.put(redecisionFields, String.valueOf(record.get(redecisionFields)));
					accdetailMap.put('aad.'+String.valueOf(redecisionFields.split('__c')[0]).toLowerCase(),redecisionFields);
				}

				redeci = new red_request(getFieldInformation(accdetailMap, detailMapValue, String.valueOf(redecisionreq.lead_guid__c), String.valueOf(redecisionreq.lead_id__c), String.valueOf(redecisionreq.member_id__c)), 'redecision');
				String str = JSON.serialize(redeci, true);
				System.debug(' >>>> '+str);
				MW_WebhookHandler.CallWebHookIntegration1(str, String.valueOf(appList[0].id), '');
			}
		}
	}

	// "aad.peer__first_name", "peer__First_Name__c"
	// peer__First_Name__c , "Smith"

	public static list<appAccData> getFieldInformation(Map<String, String>  accdetailMap, Map<String, String>  detailMapValue, String lead_guid, String lead_id, String member_id){
		list<appAccData> listFieldInfo  = new list<appAccData>();
		appAccData aad = new appAccData();

		aad.lead_guid  = lead_guid;
		aad.lead_id  = lead_id;
		aad.member_id  = member_id;

		for(String str:accdetailMap.keyset()) {
			if(str=='aad.peer__first_name') aad.first_name = detailMapValue.get(accdetailMap.get(str));
			if(str=='aad.peer__last_name') aad.last_name  = detailMapValue.get(accdetailMap.get(str));
			if(str=='aad.state') aad.state      = detailMapValue.get(accdetailMap.get(str));
			if(str=='aad.city') aad.city       = detailMapValue.get(accdetailMap.get(str));
			if(str=='aad.address_1') aad.street1    = detailMapValue.get(accdetailMap.get(str));
			if(str=='aad.address_2') aad.street2    = detailMapValue.get(accdetailMap.get(str));
			if(str=='aad.zip_code') aad.postal_code    = detailMapValue.get(accdetailMap.get(str));
			if(str=='aad.peer__date_of_birth') aad.date_of_birth = Date.valueOf(detailMapValue.get(accdetailMap.get(str)));
			if(str=='aad.monthly_housing_payment') aad.monthly_housing_payment = Decimal.valueOf(detailMapValue.get(accdetailMap.get(str)));
			if(str=='aad.annual_individual_income') aad.income_annual = Decimal.valueOf(detailMapValue.get(accdetailMap.get(str)));
			if(str=='aad.loan__social_security_number') aad.social_security_number = detailMapValue.get(accdetailMap.get(str));
			if(str=='aad.Requested_loan_amount') aad.requested_loan_amount = Decimal.valueOf(detailMapValue.get(accdetailMap.get(str)));
			if(str=='aad.suffix') aad.suffix = detailMapValue.get(accdetailMap.get(str));
		}

		listFieldInfo.add(aad);
		return listFieldInfo;
	}

	public class red_request
	{
		public String type;
		public appAccData[] data;
		public red_request(appAccData[] appAccData, String type){
			this.data = appAccData;
			this.type=type;
		}
	}


	public class appAccData {
		public String lead_guid;
		public String lead_id;
		public String member_id;
		public String first_name;
		public String last_name;
		public String state;
		public String city;
		public String street1;
		public String street2;
		public String postal_code;
		public Date date_of_birth;
		public Decimal monthly_housing_payment;
		public Decimal income_annual;
		public String social_security_number;
		public Decimal requested_loan_amount;
		public String suffix;
	}



}