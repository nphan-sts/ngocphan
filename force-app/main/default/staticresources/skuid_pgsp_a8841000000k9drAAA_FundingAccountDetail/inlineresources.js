(function(skuid){
skuid.snippet.register('newSnippet',function(args) {var bankModel = skuid.model.getModel('BankAccount');
var bankRow = bankModel.data[0];
if(bankRow.Account_Number__c == bank.loan__Bank_Account_Number__c && bankRow.Name_on_Account__c == bankRow.loan__Account__r.Name){
    
}
});
skuid.snippet.register('Mask/Unmask',function(args) {var bankModel = skuid.model.getModel('BankAccount');
var bankRow = bankModel.data[0];
try{
    if(bankRow.Unmask__c === true){
        bankModel.updateRow(bankModel.getFirstRow(),
        {
            Unmask__c : false,
            ShowBankAcct : true
        });
        bankModel.save();
        console.log('--Unmask__c--False__'+bankRow.Unmask__c);
    }
    if(bankRow.Unmask__c ===false){
        bankModel.updateRow(bankModel.getFirstRow(),
        {
            Unmask__c : true,
            ShowBankAcct : true
        });
        bankModel.save();
        console.log('--Unmask__c--True__'+bankRow.Unmask__c);
    }
}
catch(e){
    console.log('caught'+e);
}
});
skuid.snippet.register('Mask/Unmask Con BA No',function(args) {var bankModel = skuid.model.getModel('BankAccount');
var bankRow = bankModel.data[0];
try{
    if(bankRow.Unmask_Con_Info__c === true){
        bankModel.updateRow(bankModel.getFirstRow(),
        {
            Unmask_Con_Info__c : false,
            ShowConfirmBankAcct : true
        });
        bankModel.save();
        console.log('--Unmask_Con_Info__c--False__'+bankRow.Unmask_Con_Info__c);
    }
    if(bankRow.Unmask_Con_Info__c ===false){
        bankModel.updateRow(bankModel.getFirstRow(),
        {
            Unmask_Con_Info__c : true,
            ShowConfirmBankAcct : true
        });
        bankModel.save();
        console.log('--Unmask_Con_Info__c--True__'+bankRow.Unmask_Con_Info__c);
    }
}
catch(e){
    console.log('caught'+e);
}
});
(function(skuid){
	var $ = skuid.$;
	
	$('#fundingAccount').bind('copy paste',function(e) {
	    console.log('hello');
	    e.preventDefault(); return false; 
	    
    });
	$(document.body).one('pageload',function(){
		
	});
	
})(skuid);;
}(window.skuid));