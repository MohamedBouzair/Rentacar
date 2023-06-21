import { LightningElement, api, track, wire } from 'lwc';
import getServiceContract from '@salesforce/apex/RentAppController.getServiceContract';


export default class contractInfo extends LightningElement {
    @api recordId;
    @track serviceContract;

    @wire(getServiceContract, { contractId: '$recordId'})
    wiredServiceContract({data,error}) {
        if (data) {
            this.serviceContract = data;
            console.log(JSON.stringify('data trouvée'));
        } else if(error){
            console.log(error);
        }
    }
}
