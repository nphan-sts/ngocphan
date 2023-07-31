public class TestTriggerParameter {
    public static Boolean disableTriggerTest = false;
    
    public static void disableTriggerHandler(Boolean disableTriggerParameter){
        disableTriggerTest = disableTriggerParameter;
    }
}