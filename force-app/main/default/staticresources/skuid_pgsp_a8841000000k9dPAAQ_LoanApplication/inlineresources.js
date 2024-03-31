(function(skuid){
skuid.snippet.register('createTransactionRoom',function(args) {var appModel = skuid.model.getModel('Application');
var appRow = appModel.data[0];

try {
sforce.apex.execute('genesis.SkuidTransactionRoomCtrl','createTransactionRoom',
    {   
        applicationId : appRow.Id
    });
} catch(err) {
    alert(err);
}
window.location.reload();
});
skuid.snippet.register('convert',function(args) {var appModel = skuid.model.getModel('Application');
var appRow = appModel.data[0];

try {
    var ret = sforce.apex.execute('genesis.ConvertApplicationCtrl','convertApplicationToContract',
    {   
        appId : appRow.Id
    });
    alert(ret);
} catch(err) {
    alert(err);
}
window.location.reload();
});
skuid.snippet.register('Conga Button',function(args) {var appModel = skuid.model.getModel('Application');
var appRow = appModel.data[0];
console.log('check appRow'+ appRow.id);
var CongaURL = 'https://composer.congamerge.com' +
'?sessionId={!API.Session_ID}' + skuid.utils.userInfo.sessionId  +
'&serverUrl' + sforce.connection.partnerServerUrl+
'&id=' + appRow.id ;
window.open(CongaURL);

//console.log('check session Id'+ API.Session_ID);
//console.log('partner server'+ API.Partner_Server_URL_290);
//window.open(https://composer.congamerge.com?sessionId={!API.Session_ID}&serverUrl={!API.Partner_Server_URL_290}&id={!appRow.Id});
});
skuid.snippet.register('Assigntomxqueue',function(args) {var scModels = skuid.model.getModel('Application');
var scRow = scModels.data[0]; 
var result = sforce.apex.execute('PayOffUtilities','AssignToMXQueue',
{   
        appId : scRow.Id
});
alert(result);
window.location.reload();
});
skuid.snippet.register('AssignToFraudQueue',function(args) {var scModels = skuid.model.getModel('Application');
var scRow = scModels.data[0]; 
var result = sforce.apex.execute('PayOffUtilities','AssignToFraudQueue',
{   
        appId : scRow.Id
});
alert(result);
window.location.reload();
});
skuid.snippet.register('AssignToVerificationQueue',function(args) {var scModels = skuid.model.getModel('Application');
var scRow = scModels.data[0]; 
var result = sforce.apex.execute('PayOffUtilities','AssignToVerificationQueue',
{   
        appId : scRow.Id
});
alert(result);
window.location.reload();
});
skuid.snippet.register('ReloadPage',function(args) {location.reload();
});
skuid.snippet.register('AgentVerified',function(args) {var scModels = skuid.model.getModel('Application');
var scRow = scModels.data[0]; 
var appId = scRow.Id;

try{
   /*scModels.updateRow(scModels.getFirstRow(),
        {
            genesis__Status__c : 'agent_verified',
            DocuSignFlag__c: true
        });

    //alert(appId);
    scModels.save();*/  //LOP-57
     var result = sforce.apex.execute('PayOffUtilities','AssignToAgentVerifiedQueue',
     {   
        appId : scRow.Id
     });
     alert(result); 
window.location.reload();
   /* var oaModel = skuid.model.getModel('OAuthSettings'),
        oaRow = oaModel.data[0],
        oAuthID = oaRow.Id,
        clientID = oaRow.ints__Consumer_Key__c,
        redirect_url=oaRow.ints__Request_Token_URL__c;
    var ocredModel = skuid.model.getModel('OAuthCredentials_CS'),
        ocredRow = ocredModel.data[0],
        username= ocredRow.UserName__c,
        password = ocredRow.Password__c;
    
    //alert(oAuthID);
    //window.open("https://happymoney.app.box.com/api/oauth2/authorize?grant_type=password&client_id=d998c67720u9bf2zg34ll4ogesxppsh7&redirect_uri=https://ints.cs91.visual.force.com/apex/OAuth2LoginPage&username=cls_dev@happymoney.com&password=nE*UwEV7Z263eEWXY%o&C5HpaX1V&u&response_type=code&state="+appId);
    window.open("https://happymoney.app.box.com/api/oauth2/authorize?grant_type=password&client_id="+clientID+"&redirect_uri="+redirect_url+"&username="+username+"&password="+password+"&response_type=code&state="+oAuthID+"_"+appId);
    
    console.log('--genesis__Status__c--True__'+scRow.genesis__Status__c);*/
    
}

catch(e){
    console.log('caught'+e);
}
});
skuid.snippet.register('WithdrawApp',function(args) {var scModels = skuid.model.getModel('Application');
var scRow = scModels.data[0]; 
try{
    
    scModels.updateRow(scModels.getFirstRow(),
        {
            genesis__Status__c : 'Withdrawn'
        });
    scModels.save();
    console.log('--genesis__Status__c--True__'+scRow.genesis__Status__c);

}
catch(e){
    console.log('caught'+e);
}
var result = sforce.apex.execute('PayOffUtilities','AssignToWithdrawnQueue',
{   
        appId : scRow.Id
});
alert(result);
window.location.reload();
});
skuid.snippet.register('ManualDecline',function(args) {var scModels = skuid.model.getModel('Application');
var scRow = scModels.data[0]; 
var dclrsn = scRow.Decline_Reason__c;
/*var results = sforce.apex.execute('AttachPDFtoApplication','saveAttachmentFromSkuid',
{   
        idVal : scRow.Id
});*/
try{
    
    scModels.updateRow(scModels.getFirstRow(),
        {
            genesis__Status__c : 'Decline_Manual_Review'
        });
    scModels.updateRow(scModels.getFirstRow(),
        {
            decline_reason__c : dclrsn
        });    
    scModels.save();
    console.log('--genesis__Status__c--True__'+scRow.genesis__Status__c);
    
    var result = sforce.apex.execute('PayOffUtilities','AssignToDeclinedQueue',
    {   
        appId : scRow.Id
    });
    alert(result);
}
catch(e){
    console.log('caught'+e);
    alert('Error completing your request.  Please contact your Administrator!');
}
window.location.reload();
});
skuid.snippet.register('AssignToDeclineQueue',function(args) {var scModels = skuid.model.getModel('Application');
var scRow = scModels.data[0]; 
var result = sforce.apex.execute('PayOffUtilities','AssignToDeclinedQueue',
{   
        appId : scRow.Id
});
alert(result);
window.location.reload();
});
skuid.snippet.register('DisplayCurrency',function(args) {var scModels = skuid.model.getModel('Application');
var scRow = scModels.data[0]; 
var loanVal = scRow.genesis__Loan_Amount__c;
var metaDataType = loanVal.metadata;
//alert('amt '+loanVal);
//alert('DT '+metaDataType);

try{
    if(contains(loanVal,'.'))
    {}
    else{
        
    }    
    //var loanAmt = scModels.getFieldValue(scRow, loanVal);
    //alert('amt...'+loanAmt);
    //loanVal = scRow.genesis__Loan_Amount__c.setScale(2);
    //scModels.updateRow(scRow, scRow.genesis__Loan_Amount__c, loanAmt.setScale(2));
    //scModels.save();
    //scModels.updateData();
    //skuid.ui.fieldRenderers['CURRENCY']['edit'](loanVal,loanVal.setScale(2));
    console.log('--Loan Amt-- '+loanVal);
  
}
catch(e){
    console.log('caught'+e);
}
});
skuid.snippet.register('Create Application Tag for Soft pull',function(args) {var scModels = skuid.model.getModel('Application');
var scRow = scModels.data[0]; 
var result = sforce.apex.execute('PayOffUtilities','createAppTagforSoftpull',
{   
        appId : scRow.Id
});
alert(result);
window.location.reload();
});
skuid.snippet.register('AssignToFundingQueue',function(args) {var scModels = skuid.model.getModel('Application');
var scRow = scModels.data[0]; 
var result = sforce.apex.execute('PayOffUtilities','AssignToFundingQueue',
{   
        appId : scRow.Id
});
alert(result);
window.location.reload();
});
skuid.snippet.register('sendWorkVerificationEmail',function(args) {var scModels = skuid.model.getModel('Employment');
var scRow = scModels.data[0]; 



try{
    
    scModels.updateRow(scModels.getFirstRow(),
        {
            Send_work_email_verification_Email__c : true
        });
    scModels.save();
    console.log('--Verification Email sent '+scRow.Send_work_email_verification_Email__c);

  
}
catch(e){
    console.log('caught'+e);
}
alert('Work Email Verification Sent');
//window.location.reload();
});
skuid.snippet.register('AssignToFinalVerificationQueue',function(args) {var scModels = skuid.model.getModel('Application');
var scRow = scModels.data[0]; 
var result = sforce.apex.execute('PayOffUtilities','AssignToFinalVerificationQueue',
{   
        appId : scRow.Id
});
alert(result);
window.location.reload();
});
skuid.snippet.register('AssignToUser',function(args) {var scModels = skuid.model.getModel('Application');
var scRow = scModels.data[0]; 
var result = sforce.apex.execute('PayOffUtilities','AssignToUser',
{   
        appId : scRow.Id
});
alert(result);
window.location.reload();
});
skuid.snippet.register('AssignToReviewQueue',function(args) {var scModels = skuid.model.getModel('Application');
var scRow = scModels.data[0]; 
var result = sforce.apex.execute('PayOffUtilities','AssignToReviewQueue',
{   
        appId : scRow.Id
});
alert(result);
window.location.reload();
});
skuid.snippet.register('AssignToPreCheck',function(args) {var scModels = skuid.model.getModel('Application');
var scRow = scModels.data[0]; 
var result = sforce.apex.execute('PayOffUtilities','AssignToUserPreCheck',
{   
        appId : scRow.Id
});
alert(result);
window.location.reload();
});
skuid.snippet.register('AssignToOutbounder',function(args) {var scModels = skuid.model.getModel('Application');
var scRow = scModels.data[0]; 
var result = sforce.apex.execute('PayOffUtilities','AssignToUserOutbounder',
{   
        appId : scRow.Id
});
alert(result);
window.location.reload();
});
skuid.snippet.register('ReallocateButton',function(args) {var scModels = skuid.model.getModel('Application');
var scRow = scModels.data[0]; 
var result = sforce.apex.execute('MW_AllocationEngineHandler','handleReallocationById',
{   
        appId : scRow.Id
});
alert(result);
window.location.reload()
});
}(window.skuid));