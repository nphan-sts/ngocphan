// written by Saryu as the addmonths function was not working as expected in calculating the maturity date.
global class maturitydate1 {
    @InvocableMethod
    public static void setmaturitydate(list<id> appId) {
        list<genesis__applications__c> app = [select id, Anniversary_Date__c ,genesis__Term__c,genesis__payment_frequency__c FROM genesis__applications__c WHERE id in:appId and Anniversary_Date__c!=null];
        System.debug('In setmaturitydate');
        list<genesis__applications__c> updateApp = new list<genesis__applications__c>();
        try {
            for(genesis__applications__c a:app) {
                Integer frequencyMultiplier = ((Integer)a.genesis__term__c - 1);
                Integer day = a.Anniversary_Date__c.day();
                Date nextdate = a.Anniversary_Date__c.addMonths(1);
                Date maturityDate = loan.DateUtil.getNextCycleDate(a.Anniversary_Date__c , day,a.genesis__payment_frequency__c,a.Anniversary_Date__c ,nextdate,frequencyMultiplier);
                a.maturityDate__c = maturityDate;
                updateApp.add(a);
            }
			if(updateApp!=null && updateApp.size()>0)
            	update app;
            
       } catch (exception ex) {
            system.debug(logginglevel.error, 'Error a:' + ex.getCause());
            system.debug(logginglevel.error, ex.getLineNumber());
            system.debug(logginglevel.error, ex.getMessage());
            system.debug(logginglevel.error, ex.getStackTraceString());
            throw ex;
        }
        
    }
}