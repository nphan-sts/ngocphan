global class TalxResponse {

    public Static String Employer;
    public Static String Salary;
    public Static String len_of_Emp;
    public Static String hire_date;
    public Static String term_date;
    public Static String position;
    
    
    public TalxResponse(){
    
    }
   
    
    public static TalxResponse Parse(String response){

        TalxResponse talx;        
        Employer = String.isEmpty(response.substringBetween('<NAME1>','</NAME1>')) ? '' : response.substringBetween('<NAME1>','</NAME1>');
        Salary = String.isEmpty(response.substringBetween('<TSVPROJINCOME>','</TSVPROJINCOME>')) ? '' : response.substringBetween('<TSVPROJINCOME>','</TSVPROJINCOME>');
        len_of_Emp = String.isEmpty(response.substringBetween('<TOTALLENGTHOFSVC>','</TOTALLENGTHOFSVC>')) ? '' : response.substringBetween('<TOTALLENGTHOFSVC>','</TOTALLENGTHOFSVC>');
        hire_date = String.isEmpty(response.substringBetween('<DTMOSTRECENTHIRE>','</DTMOSTRECENTHIRE>')) ? '' : response.substringBetween('<DTMOSTRECENTHIRE>','</DTMOSTRECENTHIRE>');
        term_date = String.isEmpty(response.substringBetween('<DTENDEMPLOYMENT>','</DTENDEMPLOYMENT>')) ? '' : response.substringBetween('<DTENDEMPLOYMENT>','</DTENDEMPLOYMENT>');
        position = String.isEmpty(response.substringBetween('<POSITION-TITLE>','</POSITION-TITLE>')) ? '' : response.substringBetween('<POSITION-TITLE>','</POSITION-TITLE>');
        
        len_of_Emp = ( Integer.valueOf(len_of_Emp) /12 ) + ' Years, ' + Math.MOD(Integer.valueOf(len_of_Emp), 12 ) + ' Months';
        return talx;
    }
    
   
}