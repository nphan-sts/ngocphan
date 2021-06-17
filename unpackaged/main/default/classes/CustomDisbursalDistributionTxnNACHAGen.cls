/*
* Custom Changes : Creating multiple Batch header and trailer per effective date.
*
*/
global class CustomDisbursalDistributionTxnNACHAGen extends loan.FileGenerator {
    
    private loan__bank_account__c bank;    
    Long routingHash = 0;
    Integer linecount=0;
    Double blocks =0.0;
    Decimal creditTotal = 0;
    String pMode = 'ACH'; 
    Decimal customCreditTotal = 0;
    Long customRoutingHash = 0;
    Integer customerHashNo = 0;
    Public Date effectiveDate;
    List<Sobject> tempList;
    List<Sobject> tempScope;
    Map<Date,List<SObject>> MapDtxnsToDate = new Map<Date,List<SObject>>();
    Map<Date,Decimal> MapDtxnsToCreditAmount = new Map<Date,Decimal>(); 
    Map<Date,Long> MapDtxnsToRoutingHash = new Map<Date,Long>();
    
    private static String[] abc = new String[] {'A','B','C','D','E','F','G','H','I','J','K',
                                    'L','M','N','O','P','Q','R','S','T','U','V',
                                    'W','X','Y','Z'};

    loan__Automated_paYment_configuration__c autoPmtConfig = new Loan__autoMated_paYment_configuration__c();
    
    //requery scope
    private List<Loan__disbUrsaL_txn_distribution__c> requeryScope(List<SObject> scope){
        Set<ID> scopeIds = new Set<ID>();
        for(SObject s : scope) {
            scopeIds.add(s.Id);
        }
        List<Loan__disbUrsaL_txn_distribution__c> disbTxns = [SELECT Id,loan__Distribution_Amount__c,
                                                                    loan__bank_account__c,
                                                                    loan__Bank_Account__r.loan__Active__c,
                                                                    loan__Bank_Account__r.loan__Contact__c,
                                                                    loan__Bank_Account__r.loan__Account__c,
                                                                    loan__Bank_Account__r.loan__Bank_Name__c,
                                                                    loan__Bank_Account__r.loan__Account_Type__c,
                                                                    loan__Bank_Account__r.loan__Account_Usage__c,
                                                                    loan__Bank_Account__r.loan__Routing_Number__c,
                                                                    loan__Bank_Account__r.Unmasked_Bank_Account_Number__c,
                                                                    loan__Loan_Disbursal_Transaction__r.Loan__bank_account__c,
                                                                    loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__c,
                                                                    loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Name,
                                                                    loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Accrual_Start_Date__c,
                                                                    loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Bank__c,
                                                                    loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Bank__r.Name,
                                                                    loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Bank__r.loan__Routing_Number__c,
                                                                    loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Bank__r.loan__ACH_Code__c,
                                                                    loan__Loan_Disbursal_Transaction__r.loan__Mode_of_Payment__r.Name 
                                                            FROM loan__Disbursal_txn_distribution__c WHERE Id IN :scopeIds];
        
        Set<Id> loanIds = new Set<Id>();
        
        try{
            if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true) {                
                if(disbTxns.size()>0){
                    if(disbTxns[0].loan__Loan_Disbursal_Transaction__r.loan__Mode_of_Payment__r.Name!=null){
                        pMode = disbTxns[0].loan__Loan_Disbursal_Transaction__r.loan__Mode_of_Payment__r.Name;
                    }
                }
                autoPmtConfig = [SELECT Id,loan__Immediate_Destination__c,
                                    loan__Company_Identification__c,
                                    loan__Originating_DFI_Identification__c,
                                    loan__Immediate_Destination_Name__c,
                                    loan__Immediate_Origin__c,
                                    loan__Immediate_Origin_Name__c,
                                    loan__Reference_Code__c,
                                    loan__Trace_Number_Prefix__c,
                                    loan__Bank_Account__r.Unmasked_Bank_Account_Number__c,
                                    loan__Bank_Account__r.loan__Account__c,
                                    loan__Bank_Account__r.loan__Account__r.Name,
                                    loan__Bank_Account__r.loan__Account_Type__c,
                                    loan__Bank_Account__r.loan__Account_usage__c,
                                    loan__Bank_Account__r.loan__Bank_name__c,
                                    loan__Bank_Account__r.loan__ACH_Code__c,
                                    loan__Bank_Account__r.loan__Contact__c,
                                    loan__Bank_Account__r.loan__Contact__r.Name,
                                    loan__Bank_Account__r.loan__Routing_Number__c
                                FROM Loan__autoMated_paYment_configuration__c 
                                WHERE loan__Active__c = true 
                                    AND loan__Bank_Account__r.loan__Account_usage__c INCLUDES  (:loan.FractionalizationConstants.ADVANCE_TRUST_ACCOUNT)
                                    AND loan__Bank_account__r.loan__Active__c = true 
                                    AND loan__Payment_Mode__r.Name =:pMode 
                                    AND loan__Event__c INCLUDES (:loan.Loanconstants.LOAN_DISBURSAL) LIMIT 1];
            }else{
                //throw 
            }
            
        }catch(Exception e){
            throw new peer.MarketplaceException('Advance Trust Account is not available');
        }

        for(Loan__disbUrsaL_txn_distribution__c disbDist: disbTxns){
            loanIds.add(disbDist.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__c);
        }
        
        List<loan__Disbursal_Txn_Distribution__c> retVal = [Select Id
                                                                    , Name 
                                                                    , loan__Distribution_Amount__c  
                                                                    , Loan__bank_account__c 
                                                                    , loan__Bank_Account__r.loan__Active__c 
                                                                    , loan__Bank_Account__r.loan__Contact__c 
                                                                    , loan__Bank_Account__r.loan__Account__c 
                                                                    , loan__Bank_Account__r.loan__Contact__r.name 
                                                                    , loan__Bank_Account__r.loan__Account__r.name 
                                                                    , loan__Bank_Account__r.loan__Bank_Name__c 
                                                                    , loan__Bank_Account__r.loan__Account_Type__c 
                                                                    , loan__Bank_Account__r.loan__Account_Usage__c 
                                                                    , loan__Bank_Account__r.loan__Routing_Number__c 
                                                                    , loan__Bank_Account__r.Unmasked_Bank_Account_Number__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Name
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Accrual_Start_Date__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Drawer_Name__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Relationship_Type__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__bank_account__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r.loan__Account__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r.loan__Account_Type__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r.loan__Account_Usage__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r.loan__Active__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r.Unmasked_Bank_Account_Number__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r.loan__Bank_Name__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r.loan__Contact__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r.loan__Routing_Number__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r.loan__Account__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r.loan__Account_Type__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r.loan__Account_Usage__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r.loan__Active__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r.Unmasked_Bank_Account_Number__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r.loan__Bank_Name__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r.loan__Contact__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r.loan__Routing_Number__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Account_Number__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Loan_Amount__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Account__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Account__r.Name 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Contact__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Contact__r.Name 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Bank__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Bank__r.Name 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Bank__r.loan__ACH_Code__c 
                                                                    , loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Bank__r.loan__Routing_Number__c 
                                                            FROM Loan__Disbursal_Txn_Distribution__c
                                                            WHERE ID in :scopeIds];
        
        return retVal;
    }
    
    public override String getSimpleFileName() {
        if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true){
            return 'Loan_Disbursals_'+pMode;
        }
        return 'Loan_Disbursals';
    }

    public override List<String> getEntries(loan.TransactionSweepToACHState state, List<SObject> scope) {
        
        system.debug(loggingLevel.Error,'----:'+'inside entries'+scope);
        List<String> retVal = new List<String>();
        List<loan__disbUrsaL_txn_distribution__c> disbursalDistributions = requeryScope(scope);
        
        List<SObject> objects = new List<SObject>();
        System.debug(logginglevel.ERROR, 'disbursalDistributions : '+disbursalDistributions );
        for(loan__disbUrsaL_txn_distribution__c dTxn : disbursalDistributions){
            loan__Loan_Account__c loanAccount = dTxn.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r;
            loan__bank_account__c borrBank = new loan__bank_account__c();
            if(dTxn.loan__bank_account__c != null){
                borrBank = dTxn.loan__Bank_Account__r;
            }else if(dTxn.loan__Loan_Disbursal_Transaction__r.loan__bank_account__c != null){
                borrBank = dTxn.loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r;
            }else if(dTxn.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r != null){
                borrBank = loanAccount.loan__Borrower_ACH__r;
            }else{
                addToInvalidScope(dTxn,'Bank Details are missing.');
            }
            
            if(borrBank.id!=null && (borrBank.loan__Routing_Number__c != null || borrBank.Unmasked_Bank_Account_Number__c !=null || dTxn.loan__Distribution_Amount__c != null || borrBank.loan__Account_Type__c != null) ){
                addToValidScope(dTxn);
                
                // creating BODY - entry plus batch with the effective date i.e. Accrual Start Date
                
                Date accrualDtKey = dTxn.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Accrual_Start_Date__c;
                if((MapDtxnsToDate.get(accrualDtKey) != null)){
                    Decimal distributionAmount = 0;
                    Long hashNum = 0;
                    
                    List<SObject> temp = MapDtxnsToDate.get(accrualDtKey);
                    temp.add(generateEntryDetailRecord(dTxn));
                    distributionAmount = (dTxn.loan__Distribution_Amount__c != null ? dTxn.loan__Distribution_Amount__c.setScale(2):0) + MapDtxnsToCreditAmount.get(accrualDtKey);
                    hashNum = customerHashNo  + MapDtxnsToRoutingHash.get(accrualDtKey);
                    MapDtxnsToDate.put(accrualDtKey, temp);
                    MapDtxnsToCreditAmount.put(accrualDtKey, distributionAmount);
                    MapDtxnsToRoutingHash.put(accrualDtKey, hashNum);
                
                }else if (MapDtxnsToDate.get(accrualDtKey) == null){
                
                    List<SObject> temp = new List<SObject>();
                    Decimal distributionAmount = 0;
                    Long hashNum = 0;
                    effectiveDate = accrualDtKey;
                    temp.add(generateBatchHeaderRecord());
                    temp.add(generateEntryDetailRecord(dTxn));
                    distributionAmount = (dTxn.loan__Distribution_Amount__c != null ? dTxn.loan__Distribution_Amount__c.setScale(2):0);
                    hashNum = customerHashNo ;
                    MapDtxnsToDate.put(accrualDtKey, temp);
                    MapDtxnsToCreditAmount.put(accrualDtKey, distributionAmount);
                    MapDtxnsToRoutingHash.put(accrualDtKey, hashNum);
                            
                }
                                               
                //objects.add(generateEntryDetailRecord(dTxn));                          
            }
            else{
                 addToInvalidScope(dTxn,'Borrower Ach routing no, Loan account ACH Account number or Distribution amount is missing');
            }
        }// for loop ends here.
        
        for(date key : MapDtxnsToDate.keySet()){
            
            System.debug(logginglevel.ERROR, 'IN FOR LOOP : MapDtxnsToDate.keySet() :'+MapDtxnsToDate.keySet());
            tempList = new List<Sobject>();
            tempList = MapDtxnsToDate.get(key);
            customCreditTotal = MapDtxnsToCreditAmount.get(key);
            customRoutingHash = MapDtxnsToRoutingHash.get(key);
            
            //adding the Trailer here.
            tempList.add(generateBatchControlRecord(tempList)); 
            objects.addall(tempList);
                    
        }
        
        filegen.CreateSegments segments = new filegen.CreateSegments(objects);
        retVal = segments.retString();
        for(String line:retVal){
            line = line+'\n';
            addEntry(line);
        }
        return retVal;
    }
    
    public override String getHeader(loan.TransactionSweepToACHState state, List<SObject> scope) {
        String header = '';
        List<String> retVal = new List<String>();
        List<SObject> headerRecs = new List<SObject>();
        headerRecs.add(generateFileHeaderRecord(state));
        //headerRecs.add(generateBatchHeaderRecord());
        system.debug(logginglevel.error, 'headerRecs'+headerRecs);
        filegen.CreateSegments segments =new filegen.CreateSegments(headerRecs);
        system.debug(logginglevel.error, 'segments'+segments);        
        retVal = segments.retString();
        system.debug(logginglevel.error, 'retVal '+retVal );                
        header =retVal[0]+'\r\n';
        //header+=retVal[1] + '\r\n';
        return header;
        
    }
    
    public override String getTrailer(loan.TransactionSweepToACHState state, LIST<SObject> scope) {
        String achFileTrailerContent = '';
        List<String> retVal = new List<String>();
        List<SObject> trailerRecs = new List<SObject>();
        //trailerRecs.add(generateBatchControlRecord(scope));
        trailerRecs.add(generateFileControlRecord(scope));
        filegen.CreateSegments segments =new filegen.CreateSegments(trailerRecs);
        retVal = segments.retString();

        for(String s : retVal){
            achFileTrailerContent = achFileTrailerContent + s + '\r\n';
        }        
        Integer fillersToAdd = Integer.valueOf( blocks * 10 ) - linecount;
        
        achFileTrailerContent = achFileTrailerContent.subString( 0 , achFileTrailerContent.length() - 2 );
        
        //fillers are added to make number of characters in generated file multiple of 940
        for(Integer i = 0 ; i < fillersToAdd ; i++ ) {
            achFileTrailerContent = achFileTrailerContent + '\r\n'+ rightPadString('', 94,'9');
        }
        
        return achFileTrailerContent + '\r\n';
        //return 'TRAILER';
    }
    //File header
    
    private filegen__File_Header_Record__c generateFileHeaderRecord(loan.TransactionSweepToACHState state){
        
        Datetime currentSystemDateTime = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        Date csd = Date.newInstance(currentSystemDateTime.year(), currentSystemDateTime.month(), currentSystemDateTime.day());
        String hour = (currentSystemDateTime.hour()>=10?String.valueOf(currentSystemDateTime.hour()):'0'+currentSystemDateTime.hour());
        String minute = (currentSystemDateTime.minute()>=10?String.valueOf(currentSystemDateTime.minute()):'0'+currentSystemDateTime.minute());
        String myTime = hour + minute;

        filegen__File_Header_Record__c fHR = new filegen__File_Header_Record__c();
        String immediateDestination ='';
        String immediateOrigin = '';
        Integer counter= 0;
        String immediateDestinationName = '';
        String referenceCode = '';
        String immediateOriginName = '';
        Map<String,Integer> countMap = (Map<String,Integer>)state.o2;
        
        if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true){
            if(autoPmtConfig.loan__Immediate_Destination__c!=null){
                immediateDestination = loan.StringUtils.leftPadString( '' +autoPmtConfig.loan__Immediate_Destination__c,9,'0');
            }
            if(autoPmtConfig.loan__Immediate_origin__c!=null){
                immediateOrigin = autoPmtConfig.loan__Immediate_origin__c;
            }
            if(countMap.get(pMode)==null){
                countMap.put(pMode,0);
                state.o2 = countMap;
            }
            counter =countMap.get(pMode);
            if(autoPmtConfig.loan__Immediate_Destination_Name__c!=null){
                immediateDestinationName = autoPmtConfig.loan__Immediate_Destination_Name__c ;
            }
            if(autoPmtConfig.loan__Immediate_Origin_Name__c!=null){
                immediateOriginName = autoPmtConfig.loan__Immediate_Origin_Name__c;
            }
            if(autoPmtConfig.loan__Reference_Code__c!=null){
                referenceCode = autoPmtConfig.loan__Reference_Code__c;
            }
        }else{
            //throw new peer.MarketplaceExcpetion('Old ACH is not supported.');
        }
           
        fHR.filegen__Immediate_Destination__c = immediateDestination;
        fHR.filegen__Immediate_Origin__c = immediateOrigin;
        fHR.filegen__Creation_Date__c = csd;
        fHR.filegen__Creation_Time__c = myTime;
        fHR.filegen__ID_Modifier__c = abc[counter] ;
        fHR.filegen__Immediate_Destination_Name__c = immediateDestinationName;
        fHR.filegen__Immediate_Origin_Name__c = immediateOriginName;
        fHR.filegen__Reference_Code__c = referenceCode;
        return fHR;
    }
    
    //Batch Header
     private filegen__Batch_Header_Record__c generateBatchHeaderRecord(){
     
        System.debug(logginglevel.ERROR, 'IN GENRATEBATCHHEADER');
        Datetime currentSystemDateTime = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        Date csd = Date.newInstance(currentSystemDateTime.year(), currentSystemDateTime.month(), currentSystemDateTime.day());
        filegen__Batch_Header_Record__c bHR = new filegen__Batch_Header_Record__c();
        String companyName = '';
        String companyIdentification = '';
        String originatingDFIIdentification = '';
        
        if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true){
            if(autoPmtConfig.loan__Immediate_Origin_Name__c!=null){
                companyName = autoPmtConfig.loan__Immediate_Origin_Name__c;
            }
            if(autoPmtConfig.loan__Company_Identification__c!=null){
                companyIdentification = autoPmtConfig.loan__Company_Identification__c;
            }
            if(autoPmtConfig.loan__Originating_DFI_Identification__c!=null){
                originatingDFIIdentification = loan.StringUtils.leftPadString(''+autoPmtConfig.loan__Originating_DFI_Identification__c,8,'0');
            }
        }else{
            //throw 
        }
        bHR.filegen__Service_Class_Code__c = '220';
        bHR.filegen__Company_Name__c = companyName;
        bHR.filegen__Company_Discretionary_Data__c = 'ACH_PAYMENTS';
        bHR.filegen__Company_Identification__c = companyIdentification;
        
        bHR.filegen__SEC_Code__c = 'PPD';
        bHR.filegen__Company_Entry_Description__c = 'AUTOPAY';
        bHR.filegen__Company_Descriptive_Date__c = effectiveDate;//csd;
        bHR.filegen__Effective_Entry_Date__c = effectiveDate;//csd;
        bHR.filegen__Originating_DFI_Identification__c = originatingDFIIdentification;
        bHR.filegen__Batch_Number__c = '0000123';
        return bHR;
    }
    
    //Entry Detail
    private filegen__Entry_Detail_Record__c generateEntryDetailRecord(Loan__disbUrsaL_txn_distribution__c disbursalDistTxn){
        
        filegen__Entry_Detail_Record__c eDR = new filegen__Entry_Detail_Record__c();
        loan__Loan_Account__c loanAccount = disbursalDistTxn.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r;
        Loan__bank_account__c borrBank = new Loan__bank_account__c();

        if(disbursalDistTxn.Loan__bank_account__c!=null){
            borrBank = disbursalDistTxn.loan__Bank_Account__r;
        }else if(disbursalDistTxn.loan__Loan_Disbursal_Transaction__r.Loan__bank_account__c!=null){
            borrBank = disbursalDistTxn.loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r;
        }else{
            borrBank = loanAccount.loan__Borrower_ACH__r;
        }
        
        if(loan.Loanconstants.ACCOUNT_TYPE_SAVING.equalsIgnoreCase(borrBank.loan__Account_Type__c) 
            || Loan.loanconstants.ACCOUNT_TYPE_SAVINGS.equalsIgnoreCase(borrBank.loan__Account_Type__c) ){
            eDR.filegen__Transaction_Code__c = '32';
        }else if(Loan.loanconstants.ACCOUNT_TYPE_CHECKING.equalsIgnoreCase(borrBank.loan__Account_Type__c)){
            eDR.filegen__Transaction_Code__c = '22';
        }
        String customerName = '';
        if(disbursalDistTxn.loan__Bank_Account__r != null) {
            if(disbursalDistTxn.loan__Bank_Account__r.loan__Account__c !=null) {
                customerName = disbursalDistTxn.loan__Bank_Account__r.loan__Account__r.name;
            } else if(disbursalDistTxn.loan__Bank_Account__r.loan__Contact__c != null) {
                customerName = disbursalDistTxn.loan__Bank_Account__r.loan__Contact__r.name;
            }
        }else if(loanAccount.loan__ACH_Relationship_Type__c == null || loanAccount.loan__ACH_Relationship_Type__c ==    Loan.loanconstants.ACH_RELATIONSHIP_TYPE_PRIMARY){ 
            if(loanAccount.loan__Account__c != null){
                customerName = loanAccount.loan__Account__r.Name;
            }
            else if(loanAccount.loan__Contact__c != null){
                customerName = loanAccount.loan__Contact__r.Name;
            }
        }else{
            customerName = loanAccount.loan__ACH_Drawer_Name__c;
        }
        
        String customerRoutingNo = '';
        if(borrBank.loan__Routing_Number__c != null){
            customerRoutingNo = String.valueOf(borrBank.loan__Routing_Number__c);
        }
        
        if(customerRoutingNo.length()<9){
            customerRoutingNo=loan.StringUtils.leftPadString(''+customerRoutingNo,9,'0');
        }
        
        eDR.filegen__RDFI_Identification__c = customerRoutingNo;
        String checkDigit = '';
        if(borrBank.loan__Routing_Number__c != null && borrBank.loan__Routing_Number__c.length() >=8 ){
            checkDigit = borrBank.loan__Routing_Number__c.substring(8);
        }
        eDR.filegen__Check_Digit__c = checkDigit;
        eDR.filegen__RDFI_Account_Number__c = borrBank.Unmasked_Bank_Account_Number__c != null ?borrBank.Unmasked_Bank_Account_Number__c:'';
        eDR.filegen__Amount__c = disbursalDistTxn.loan__Distribution_Amount__c != null ?String.valueOf(disbursalDistTxn.loan__Distribution_Amount__c.setScale(2)):'';
        String customerLoanName = loan.StringUtils.rightPadString(loanAccount.Name.replace('-','0'),15, ' ');
        eDR.filegen__Individual_Identification_Number__c = customerLoanName;
        eDR.filegen__Individual_Name__c = customerName;
        eDR.filegen__Addenda_Record_Indicator__c='0';
        String tracePrefix = '';
        String traceNum = '';
        if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true){
            if(autoPmtConfig.loan__Trace_Number_Prefix__c!=null){
                tracePrefix = autoPmtConfig.loan__Trace_Number_Prefix__c;
            }
        }else{
            //throw 
        }
        
        if( tracePrefix != null){
            traceNum = String.valueOf(tracePrefix+disbursalDistTxn.Name.subString(6));
        }else{
            traceNum = loan.StringUtils.leftPadString((disbursalDistTxn.Name.subString(7)),15, '0');
        }
        eDR.filegen__Trace_Number__c = traceNum;
        
        customerHashNo = 0;
        if(borrBank != null && borrBank.loan__Routing_Number__c != null && borrBank.loan__Routing_Number__c.length() >=8){
            customerHashNo = Double.valueOf( borrBank.loan__Routing_Number__c.substring(0,8) ).intValue();
        }
        routingHash = routingHash + customerHashNo;
        creditTotal = creditTotal + (disbursalDistTxn.loan__Distribution_Amount__c != null ?disbursalDistTxn.loan__Distribution_Amount__c.setScale(2):0);
        
        return eDR;
    }
    
    //Batch Control
    private filegen__Batch_Control_Record__c generateBatchControlRecord(LIST<SObject> scope){
        
        filegen__Batch_Control_Record__c bCR = new filegen__Batch_Control_Record__c();        
        
        bCR.filegen__Service_Class_Code__c = '220';
        bCR.filegen__Entry_Addenda_Count__c = String.valueOf(scope.size() - 1);
        bCR.filegen__Entry_Hash__c = String.valueOf(customRoutingHash);
        bCR.filegen__Total_Credit_Entry_Dollar_Amount__c = String.valueOf(Integer.valueOf(customCreditTotal.setScale(2)*100));
        String companyIdentification = '';
        String originatingDFIIdentification = '';
        
        if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true){
            if(autoPmtConfig.loan__company_identification__c!=null){
                companyIdentification = autoPmtConfig.loan__Company_Identification__c;
            }
            if(autoPmtConfig.loan__originating_DFI_Identification__c!=null){
                originatingDFIIdentification =loan.StringUtils.leftPadString(''+ autoPmtConfig.loan__Originating_DFI_Identification__c,8,'0');
            }
        }else{
            //throw new MarketplaceException('');
        }
        
        bCR.filegen__Company_Identification__c = companyIdentification;
        
        bCR.filegen__Originating_DFI_Identification__c = originatingDFIIdentification;
        bCR.filegen__Batch_Number__c = '0000123';
        return bCR;
    }
    
    //File Control
    private filegen__File_Control_Record__c generateFileControlRecord(LIST<SObject> scope){
        filegen__File_Control_Record__c fCR = new filegen__File_Control_Record__c();
        
        linecount = getValidScope().size()+4;
        blocks = math.ceil((double.valueOf(linecount))/10);
        fCR.filegen__Batch_Count__c = '000001';
        fCR.filegen__Block_Count__c = String.valueOf(Integer.valueOf(blocks));
        fCR.filegen__Entry_Addenda_Count__c = String.valueOf(getValidScope().size());
        fCR.filegen__Entry_Hash__c = String.valueOf(routingHash);
        fCR.filegen__Total_Credit_Entry_Dollar_Amount_in_Fi__c = String.valueOf(Integer.valueOf(creditTotal.setScale(2)*100));
        return fCR;
    }
    
    String rightPadString(String str, Integer size, String padString) {    
        if (str == null) {
            return null;
        }        
        Integer len = str.length();
        
        if(len>size){
            //If string length is greater than 'size', truncate
            return str.mid(0,size);
        }        
        return str.rightPad(size,padString);
    }
}