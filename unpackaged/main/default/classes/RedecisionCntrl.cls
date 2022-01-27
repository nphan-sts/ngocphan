/* ****************Modification History******************
 * Last Modified by    Date    JIRA number
 *     Pallavi      2019/06/19    CLS-1283
 *     Pallavi      2019/11/29    LOS-203
 *     Pallavi      2020/01/31    CRM-272
 ******************Modification History******************/

global class RedecisionCntrl{
    
    global static void accRedecisionTrigger(Map<id,Account> oldAccMap,Map<id,Account> newAccMap){
        List<genesis__applications__c> applicationList;
        /*pallavi CLS-1321*/
        List<Profiles_NotConsidered_ForRedecision__c> profiles = Profiles_NotConsidered_ForRedecision__c.getAll().values();
        String currentUser = UserInfo.getName();
        List<User> profileName = [SELECT profile.name from user where name =: currentUser LIMIT 1];
        /*pallavi CLS-1321*/
        /*LOS-203*/
        List<StatusNotConsideredForRedecision__c> status = StatusNotConsideredForRedecision__c.getAll().values();
        List<String> statusName = new List<String>();
        for(StatusNotConsideredForRedecision__c name : status){
            statusName.add(name.Status__c);
        }
        /*LOS-203*/
        applicationList = [SELECT id, Name,
                                            genesis__account__c ,
                                            genesis__account__r.Member_ID__c,
                                            genesis__account__r.loan__SOCIAL_SECURITY_NUMBER__c,
                                            Lead_ID__c,
                                            Bureau_SSN__c,
                                            genesis__Status__c,
                                            GIACT_Date__c,
                                            GIACTPerformed_By__c,
                                            GIACT_Status__c,
                                            Income_Verification_Flag__c,
                                            Neo_Verification__c,
                                            genesis__account__r.manualredecision__c,
                                            (Select id,name,Pricing_Tier__c, Amount__c
                                                From Pricing_Offer__r),
                                            (Select id from Identity_verifications__r),
                                            (Select id from KBA_Details__r),
                                            (Select id from Income_Calculators__r),                                         
                                            (Select id from Net_Income_Calculators__r),
                                            (Select id from Neo_Verify__r),
                                            (Select id from Credit_Policy__r),
                                            (Select id from Hard_Credit_Pulls__r),
                                            (Select id from Credit_Bureau__r),                                         
                                            (Select id from Hard_Pull_Data__r),
                                            (Select id from Hard_Inquiry_Meta_Data__r),
                                            (Select id from Approved_Offer__r),
                                            (Select id,name,
                                                Box_URl__c
                                                from genesis__Application_Document_Category__r 
                                                Where name like '%TIL%' 
                                                or name like '%Credit Score Notice%')
                                            FROM genesis__applications__c
                                            WHERE genesis__account__c = :newAccMap.keyset() 
                                            AND genesis__status__c != : statusName  //LOS-203
                                            ];
        
                                                    
        list<Redecision_Request__c> rrToBeInseted = new list<Redecision_Request__c>();
        list<Pricing_Offer__c> allOffersTobeDel = new list<Pricing_Offer__c>();
        list<Identity_verification__c> allIVToBeDel = new list<Identity_verification__c>();
        list<KBA_Details__c> allKbaToBeDel = new list<KBA_Details__c>();
        list<Income_Calculators__c> allICToBeDel = new list<Income_Calculators__c>();
        list<Net_Income_Calculator__c> allNICToBeDel = new list<Net_Income_Calculator__c>();
        list<Neo_Verify__c> allNeoVerToBeDel = new list<Neo_Verify__c>();
        list<Credit_Policy__c> allCPToBeDel = new list<Credit_Policy__c>();
        list<Hard_Credit_Pull__c> allHCPToBeDel = new list<Hard_Credit_Pull__c>();
        list<Credit_Bureau__c> allCBToBeDel = new list<Credit_Bureau__c>();
        list<Hard_Pull_Data__c> allHPDToBeDel = new list<Hard_Pull_Data__c>();
        list<Hard_Inquiry_Meta_Data__c> allHIMDToBeDel = new list<Hard_Inquiry_Meta_Data__c>();
        list<Approved_Offer__c> allAppOfferToBeDel = new list<Approved_Offer__c>();
        list<genesis__Application_Document_Category__c> allADCToBeupdated = new list<genesis__Application_Document_Category__c>();
        list<genesis__applications__c> appToBeUpdated = new list<genesis__applications__c>();        
        
        
        for(genesis__applications__c app : applicationList){
            Account accOld = oldAccMap.get(app.genesis__account__c);
            Account accNew = newAccMap.get(app.genesis__account__c);            
            String fieldsChanged;
            Boolean redecisionRequired = false; 
            Boolean SSNmatch = true;
            if(app.genesis__account__r.loan__SOCIAL_SECURITY_NUMBER__c != null && app.Bureau_SSN__c != null && app.genesis__account__r.loan__SOCIAL_SECURITY_NUMBER__c != app.Bureau_SSN__c){
                SSNmatch = false;
            }
            if(/*(accOld.loan__SOCIAL_SECURITY_NUMBER__c != null && accOld.loan__SOCIAL_SECURITY_NUMBER__c != accNew.loan__SOCIAL_SECURITY_NUMBER__c) ||*/ accNew.manualredecision__c==true){   //CRM-272
                System.debug('fields changed' +fieldsChanged+ ' and manualredecision' +accNew.manualredecision__c);    
                    if(fieldsChanged == null && accNew.manualredecision__c==True){
                    system.debug('in manual redecision');
                    List<Account> manredlist;
                    manredlist = [select id, manualredecision__c FROM Account Where id in: newAccMap.keyset()];
                    manredlist[0].manualredecision__c = false;
                    update manredlist;
                    }
                if(fieldsChanged == null){
                    fieldsChanged = 'loan__SOCIAL_SECURITY_NUMBER__c'; //(body__c should not be null)
                }
                /*else{ //CRM-272(not needed. fieldsChanged here is always null)
                    fieldsChanged = fieldsChanged + ',loan__SOCIAL_SECURITY_NUMBER__c';
                }*/
                redecisionRequired = true;             
            }
            if(accOld.peer__Date_of_Birth__c != null && accOld.peer__Date_of_Birth__c != accNew.peer__Date_of_Birth__c){
                if(fieldsChanged == null){
                    fieldsChanged = 'peer__Date_of_Birth__c';
                }
                else{
                    fieldsChanged = fieldsChanged + ',peer__Date_of_Birth__c';
                }
                redecisionRequired = true;
            }
            if(accOld.peer__First_Name__c != null && accOld.peer__First_Name__c != accNew.peer__First_Name__c && SSNmatch == false){
                if(fieldsChanged == null){
                    fieldsChanged = 'peer__First_Name__c';
                }
                else{
                    fieldsChanged += ',peer__First_Name__c';
                }
                redecisionRequired = true;     
            }
            if(accOld.peer__Last_Name__c != null && accOld.peer__Last_Name__c != accNew.peer__Last_Name__c && SSNmatch == false){
                if(fieldsChanged == null){
                    fieldsChanged = 'peer__Last_Name__c';
                }
                else{
                    fieldsChanged = fieldsChanged + ',peer__Last_Name__c';
                }     
                redecisionRequired = true;           
            }
            if(/*accOld.Suffix__c!= null &&*/ accOld.Suffix__c!= accNew.Suffix__c && SSNmatch == false){
                if(fieldsChanged == null){
                    fieldsChanged = 'Suffix__c';
                }
                else{
                    fieldsChanged = fieldsChanged + ',Suffix__c';
                }     
                redecisionRequired = true;           
            }
            if(accOld.Address_1__c != null && accOld.Address_1__c != accNew.Address_1__c && SSNmatch == false){
                if(fieldsChanged == null){
                    fieldsChanged = 'Address_1__c';
                }
                else{
                    fieldsChanged = fieldsChanged + ',Address_1__c';
                }
                redecisionRequired = true;                
            }
            if(accOld.Address_2__c != null && accOld.Address_2__c != accNew.Address_2__c && SSNmatch == false){
                if(fieldsChanged == null){
                    fieldsChanged = 'Address_2__c';
                }
                else{
                    fieldsChanged = fieldsChanged + ',Address_2__c';
                }    
                redecisionRequired = true;            
            }
            if(accOld.State__c != null && accOld.State__c != accNew.State__c && SSNmatch == false){
                if(fieldsChanged == null){
                    fieldsChanged = 'State__c';
                }
                else{
                    fieldsChanged = fieldsChanged + ',State__c';
                }    
                redecisionRequired = true;            
            }
            if(accOld.City__c != null && accOld.City__c != accNew.City__c && SSNmatch == false){
                if(fieldsChanged == null){
                    fieldsChanged = 'City__c';
                }
                else{
                    fieldsChanged = fieldsChanged + ',City__c';
                }    
                redecisionRequired = true;             
            }
            if(accOld.ZIP_Code__c != null && accOld.ZIP_Code__c != accNew.ZIP_Code__c && SSNmatch == false){
                if(fieldsChanged == null){
                    fieldsChanged = 'ZIP_Code__c';
                }
                else{
                    fieldsChanged = fieldsChanged + ',ZIP_Code__c';
                }    
                redecisionRequired = true;            
            }
            if(accOld.Annual_Individual_Income__c != null && accOld.Annual_Individual_Income__c != accNew.Annual_Individual_Income__c){
                if(fieldsChanged == null){
                    fieldsChanged = 'Annual_Individual_Income__c';
                }
                else{
                    fieldsChanged = fieldsChanged + ',Annual_Individual_Income__c';
                }  
                redecisionRequired = true;            
            }
            if(accOld.Monthly_Housing_Payment__c != null && accOld.Monthly_Housing_Payment__c != accNew.Monthly_Housing_Payment__c){
                if(fieldsChanged == null){
                    fieldsChanged = 'Monthly_Housing_Payment__c';
                }
                else{
                    fieldsChanged = fieldsChanged + ',Monthly_Housing_Payment__c';
                }
                redecisionRequired = true;               
            } 
            //pallavi
            if(profileName[0].profile.name != null){
                String profName = String.valueOf(profileName[0].profile.name);
                System.debug(profName);
                for(Profiles_NotConsidered_ForRedecision__c a:profiles){
                    System.debug(a.profile_name__c);
                    if(profName.equals(a.profile_name__c)){
                        System.debug('no redecision');
                        redecisionRequired = false;
                        break;
                    }
                }
            }
            //pallavi
            if(redecisionRequired == true){
                if(app.Pricing_Offer__r != null){
                    allOffersTobeDel.addall(app.Pricing_Offer__r);
                    }
                if(app.Identity_verifications__r != null){
                    allIVToBeDel.addall(app.Identity_verifications__r);
                    }
                if(app.KBA_Details__r != null){
                    allKbaToBeDel.addall(app.KBA_Details__r);
                    }
                if(app.Income_Calculators__r != null){
                    allICToBeDel.addall(app.Income_Calculators__r );                                        
                    }
                if(app.Net_Income_Calculators__r != null){
                    allNICToBeDel.addall(app.Net_Income_Calculators__r);
                    }
                if(app.Neo_Verify__r != null){
                    allNeoVerToBeDel.addall(app.Neo_Verify__r);
                    }
                if(app.Credit_Policy__r != null){
                    allCPToBeDel.addall(app.Credit_Policy__r);
                    }
                if(app.Hard_Credit_Pulls__r != null){
                    allHCPToBeDel.addall(app.Hard_Credit_Pulls__r);
                    }
                if(app.Credit_Bureau__r != null){
                    allCBToBeDel.addall(app.Credit_Bureau__r);                                
                    }
                if(app.Hard_Pull_Data__r != null){
                    allHPDToBeDel.addall(app.Hard_Pull_Data__r);
                    }
                if(app.Hard_Inquiry_Meta_Data__r != null){
                    allHIMDToBeDel.addall(app.Hard_Inquiry_Meta_Data__r);
                    }
                if(app.Approved_Offer__r != null){
                    allAppOfferToBeDel.addall(app.Approved_Offer__r);
                    }
                if(app.genesis__Application_Document_Category__r != null){
                        for(genesis__Application_Document_Category__c adc : app.genesis__Application_Document_Category__r){
                            adc.Box_URl__c = null;
                            allADCToBeupdated.add(adc);
                        }
                    }
                Redecision_Request__c rr = new Redecision_Request__c();
                rr.Application__c = app.id;
                rr.Body__c = fieldsChanged;
                rr.Triggered_From__c = 'Account';
                rrToBeInseted.add(rr);
                app.genesis__Status__c = 'Redecision_Required';
                appToBeUpdated.add(app);
            }
        }
        
        if(allOffersTobeDel != null && allOffersTobeDel.size() > 0){
            Delete allOffersTobeDel;
        }
        /*
        if(allIVToBeDel != null && allIVToBeDel.size() > 0){
            Delete allIVToBeDel;
        }
        */
        /*
        if(allKbaToBeDel != null && allKbaToBeDel.size() > 0){
            Delete allKbaToBeDel;
        }
        */
        /*
        if(allICToBeDel != null && allICToBeDel.size() > 0){
            Delete allICToBeDel;
        }
        */
        /*
        if(allNICToBeDel != null && allNICToBeDel.size() > 0){
            Delete allNICToBeDel;
        }
        */
        /*
        if(allNeoVerToBeDel != null && allNeoVerToBeDel.size() > 0){
            Delete allNeoVerToBeDel;
        }
        */
        /*
        if(allCPToBeDel != null && allCPToBeDel.size() > 0){
            Delete allCPToBeDel;
        }
        */
        /*
        if(allHCPToBeDel != null && allHCPToBeDel.size() > 0){
            Delete allHCPToBeDel;
        }
        */
        /*
        if(allCBToBeDel != null && allCBToBeDel.size() > 0){
            Delete allCBToBeDel;
        }
        */
        /*
        if(allHPDToBeDel != null && allHPDToBeDel.size() > 0){
            Delete allHPDToBeDel;
        }
        */
        /*
        if(allHIMDToBeDel != null && allHIMDToBeDel.size() > 0){
            Delete allHIMDToBeDel;
        }
        */
        if(allAppOfferToBeDel != null && allAppOfferToBeDel.size() > 0){
            Delete allAppOfferToBeDel;
        }
        if(allADCToBeupdated != null && allADCToBeupdated.size() > 0){
            Update allADCToBeupdated;
        }
        if(rrToBeInseted.size() > 0 && rrToBeInseted != null){
            insert rrToBeInseted;           
        }
        if(appToBeUpdated.size() > 0 && appToBeUpdated != null){
            update appToBeUpdated;
        }
        
    }
    global static void appRedecisionTrigger(Map<id,genesis__applications__c> oldAppMap,Map<id,genesis__applications__c> newAppMap){
        /*LOS-203*/
        List<StatusNotConsideredForRedecision__c> status = StatusNotConsideredForRedecision__c.getAll().values();
        List<String> statusName = new List<String>();
        for(StatusNotConsideredForRedecision__c name : status){
            statusName.add(name.Status__c);
        }
        /*LOS-203*/
        List<genesis__applications__c> applicationList;
        applicationList = [SELECT id, Name,
                                            genesis__account__c ,
                                            genesis__account__r.loan__SOCIAL_SECURITY_NUMBER__c,
                                            genesis__account__r.Member_ID__c,
                                            Lead_ID__c,
                                            Bureau_SSN__c,
                                            genesis__Status__c,
                                            GIACT_Date__c,
                                            GIACTPerformed_By__c,
                                            GIACT_Status__c,
                                            Income_Verification_Flag__c,
                                            Neo_Verification__c,
                                            genesis__account__r.ManualRedecision__c,
                                            (Select id,name,Pricing_Tier__c, Amount__c
                                                From Pricing_Offer__r),
                                            (Select id from Identity_verifications__r),
                                            (Select id from KBA_Details__r),
                                            (Select id from Income_Calculators__r),                                         
                                            (Select id from Net_Income_Calculators__r),
                                            (Select id from Neo_Verify__r),
                                            (Select id from Credit_Policy__r),
                                            (Select id from Hard_Credit_Pulls__r),
                                            (Select id from Credit_Bureau__r),                                         
                                            (Select id from Hard_Pull_Data__r),
                                            (Select id from Hard_Inquiry_Meta_Data__r),
                                            (Select id from Approved_Offer__r),
                                            (Select id,name,
                                                Box_URl__c
                                                from genesis__Application_Document_Category__r 
                                                Where name like '%TIL%' 
                                                or name like '%Credit Score Notice%')
                                            FROM genesis__applications__c
                                            Where id in: newAppMap.keyset()
                                            AND genesis__status__c != : statusName  //LOS-203
                                            ];
                                            
        list<Redecision_Request__c> rrToBeInseted = new list<Redecision_Request__c>();    
        list<Pricing_Offer__c> allOffersTobeDel = new list<Pricing_Offer__c>();
        list<Identity_verification__c> allIVToBeDel = new list<Identity_verification__c>();
        list<KBA_Details__c> allKbaToBeDel = new list<KBA_Details__c>();
        list<Income_Calculators__c> allICToBeDel = new list<Income_Calculators__c>();
        list<Net_Income_Calculator__c> allNICToBeDel = new list<Net_Income_Calculator__c>();
        list<Neo_Verify__c> allNeoVerToBeDel = new list<Neo_Verify__c>();
        list<Credit_Policy__c> allCPToBeDel = new list<Credit_Policy__c>();
        list<Hard_Credit_Pull__c> allHCPToBeDel = new list<Hard_Credit_Pull__c>();
        list<Credit_Bureau__c> allCBToBeDel = new list<Credit_Bureau__c>();
        list<Hard_Pull_Data__c> allHPDToBeDel = new list<Hard_Pull_Data__c>();
        list<Hard_Inquiry_Meta_Data__c> allHIMDToBeDel = new list<Hard_Inquiry_Meta_Data__c>();
        list<Approved_Offer__c> allAppOfferToBeDel = new list<Approved_Offer__c>();
        list<genesis__Application_Document_Category__c> allADCToBeupdated = new list<genesis__Application_Document_Category__c>();
        list<genesis__applications__c> appToBeUpdated = new list<genesis__applications__c>();
        
        for(genesis__applications__c app : applicationList){
            genesis__applications__c oldApp = oldAppMap.get(app.id);
            genesis__applications__c newApp = newAppMap.get(app.id);
            List<Pricing_Offer__c> appOffers = app.Pricing_Offer__r;
            Boolean redecisionRequired = true;
            String fieldsChanged;
            if((oldApp.Requested_loan_amount__c != null && oldApp.Requested_loan_amount__c != newApp.Requested_loan_amount__c) ){
                for(Pricing_Offer__c po : appOffers){
                    if(po.Amount__c == newApp.Requested_loan_amount__c){
                        redecisionRequired = false;
                        break;
                    }                   
                }
                if(redecisionRequired == true){ 
                    if(app.Pricing_Offer__r != null){
                        allOffersTobeDel.addall(app.Pricing_Offer__r);
                        }
                    if(app.Identity_verifications__r != null){
                        allIVToBeDel.addall(app.Identity_verifications__r);
                        }
                    if(app.KBA_Details__r != null){
                        allKbaToBeDel.addall(app.KBA_Details__r);
                        }
                    if(app.Income_Calculators__r != null){
                        allICToBeDel.addall(app.Income_Calculators__r );                                        
                        }
                    if(app.Net_Income_Calculators__r != null){
                        allNICToBeDel.addall(app.Net_Income_Calculators__r);
                        }
                    if(app.Neo_Verify__r != null){
                        allNeoVerToBeDel.addall(app.Neo_Verify__r);
                        }
                    if(app.Credit_Policy__r != null){
                        allCPToBeDel.addall(app.Credit_Policy__r);
                        }
                    if(app.Hard_Credit_Pulls__r != null){
                        allHCPToBeDel.addall(app.Hard_Credit_Pulls__r);
                        }
                    if(app.Credit_Bureau__r != null){
                        allCBToBeDel.addall(app.Credit_Bureau__r);                                
                        }
                    if(app.Hard_Pull_Data__r != null){
                        allHPDToBeDel.addall(app.Hard_Pull_Data__r);
                        }
                    if(app.Hard_Inquiry_Meta_Data__r != null){
                        allHIMDToBeDel.addall(app.Hard_Inquiry_Meta_Data__r);
                        }
                    if(app.Approved_Offer__r != null){
                        allAppOfferToBeDel.addall(app.Approved_Offer__r);
                        }
                    if(app.genesis__Application_Document_Category__r != null){
                            for(genesis__Application_Document_Category__c adc : app.genesis__Application_Document_Category__r){
                                adc.Box_URl__c = null;
                                allADCToBeupdated.add(adc);
                            }
                        }
                        
                    if(fieldsChanged == null){
                        fieldsChanged = 'Requested_loan_amount__c';
                    }
                    else{
                        fieldsChanged += ',Requested_loan_amount__c';
                    }
                    Redecision_Request__c rr = new Redecision_Request__c();
                    rr.Application__c = app.id;
                    rr.Body__c = fieldsChanged;
                    rr.Triggered_From__c = 'Application';
                    rrToBeInseted.add(rr);
                    app.genesis__Status__c = 'Redecision_Required';
                    appToBeUpdated.add(app);

                }
            }
            
        }
        if(allOffersTobeDel != null && allOffersTobeDel.size() > 0){
            Delete allOffersTobeDel;
        }
        /*
        if(allIVToBeDel != null && allIVToBeDel.size() > 0){
            Delete allIVToBeDel;
        }
        */
        /*
        if(allKbaToBeDel != null && allKbaToBeDel.size() > 0){
            Delete allKbaToBeDel;
        }
        */
        /*
        if(allICToBeDel != null && allICToBeDel.size() > 0){
            Delete allICToBeDel;
        }
        */
        /*
        if(allNICToBeDel != null && allNICToBeDel.size() > 0){
            Delete allNICToBeDel;
        }
        */
        /*
        if(allNeoVerToBeDel != null && allNeoVerToBeDel.size() > 0){
            Delete allNeoVerToBeDel;
        }
        */
        /*
        if(allCPToBeDel != null && allCPToBeDel.size() > 0){
            Delete allCPToBeDel;
        }
        */
        /*
        if(allHCPToBeDel != null && allHCPToBeDel.size() > 0){
            Delete allHCPToBeDel;
        }
        */
        /*
        if(allCBToBeDel != null && allCBToBeDel.size() > 0){
            Delete allCBToBeDel;
        }
        */
        /*
        if(allHPDToBeDel != null && allHPDToBeDel.size() > 0){
            Delete allHPDToBeDel;
        }
        */
        /*
        if(allHIMDToBeDel != null && allHIMDToBeDel.size() > 0){
            Delete allHIMDToBeDel;
        }
        */
        if(allAppOfferToBeDel != null && allAppOfferToBeDel.size() > 0){
            Delete allAppOfferToBeDel;
        }
        if(allADCToBeupdated != null && allADCToBeupdated.size() > 0){
            Update allADCToBeupdated;
        }
        if(rrToBeInseted.size() > 0 && rrToBeInseted != null){
            insert rrToBeInseted;
        }
        if(appToBeUpdated.size() > 0 && appToBeUpdated != null){
            update appToBeUpdated;
        }
    }
    
}
