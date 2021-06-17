public class MWQueuebleJob implements Queueable, Database.AllowsCallouts {

    private List<String> appList                 {get;Set;}

    public MWQueuebleJob(List<String> appList ){
        this.appList = appList;
    }

    public void execute(QueueableContext context) {
        try{
         // -- CLS - 1018
            MW_DocumentCategoryHandler.processDataCate(appList); 
            ID JobID = context.getJobId();
            List<MCCallout__c> newCalloutJob = new list<MCCallout__c>([Select Id, Job_ID__c, Duration__c, Response__c, Send_on__c, Status__c 
                                                From MCCallout__c Where Job_ID__c = : JobID limit 1]);
            if(newCalloutJob.size()>0) {
            newCalloutJob[0].Application__c= new list<String>(appList)[0];
            newCalloutJob[0].Status__c = 'processed';
            update newCalloutJob;
            
            }
             // -- CLS - 1018 ends
            /*List<MCCallout__c> currentCallout = new List<MCCallout__c>([Select Id, Job_ID__c, Duration__c, Response__c, Send_on__c, Status__c 
                                                From MCCallout__c Where Job_ID__c = :context.getJobId() limit 1]);
            ID JobID = context.getJobId();
            if(currentCallout.size()>0){
                Long start = System.now().getTime();
                MW_DocumentCategoryHandler.processDataCate(appList); 
                currentCallout[0].Send_on__c = System.now();
                currentCallout[0].Duration__c = system.now().getTime()-start;
                update currentCallout;
            }*/
        }catch(Exception ex){
            System.debug('******' +ex.getMessage());           
         }
    }
    
    /*
        Calcuate the Anniversary_Date 
     */
    public static Date updateAniveDate(Date signedDate){
        Date annviDate              = signedDate;
        Integer  daysInMonth        = date.daysInMonth(annviDate.year(), annviDate.month());// 31
        Integer  CurrentdayInMonth  = annviDate.day(); //18
        Integer daydiff             = daysInMonth-CurrentdayInMonth;
        if(daydiff<=3){
            if(daydiff==3)  
            annviDate  = annviDate.addDays(6).addMonths(1);
            if(daydiff==2)  
            annviDate  = annviDate.addDays(5).addMonths(1);
            if(daydiff==1)  
            annviDate  = annviDate.addDays(4).addMonths(1);
            if(daydiff==0)  
            annviDate  = annviDate.addDays(3).addMonths(1);    
        }else{
            annviDate  = annviDate.addDays(3).addMonths(1);
        }
        return annviDate;
    }
    
    public static Date updateAniveDate1(Date signedDate){
        Date annviDate              = signedDate;
        Integer  daysInMonth        = date.daysInMonth(annviDate.year(), annviDate.month());// 31
        Integer  CurrentdayInMonth  = annviDate.day(); //18
        Integer daydiff             = daysInMonth-CurrentdayInMonth;
        if(daydiff<=3){
            if(daydiff==3)  
            annviDate  = annviDate.addDays(6).addMonths(1);
            if(daydiff==2)  
            annviDate  = annviDate.addDays(5).addMonths(1);
            if(daydiff==1)  
            annviDate  = annviDate.addDays(4).addMonths(1);
            if(daydiff==0)  
            annviDate  = annviDate.addDays(3).addMonths(1);    
        }else{
            annviDate  = annviDate.addDays(3).addMonths(1);
        }
        return annviDate;
    }
}