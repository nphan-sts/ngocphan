
//ADCShowBox

public with sharing class ADCShowBoxURLsController
{
    public ApexPages.StandardController Controller;
    public Id adcId{get;set;}
    public genesis__Application_Document_Category__c adc{get;set;}
    public List<String> boxuRLlist{get;set;}
    
    public ADCShowBoxURLsController(ApexPages.StandardController controller)
    {
        this.Controller = Controller;
        adcId = ((genesis__Application_Document_Category__c)Controller.getRecord()).Id;    
        adc = [Select id,name,Box_URL_array__c from genesis__Application_Document_Category__c where id =: adcID];
        if(adc.Box_URL_array__c != null){
            boxuRLlist = adc.Box_URL_array__c.Split(',');
            System.debug('boxuRLlist ' + boxuRLlist );
            system.debug('Size of List **' + boxuRLlist.size());
        }   
        
    }
   
}
