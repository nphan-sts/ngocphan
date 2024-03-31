public with sharing class ApiVersion {
    public static String getNewestAPIVersion()
    {
        String latestVersion = 'v50.0';//default
        JSONGenerator gen = JSON.createGenerator(false);
    
        gen.writeObject(new Account(Id='0012p00001aA1AaAAA'));//dummy
    
        for (String part : gen.getAsString().split('/')) {
            if (part.startsWith('v') && part.contains('.') && part.length() == 5) {
                latestVersion = part;
                break;
            }
        }

        return latestVersion;
    }
}