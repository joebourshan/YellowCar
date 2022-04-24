import { LightningElement, api } from 'lwc';
import getFilesListApex from '@salesforce/apex/SelfServiceController.getFilesList';

export default class SelfServiceInfoForCase extends LightningElement {

    @api recordId;
    filesLinksList=[];
    

    connectedCallback(){
        console.log('recordId', this.recordId);
        getFilesListApex({caseId: this.recordId}).then(result=>{
            this.filesLinksList=[...result];
        }).catch( error => {
            console.error('problem with getFilesListApex', result);
        })

    }

}








