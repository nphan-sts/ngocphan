global class CustomACHReturnFileParser extends loan.ACHReturnPaymentProcessor{
    public List<loan.ACHReturn> achReturns = new List<loan.ACHReturn>();
    
    public override List<loan.ACHReturn> parseFile(String fileContent,String objectType) {
        
        Date systemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        
        List<String> bodyLines = fileContent.split('\n');
        
        Map<String,String> loanNamesToReturnCodeMap = new Map<String,String>();
        Map<String,String> loanNames = new Map<String,String>();
        Map<String,Date> loanToLptDateMap = new Map<String,Date>();
        Map<String,String> loanToLPTNameMap = new Map<String,String>();
        Map<String,List<String>> loanToLPTs = new Map<String,List<String>>();     //Map to store Loan Id vs List of Lpts received in file to reverse.
        String lptErrors = 'Error|CL Contract|Last Seven Digits of LPT \n';
        
        system.debug(bodyLines[0]);
        Integer currentYear = systemDate.year();
        String first2DegitOfTheCurrentYear = String.valueof(currentYear).subString(0,2);
        Boolean lptReversalFound = False;
        Boolean disbursalRevFound = False;
        Boolean changeCodeFound = False;
        Date lptDate;
        
        List<String> PPDAdvanceEntries = new List<String>();
        String DDPAdvanceHeader = 'Borrower Name,Loan,Return Code'+'\r\n';
        PPDAdvanceEntries.add(DDPAdvanceHeader );
        String PPDAdvancefileBody = '';
        
        List<String> CORPaymentEntries = new List<String>();
        String  CORPaymentHeader = 'Borrower Name,Loan,Return Code,Description'+'\r\n';
        CORPaymentEntries.add(CORPaymentHeader );
        String CORPaymentfileBody = '';
        
        List<String> entry = new List<String>();
        String loanEntry = '';
        
        List<String> changeCodeentry = new List<String>();
        String changeCodeloanEntry = '';
        
        try{
            for(Integer iterator = 0;iterator < bodyLines.size();iterator++ ){
                String line = bodyLines[iterator];
                system.debug('--Line--'+line);
                
                if(!lptReversalFound) {
                    if(line.startsWith('5')
                       && line.subString(50,60).equalsIgnoreCase('PPDAUTOPAY')) {
                           lptDate = Date.newInstance(Integer.valueof(first2DegitOfTheCurrentYear + line.subString(67,69)),
                                                      Integer.valueof(line.subString(63,65)),
                                                      Integer.valueof(line.subString(65,67)));
                           
                           lptReversalFound = True;
                           disbursalRevFound = False;
                           changeCodeFound = False;
                       }else{
                           lptReversalFound = False;
                       }
                }
                
                if(line.startsWith('6') && lptReversalFound) {
                    String txnName = '';
                    String loanName = '';
                    String refForNextLine = '';
                    
                    if(line.subString(39,42).equals('LAI')) {
                        //Formulate Loan Name in CLI format
                        loanName = line.subString(39,51);
                        System.debug(logginglevel.error,'---loanName 1 :: ---'+loanName);
                        loanName = loanName.subString(0,3)+'-'+loanName.subString(4,loanName.length());
                        System.debug(logginglevel.error,'---loanName 2 :: ---'+loanName);
                        if(loanName.charAt(loanName.length()-1)==32 ){
                            loanName = loanName.substring(0, loanName.length()-1);
                        }
                        txnName = bodyLines[iterator + 1].subString(14,21);
                        loanToLPTNameMap.put(loanName,txnName);
                        List<String> lpts = loanToLPTs.get(loanName);
                        if(lpts == null) {
                            lpts =  new List<String>();
                            loanToLPTs.put(loanName,lpts);
                        }       
                        
                        
                        lpts.add(txnName);
                        
                        refForNextLine = line.subString(79,94);
                        loanNames.put(refForNextLine,loanName);
                        
                        //If Lpts are more than 1, remove & add to csv
                        if(lpts.size() > 1) {
                            //remove lpt from map, will be processed manually.
                            LoanToLptDateMap.remove(loanName);
                            if(lptErrors == null){
                                lptErrors = 'More than one LPTs found on Same Loan' + '|' + loanName + '|' + lpts[0] + ':' + lpts[1] + '\r\n';
                            }
                            else{
                                lptErrors += 'More than one LPTs found on Same Loan' + '|' + loanName + '|' + lpts[0] + ':' + lpts[1] + '\r\n';
                            }
                            //
                            
                        }else {//add to map for processing 
                            LoanToLptDateMap.put(loanName,lptDate);
                        }
                        
                    }  
                }else if(line.startsWith('799') && lptReversalFound){
                    String returnCode = '';
                    returnCode = line.subString(3,6);
                    loanNamesToReturnCodeMap.put(loanNames.get(line.subString(79,94)),returnCode);
                }
                
                /*
                * Disbursal Reversals
                */
                if(!disbursalRevFound) {
                    if(line.startsWith('5')
                       && line.subString(50,60).equalsIgnoreCase('PPDADVANCE')){
                           
                           disbursalRevFound = True;
                           lptReversalFound = False;
                           changeCodeFound = False;
                       }else{
                           disbursalRevFound = False;
                       }
                }
                
                system.debug('--disbursalRevFound--'+disbursalRevFound);
                
                if(line.startsWith('6') && disbursalRevFound) {
                    String loanName = '';
                    String borrowerName = '';
                    
                    if(line.subString(39,42).equals('LAI')){
                        loanName = line.subString(39,51);
                        loanName = loanName.subString(0,3)+'-'+loanName.subString(4,loanName.length());
                        if(loanName.charAt(loanName.length()-1)==32 ){
                            loanName = loanName.substring(0, loanName.length()-1);
                        }
                        borrowerName = line.subString(54,78);
                        entry.add(borrowerName);
                        entry.add(loanName);
                    }  
                }else if(line.startsWith('799') && disbursalRevFound){
                    String returnCode = '';
                    returnCode = line.subString(3,6);
                    entry.add(returnCode);
                    for(String e :entry){
                        loanEntry += e +',';
                    }
                    loanEntry.removeEnd(',');
                    loanEntry += '\r\n';
                    PPDAdvanceEntries.add(loanEntry);
                }
                
                /*
                * Change code Processing.
                */
                system.debug('--loanEntry--'+loanEntry);
                if(!changeCodeFound){
                    if(line.startsWith('5')
                       && line.subString(50,60).equalsIgnoreCase('CORPAYMENT')){
                           changeCodeFound= True;
                           lptReversalFound = False;
                           disbursalRevFound = False;
                       }else{
                           changeCodeFound = False;
                       }
                }
                system.debug('--changeCodeFound--'+changeCodeFound);
                if(line.startsWith('6') && changeCodeFound){
                    String loanName = '';
                    String borrowerName = '';
                    system.debug('--line.subString(39,42)--'+line.subString(39,42));
                    if(line.subString(39,42).equals('LAI')){
                        loanName = line.subString(39,51);
                        loanName = loanName.subString(0,3)+'-'+loanName.subString(4,loanName.length());
                        if(loanName.charAt(loanName.length()-1)==32 ){
                            loanName = loanName.substring(0, loanName.length()-1);
                        }
                        borrowerName = line.subString(52,78);
                        changeCodeentry.add(borrowerName);
                        changeCodeentry.add(loanName);
                    }  
                }else if(line.startsWith('798') && changeCodeFound){
                    String returnCode = '';
                    String description = '';
                    returnCode = line.subString(3,6);
                    changeCodeentry.add(returnCode);
                    changeCodeentry.add(line.subString(27,60));
                    for(String e :changeCodeentry){
                        changeCodeloanEntry += e +',';
                    }
                    changeCodeloanEntry.removeEnd(',');
                    changeCodeloanEntry += '\r\n';
                    CORPaymentEntries.add(changeCodeloanEntry);
                }
                system.debug('--changeCodeloanEntry--'+changeCodeloanEntry);
                if(line.startsWith('7')){
                    changeCodeFound= False;
                    lptReversalFound = False;
                    disbursalRevFound = False;
                    entry = new List<String>();
                    loanEntry = '';
                    
                    changeCodeentry = new List<String>();
                    changeCodeloanEntry = '';
                }
                
            } 
            
            //Insert Reversal Advance file
            system.debug('--PPDAdvanceEntries--'+PPDAdvanceEntries);
            if(PPDAdvanceEntries != null && PPDAdvanceEntries.size() > 1) {
                String PPDAdvancefolderName = loan.CustomSettingsUtil.getACHParameters().PPDAdvance_Folder_Name__c;
                String PPDAdvancefolderId;
                
                for(String s : PPDAdvanceEntries) {
                    PPDAdvancefileBody += s;
                }
                if (PPDAdvancefolderName != null) {
                    Folder[] folder = [SELECT Id FROM Folder WHERE Name = :PPDAdvancefolderName];
                    if (folder.size() > 0) {
                        PPDAdvancefolderId = folder[0].Id;
                    } else {
                        PPDAdvancefolderId = (Id) UserInfo.getUserId();
                    }
                } else {
                    PPDAdvancefolderId = (Id) UserInfo.getUserId();
                }
                Document  PPDAdvanceDoc = new Document();
                PPDAdvanceDoc.Name = 'Disbursal Reversal'+ '_' +DateTime.Now().format()+'.csv';
                PPDAdvanceDoc.Body = Blob.valueOf(PPDAdvancefileBody);
                PPDAdvanceDoc.ContentType = 'text/csv';
                PPDAdvanceDoc.Type = 'csv';
                PPDAdvanceDoc.Description='';
                PPDAdvanceDoc.folderid = PPDAdvancefolderId ;
                insert PPDAdvanceDoc ;
            }
            system.debug('--CORPaymentEntries --'+CORPaymentEntries );
            //Insert change details file
            if(CORPaymentEntries != null && CORPaymentEntries.size() > 1){
                for(String s:CORPaymentEntries){
                    CORPaymentfileBody += s;
                }
                String CORPaymentfolderName = loan.CustomSettingsUtil.getACHParameters().CORPayment_Folder_Name__c;
                String CORPaymentfolderId;
                
                if (CORPaymentfolderName != null) {
                    Folder[] folder = [SELECT Id FROM Folder WHERE Name = :CORPaymentfolderName ];
                    if (folder.size() > 0) {
                        CORPaymentfolderId = folder[0].Id;
                    } else {
                        CORPaymentfolderId = (Id) UserInfo.getUserId();
                    }
                } else {
                    CORPaymentfolderId = (Id) UserInfo.getUserId();
                }
                Document  CORPaymentDoc = new Document();
                CORPaymentDoc.Name = 'Change Details'+ '_' +DateTime.now().format()+'.csv';
                CORPaymentDoc.Body = Blob.valueOf(CORPaymentfileBody);
                CORPaymentDoc.ContentType = 'text/csv';
                CORPaymentDoc.Type = 'csv';
                CORPaymentDoc.Description='';
                CORPaymentDoc.folderid = CORPaymentfolderId;
                insert CORPaymentDoc ;
            } 
            
            // Handle Reversed LPT 
            List<loan__Loan_Payment_Transaction__c > paymentReversal =new List<loan__Loan_Payment_Transaction__c >();
            
            paymentReversal.addAll((List<loan__Loan_Payment_Transaction__c>)[select id,
                                                                             Name,
                                                                             loan__Loan_Account__r.name,
                                                                             loan__Transaction_Date__c 
                                                                             From loan__Loan_Payment_Transaction__c 
                                                                             where loan__Loan_Account__r.Name In: loanNamesToReturnCodeMap.keySet()
                                                                             AND loan__Reversed__c = True
                                                                          //   AND Is_Migrated__c = False
                                                                          //   AND loan__Payment_Mode__r.name like '%ACH%'
                                                                             ]);
            
            for(loan__Loan_Payment_Transaction__c lpt:paymentReversal) {
            
              if(String.valueOf(lpt.name.substring(6)).equalsIgnoreCase(loanToLPTNameMap.get(lpt.loan__Loan_Account__r.Name))){
                //Remove LPT reversed already.
                loanToLPTNameMap.remove(lpt.loan__Loan_Account__r.Name);
                if(lptErrors == null){
                    lptErrors = 'LPT already reversed' + '|' + lpt.loan__Loan_Account__r.Name + '|' + loanToLPTNameMap.get(lpt.loan__Loan_Account__r.Name) + '\r\n';
                }
                else{
                    lptErrors = lptErrors + 'LPT already reversed' + '|' + lpt.loan__Loan_Account__r.Name + '|' + loanToLPTNameMap.get(lpt.loan__Loan_Account__r.Name) + '\r\n';
                    
                }
              }
            
            }         
            // End of handle reversed LPT
             
            // Adding new Logic to get Lpts by name not by date and creating the Document for Errors
            List<loan__Loan_Account__c> loanswithPaymentsList = new List<loan__Loan_Account__c>();
            System.debug('list'+loanToLPTNameMap.keySet());
            loanswithPaymentsList.addAll((List<loan__Loan_Account__c>)[Select ID,
                                                                              NAME,
                                                                              (Select ID,
                                                                                         NAME,
                                                                                        loan__Transaction_Date__c,
                                                                                        loan__Loan_Account__r.name,
                                                                                        Original_LPT_Reference__c
                                                                                from loan__Loan_Payment_Transactions__r
                                                                                where loan__Cleared__c = true 
                                                                                And loan__Reversed__c = False
                                                                //                AND loan__Payment_Mode__r.name like '%ACH%'
                                                                                order By loan__Transaction_Time__c DESC
                                                                                LIMIT 1)
                                                                       From loan__Loan_Account__c
                                                                       where NAME In: loanToLPTNameMap.keySet()]);
            
            for(loan__Loan_Account__c loanAcc : loanswithPaymentsList){
                
                loan.ACHReturn achRet = new loan.ACHReturn();
                if(loanAcc.loan__Loan_Payment_Transactions__r != null&&loanAcc.loan__Loan_Payment_Transactions__r.size() > 0){
                    
                    loan__Loan_Payment_Transaction__c lpt = loanAcc.loan__Loan_Payment_Transactions__r[0];
                    
                    /**
                    *  Change log :    
                    *     Created new custom field 'Original_LPT_Reference__c' where user will update with the lpt name
                    *     which they have deleted for reversing older lpt.
                    *     Also, added an 'OR' condition in checking if the LPT reference in the NACHA file matches with the Original_LPT_Reference__c.
                    */
                    
                    if(String.valueOf(lpt.name.substring(6)).equalsIgnoreCase(loanToLPTNameMap.get(loanAcc.Name)) 
                        || (lpt.Original_LPT_Reference__c != null && String.valueOf(lpt.Original_LPT_Reference__c.substring(6)).equalsIgnoreCase(loanToLPTNameMap.get(loanAcc.Name)))){
                        
                        achRet.payment = lpt;
                        achRet.returnCode = loanNamesToReturnCodeMap.get(lpt.loan__Loan_Account__r.name);
                        achReturns.add(achRet);
                        
                    }
                    else{
                        
                        if(lptErrors == null){
                            lptErrors = 'Cannot Reverse this Transaction' + '|' + loanAcc.Name + '|' + loanToLPTNameMap.get(loanAcc.Name) + '\r\n';
                        }
                        else{
                            lptErrors = lptErrors + 'Cannot Reverse this Transaction' + '|' + loanAcc.Name + '|' + loanToLPTNameMap.get(loanAcc.Name) + '\r\n';
                            
                        }
                        
                    }
                    
                }
                else {
                    if(lptErrors == null){
                        lptErrors = 'Not able to find any cleared transaction on this Loan' + '|' + loanAcc.Name + '|' + loanToLPTNameMap.get(loanAcc.Name) + '\r\n';
                    }
                    else{
                        lptErrors = lptErrors + 'Not able to find any cleared transaction on this Loan' + '|' + loanAcc.Name + '|' + loanToLPTNameMap.get(loanAcc.Name) + '\r\n';
                    }
                }
                
            }
            
            if(lptErrors.length() > 42){
                String lptErrorDocName = loan.CustomSettingsUtil.getACHParameters().lptErrorDoc_Folder_Name__c;
                String lptErrorDocFolderId;
                
                if (lptErrorDocName != null) {
                    Folder[] folder = [SELECT Id FROM Folder WHERE Name = :lptErrorDocName ];
                    if (folder.size() > 0) {
                        lptErrorDocFolderId = folder[0].Id;
                    } else {
                        lptErrorDocFolderId = (Id) UserInfo.getUserId();
                    }
                } else {
                    lptErrorDocFolderId = (Id) UserInfo.getUserId();
                }
                Document  lptErrorDoc = new Document();
                lptErrorDoc.Name = 'LPT_Rversal_Errors'+ '_' +DateTime.now().format()+'.csv';
                lptErrorDoc.Body = Blob.valueOf(lptErrors);
                lptErrorDoc.ContentType = 'text/csv';
                lptErrorDoc.Type = 'csv';
                lptErrorDoc.Description='';
                lptErrorDoc.folderid = lptErrorDocFolderId;
                insert lptErrorDoc ;
            }
            
        }catch(Exception e){
            throw new peer.MarketplaceException('Error while parsing return file '+e.getMessage()+'. Stack: '+e.getStackTraceString());
         //   system.debug(e.getMessage()+'---'+e.getStackTraceString());
        }
        return achReturns;
    }
}