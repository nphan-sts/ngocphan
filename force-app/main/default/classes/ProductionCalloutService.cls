public with sharing class ProductionCalloutService {
    private String token;
    public ProductionCalloutService(String token) {
        this.token = token;
    }
    
    public ManagedPackageCallout.ManagedPackageResponse getManagedPackage() {
        return new ManagedPackageCallout().getManagedPackage(this.token);
    }
}