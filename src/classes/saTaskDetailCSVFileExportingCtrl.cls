public with sharing class saTaskDetailCSVFileExportingCtrl {
	public String sTitle {get; set;}
	public List<List<String>> lslsRow {get;set;}
	private String orderby;
	private List<String> kdKnowledgeIds;
	private String inClause;
	

	public saTaskDetailCSVFileExportingCtrl() {
		createFileName();
		queryData();
	}

	private void createFileName(){
		String fileName = '';
       	fileName = 'TaskDetail_';
       	//head row
		sTitle = '"支社","支店","作成者","ToDo件名","ToDo開始日","ToDo終了日","運用中フラグ","最終更新日","最終更新者","saMessageType__c","Type__c","User__c","UserReceiveEmail__c","ReplyComment__c"';
		filename = 	Datetime.now().format('yyyyMMdd') + '_' + filename + '.csv';
		Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename="' + EncodingUtil.urlEncode(fileName, 'UTF-8') + '"');
	}

	private void queryData(){
		String messageId = Apexpages.currentPage().getParameters().get('id');
		String queryStr = 'SELECT RegionalOfficeCode__c, BranchCode__c, CreatedBy.Name, Title__c, PublishedDateFormula__c, DeadlineDateFormula__c, IsPublished__c, LastModifiedDate, LastModifiedBy.Name FROM saMessage__c WHERE Id = \'' +  String.escapeSingleQuotes(messageId) + '\'';
		
		for (saMessage__c m : Database.query(queryStr)){
        	String queryDetail = 'SELECT saMessageType__c, Type__c, User__c, UserReceiveEmail__c, ReplyComment__c ' + 
				'FROM saMessageDetail__c WHERE saMessage__c = \'' +  String.escapeSingleQuotes(messageId) + '\'';
			String shisha = '';
			String shiten = '';
			for (UserRole ur : auUtilCmn.getChildRoles(NULL, auConstantCmn.ROLE_CODE_HONBU, true, true)) {
       		    if(ur.DeveloperName == m.RegionalOfficeCode__c){
       		    	shisha = ur.Name;
       		    }
       		    if(ur.DeveloperName == m.BranchCode__c){
       		    	shiten = ur.Name;
       		    }
       		    if(!String.isBlank(shisha) && !String.isBlank(shiten)) {
       		    	break;
       		    }
       		}

       		Date fromDate = m.PublishedDateFormula__c;
        	Date toDate = m.DeadlineDateFormula__c;
        	String fromDt = fromDate != null ? datetime.newInstance(fromDate.year(), fromDate.month(), fromDate.day()).format('yyyy/MM/dd') : '';
        	String toDt = toDate != null ? datetime.newInstance(toDate.year(), toDate.month(), toDate.day()).format('yyyy/MM/dd') : '';		

        	lslsRow = createCsvData(queryDetail, shisha, shiten, m.CreatedBy.Name, m.Title__c, fromDt, toDt, m.IsPublished__c, m.LastModifiedDate.format('yyyy/MM/dd'), m.LastModifiedBy.Name);
        }
	}

	//利用状況
	@ReadOnly @RemoteAction public static List<List<String>> createCsvData(String queryDetail, String shisha, 
		String shiten, String createBy, String title, String dateFrom, String dateTo, Boolean isPublic, String lastModifiedDate, String lastModifiedBy){
		List<saMessageDetail__c> listDetail = Database.query(queryDetail);
		List<List<String>> lslsRow = new List<List<String>>();
		List<String> lsRow = new List<String>();
		for (saMessageDetail__c d : listDetail) {
			if(lsRow.size() >= 1000) {
				lslsRow.add(lsRow);
	            lsRow = new List<String>();
			}
			String csvRow = '"' + shisha + '","' + shiten + '","' + createBy + '","' + title + '","' + dateFrom + '","' + dateTo + '","' +
			(isPublic ? '○' : '') + '","' + lastModifiedDate + '","' + lastModifiedBy + '","' + d.saMessageType__c + 
			'","' + d.Type__c + '","' + d.User__c + '","' + d.UserReceiveEmail__c + '","' + d.ReplyComment__c + '"';
			
			lsRow.add(csvRow);
		}
		lslsRow.add(lsRow);
		return lslsRow;
	}
}