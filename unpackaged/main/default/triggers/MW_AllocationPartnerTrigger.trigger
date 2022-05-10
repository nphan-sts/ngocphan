/**
 * Allocation Engine Service (AES) only inserts these objects.
 * Skuid UI only updates these objects in a manual reallocation.
 *
 * Test Coverage: MW_AllocationEngineHandlerTest
 */
trigger MW_AllocationPartnerTrigger on Allocation_Partner__c (after update) {
    if (Trigger.isAfter && Trigger.isUpdate && MW_AllocationEngineHandler.isAllocationEngineServiceEnabled()) {
        MW_AllocationEngineHandler.handleUpdatedAllocationPartners(Trigger.new);
    }
}