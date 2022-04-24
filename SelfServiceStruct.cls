public with sharing class SelfServiceStruct {

            
    public SelfServiceStruct() {}

    
    public class SelfServiceInput{
        @AuraEnabled public Contact ssContact {get;set;}
        @AuraEnabled public ExtraInput ssExtraInput {get;set;}
        @AuraEnabled public AttachedFiles ssAttachedFiles {get;set;}
       
        public SelfServiceInput(){}

        public SelfServiceInput(Contact sContact, ExtraInput sExtraInput, AttachedFiles sAttachedFiles){
            ssContact = sContact ;
            ssExtraInput = sExtraInput;
            ssAttachedFiles = sAttachedFiles;
        }
    }
   

    
    public class ExtraInput{
        @AuraEnabled public String FirstName {get;set;}
        @AuraEnabled public String LastName {get;set;}
        @AuraEnabled public String Email {get;set;}
        @AuraEnabled public String Description {get;set;}
        
        public ExtraInput(){}
    }



    public class AttachedFiles {
        @AuraEnabled public List<Id> contentDocumentIdList {get;set;}
        @AuraEnabled public List<Id> contentVersionIdList {get;set;}
        @AuraEnabled public List<Id> contentBodyIdList {get;set;}
        @AuraEnabled public List<String> FileNameList {get;set;}

        public AttachedFiles(){
            contentDocumentIdList = new List<Id>();
            contentVersionIdList = new List<Id>();
            contentBodyIdList = new List<Id>();
            FileNameList = new List<String>();
        }
    }

    

}
