import { LightningElement, api, wire, track } from 'lwc';
import getVehicles from '@salesforce/apex/RentAppController.getVehicles';
import addVehicleToCurrentServiceContract from '@salesforce/apex/RentAppController.addVehicleToCurrentServiceContract';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    {
        label: 'Nom du véhicule',
        fieldName: 'vehicleName',
        type: 'text',
        sortable: true
    },
    {
        label: 'Type de véhicule',
        fieldName: 'type',
        type: 'text',
        sortable: true
    },
    {
        label: 'Modèle-Année du véhicule',
        fieldName: 'modele',
        type: 'text',
        sortable: true
    },
    {
        label: 'Couleur du véhicule',
        fieldName: 'color',
        type: 'text',
        sortable: true
    },
    {
        label: 'prix à l\'unité',
        fieldName: 'priceunit',
        type: 'Decimal',
        sortable: true
    },
    {
    label: 'Prix de vente',
    fieldName: 'salesPrice',
    type: 'Decimal',
    editable: true,
    sortable: true
    },
];

export default class Vehicles extends LightningElement {

    @api recordId;
    @track filter = ['','','',''];
    @track selectedVehicles = [];
    @track data;
    columns = columns;
    vehicles;
    error;


    @wire(getVehicles, {recordId: '$recordId', filter: '$filter'})
    wired_Method(result) {
        console.log(JSON.stringify(result));
        let data = result.data;
        if(data){
            console.log(JSON.stringify(data));
            console.log('Voici ma data: ' + data);

            // this.data = result.data;
            this.vehicles = this.data.vehicles;
            console.log('Véhicules: ' + JSON.stringify(vehicles));
            this.error = undefined;
            console.log('recordId', this.recordId);
            console.log('data', data);
        } else if(result.error){
            this.error = result.error;
            this.data = undefined;
            console.log('error', error);
        }
    }

    handleDraftValues(event) {
        console.log('draft ', event.detail.draftValues);

        let draftData = event.detail.draftValues;
        let tempData = this.vehicles.map( element => {
            let temp = Object.assign({},element);
             draftData.forEach(e => {
                if(temp.Id === e.Id){
                    if(e.salesPrice >= temp.unitPrice){
                        temp.salesPrice = e.salesPrice;
                    }else if(e.salesPrice < temp.unitPrice){
                        this.showToast("Error", "Le prix de vente ne peut pas être inférieur au prix unitaire !!!", "error");
                    }
                }
        });
        return temp;
        });

        this.vehicles=tempData;
        console.log('tempdata ',this.vehicles);
        this.draftValues = [];

    }
  
    handelFilter(event){
        this.filter=event.detail.filter;
    }

    handleSave(){
        this.selectedVehicles =this.template.querySelector('lightning-datatable').getSelectedRows();
        if(this.selectedVehicles.length>0){
            addVehicleToCurrentServiceContract({vehicles: this.selectedVehicles, serviceContractId: this.recordId}).then(result => {
                if(result==='Vendu')
                {
                    
                    window.history.back();

                }   
                if(result==='Vente échouée')
                {
                    const event = new ShowToastEvent({ title: 'ERREUR',message:'Le prix de vente ne peut pas être inférieur au prix unitaire !!',variant:"error"});
                    this.dispatchEvent(event);
                }
                if (result==='Echec')
                {
                    const event = new ShowToastEvent({ title: 'ERREUR',message:'Impossible de louer plus qu\'une voiture !!',variant:"error"});
                    this.dispatchEvent(event); 
                }
                   
            })
                .catch(error => {
                    const event = new ShowToastEvent({ title: 'ERREUR',message:'Impossible d\'enregistrer !!',variant:"error"});
                    this.dispatchEvent(event);
                    console.log('error is : ',error);
                })
        }else {
            const event = new ShowToastEvent({ title: 'ERREUR',message:'Vous devez sélectionner un véhicule avant d\'enregistrer !!',variant:"error"});
                    this.dispatchEvent(event);
        }

        }  
  

    handleCancel(){
        window.history.back();
    }
}





/*const columns = [
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
}*/