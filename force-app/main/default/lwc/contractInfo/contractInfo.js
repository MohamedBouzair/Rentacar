import { LightningElement, api, track, wire } from 'lwc';
import getServiceContract from '@salesforce/apex/RentAppController.getServiceContract';

export default class contractInfo extends LightningElement {
    @api recordId;
    @track serviceContract;
    @track data;

    @wire(getServiceContract, { contractId: '$recordId'})
    wiredServiceContract({data,error}) {
        console.log(JSON.stringify(data));
        if (data) {
            this.serviceContract = data;
            console.log(JSON.stringify('Contrat trouvé'));
        } else if(error){
            console.log('error');
        }
    }
}
