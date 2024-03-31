global class CustomAutoWriteOff implements Schedulable {

    global void execute(SchedulableContext SC) {
        
        //Get Org Params
        loan__Org_Parameters__c orgPAram = loan.CustomSettingsUtil.getOrgParameters();
        
        
        List<String> allowableLoanStatuses = new List<String>();
        allowableLoanStatuses.add('\'' + 'Active - Good Standing' + '\'');
        allowableLoanStatuses.add('\'' + 'Active - Bad Standing' + '\'');
        allowableLoanStatuses.add('\'' + 'Active - Matured' + '\'');

        //get custom query
        String query = 'SELECT Id, ' +
                                'Name, ' +
                                'Interest_Remaining__c, ' +
                                'Principal_Remaining__c, ' +
                                'Loan_Balance__c, ' +
                                'Fees_Remaining__c, ' +
                                'Capitalized_Interest__c, ' +
                                'Capitalized_Fee__c, ' +
                                'Interest_Posted__c, ' +
                                'Loan_Status__c, ' +
                                'Total_Overdue_Fees__c, ' +
                                'Total_Amount_Overdue__c, ' +
                                'Loan_Product_Name__c, ' +
                                'Delinquent_Amount__c, ' +
                                'Branch__c, ' +
                                'Uncleared_Written_Off_Amount__c, ' +
                                'ACH_On__c, ' +
                                'OT_ACH_Payment_Amount__c, ' +
                                'OT_ACH_Fee_Amount__c, ' +
                                'Number_of_Days_Overdue__c ' +
                            'FROM Loan_Account__c ' +    
                            'WHERE Number_of_Days_Overdue__c  >= ' + orgPAram.WriteOffSuggestion__c +
                            ' AND Number_of_Days_Overdue__c != null ' +
                            ' AND Loan_Status__c in ' + allowableLoanStatuses +
                            ' AND Invalid_Data__c = false' +
                            ' AND Skip_AutoWriteOff__c = false';
        
        loan.AutoWriteOffJob a = new loan.AutoWriteOffJob(query);
        Database.executeBatch(a,50);
    }

}