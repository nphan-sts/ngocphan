public with sharing class SlackCall implements Queueable {

    private Map<String, String> mapChannelMsg;

    public SlackCall(Map<String, String> mapChannelMsg) {
        this.mapChannelMsg = mapChannelMsg;
    }

    public void execute(QueueableContext context) {
        for (string channel : mapChannelMsg.keySet()) {
            sendSlackCalls(mapChannelMsg.get(channel), channel);
        }
    }

    @future(callout=true)
    static void sendSlackCalls(String msg, String channel) {
        if (!Test.isRunningTest()) {
            MW_SlackCallOut.slackCallOut(channel, msg);
        }
    }
}