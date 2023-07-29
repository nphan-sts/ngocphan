public with sharing class SlackCall implements Queueable{

    private String msg;

    public SlackCall(String msg) {
        this.msg = msg;
    }

    public void execute(QueueableContext context) {
        sendSlackCalls(msg);    
    }

    @future(callout=true)
    public static void sendSlackCalls(String msg){
        if(!Test.isRunningTest()) { 
            MW_SlackCallOut.slackCallOut(MW_Settings__c.getInstance().lsp_team_slack_channel_webhook__c, msg);
        }
    }
}