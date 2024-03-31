(function(skuid){
skuid.snippet.register('Verify Bank account',function(args) {var appModel = skuid.model.getModel('ParentApplication');
var appRow = appModel.data[0];
console.log(appRow.Id);
var yodleeModel = skuid.model.getModel('YodleeBankAccount');
console.log('see1 '+yodleeModel);
var yodleeRow=yodleeModel.data;
/*var opendocModel = skuid.model.getModel('ADCOpen');
var rejectedModel = skuid.model.getModel('ADCRejected');
var submittedModel = skuid.model.getModel('ADCSubmited');

var opendocRow=opendocModel.data;
var rejectedRow=rejectedModel.data;
var submittedRow=submittedModel.data;*/

var count=0;
if(yodleeRow.length>0){
console.log('see12');
    for(var i=0;i<yodleeRow.length;i++){
         console.log('see123');
        if(yodleeRow[i].verified__c===true){
            count++;
             console.log('see1234');
        console.log(yodleeRow[i].Id);
        var yodleeid =yodleeRow[i].Id;
        console.log('see12345');
        console.log(yodleeid);
        }
    }
}
    console.log('count'+count);
   //var count1=0;
    if(count<1){
       alert('select the bank account to verify'); 
    window.location.reload(1);
    }
    else{
        console.log(yodleeRow);
        console.log(yodleeid);
        /*if(opendocRow.length>0){
            for(var i=0;i<opendocRow.length;i++){
                console.log('see123');
                if(opendocRow[i].Name==='Bank Statement 1'){
                    opendocRow[i].genesis__Status__c = 'CLEARED';
                    opendocRow[i].Cleared_Reason__c = 'Verified by yodlee bank account.';
                    count1++;
                }
                if(opendocRow[i].Name==='Bank Statement 2'){
                    opendocRow[i].genesis__Status__c = 'CLEARED';
                    opendocRow[i].Cleared_Reason__c = 'Verified by yodlee bank account.';
                    count1++;
                }
            }
        }*/
        //if(count1<1){
        //    alert('No open docs'); 
       // }
       
    try {
    
    var ret = sforce.apex.execute('verifyBankAccount','Verify',
    {   
        applicationID : appRow.Id,
        //yodleeID : yodleeid
    });
    console.log(ret);
    alert('Bank account(s) verified successfully'); 
} catch(err) {
    alert('The process been performed is not valid');
    console.log(err);
}
    }
window.location.reload(1);
});
skuid.snippet.register('Get Transactions',function(args) {var appModel = skuid.model.getModel('Account');
var parentappModel = skuid.model.getModel('ParentApplication');
var appRow1 = parentappModel.data[0]; 
console.log('Application Record'+appRow1);

console.log('appRow1.genesis__Account__c'+appRow1.genesis__Account__c);
console.log('appRow1.ID : : '+appRow1.Id);
console.log('No of days : : '+appRow1.Number_of_days__c);
try{
var appRow = appModel.data[0]; 
    $.blockUI({
        message: 'Fetching Yodlee Transactions...',
        onBlock:function(){
            console.log('No of days : : '+appRow1.Number_of_days__c);
            if(appRow1.Number_of_days__c===undefined || appRow1.Number_of_days__c===null) {
                appRow1.Number_of_days__c = -1;
            }
            var result = sforce.apex.execute('YodleeTransactionAPICallOut','getTransactions',
            {
                accId : appRow1.genesis__Account__c,
                appId : appRow1.Id,
                noOfDays : appRow1.Number_of_days__c,
            });
            console.log('No of days : : '+appRow1.Number_of_days__c);
            var result1 = sforce.apex.execute('UpdateAccountInfo', 'getLastUpdate',
            {
                accountId : appRow1.genesis__Account__c
            });
            console.log('No of days : : '+appRow1.Number_of_days__c);
            $.unblockUI();
            if(result.indexOf("Please contact your administrator")!=-1)
                alert ('Please check the yodlee user credentials');
            else
                alert(result); 
            //parentappModel.updateRows(appRow1);
            //parentappModel.commit();
            //parentappModel.save();
            window.location.reload();
        }
    });
}
catch(e){
    console.log('caught'+e);
}
//alert(applicationId);
//alert(result);
//console.log(result);
//window.location.reload(1);
});
skuid.snippet.register('changeTextToGIACTlink',function(args) {var $ = skuid.$;
var params = arguments[0];
value = arguments[1];
var elem = params.element;

var URLvalue = '<a href=" '+value+' "target="_blank">GIACT</a>';

$(elem).html(URLvalue);
});
skuid.snippet.register('RefreshWindow',function(args) {var params = arguments[0],
	$ = skuid.$;

window.location.reload(1);
});
}(window.skuid));