trigger CustomIdentityVerificationTrigger on Identity_Verification__c (before insert, before update) {
    //added disable trigger condition check - CRM-437
    if (!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c) {
    if(trigger.isbefore){
        if(trigger.isInsert || trigger.isUpdate){
            for(Identity_Verification__c idnVerify : trigger.New){
                String userName = UserInfo.getName();
                Date currentDate = System.Today();
                
                System.debug('... idnVerify:... '+ idnVerify.Id + '...userName...' + userName +'...currentDate ...'+ currentDate);
                if(idnVerify.Id != null){
                    Identity_Verification__c oldTrgIdn = Trigger.oldMap.get(idnVerify.Id);                    
                    
                    System.debug('Old Trigger... '+ oldTrgIdn);
                    if(oldTrgIdn != Null && !String.isBlank(oldTrgIdn.TLO_Status__c) && (idnVerify.TLO_Status__c != oldTrgIdn.TLO_Status__c)){
                        System.debug('TLO Details:... ' + idnVerify.TLO_Status__c  + '  ... '+ oldTrgIdn.TLO_Status__c);
                    
                        idnVerify.TLO_Date__c = currentDate;
                        idnVerify.TLO_Performed_By__c = userName;  
                        //if(idnVerify.TLO_Status__c == 'Performed')
                        //    idnVerify.counter__c = idnVerify.counter__c + 1;
                    }                    
                    else if(oldTrgIdn == Null && !String.isBlank(idnVerify.TLO_Status__c) && (idnVerify.TLO_Status__c != 'Not Performed')){
                        idnVerify.TLO_Date__c = currentDate;
                        idnVerify.TLO_Performed_By__c = userName;  
                        //if(idnVerify.TLO_Status__c == 'Performed')
                        //    idnVerify.counter__c = idnVerify.counter__c + 1;                      
                    }
                    if(oldTrgIdn != Null && !String.isBlank(oldTrgIdn.Precise_Identity_Screening_Status__c) && 
                       (idnVerify.Precise_Identity_Screening_Status__c != oldTrgIdn.Precise_Identity_Screening_Status__c)){
                        System.debug('Precise_Identity_Screening_Status__c Details:... ' + idnVerify.Precise_Identity_Screening_Status__c  +
                                 '  ... '+ oldTrgIdn.Precise_Identity_Screening_Status__c);
                        idnVerify.Precise_Identity_Screening_Date__c = currentDate;
                        idnVerify.Precise_Identity_Screening_Performed_By__c = userName;                         
                    }
                    else if(oldTrgIdn == Null && !String.isBlank(idnVerify.Precise_Identity_Screening_Status__c) && (idnVerify.Precise_Identity_Screening_Status__c != 'Not Performed')){
                        idnVerify.Precise_Identity_Screening_Date__c = currentDate;
                        idnVerify.Precise_Identity_Screening_Performed_By__c = userName;                         
                    }
                    if(oldTrgIdn != Null && !String.isBlank(oldTrgIdn.Precise_Account_Opening_Status__c) && 
                       (idnVerify.Precise_Account_Opening_Status__c != oldTrgIdn.Precise_Account_Opening_Status__c)){
                        System.debug('Precise_Account_Opening_Status__c Details:... ' + idnVerify.Precise_Account_Opening_Status__c  +
                                 '  ... '+ oldTrgIdn.Precise_Account_Opening_Status__c);
                        idnVerify.Precise_Account_Opening_Date__c = currentDate;
                        idnVerify.Precise_Account_Opening_Performed_By__c = userName;                         
                    }
                    else if(oldTrgIdn == Null && !String.isBlank(idnVerify.Precise_Account_Opening_Status__c) && (idnVerify.Precise_Account_Opening_Status__c != 'Not Performed')){
                        idnVerify.Precise_Account_Opening_Date__c = currentDate;
                        idnVerify.Precise_Account_Opening_Performed_By__c = userName;                         
                    }
                    if(oldTrgIdn != Null && !String.isBlank(oldTrgIdn.IDMV_Status__c) && (idnVerify.IDMV_Status__c != oldTrgIdn.IDMV_Status__c)){
                        System.debug('IDMV_Status__c Details:... ' + idnVerify.IDMV_Status__c  + '  ... '+ oldTrgIdn.IDMV_Status__c);
                        idnVerify.IDMV_Date__c = currentDate;
                        idnVerify.IDMV_Performed_By__c = userName;                         
                    }
                    else if( oldTrgIdn == Null && !String.isBlank(idnVerify.IDMV_Status__c) && (idnVerify.IDMV_Status__c != 'Not Performed')){
                        idnVerify.IDMV_Date__c = currentDate;
                        idnVerify.IDMV_Performed_By__c = userName;                         
                    }
                    if(oldTrgIdn != Null && !String.isBlank(oldTrgIdn.IDMA_Status__c) && (idnVerify.IDMA_Status__c != oldTrgIdn.IDMA_Status__c)){
                        System.debug('IDMA_Status__c Details:... ' + idnVerify.IDMA_Status__c  + '  ... '+ oldTrgIdn.IDMA_Status__c);
                        idnVerify.IDMA_Date__c = currentDate;
                        idnVerify.IDMA_Performed_By__c = userName;                         
                    }
                    else if(oldTrgIdn == Null && !String.isBlank(idnVerify.IDMA_Status__c) && (idnVerify.IDMA_Status__c != 'Not Performed')){
                        idnVerify.IDMA_Date__c = currentDate;
                        idnVerify.IDMA_Performed_By__c = userName;                         
                    }
                    System.debug('OFAC_Status__c Details:... ' + idnVerify.OFAC_Status__c  + '  ... '+ oldTrgIdn.OFAC_Status__c);
                    if(oldTrgIdn != Null && !String.isBlank(oldTrgIdn.OFAC_Status__c) && (idnVerify.OFAC_Status__c != oldTrgIdn.OFAC_Status__c)){
                        idnVerify.OFAC_Date__c = currentDate;
                        idnVerify.OFAC_Performed_By__c = userName;                         
                    }
                    else if(oldTrgIdn == Null && !String.isBlank(idnVerify.OFAC_Status__c) && (idnVerify.OFAC_Status__c != 'Not Performed')){
                        idnVerify.OFAC_Date__c = currentDate;
                        idnVerify.OFAC_Performed_By__c = userName;                         
                    }
                    System.debug('Bank_Verification_Flag__c Details:... ' + idnVerify.Bank_Verification_Flag__c  + '  ... '+ oldTrgIdn.Bank_Verification_Flag__c);
                    System.debug('Bank_Verification_Flag__c Details:...StringBlank ' + String.isBlank(oldTrgIdn.Bank_Verification_Flag__c));
                    if(oldTrgIdn != Null /*&& !String.isBlank(oldTrgIdn.Bank_Verification_Flag__c)*/ && (idnVerify.Bank_Verification_Flag__c != oldTrgIdn.Bank_Verification_Flag__c)){
                        System.debug('Bank_Verification_Flag__c Details:... ' + idnVerify.Bank_Verification_Flag__c  + '  ... '+ oldTrgIdn.Bank_Verification_Flag__c);
                    
                        idnVerify.BAV_Date__c = currentDate;
                        idnVerify.BAV_Performed_By__c = userName;                         
                    }
                    /*else if(!String.isBlank(idnVerify.Bank_Verification_Flag__c)){
                        
                        
                       // idnVerify.BAV_Date__c = oldTrgIdn.BAV_Date__c;
                      //  idnVerify.BAV_Performed_By__c = oldTrgIdn.BAV_Performed_By__c;  
                        idnVerify.BAV_Date__c = currentDate;
                        idnVerify.BAV_Performed_By__c = userName; 
                    }*/
                    
                    // Deal Room Verification Flag.
                                        
                    if(oldTrgIdn != Null /*&& !String.isBlank(oldTrgIdn.Deal_room_Verification_Flag__c)*/ && (idnVerify.Deal_room_Verification_Flag__c!= oldTrgIdn.Deal_room_Verification_Flag__c)){
                        System.debug('Deal_room_Verification_Flag__c Details:... ' + idnVerify.Deal_room_Verification_Flag__c+ '  ... '+ oldTrgIdn.Deal_room_Verification_Flag__c);                   
                        idnVerify.Deal_Room_Performed_Date__c = currentDate;
                        idnVerify.Deal_Room_Performed_by__c = userName;                         
                    }
                   /* else if(!String.isBlank(idnVerify.Deal_room_Verification_Flag__c)){
                        idnVerify.Deal_Room_Performed_Date__c = currentDate;
                        idnVerify.Deal_Room_Performed_by__c = userName; 
                       //   idnVerify.Deal_Room_Performed_Date__c = oldtrgidn.Deal_Room_Performed_Date__c;
                       //   idnVerify.Deal_Room_Performed_by__c = oldtrgidn.Deal_Room_Performed_by__c ; 
                    }*/
                    
                    // Credit Policy Flag.
                    
                    if(oldTrgIdn != Null /*&& !String.isBlank(oldTrgIdn.Credit_Policy_Verification_Flag__c)*/ && (idnVerify.Credit_Policy_Verification_Flag__c != oldTrgIdn.Credit_Policy_Verification_Flag__c)){
                        System.debug('Credit_Policy_Verification_Flag__c Details:... ' + idnVerify.Credit_Policy_Verification_Flag__c + '  ... '+ oldTrgIdn.Credit_Policy_Verification_Flag__c );                   
                        idnVerify.Credit_Policy_Performed_Date__c = currentDate;
                        idnVerify.Credit_Policy_Performed_By__c = userName;                         
                    }
                  /* else if(!String.isBlank(idnVerify.Credit_Policy_Verification_Flag__c)){
                        idnVerify.Credit_Policy_Performed_Date__c = currentDate;
                        idnVerify.Credit_Policy_Performed_By__c = userName; 
                    }*/
                    
                    // Identity Flag Verification.
                    
                    if(oldTrgIdn != Null /*&& !String.isBlank(oldTrgIdn.Identity_Verification__c)*/ && (idnVerify.Identity_Verification__c != oldTrgIdn.Identity_Verification__c)){
                        System.debug('Identity_Verification__c Details:... ' + idnVerify.Identity_Verification__c  + '  ... '+ oldTrgIdn.Identity_Verification__c);
                    
                        idnVerify.IV_Performed_Date__c = currentDate;
                        idnVerify.IV_Performed_By__c = userName;                         
                    }
                    /*else if(!String.isBlank(idnVerify.Identity_Verification__c)){
                        idnVerify.IV_Performed_Date__c = currentDate;
                         idnVerify.IV_Performed_By__c = userName;   
                        
                      //  idnVerify.IV_Performed_Date__c = oldtrgidn.IV_Performed_Date__c;
                      //  idnVerify.IV_Performed_By__c = oldtrgidn.IV_Performed_By__c;   
                    }*/
                    
                    //
                    
                    
                    if(oldTrgIdn != Null /*&& !String.isBlank(oldTrgIdn.Income_Verification_Flag__c)*/ && (idnVerify.Income_Verification_Flag__c != oldTrgIdn.Income_Verification_Flag__c)){
                        System.debug('Income_Verification_Flag__c Details:... ' + idnVerify.Income_Verification_Flag__c  + '  ... '+ oldTrgIdn.Income_Verification_Flag__c);
                    
                        idnVerify.IncomeV_Date__c = currentDate;
                        idnVerify.IncomeV_Performed_By__c = userName;                         
                    }
                   /* else if(!String.isBlank(idnVerify.Income_Verification_Flag__c)){
                        idnVerify.IncomeV_Date__c = currentDate;
                        idnVerify.IncomeV_Performed_By__c = userName;     
                       // idnVerify.IncomeV_Date__c = oldtrgidn.IncomeV_Date__c ;
                       // idnVerify.IncomeV_Performed_By__c = oldtrgidn.IncomeV_Performed_By__c; 
                    }*/
                    /*if(oldTrgIdn != Null && !String.isBlank(oldTrgIdn.KBA_Verification_Flag__c) && (idnVerify.KBA_Verification_Flag__c != oldTrgIdn.KBA_Verification_Flag__c)){
                        System.debug('KBA_Verification_Flag__c Details:... ' + idnVerify.KBA_Verification_Flag__c  + '  ... '+ oldTrgIdn.KBA_Verification_Flag__c);
                    
                        idnVerify.KBAV_Performed_Date__c = currentDate;
                        idnVerify.KBAV_Performed_BY__c = userName;                         
                    }
                    else if(!String.isBlank(idnVerify.KBA_Verification_Flag__c)){
                        idnVerify.KBAV_Performed_Date__c = currentDate;
                        idnVerify.KBAV_Performed_BY__c = userName;                         
                    }
                    if(oldTrgIdn != Null && !String.isBlank(oldTrgIdn.Neo_Verification_Flag__c) && (idnVerify.Neo_Verification_Flag__c != oldTrgIdn.Neo_Verification_Flag__c)){
                        System.debug('Neo_Verification_Flag__c Details:... ' + idnVerify.Neo_Verification_Flag__c  + '  ... '+ oldTrgIdn.Neo_Verification_Flag__c);
                    
                        idnVerify.NeoV_Performed_Date__c = currentDate;
                        idnVerify.NeoV_Performed_By__c = userName;                         
                    }
                    else if(!String.isBlank(idnVerify.Neo_Verification_Flag__c)){
                        idnVerify.NeoV_Performed_Date__c = currentDate;
                        idnVerify.NeoV_Performed_By__c = userName;                         
                    }*/
                }               
                else{
                    //String userName = UserInfo.getName();
                    //Date currentDate = System.Today();
                    System.debug('TLO Details:... ' + idnVerify.TLO_Status__c );
                    if(!String.isBlank(idnVerify.TLO_Status__c) && (idnVerify.TLO_Status__c != 'Not Performed')){
                        idnVerify.TLO_Date__c = currentDate;
                        idnVerify.TLO_Performed_By__c = userName;  
                        //if(idnVerify.TLO_Status__c == 'Performed')
                        //    idnVerify.counter__c = idnVerify.counter__c + 1;
                    }
                    System.debug('Precise_Identity_Screening_Status__c Details:... ' + idnVerify.Precise_Identity_Screening_Status__c );
                    if(!String.isBlank(idnVerify.Precise_Identity_Screening_Status__c) && (idnVerify.Precise_Identity_Screening_Status__c != 'Not Performed')){
                        idnVerify.Precise_Identity_Screening_Date__c = currentDate;
                        idnVerify.Precise_Identity_Screening_Performed_By__c = userName;                         
                    }
                    System.debug('Precise_Account_Opening_Status__c Details:... ' + idnVerify.Precise_Account_Opening_Status__c );
                    if(!String.isBlank(idnVerify.Precise_Account_Opening_Status__c) && (idnVerify.Precise_Account_Opening_Status__c != 'Not Performed')){
                        idnVerify.Precise_Account_Opening_Date__c = currentDate;
                        idnVerify.Precise_Account_Opening_Performed_By__c = userName;                         
                    }
                    System.debug('IDMV_Status__c Details:... ' + idnVerify.IDMV_Status__c);
                    if(!String.isBlank(idnVerify.IDMV_Status__c) && (idnVerify.IDMV_Status__c != 'Not Performed')){
                        idnVerify.IDMV_Date__c = currentDate;
                        idnVerify.IDMV_Performed_By__c = userName;                         
                    }
                    System.debug('IDMA_Status__c Details:... ' + idnVerify.IDMA_Status__c);
                    if(!String.isBlank(idnVerify.IDMA_Status__c) && (idnVerify.IDMA_Status__c != 'Not Performed')){
                        idnVerify.IDMA_Date__c = currentDate;
                        idnVerify.IDMA_Performed_By__c = userName;                         
                    }
                    System.debug('OFAC_Status__c Details:... ' + idnVerify.OFAC_Status__c);
                    if(!String.isBlank(idnVerify.OFAC_Status__c) && (idnVerify.OFAC_Status__c != 'Not Performed')){
                        idnVerify.OFAC_Date__c = currentDate;
                        idnVerify.OFAC_Performed_By__c = userName;                         
                    }
                    
                    System.debug('Bank_Verification_Flag__c Details:... ' + idnVerify.Bank_Verification_Flag__c);
                    if(!String.isBlank(idnVerify.Bank_Verification_Flag__c)){
                        idnVerify.BAV_Date__c = currentDate;
                        idnVerify.BAV_Performed_By__c = userName;                         
                    }
                    
                    System.debug('Deal_room_Verification_Flag__c Details:... ' + idnVerify.Deal_room_Verification_Flag__c);
                    if(!String.isBlank(idnVerify.Deal_room_Verification_Flag__c)){
                        idnVerify.Deal_Room_Performed_Date__c = currentDate;
                        idnVerify.Deal_Room_Performed_by__c = userName;                         
                    }
                    
                    // Credit Policy Flag.
                    System.debug('Credit_Policy_Verification_Flag__c Details:... ' + idnVerify.Credit_Policy_Verification_Flag__c);
                    if(idnVerify.Credit_Policy_Verification_Flag__c != null && !String.isEmpty(idnVerify.Credit_Policy_Verification_Flag__c)){
                        idnVerify.Credit_Policy_Performed_Date__c = currentDate;
                        idnVerify.Credit_Policy_Performed_By__c = userName;                         
                    }
                    
                    System.debug('Identity_Verification__c Details:... ' + idnVerify.Identity_Verification__c);
                    if(idnVerify.Identity_Verification__c != null && !String.isEmpty(idnVerify.Identity_Verification__c)){
                        idnVerify.IV_Performed_Date__c = currentDate;
                        idnVerify.IV_Performed_By__c = userName;                         
                    }
                    System.debug('Income_Verification_Flag__c Details:... ' + idnVerify.Income_Verification_Flag__c);
                    if(!String.isBlank(idnVerify.Income_Verification_Flag__c)){
                        idnVerify.IncomeV_Date__c = currentDate;
                        idnVerify.IncomeV_Performed_By__c = userName;                         
                    }
                    /*System.debug('KBA_Verification_Flag__c Details:... ' + idnVerify.KBA_Verification_Flag__c);
                    if(!String.isBlank(idnVerify.KBA_Verification_Flag__c)){
                        idnVerify.KBAV_Performed_Date__c = currentDate;
                        idnVerify.KBAV_Performed_BY__c = userName;                         
                    }*/
                    /*System.debug('Neo_Verification_Flag__c Details:... ' + idnVerify.Neo_Verification_Flag__c);
                    if(!String.isBlank(idnVerify.Neo_Verification_Flag__c)){
                        idnVerify.NeoV_Performed_Date__c = currentDate;
                        idnVerify.NeoV_Performed_By__c = userName;                         
                    }*/
                }
            }
        }
    }
    }
}