global with sharing class DM_Metadata_Config_Wrapper
{   
    global DM_Metadata_Config DM_Metadata_Config;

    global class DM_Metadata_Config
    {
        global List<ForEachLendingProduct> ForEachLendingProduct;
    }
    global class ForEachLendingProduct
    {
        global String name;        
        global List<Config> Config;
    }
    global class Config
    {
        global String srcObj;
        global String trgObj;
        global String strategy;
        global String strategyClass;
        global List<fieldMapping> fieldMapping;
    }
    global class fieldMapping
    {
        global String srcField;
        global String trgField;
        global String dataType;
    }
    
}