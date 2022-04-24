import { LightningElement } from 'lwc';

import getApexStruct from '@salesforce/apex/SelfServiceController.getApexStruct';
import submitApex from '@salesforce/apex/SelfServiceController.submitCaseAndFirePlatformEvent';

    
export default class SelfServiceContainer extends LightningElement {

    commSelfServiceInput;
    
    submitClicked=false;
    disableSubmit=true;
    numOfUploadedFiles = 0;
    uploadedFilesNames = '';
    

    connectedCallback(){
        getApexStruct().then(result=>{
            this.commSelfServiceInput = {...result};//console.log('this.commSelfServiceInput' ,this.commSelfServiceInput);
        }).catch( error => {
            console.error('problem with getApexStruct', result);
        })
    }



    submit() { 
        console.log('Submit Clicked');   
        submitApex({commSelfServiceInput: this.commSelfServiceInput}).then(result=>{
            this.submitClicked=true;//console.log('SelfServiceController submit insert Case with attached file Succeeded', result );
        }).catch( error => {
            console.error('problem with submitApex');
        });
    }  



    extraInputChanged(event) {
        console.log('event.detail.value', event.detail.value);
        console.log('event.target.name', event.target.name);
        this.commSelfServiceInput.ssExtraInput[event.target.name] = event.detail.value;
        this.calcDisableSubmit();  
    }

    
    
    calcDisableSubmit(){
        if((this.commSelfServiceInput.ssExtraInput.LastName != '') &&
           (this.commSelfServiceInput.ssExtraInput.FirstName !='') &&
           (this.commSelfServiceInput.ssExtraInput.Email != null)) {
                this.disableSubmit=false;
        }
        else{
            this.disableSubmit=true;
        }
    }

            

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles', uploadedFiles);
        for (let i = 0; i < uploadedFiles.length; i++) {
            this.commSelfServiceInput.ssAttachedFiles.FileNameList[i+this.numOfUploadedFiles] = uploadedFiles[i].name; 
            this.commSelfServiceInput.ssAttachedFiles.contentDocumentIdList[i+this.numOfUploadedFiles] = uploadedFiles[i].documentId; 
            this.commSelfServiceInput.ssAttachedFiles.contentVersionIdList[i+this.numOfUploadedFiles] = uploadedFiles[i].contentVersionId; 
            this.commSelfServiceInput.ssAttachedFiles.contentBodyIdList[i+this.numOfUploadedFiles] = uploadedFiles[i].contentBodyId;
            if(this.uploadedFilesNames == ''){
                this.uploadedFilesNames = uploadedFiles[i].name;
            }
            else{
                this.uploadedFilesNames = this.uploadedFilesNames + ',   ' + uploadedFiles[i].name;
            }    
        }
        this.numOfUploadedFiles = this.numOfUploadedFiles + uploadedFiles.length;//console.log('ssAttachedFiles', this.commSelfServiceInput.ssAttachedFiles);
    }

    
    get acceptedFormats() {
        return ['.png', '.jpg'];
    }

}