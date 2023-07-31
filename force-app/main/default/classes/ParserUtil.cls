/**
 * Utility Class to Parse Metadata Config specified in Static Resources. 
 * 
 * 
 * @author - Nikhil Chawra
 * **/
public class ParserUtil {
     public static DM_Metadata_Config_Wrapper getParser() {
           //Calling Static Resource
           StaticResource sr;
           DM_Metadata_Config_Wrapper configWrapper;
           if(!Test.isRunningTest())
            sr = [Select body from StaticResource where Name = 'DM_Metadata_Config']; 
           else
            sr = [Select body from StaticResource where Name = 'Test_DM_Metadata_Config'];
              
           if(sr !=null)
                {
                  String jasonMetadata = sr.body.toString();
                  //
                  //system.debug('Json without Parse:::'+ jasonMetadata);
                  configWrapper = (DM_Metadata_Config_Wrapper) JSON.deserialize(sr.body.toString(), DM_Metadata_Config_Wrapper.class);
                  system.debug('Json Parsed:::'+configWrapper);
                  //system.debug('Json Parsed:::'+configWrapper.DM_Metadata_Config.ForEachLendingProduct[0].name);
                }
           return configWrapper;
    }

}