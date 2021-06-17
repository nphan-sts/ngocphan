/**
 * A Call Out class to send logs to DataDog.
 * The URL and API Key are retrieved from MW_Settings, and if either of these
 *  are unset, it will not send to DataDog at all.
 */
public class MW_DataDogCallOut {
	private static final String url = MW_Settings__c.getInstance()
		.DataDogApiURL__c;
	private static final String apiKey = MW_Settings__c.getInstance()
		.DataDogApiKey__c;
	private static final String tags = MW_Settings__c.getInstance()
		.DataDogTags__c;
	private static final String service = 'CLS';

	/**
	 * This takes a MW_LogUtility_Queueable.Log and converts it to JSON to send to DataDog.
	 * Additionally, it adds additional facets with their corresponding facet name.
	 */
	public static void send(MW_LogUtility_Queueable.Log log) {
		List<String> facetList = new List<String>();
		facetList.add('severity:' + log.type);
		futureSend(JSON.serialize(log), facetList);
	}

	/**
	 * This takes a MW_LogUtility.Log and converts it to JSON to send to DataDog.
	 * Additionally, it adds additional tags for severity, lead ID, and account ID.
	 */
	public static HttpResponse send(MW_LogUtility.Log log) {
		return send(log, new List<String>());
	}

	public static HttpResponse send(
		MW_LogUtility.Log log,
		List<String> additionalTags
	) {
		additionalTags.add('severity:' + log.type);
		if (log.leadId != null) {
			additionalTags.add('leadId:' + log.leadId);
		}
		if (log.applicationId != null) {
			additionalTags.add('applicationId:' + log.applicationId);
		}
		return send(JSON.serialize(log), additionalTags);
	}

	/**
	 * This sends a preformatted message string to datadog.
	 */
	public static HttpResponse send(String message) {
		return send(message, new List<string>());
	}

	@Future(callout=true)
	public static void futureSend(String message, List<String> additionalTags) {
		send(message, additionalTags);
	}

	public static HttpResponse send(String message, List<String> additionalTags) {
		HttpResponse response = new HttpResponse();
		if (String.isEmpty(apiKey) || String.isEmpty(url)) {
			System.debug(
				'DataDog API Key or URL is not set; unable to send logs to DataDog.'
			);
			return response;
		}
		if (!String.isEmpty(tags)) {
			additionalTags.add(tags);
		}

		Map<String, Object> body = new Map<String, Object>();
		body.put('ddtags', String.join(additionalTags, ','));
		body.put('ddsource', 'Salesforce');
		body.put('message', message);
		body.put('service', service);

		HttpRequest req = new HttpRequest();
		req.setEndpoint(url);
		req.setTimeout(2 /* seconds */ * 1000 /* milliseconds */);
		req.setMethod('POST');
		req.setHeader('DD-API-KEY', apiKey);
		req.setHeader('Content-Type', 'application/json');
		req.setBody(JSON.serialize(body));
		Http http = new Http();
		try {
			response = http.send(req);
		} catch (Exception e) {
			System.debug('Unable to contact DataDog.' + e.getMessage());
		}
		return response;
	}

	/**
	 * This takes a List of MW_LogUtility.Log and converts it to JSON to send to DataDog.
	 * Additionally, it adds additional tags for severity, lead ID, and account ID.
	 */
	public static HttpResponse sendBatch(List<MW_LogUtility.Log> logs) {
		return sendBatch(logs, new List<String>());
	}
	public static HttpResponse sendBatch(
		List<MW_LogUtility.Log> logs,
		List<String> additionalTags
	) {
		HttpResponse response = new HttpResponse();
		if (String.isEmpty(apiKey) || String.isEmpty(url)) {
			System.debug(
				'DataDog API Key or URL is not set; unable to send logs to DataDog.'
			);
			return response;
		}
		List<Map<String, Object>> bodies = new List<Map<String, Object>>();
		for (MW_LogUtility.Log log : logs) {
			List<String> logTags = additionalTags.clone();
			logTags.add('severity:' + log.type);
			if (log.leadId != null) {
				logTags.add('leadId:' + log.leadId);
			}
			if (log.applicationId != null) {
				logTags.add('applicationId:' + log.applicationId);
			}
			if (!String.isEmpty(tags)) {
				logTags.add(tags);
			}
			Map<String, Object> body = new Map<String, Object>();
			body.put('ddtags', String.join(logTags, ','));
			body.put('ddsource', 'Salesforce');
			body.put('message', JSON.serialize(log));
			body.put('service', service);
			bodies.add(body);
		}

		HttpRequest req = new HttpRequest();
		req.setEndpoint(url);
		req.setTimeout(2 /* seconds */ * 1000 /* milliseconds */);
		req.setMethod('POST');
		req.setHeader('DD-API-KEY', apiKey);
		req.setHeader('Content-Type', 'application/json');
		req.setBody(JSON.serialize(bodies));
		Http http = new Http();
		try {
			response = http.send(req);
		} catch (Exception e) {
			System.debug('Unable to contact DataDog.' + e.getMessage());
		}
		return response;
	}
}