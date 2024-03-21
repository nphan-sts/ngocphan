/**
* Description: 
*
*   Modification Log :
---------------------------------------------------------------------------
    Developer               Date                Description
---------------------------------------------------------------------------
    
******************************************************************************************/
public class SiftIntegrationJSONBean{
    public Integer status;  //0
    public String error_message;    //OK
    public Double score;    //0.41122398700382345
    public cls_reasons[] reasons;
    public String user_id;  //e05a78bb-0344-4cbd-b76a-4b9525736abe
    public cls_actions[] actions;
    public class cls_reasons {
        public String name; //Number of users with the same email address
        public String value;    //8193
    }
    //For sift score
    public score_response score_response;
     public class score_response {
        public Double score{get;set;} 
        public Double status{get;set;}
     }

    public class cls_actions {
        public String id;   //ec158386c487a467180abc6800d3cd757ffffea1f4df741b:558c8061e4b0e75151f01f4f
        public cls_action action;
        public cls_entity entity;
    }
    public class cls_action {
        public String id;   //558c8061e4b0e75151f01f4f
    }
    public class cls_entity {
        public String id;   //e05a78bb-0344-4cbd-b76a-4b9525736abe
    }
    
}