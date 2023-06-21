import { LightningElement, wire, track } from 'lwc';
import getVehicle from '@salesforce/apex/RentAppController.getVehicle';
 
const columns = [
    { label: 'Nom', fieldName: 'Name' },
    { label: 'Modèle', fieldName: 'Modele__c' },
    { label: 'Type', fieldName: 'Type__c' },
    { label: 'Couleur', fieldName: 'Couleur__c' },
    { label: 'Nombre de personne', fieldName: 'Nombre_de_personne__c' },
    { label: 'Prix d\'achat Minimal', fieldName: 'Prix_d_achat_Min__c', editable: true },
    { label: 'Prix d\'achat', fieldName: 'Prix_d_achat__c', editable: true },
];
 
export default class vehicleList extends LightningElement {
    @track data;
    @track error;
    @track columns = columns;
    @track searchString;
    @track initialRecords;
 
    @wire(getVehicle)
    wiredVehicle({ error, data }) {
        if (data) {
            console.log(data);
            this.data = data;
            this.initialRecords = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }
 
    handleSearch(event) {
        const searchKey = event.target.value.toLowerCase();
 
        if (searchKey) {
            this.data = this.initialRecords;
 
            if (this.data) {
                let searchRecords = [];
 
                for (let record of this.data) {
                    let valuesArray = Object.values(record);
 
                    for (let val of valuesArray) {
                        console.log('val is ' + val);
                        let strVal = String(val);
 
                        if (strVal) {
 
                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }
 
                console.log('Matched Vehicles are ' + JSON.stringify(searchRecords));
                this.data = searchRecords;
            }
        } else {
            this.data = this.initialRecords;
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;
            case 'show_details':
                this.showRowDetails(row);
                break;
            default:
        }
    }

    deleteRow(row) {
        const { id } = row;
        const index = this.findRowIndexById(id);
        if (index !== -1) {
            this.data = this.data
                .slice(0, index)
                .concat(this.data.slice(index + 1));
        }
    }

    findRowIndexById(id) {
        let ret = -1;
        this.data.some((row, index) => {
            if (row.id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }

    showRowDetails(row) {
        this.record = row;
    }
}