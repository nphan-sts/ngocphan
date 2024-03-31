(function(skuid){
skuid.snippet.register('CallTalx',function(args) {var params = arguments[0],
	$ = skuid.$;

var app = skuid.model.getModel('ApplicationTalx');
var talx = skuid.model.getModel('Talx');


console.log(talx.data[0]);
var appData = app.data[0];
console.log('App id',appData);
alert('Talx API Calling');
var result = sforce.apex.execute('TalxIntegration','getRequestandResponse',
{
    appId: appData.Id
});

window.location.reload(1);
});
}(window.skuid));