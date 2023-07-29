@isTest
private class WrapperDocuSign_Test{
  static testMethod void test_parse_UseCase1(){
    WrapperDocuSign obj01 = new WrapperDocuSign();
    obj01.envelopeId = 'test data';
    obj01.uri = 'test data';
    obj01.statusDateTime = 'test data';
    obj01.status = 'test data';
    String Jstring = JSON.serialize(obj01);
    WrapperDocuSign.parse(Jstring);
  }
}