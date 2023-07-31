/* ****************Modification History******************
 * Created By        Date          JIRA number
 *1. Pallavi        2020/01/29     LOS-243(Create CL Loan Current Loan Statement)
 *      
 ******************Modification History******************/
public class LoanStatementController {
    
    public loan__loan_account__c contractRec{get;set;}
    public loan__Loan_Payment_Transaction__c LPTRec{get;set;}
    public loan__Interest_Posting_Transaction__c IPTRec{get;set;}
    public Date systemDate{get;set;}
    //public loan__Repayment_Schedule__c AMZrec{get;set;}
    public loan__Repayment_Schedule__c AMZrec1{get;set;}
    public double dailyRate{get;set;}
    public double prevPaidInterest{get;set;}
    public double PaidInterest{get;set;}
    public double TotalDueAmount{get;set;}
    public Boolean flag { get ; set; }
    public double prevDuePrincipal{get;set;}
    public double prevDueInterest{get;set;}
    public String street{get;set;}
    public String city{get;set;}
    public String statePostalCode{get;set;}
        
    public LoanStatementController(){
        System.debug('------------LoanStatementController------------');
        
        Id loanId = ApexPages.currentPage().getParameters().get('Id');
        
        System.debug('------------loanId------------' + loanId);
        
        List<AggregateResult> AMZrec2 = new List<AggregateResult>();
        List<AggregateResult> AMZrec3 = new List<AggregateResult>();
        
        Organization org = [select id,address from organization];
        address add = org.address;
        street = add.getStreet();
        city = add.getCity();
        statePostalCode = add.getState() + ', ' + add.getPostalCode();
        
        flag = false;
        TotalDueAmount = 0;
        prevDuePrincipal = 0;
        prevDueInterest = 0;
    
        if(loanId != null){
            contractRec = [Select id,name,loan__Next_Installment_Date__c,loan__Pmt_Amt_Cur__c,
                           lead_Guid__c,Payoff_Loan_ID__c,loan__Principal_Remaining__c,loan__Interest_Rate__c,loan__Loan_Purpose__c,
                           loan__Principal_Paid__c,loan__Payment_Amount__c,loan__Account__r.name,loan__Account__r.Address_1__c,
                           loan__Account__r.Address_2__c,loan__Account__r.State__c,loan__Account__r.ZIP_Code__c,loan__Account__r.City__c
                           from loan__loan_account__c where id =: loanId];
            
            List<loan__Loan_Payment_Transaction__c> ListLPTRec = [Select id,loan__Transaction_Date__c,loan__Principal__c,loan__Interest__c from loan__Loan_Payment_Transaction__c
                                                                 Where loan__Loan_Account__c =: loanId and loan__Cleared__c = true and loan__Reversed__c = false
                                                                 order by loan__Transaction_Date__c LIMIT 1];
            
            if(ListLPTRec.size()>0)
               LPTRec =  ListLPTRec[0];
            
            System.debug('----LPTRec----');  //remove
            
            List<loan__Interest_Posting_Transaction__c> ListIPTRec = [Select id,loan__Transaction_Creation_Date__c,loan__Transaction_Due_Date__c from loan__Interest_Posting_Transaction__c where 
                                                                     loan__Loan_Contract__c =: loanId and loan__Status__c = 'Closed'
                                                                     order by loan__Transaction_Due_Date__c desc LIMIT 1];
            if(ListIPTRec.size()>0)
               IPTRec =  ListIPTRec[0];
            
            systemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
            
            /*List<loan__Repayment_Schedule__c> ListAMZrec = [Select id,loan__Due_Principal__c,loan__Due_Interest__c,loan__Total_Installment__c from loan__Repayment_Schedule__c 
                                                 where loan__Loan_Account__c =: loanId and loan__isPaid__c = false and loan__Archived__c = false
                                                 and loan__Is_Billed__c = true
                                                 order by loan__Due_Date__c desc];*/
            
            /*if(ListAMZrec.size()>0)
                AMZrec = ListAMZrec[0];*/
            
            /*for(loan__Repayment_Schedule__c repSch : ListAMZrec){
                TotalDueAmount = TotalDueAmount + repSch.loan__Total_Installment__c;
            }*/
            
            List<loan__Repayment_Schedule__c> ListAMZrec1 = [Select id,loan__Due_Principal__c,loan__Due_Interest__c,loan__Total_Installment__c from loan__Repayment_Schedule__c
                                                             where loan__Loan_Account__c =: loanId and loan__isPaid__c = false and loan__Is_Billed__c = true 
                                                             and loan__Archived__c = false
                                                             order by loan__Due_Date__c desc];
            double TotaldueInterest = 0;
            double TotalduePrincipal = 0;
            
            for(loan__Repayment_Schedule__c repSch : ListAMZrec1){
                TotalDueAmount = TotalDueAmount + repSch.loan__Total_Installment__c;
                TotaldueInterest = TotaldueInterest + repSch.loan__Due_Interest__c;
                TotalduePrincipal = TotalduePrincipal + repSch.loan__Due_Principal__c;
            }
            
            if(ListAMZrec1.size()>0){
                AMZrec1 = ListAMZrec1[0];
                prevDuePrincipal = TotalduePrincipal-ListAMZrec1[0].loan__Due_Principal__c;
                prevDueInterest =  TotaldueInterest- ListAMZrec1[0].loan__Due_Interest__c;
            }
        
            dailyRate = contractRec.loan__Interest_Rate__c/360;
            
            Integer prevYear = systemDate.year() - 1;
            Integer currYear = systemDate.year();
            
            AMZrec2 = [select sum(loan__Paid_Interest__c) interest from loan__Repayment_Schedule__c where loan__Loan_Account__c =: loanId
                            and CALENDAR_YEAR(loan__Due_Date__c) =: prevYear and loan__Archived__c = false];
            AMZrec3 = [select sum(loan__Paid_Interest__c) interest from loan__Repayment_Schedule__c where loan__Loan_Account__c =: loanId
                            and CALENDAR_YEAR(loan__Due_Date__c) =: currYear and loan__Archived__c = false];
            
            
            if(AMZrec2.size()>0)
              prevPaidInterest = (Double)AMZrec2[0].get('interest');
            
            if(AMZrec3.size()>0)
              PaidInterest = (Double)AMZrec3[0].get('interest');
            
        }
    }

}