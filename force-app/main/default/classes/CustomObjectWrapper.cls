public with sharing class CustomObjectWrapper {

    public String objectApiName;
    public String ojbectLabel;
    public Integer totalRecord;
    public String objectType;//custom settting, custom object, stardard object, custom metadata, managed packaged
    public CustomObjectWrapper(String objectApiName, String ojbectLabel, String objectType, Integer totalRecord) {
        this.objectApiName = objectApiName;
        this.ojbectLabel = ojbectLabel;
        this.totalRecord = totalRecord;
        this.objectType = objectType;

        System.debug('--objectApiName--' + objectApiName);
        System.debug('--objectType--' + objectType);

    }
}