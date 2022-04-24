public with sharing class SelfServiceController {
  
    
    public static final Integer MAX_FILES_TO_SHOW = 8;
    public static final String CONTENT_VERSION_LINK = '/sfc/servlet.shepherd/version/download/';
    
    
    
        
    public SelfServiceController(){}


    @AuraEnabled
    public static SelfServiceStruct.SelfServiceInput getApexStruct(){
        //Id uId = UserInfo.getUserId();
        //User cUser = [SELECT ContactId FROM User WHERE Id=:uId LIMIT 1];//System.debug('cUser = ' + cUser);
        Contact dbContact = [
            SELECT Id, FirstName, LastName, Email, AccountId
            FROM Contact LIMIT 1
            //FROM Contact WHERE Id=:cUser.ContactId LIMIT 1
        ];// System.debug('cContact = ' + cContact);//System.debug('cContact' + json.serializePretty(cContact));     

        SelfServiceStruct.ExtraInput extraInput = new SelfServiceStruct.ExtraInput();
        SelfServiceStruct.AttachedFiles attachedFiles = new SelfServiceStruct.AttachedFiles();
        SelfServiceStruct.SelfServiceInput selfServiceInput = new SelfServiceStruct.SelfServiceInput(dbContact,extraInput,attachedFiles);
        return selfServiceInput;
    }



    
    @AuraEnabled
    public static void submitCaseAndFirePlatformEvent(SelfServiceStruct.SelfServiceInput commSelfServiceInput) {
        Case contactUsCase = new Case();
        
        contactUsCase.SuppliedName = commSelfServiceInput.ssExtraInput.firstName + ' ' + commSelfServiceInput.ssExtraInput.lastName;
        contactUsCase.SuppliedEmail = commSelfServiceInput.ssExtraInput.email;
        contactUsCase.AccountId = commSelfServiceInput.ssContact.AccountId;
        contactUsCase.Description = commSelfServiceInput.ssExtraInput.description;
        System.debug('submitCase insert Case contactUsCase = ' + contactUsCase);
        insert contactUsCase;//DML
        
        Id caseId = contactUsCase.Id;
               

        Self_Service__e event = new Self_Service__e();
        event.SS_CaseId__c = caseId;
        Database.SaveResult result = EventBus.publish(event);


        createAndInsertFiles(contactUsCase, commSelfServiceInput.ssAttachedFiles);//DML
        
        
        WorkOrder contactUsWorkOrder = new WorkOrder();

        WorkType wt = [SELECT Id, Name FROM WorkType WHERE name='OnLine Session with Agent' LIMIT 1]; //custom MTD !!!!!!!!
        ServiceTerritory teritory = [SELECT Id, Name FROM ServiceTerritory  WHERE name = 'Israel'  LIMIT 1]; //custom MTD !!!!!!!!!!
        contactUsWorkOrder.ServiceTerritoryId = teritory.Id;
        contactUsWorkOrder.WorkTypeId = wt.Id;
        contactUsWorkOrder.CaseId = caseId;
        insert contactUsWorkOrder; //DML

        
           
    }
  


    public static void createAndInsertFiles(Case contactUsCase, SelfServiceStruct.AttachedFiles attachedFiles) {
        
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        for(Integer i = 0; i<attachedFiles.contentDocumentIdList.size(); i++){ 
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = attachedFiles.contentDocumentIdList[i];
            contentDocumentLink.LinkedEntityId = contactUsCase.Id;
            cdl.add(contentDocumentLink);
        }
        insert cdl;//DML         
    }



    @AuraEnabled
    public static List<String> getFilesList(Id caseId) {
          
        List<ContentDocumentLink> cdlList = [
            SELECT ContentDocumentId,LinkedEntityId, ContentDocument.LatestPublishedVersionId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :caseId LIMIT :MAX_FILES_TO_SHOW
        ];
        System.debug('cdlList = ' + cdlList);
        
        List<String> filesLinksToReturn = new List<String>();
        for(ContentDocumentLink cdl :cdlList){ 
            filesLinksToReturn.add(CONTENT_VERSION_LINK+cdl.ContentDocument.LatestPublishedVersionId);    
        }
        
        return filesLinksToReturn;      
    }



    // @AuraEnabled
    // //public static String AddBellNotification(Case caseitem) {
    // public static String AddBellNotification() {
        
    //     FeedItem post = new FeedItem();
    //     // post.ParentId = caseitem.OwnerId;
    //     post.ParentId = '0051r000007n5qJAAQ';
    //     post.Body = 'caseitem.Message_To_Alert__c';
    //     post.Title = 'Case';
    //     post.LinkUrl = '/lightning/r/Case/' + '5001r00001wAitsAAC' + '/view';
    //     // post.LinkUrl = '/lightning/r/Case/' + caseitem.Id + '/view';
    //     insert post;
    //     return 'ggggg';                
    // }
}