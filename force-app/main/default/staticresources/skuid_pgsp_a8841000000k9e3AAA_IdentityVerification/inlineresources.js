(function(skuid){
skuid.snippet.register('UpdateRow',function(args) {var params = arguments[0],
	$ = skuid.$;

var app = skuid.model.getModel('Application');
var identity = skuid.model.getModel('IdentityVerification');

var identityRow = identity.data[0];

console.log('Identity Row ', identityRow);
var tloPerformed = identityRow.TLO_Performed_By__c;
var preciseIdentity = identityRow.Precise_Identity_Screening_Performed_By__c;
var preciseAccount = identityRow.Precise_Account_Opening_Performed_By__c;
var idmvPerformed = identityRow.IDMV_Performed_By__c;
var idmaPerformed = identityRow.IDMA_Performed_By__c;
var ofacPerformed = identityRow.OFAC_Performed_By__c;

identityRow.TLO_Performed_By__c = identityRow.PerformedBy;
identityRow.Precise_Identity_Screening_Performed_By__c = identityRow.PerformedBy;
identityRow.Precise_Account_Opening_Performed_By__c = identityRow.PerformedBy;
identityRow.IDMV_Performed_By__c = identityRow.PerformedBy;
identityRow.IDMA_Performed_By__c = identityRow.PerformedBy;
identityRow.OFAC_Performed_By__c = identityRow.PerformedBy;

identityRow.Application__c = app.data[0].id;

console.log('Performed by + ',identityRow.TLO_Performed_By__c,identityRow.Precise_Identity_Screening_Performed_By__c,identityRow.Precise_Account_Opening_Performed_By__c,identityRow.IDMV_Performed_By__c,identityRow.IDMA_Performed_By__c,identityRow.OFAC_Performed_By__c);
console.log('Application ', identityRow.Application__c);
/*var tloDate = identityRow.TLO_Date__c;
var perciseIDate = identityRow.Precise_Identity_Screening_Date__c;
var perciseADate = identityRow.Precise_Account_Opening_Date__c;
var idmvDate = identityRow.IDMV_Date__c;
var idmaDate = identityRow.IDMA_Date__c;
var ofacDate = identityRow.OFAC_Date__c;


identityRow.TLO_Date__c = identityRow.TLO_Date;
identityRow.Precise_Identity_Screening_Date__c = identityRow.TLO_Date;
perciseADate = identityRow.TLO_Date;
idmvDate = identityRow.TLO_Date;
idmaDate = identityRow.TLO_Date;
ofacDate = identityRow.TLO_Date;

console.log(tloDate,perciseIDate,perciseADate,idmvDate,idmaDate,ofacDate);*/

//identity.save();
skuid.model.save(identity);
console.log('After Update',identityRow);
});
skuid.snippet.register('CallClass',function(args) {var params = arguments[0],
	$ = skuid.$;

var app = skuid.model.getModel('Application');
var identity = skuid.model.getModel('IdentityVerification');

var identityRow = identity.data[0];

var result = sforce.apex.execute('PayOffUtilities','updateIdentity',
    {
        identityVerify : identityRow,
        appId : app.data[0].Id
    });
});
skuid.snippet.register('SiftIntegration',function(args) {var params = arguments[0],
	$ = skuid.$;

var app = skuid.model.getModel('Application');
var appRow = app.data[0];

var result = sforce.apex.execute('SiftIntegrationAPI','getSiftStatusResponse',
{
    
})
});
skuid.snippet.register('RefreshWindow',function(args) {var params = arguments[0],
	$ = skuid.$;

window.location.reload(1);
});
skuid.snippet.register('CheckCounter',function(args) {var params = arguments[0],
	$ = skuid.$;

var identityModel = Skuid.Model.getModel('IdentityVerification');

var identityRow = identityModel.data[0];

var tlo = identityRow.TLO_Status__c;
var preIdentity = identityRow.Precise_Identity_Screening_Status__c;
var preAcc = identityRow.Precise_Account_Opening_Status__c;
var idmv = identityRow.IDMV_Status__c;
var idma = identityRow.IDMA_Status__c;
var ofac = identityRow.OFAC_Status__c;

var counter = identityRow.counter__c;
});
skuid.snippet.register('DefaultValues',function(args) {(function(skuid){
	var $ = skuid.$;
	$(document.body).one('pageload',function(){
		$('.nx-fieldtext .nx-radiowrapper:first-child').remove();
	});
})(skuid);
});
skuid.snippet.register('displayTLOLink',function(args) {var $ = skuid.$;
var params = arguments[0];
value = arguments[1];
var elem = params.element;

var URLvalue = '<a href=" '+value+' "target="_blank">TLO</a>';

$(elem).html(URLvalue);
});
}(window.skuid));