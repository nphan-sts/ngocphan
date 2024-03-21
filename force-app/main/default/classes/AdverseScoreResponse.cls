global class AdverseScoreResponse {
    global String requestBody;
    global String responseBody;
    global String integrationErrorStatus;
    global String integrationErrorStatusCode;
    global String errorMessage;
    global List<Adverse__c> no_hit;
    global List<Adverse_Actions__c> adv;
    global List<Score_Factors__c> scf;
    global List<Credit_policy_decisions> credit_policy_decisions;
    global metadata metadata;
    global class Adverse_actions {
        global String name;
        global String reason;
        global String description;
    }

    global class Data {
        global Boolean no_hit;
        global Decision_codes decision_codes;
        }

    global class Credit_policy_decisions {
        global Boolean no_hit;
        global Data data;
        global Decision_codes decision_codes;
        }

    
    global class Score_factor_text {
        global Integer rank;
        global String code;
        global String description;
    }

    global class metadata {
        global Integer status;
    }

    global class Decision_codes {
        global List<Adverse_actions> adverse_actions;
        global List<Score_factor_text> score_factor_text;
    }

    global AdverseScoreResponse parse(String json,String accId, String appId) {
         AdverseScoreResponse advResponseData = (AdverseScoreResponse) System.JSON.deserialize(json, AdverseScoreResponse.class);
         
         try{
            advResponseData.adv = mappingOfFields(advResponseData,accId,appId);
            advResponseData.scf= mappingOfFieldscf(advResponseData,accId,appId);
            advResponseData.no_hit=mappingOfFieldNoHit(advResponseData,accId,appId);
            
        }catch(Exception e){
            System.debug('Exception stack: '+e.getStackTraceString());
            throw new ints.IntegrationException(' API call failure Message: '+e.getMessage());
        }
        return advResponseData;
    }
      global static List<Adverse_Actions__c> mappingOfFields(AdverseScoreResponse advResponseData,String accId,String appId){
          List<Adverse_Actions__c> adverse=new List<Adverse_Actions__c>();
          
          if(null != advResponseData.Credit_policy_decisions){
              for(AdverseScoreResponse.Adverse_actions adv: advResponseData.Credit_policy_decisions[0].Decision_codes.Adverse_actions){
                  Adverse_Actions__c advobj=new Adverse_Actions__c();
                  advobj.Adverse_action_name__c=adv.name;
                  advobj.Description__c=adv.description;
                  advobj.Reason__c=adv.reason;
                  advobj.Account__c=accId;
                  advobj.Application__c=appId;
                  adverse.add(advobj);
              }
          }
          return adverse;
      }
    global static List<Score_Factors__c> mappingOfFieldscf(AdverseScoreResponse advResponseData,String accId,String appId){
          List<Score_Factors__c> scorefac=new List<Score_Factors__c>();
          
          if(null != advResponseData.Credit_policy_decisions){
              for(AdverseScoreResponse.Score_factor_text scfa : advResponseData.Credit_policy_decisions[0].Decision_codes.Score_factor_text){
                  Score_Factors__c scfobj=new Score_Factors__c();
                  scfobj.Rank__c=scfa.rank;
                  scfobj.Description__c=scfa.description;
                  scfobj.Code__c=Decimal.valueOf(scfa.code);
                  scfobj.Account__c=accId;
                  scfobj.Application__c=appId;
                  scorefac.add(scfobj);
              }
          }
          return scorefac;
      }
      global static List<Adverse__c> mappingOfFieldNoHit(AdverseScoreResponse advResponseData,String accId,String appId){
          List<Adverse__c> adverse=new List<Adverse__c>();
          
          if(null != advResponseData.Credit_policy_decisions){
          
               Adverse__c advobj=new Adverse__c();
               advobj.No_Hit__c=advResponseData.Credit_policy_decisions[0].no_hit;
               advobj.Account__c=accId;
               advobj.Application__c=appId;
               adverse.add(advobj);
          }
          
          return adverse;
      }
}