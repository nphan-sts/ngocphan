public class MW_SlackCallOut { //implements Queueable, Database.AllowsCallouts {
	// private final String url;
	// private final String method;
	// private final String body;

	// public MW_SlackCallOut(String url, String method, String body) {
	//      this.url = url;
	//      this.method = method;
	//      this.body = body;
	// }
	public static void callSlack(MW_LogUtility.Log log){
		Map<String, Object> msg = new Map<String, Object>();
		msg.put('text', messageIcon(log.type) + '\n' +
		        '*Type:* ' + log.type + '\n' +
		        '*Application* *Id:* ' + log.applicationId + '\n' +
		        '*Lead* *ID:* ' + log.leadId + '\n' +
				// '*UTM* *Source:* ' + log.utm_source + '\n' +
				// '*UTM* *utm_medium:* ' + log.utm_medium + '\n' +
		        '*Apex* *Class:* ' + log.apexClass + '\n' +
		        '*Method:* ' + log.method + '\n' +
		        '*Status* *Code:* ' + log.statusCode + '\n' +
		        // '*Message:* ' + '```' + removePIIData(log.message) + '```' + '\n' +
		        '*Message:* ' + '```' + removePIIData(((MW_LogUtility.ExceptionDO)log.data).message) + '```' + '\n' +
		        // '*Stack Trace:* ' + '```' + log.stackTrace + '```');
		        '*Stack Trace:* ' + '```' + ((MW_LogUtility.ExceptionDO)log.data).stackTrace + '```');
		String body = JSON.serialize(msg);
		if(!Test.isRunningTest()) {
			slackCallOut(logLevelChannels(log.type), body);
		}
	} 

	public static void slackCallOut(String url, String body){
		HttpRequest req = new HttpRequest();
		req.setEndpoint(url);
		req.setMethod('POST');
		req.setBody(body);
		Http http = new Http();
		HttpResponse res = http.send(req);
	}

	public static String messageIcon(String level){
		if(level == 'Error') {
			return MW_Settings__c.getInstance().Slack_Alert_Icon__c;
		}
		else{
			//Panda icon
			return MW_Settings__c.getInstance().Slack_Info_Icon__c;
		}
	}

	public static String logLevelChannels(String level){
		if(level == 'Error') {
			return MW_Settings__c.getInstance().Slack_Alert_Channels__c;
		}
		else{
			return MW_Settings__c.getInstance().Slack_Info_Channels__c;
		}
	}

	public static String removePIIData(String logMessage){
		if(logMessage != null) {
			for(String attribute : piiAttribute()) {
				if(logMessage.substringBetween(attribute, ',') != null) {
					logMessage = logMessage.replace(logMessage.substringBetween(attribute, ','), ':"PII Encrypted"');
				}
				//might be end of json
				else if(logMessage.substringBetween(attribute, '}') != null) {
					logMessage = logMessage.replace(logMessage.substringBetween(attribute, '}'), ':"PII Encrypted"}');
				}
			}
		}
		return logMessage;
	}

	public static List<String> piiAttribute(){
		List<String> result = new List<String>{'"social_security_number"', '"first_name"', '"last_name"', '"state"',
			                               '"city"', '"street1"', '"street2"', '"postal_code"',
			                               '"date_of_birth"', '"monthly_housing_payment"', '"income_annual"', '"zip_code"',
			                               '"phone"', '"peer_last_name"', '"peer_first_name"', '"peer_date_of_birth"',
			                               '"housing_status"', '"annual_individual_income"'};
		return result;
	}
	// public void execute(QueueableContext ctx) {
	//      HttpRequest req = new HttpRequest();
	//      req.setEndpoint(url);
	//      req.setMethod(method);
	//      req.setBody(body);
	//      Http http = new Http();
	//      HttpResponse res = http.send(req);
	// }
}