(function(skuid){
skuid.snippet.register('OpenPreviewDialog',function(args) {var params = arguments[0],
	$ = skuid.$;

var attachmentRow = skuid.model.getModel('NewAttachmentModel').getFirstRow();
var title = attachmentRow.Name;
var iframeUrl = '/servlet/servlet.FileDownload?file=' + attachmentRow.Id;
		
openTopLevelDialog({
    title: title,
    iframeUrl: iframeUrl
});
});
skuid.snippet.register('AddAttachmentsModal',function(args) {var params = arguments[0],
	$ = skuid.$;
var selectDocument = skuid.model.getModel('DocumentCategoryDetails').data[0];
var title = 'Add Application Documents to ' + selectDocument.Name; 
var skuidPage = 'ApplicationAttachmentList';
var iframeUrl = '/apex/skuid__ui?page=' + skuidPage + '&id=' + selectDocument.Id;
var prefixHtml = '<div><p>Select the following application documents that have not been added to any application document category and add them to <strong>' + selectDocument.Name + '</strong>.</p></div>';
openTopLevelDialog({
	title: title,
	iframeUrl: iframeUrl,
	prefixHtml: prefixHtml
});
});
skuid.snippet.register('DeleteDocumentCategory',function(args) {var params = arguments[0],
	$ = skuid.$;
var selectDocument = skuid.model.getModel('DocumentCategoryDetails').data[0];
var documentCategoryId = selectDocument.Id;	
var documentCategoryName = selectDocument.Name

var title = 'Delete ' + documentCategoryName + '?';
var message = '<p>Are you sure you want to Delete this Application Document Category'
			+ ', <strong>\'' + documentCategoryName + '\'</strong>?</p>';
var cancelText = 'No, do not Delete anything.';
var okText = 'Yes, Delete Application Document Category'
			+ ' \'' + documentCategoryName + '\'';

var okAction = {
	func: 'generateDeleteDocumentCategoryMessage',
	parameters: [documentCategoryId]
};

openTopLevelConfirmation({
	title: title,
	message: message,
	cancelText: cancelText,
	okText: okText,
	okAction: okAction
});
});
skuid.snippet.register('DeleteAttachment',function(args) {var params = arguments[0],
	$ = skuid.$;
var catAssociation = skuid.model.getModel('AppDocCatAssociation').data[0];
var documentId = catAssociation.genesis__AttachmentId__c;
var parentId = catAssociation.genesis__Application_Document_Category__c;

var attachmentModelData = skuid.model.getModel('NewAttachmentModel').data[0];
var documentName = attachmentModelData.Name;


var title = 'Delete ' + documentName + '?';
var message = '<p>Are you sure you want to Delete this Application Document'
			+ ', <strong>\'' + documentName + '\'</strong>?</p>';
var cancelText = 'No, do not Delete anything.';
var okText = 'Yes, Delete Application Document'
			+ ' \'' + documentName + '\'';

var okAction = {
	func: 'generateDeleteDocumentMessage',
	parameters: [documentId, parentId]
};

openTopLevelConfirmation({
	title: title,
	message: message,
	cancelText: cancelText,
	okText: okText,
	okAction: okAction
});
});
(function(skuid){
var $ = skuid.$;
$(document.body).one('pageload',function(){
openLinksInNewTab();
});
})(skuid);;
skuid.snippet.register('NewDocumentsTag',function(args) {var appModel = skuid.model.getModel('ParentApp');
var appRow = appModel.data[0];
console.log(appRow.Id);
try {
    var ret = sforce.apex.execute('PayOffUtilities','NewDocumentsTag',
    {   
        appId : appRow.Id
    });
    alert(ret);
} catch(err) {
    alert(err);
}
window.location.reload();
});
skuid.snippet.register('SendDocUploadNotification',function(args) {var appDocCatModel = skuid.model.getModel('DocumentCategoryDetails');
var scRow = appDocCatModel.data[0]; 
console.log('--APP DOC CATEGORIES '+scRow);

try{
    
    appDocCatModel.updateRow(appDocCatModel.getFirstRow(),
        {
            Doc_Upload_Notification__c : true
        });
        
    appDocCatModel.save();
    console.log('--Notification Email sent '+scRow.Doc_Upload_Notification__c);
  
}
catch(e){
    console.log('caught'+e);
}

window.location.reload();
});
skuid.snippet.register('SendDocUploadReminder',function(args) {var appDocCatModel = skuid.model.getModel('DocumentCategoryDetails');
var scRow = appDocCatModel.data[0]; 
console.log('--APP DOC CATEGORIES '+scRow);

try{
    
    appDocCatModel.updateRow(appDocCatModel.getFirstRow(),
        {
            Doc_Upload_Reminder__c : true
        });
        
    appDocCatModel.save();
    console.log('--Reminder Notification Email sent '+scRow.Doc_Upload_Notification__c);
  
}
catch(e){
    console.log('caught'+e);
}

window.location.reload();
});
}(window.skuid));