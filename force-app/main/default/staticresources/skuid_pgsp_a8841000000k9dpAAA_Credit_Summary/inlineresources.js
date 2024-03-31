(function(skuid){
skuid.snippet.register('ShowRawXML',function(args) {var accModel = skuid.model.getModel('CreditPolicy');
var accRow = appModels.data[0]; 
try{
    if(accRow.ShowRawXML === true){
        accModel.updateRow(accModel.getFirstRow(),
        {
            ShowRawXML : false
        });
        accModel.save();
        console.log('--ShowRawXML--False__'+accRow.ShowRawXML);
    }
    if(accRow.ShowRawXML ===false){
        accModel.updateRow(accModel.getFirstRow(),
        {
            ShowRawXML : true
        });
        accModel.save();
        console.log('--ShowRawXML--True__'+accRow.ShowRawXML);
    }
}
catch(e){
    console.log('caught'+e);
}
});
skuid.snippet.register('BureauSubsetDoc',function(args) {var params = arguments[0],
	$ = skuid.$;


var attachmentRow = skuid.model.getModel('AttachmentModel').getFirstRow();
//console.log('Hello'+attachmentRow.Id);
//alert(attachmentRow.Id);
//alert(attachmentRow.Name);
if(attachmentRow===undefined || attachmentRow === null){
    alert('No data found');
} else {
    var title = attachmentRow.Name;
    var iframeUrl = '/servlet/servlet.FileDownload?file=' + attachmentRow.Id;
    openTopLevelDialog({
        title: title,
        iframeUrl: iframeUrl
    });
}
});
}(window.skuid));