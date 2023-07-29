public class DocusignTabAPIResponse {

  public class CheckboxTabs {
    public String name {get;set;} 
    public String tabLabel {get;set;} 
    public String selected {get;set;} 
    public String shared {get;set;} 
    public String requireInitialOnSharedChange {get;set;} 
    public String required {get;set;} 
    public String locked {get;set;} 
    public String documentId {get;set;} 
    public String recipientId {get;set;} 
    public String pageNumber {get;set;} 
    public String xPosition {get;set;} 
    public String yPosition {get;set;} 
    public String tabId {get;set;} 
    public String templateLocked {get;set;} 
    public String templateRequired {get;set;} 

    public CheckboxTabs(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'name') {
              name = parser.getText();
            } else if (text == 'tabLabel') {
              tabLabel = parser.getText();
            } else if (text == 'selected') {
              selected = parser.getText();
            } else if (text == 'shared') {
              shared = parser.getText();
            } else if (text == 'requireInitialOnSharedChange') {
              requireInitialOnSharedChange = parser.getText();
            } else if (text == 'required') {
              required = parser.getText();
            } else if (text == 'locked') {
              locked = parser.getText();
            } else if (text == 'documentId') {
              documentId = parser.getText();
            } else if (text == 'recipientId') {
              recipientId = parser.getText();
            } else if (text == 'pageNumber') {
              pageNumber = parser.getText();
            } else if (text == 'xPosition') {
              xPosition = parser.getText();
            } else if (text == 'yPosition') {
              yPosition = parser.getText();
            } else if (text == 'tabId') {
              tabId = parser.getText();
            } else if (text == 'templateLocked') {
              templateLocked = parser.getText();
            } else if (text == 'templateRequired') {
              templateRequired = parser.getText();
            } else {
              System.debug(LoggingLevel.WARN, 'CheckboxTabs consuming unrecognized property: '+text);
              consumeObject(parser);
            }
          }
        }
      }
    }
  }
  
  public class RadioGroupTabs {
    public String documentId {get;set;} 
    public String recipientId {get;set;} 
    public String templateLocked {get;set;} 
    public String templateRequired {get;set;} 
    public String groupName {get;set;} 
    public List<Radios> radios {get;set;} 
    public String shared {get;set;} 
    public String requireInitialOnSharedChange {get;set;} 
    public String requireAll {get;set;} 

    public RadioGroupTabs(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'documentId') {
              documentId = parser.getText();
            } else if (text == 'recipientId') {
              recipientId = parser.getText();
            } else if (text == 'templateLocked') {
              templateLocked = parser.getText();
            } else if (text == 'templateRequired') {
              templateRequired = parser.getText();
            } else if (text == 'groupName') {
              groupName = parser.getText();
            } else if (text == 'radios') {
              radios = arrayOfRadios(parser);
            } else if (text == 'shared') {
              shared = parser.getText();
            } else if (text == 'requireInitialOnSharedChange') {
              requireInitialOnSharedChange = parser.getText();
            } else if (text == 'requireAll') {
              requireAll = parser.getText();
            } else {
              System.debug(LoggingLevel.WARN, 'RadioGroupTabs consuming unrecognized property: '+text);
              consumeObject(parser);
            }
          }
        }
      }
    }
  }
  
  public class SignHereTabs {
    public String stampType {get;set;} 
    public String name {get;set;} 
    public String tabLabel {get;set;} 
    public Integer scaleValue {get;set;} 
    public String optional {get;set;} 
    public String documentId {get;set;} 
    public String recipientId {get;set;} 
    public String pageNumber {get;set;} 
    public String xPosition {get;set;} 
    public String yPosition {get;set;} 
    public String tabId {get;set;} 
    public String templateLocked {get;set;} 
    public String templateRequired {get;set;} 

    public SignHereTabs(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'stampType') {
              stampType = parser.getText();
            } else if (text == 'name') {
              name = parser.getText();
            } else if (text == 'tabLabel') {
              tabLabel = parser.getText();
            } else if (text == 'scaleValue') {
              scaleValue = parser.getIntegerValue();
            } else if (text == 'optional') {
              optional = parser.getText();
            } else if (text == 'documentId') {
              documentId = parser.getText();
            } else if (text == 'recipientId') {
              recipientId = parser.getText();
            } else if (text == 'pageNumber') {
              pageNumber = parser.getText();
            } else if (text == 'xPosition') {
              xPosition = parser.getText();
            } else if (text == 'yPosition') {
              yPosition = parser.getText();
            } else if (text == 'tabId') {
              tabId = parser.getText();
            } else if (text == 'templateLocked') {
              templateLocked = parser.getText();
            } else if (text == 'templateRequired') {
              templateRequired = parser.getText();
            } else {
              System.debug(LoggingLevel.WARN, 'SignHereTabs consuming unrecognized property: '+text);
              consumeObject(parser);
            }
          }
        }
      }
    }
  }
  
  public class DateTabs {
    public String validationPattern {get;set;} 
    public String validationMessage {get;set;} 
    public String shared {get;set;} 
    public String requireInitialOnSharedChange {get;set;} 
    public String requireAll {get;set;} 
    public String value {get;set;} 
    public Integer width {get;set;} 
    public String required {get;set;} 
    public String locked {get;set;} 
    public String concealValueOnDocument {get;set;} 
    public String disableAutoSize {get;set;} 
    public Integer maxLength {get;set;} 
    public String tabLabel {get;set;} 
    public String font {get;set;} 
    public String fontColor {get;set;} 
    public String fontSize {get;set;} 
    public String documentId {get;set;} 
    public String recipientId {get;set;} 
    public String pageNumber {get;set;} 
    public String xPosition {get;set;} 
    public String yPosition {get;set;} 
    public String tabId {get;set;} 
    public String templateLocked {get;set;} 
    public String templateRequired {get;set;} 

    public DateTabs(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'validationPattern') {
              validationPattern = parser.getText();
            } else if (text == 'validationMessage') {
              validationMessage = parser.getText();
            } else if (text == 'shared') {
              shared = parser.getText();
            } else if (text == 'requireInitialOnSharedChange') {
              requireInitialOnSharedChange = parser.getText();
            } else if (text == 'requireAll') {
              requireAll = parser.getText();
            } else if (text == 'value') {
              value = parser.getText();
            } else if (text == 'width') {
              width = parser.getIntegerValue();
            } else if (text == 'required') {
              required = parser.getText();
            } else if (text == 'locked') {
              locked = parser.getText();
            } else if (text == 'concealValueOnDocument') {
              concealValueOnDocument = parser.getText();
            } else if (text == 'disableAutoSize') {
              disableAutoSize = parser.getText();
            } else if (text == 'maxLength') {
              maxLength = parser.getIntegerValue();
            } else if (text == 'tabLabel') {
              tabLabel = parser.getText();
            } else if (text == 'font') {
              font = parser.getText();
            } else if (text == 'fontColor') {
              fontColor = parser.getText();
            } else if (text == 'fontSize') {
              fontSize = parser.getText();
            } else if (text == 'documentId') {
              documentId = parser.getText();
            } else if (text == 'recipientId') {
              recipientId = parser.getText();
            } else if (text == 'pageNumber') {
              pageNumber = parser.getText();
            } else if (text == 'xPosition') {
              xPosition = parser.getText();
            } else if (text == 'yPosition') {
              yPosition = parser.getText();
            } else if (text == 'tabId') {
              tabId = parser.getText();
            } else if (text == 'templateLocked') {
              templateLocked = parser.getText();
            } else if (text == 'templateRequired') {
              templateRequired = parser.getText();
            } else {
              System.debug(LoggingLevel.WARN, 'DateTabs consuming unrecognized property: '+text);
              consumeObject(parser);
            }
          }
        }
      }
    }
  }
  
  public class FullNameTabs {
    public String name {get;set;} 
    public String value {get;set;} 
    public String tabLabel {get;set;} 
    public String font {get;set;} 
    public String fontColor {get;set;} 
    public String fontSize {get;set;} 
    public String documentId {get;set;} 
    public String recipientId {get;set;} 
    public String pageNumber {get;set;} 
    public String xPosition {get;set;} 
    public String yPosition {get;set;} 
    public String tabId {get;set;} 
    public String templateLocked {get;set;} 
    public String templateRequired {get;set;} 

    public FullNameTabs(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'name') {
              name = parser.getText();
            } else if (text == 'value') {
              value = parser.getText();
            } else if (text == 'tabLabel') {
              tabLabel = parser.getText();
            } else if (text == 'font') {
              font = parser.getText();
            } else if (text == 'fontColor') {
              fontColor = parser.getText();
            } else if (text == 'fontSize') {
              fontSize = parser.getText();
            } else if (text == 'documentId') {
              documentId = parser.getText();
            } else if (text == 'recipientId') {
              recipientId = parser.getText();
            } else if (text == 'pageNumber') {
              pageNumber = parser.getText();
            } else if (text == 'xPosition') {
              xPosition = parser.getText();
            } else if (text == 'yPosition') {
              yPosition = parser.getText();
            } else if (text == 'tabId') {
              tabId = parser.getText();
            } else if (text == 'templateLocked') {
              templateLocked = parser.getText();
            } else if (text == 'templateRequired') {
              templateRequired = parser.getText();
            } else {
              System.debug(LoggingLevel.WARN, 'FullNameTabs consuming unrecognized property: '+text);
              consumeObject(parser);
            }
          }
        }
      }
    }
  }
  
  public class Radios {
    public String pageNumber {get;set;} 
    public String xPosition {get;set;} 
    public String yPosition {get;set;} 
    public String value {get;set;} 
    public String selected {get;set;} 
    public String tabId {get;set;} 
    public String required {get;set;} 
    public String locked {get;set;} 

    public Radios(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'pageNumber') {
              pageNumber = parser.getText();
            } else if (text == 'xPosition') {
              xPosition = parser.getText();
            } else if (text == 'yPosition') {
              yPosition = parser.getText();
            } else if (text == 'value') {
              value = parser.getText();
            } else if (text == 'selected') {
              selected = parser.getText();
            } else if (text == 'tabId') {
              tabId = parser.getText();
            } else if (text == 'required') {
              required = parser.getText();
            } else if (text == 'locked') {
              locked = parser.getText();
            } else {
              System.debug(LoggingLevel.WARN, 'Radios consuming unrecognized property: '+text);
              consumeObject(parser);
            }
          }
        }
      }
    }
  }
  
  public class TextTabs {
    public Integer height {get;set;} 
    public String validationPattern {get;set;} 
    public String validationMessage {get;set;} 
    public String shared {get;set;} 
    public String requireInitialOnSharedChange {get;set;} 
    public String requireAll {get;set;} 
    public String value {get;set;} 
    public String originalValue {get;set;} 
    public Integer width {get;set;} 
    public String required {get;set;} 
    public String locked {get;set;} 
    public String concealValueOnDocument {get;set;} 
    public String disableAutoSize {get;set;} 
    public Integer maxLength {get;set;} 
    public String tabLabel {get;set;} 
    public String font {get;set;} 
    public String fontColor {get;set;} 
    public String fontSize {get;set;} 
    public String documentId {get;set;} 
    public String recipientId {get;set;} 
    public String pageNumber {get;set;} 
    public String xPosition {get;set;} 
    public String yPosition {get;set;} 
    public String tabId {get;set;} 
    public String templateLocked {get;set;} 
    public String templateRequired {get;set;} 
    public String isPaymentAmount {get;set;} 
    public String bold {get;set;} 
    public String italic {get;set;} 
    public String underline {get;set;} 

    public TextTabs(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'height') {
              height = parser.getIntegerValue();
            } else if (text == 'validationPattern') {
              validationPattern = parser.getText();
            } else if (text == 'validationMessage') {
              validationMessage = parser.getText();
            } else if (text == 'shared') {
              shared = parser.getText();
            } else if (text == 'requireInitialOnSharedChange') {
              requireInitialOnSharedChange = parser.getText();
            } else if (text == 'requireAll') {
              requireAll = parser.getText();
            } else if (text == 'value') {
              value = parser.getText();
            } else if (text == 'originalValue') {
              originalValue = parser.getText();
            } else if (text == 'width') {
              width = parser.getIntegerValue();
            } else if (text == 'required') {
              required = parser.getText();
            } else if (text == 'locked') {
              locked = parser.getText();
            } else if (text == 'concealValueOnDocument') {
              concealValueOnDocument = parser.getText();
            } else if (text == 'disableAutoSize') {
              disableAutoSize = parser.getText();
            } else if (text == 'maxLength') {
              maxLength = parser.getIntegerValue();
            } else if (text == 'tabLabel') {
              tabLabel = parser.getText();
            } else if (text == 'font') {
              font = parser.getText();
            } else if (text == 'fontColor') {
              fontColor = parser.getText();
            } else if (text == 'fontSize') {
              fontSize = parser.getText();
            } else if (text == 'documentId') {
              documentId = parser.getText();
            } else if (text == 'recipientId') {
              recipientId = parser.getText();
            } else if (text == 'pageNumber') {
              pageNumber = parser.getText();
            } else if (text == 'xPosition') {
              xPosition = parser.getText();
            } else if (text == 'yPosition') {
              yPosition = parser.getText();
            } else if (text == 'tabId') {
              tabId = parser.getText();
            } else if (text == 'templateLocked') {
              templateLocked = parser.getText();
            } else if (text == 'templateRequired') {
              templateRequired = parser.getText();
            } else if (text == 'isPaymentAmount') {
              isPaymentAmount = parser.getText();
            } else if (text == 'bold') {
              bold = parser.getText();
            } else if (text == 'italic') {
              italic = parser.getText();
            } else if (text == 'underline') {
              underline = parser.getText();
            } else {
              System.debug(LoggingLevel.WARN, 'TextTabs consuming unrecognized property: '+text);
              consumeObject(parser);
            }
          }
        }
      }
    }
  }
  
  public List<SignHereTabs> signHereTabs {get;set;} 
  public List<FullNameTabs> fullNameTabs {get;set;} 
  public List<FullNameTabs> dateSignedTabs {get;set;} 
  public List<TextTabs> textTabs {get;set;} 
  public List<DateTabs> dateTabs {get;set;} 
  public List<CheckboxTabs> checkboxTabs {get;set;} 
  public List<RadioGroupTabs> radioGroupTabs {get;set;} 
  public List<FullNameTabs> emailAddressTabs {get;set;} 

  public DocusignTabAPIResponse(JSONParser parser) {
    while (parser.nextToken() != System.JSONToken.END_OBJECT) {
      if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
        String text = parser.getText();
        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
          if (text == 'signHereTabs') {
            signHereTabs = arrayOfSignHereTabs(parser);
          } else if (text == 'fullNameTabs') {
            fullNameTabs = arrayOfFullNameTabs(parser);
          } else if (text == 'dateSignedTabs') {
            dateSignedTabs = arrayOfFullNameTabs(parser);
          } else if (text == 'textTabs') {
            textTabs = arrayOfTextTabs(parser);
          } else if (text == 'dateTabs') {
            dateTabs = arrayOfDateTabs(parser);
          } else if (text == 'checkboxTabs') {
            checkboxTabs = arrayOfCheckboxTabs(parser);
          } else if (text == 'radioGroupTabs') {
            radioGroupTabs = arrayOfRadioGroupTabs(parser);
          } else if (text == 'emailAddressTabs') {
            emailAddressTabs = arrayOfFullNameTabs(parser);
          } else {
            System.debug(LoggingLevel.WARN, 'DocusignTabAPIResponse consuming unrecognized property: '+text);
            consumeObject(parser);
          }
        }
      }
    }
  }
  
  
  public static DocusignTabAPIResponse parse(String json) {
    System.JSONParser parser = System.JSON.createParser(json);
    return new DocusignTabAPIResponse(parser);
  }
  
  public static void consumeObject(System.JSONParser parser) {
    Integer depth = 0;
    do {
      System.JSONToken curr = parser.getCurrentToken();
      if (curr == System.JSONToken.START_OBJECT || 
        curr == System.JSONToken.START_ARRAY) {
        depth++;
      } else if (curr == System.JSONToken.END_OBJECT ||
        curr == System.JSONToken.END_ARRAY) {
        depth--;
      }
    } while (depth > 0 && parser.nextToken() != null);
  }
  

    private static List<SignHereTabs> arrayOfSignHereTabs(System.JSONParser p) {
        List<SignHereTabs> res = new List<SignHereTabs>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new SignHereTabs(p));
        }
        return res;
    }




    private static List<RadioGroupTabs> arrayOfRadioGroupTabs(System.JSONParser p) {
        List<RadioGroupTabs> res = new List<RadioGroupTabs>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new RadioGroupTabs(p));
        }
        return res;
    }




    private static List<FullNameTabs> arrayOfFullNameTabs(System.JSONParser p) {
        List<FullNameTabs> res = new List<FullNameTabs>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new FullNameTabs(p));
        }
        return res;
    }



    private static List<Radios> arrayOfRadios(System.JSONParser p) {
        List<Radios> res = new List<Radios>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Radios(p));
        }
        return res;
    }









    private static List<TextTabs> arrayOfTextTabs(System.JSONParser p) {
        List<TextTabs> res = new List<TextTabs>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new TextTabs(p));
        }
        return res;
    }





    private static List<DateTabs> arrayOfDateTabs(System.JSONParser p) {
        List<DateTabs> res = new List<DateTabs>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new DateTabs(p));
        }
        return res;
    }


    private static List<CheckboxTabs> arrayOfCheckboxTabs(System.JSONParser p) {
        List<CheckboxTabs> res = new List<CheckboxTabs>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new CheckboxTabs(p));
        }
        return res;
    }


}