public class DocusignDocumentResponse {
    public String errorCode;
    public String message;
    public String status;	
	public String documentsUri;	
	public String recipientsUri;	
	public String attachmentsUri;
	public String envelopeUri;
	public String emailSubject;
	public String emailBlurb; 
	public String customFieldsUri;	
	public String autoNavigation;	
	public String envelopeIdStamping;	
	public String notificationUri;	
	public String enableWetSign;
	public String allowMarkup;
	public String allowReassign;	
	public String createdDateTime;
	public String lastModifiedDateTime;
	public String initialSentDateTime;
	public String sentDateTime;	
	public String statusChangedDateTime;	
	public String documentsCombinedUri;	
	public String certificateUri;
	public String templatesUri;
	public String brandId;	
	public String purgeState;
	public String is21CFRPart11;
	public String signerCanSignOnMobile;	
	public String isSignatureProviderEnvelope;
	public String allowViewHistory;
    public String envelopeId;
	public EnvelopeDocuments[] envelopeDocuments;
	public class EnvelopeDocuments {
		public String documentId;
		public String name;
		public String type;
		public String uri;
		public String order;
		public String pages;
		public AvailableDocumentTypes[] availableDocumentTypes;
		public String display;
		public String includeInDownload;
		public String signerMustAcknowledge;
		public String authoritativeCopy;
	}
	public class AvailableDocumentTypes {
		public String type;	
		public String isDefault;	
	}
    public DocumentFields[] documentFields;
	public class DocumentFields {
		public String name;	
		public String value;
	}

}