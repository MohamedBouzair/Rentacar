import { LightningElement, api, wire, track } from 'lwc';
import getVehicles from '@salesforce/apex/RentAppController.getVehicles';
import addVehicleToCurrentServiceContract from '@salesforce/apex/RentAppController.addVehicleToCurrentServiceContract';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Vehicles extends LightningElement {

    @track searchString;
    @track initialRecords;
    @api recordId;
    @track filter = ['','','',''];
    @track selectedVehicles = [];
    @track data;
    @track error;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    @track columns = [
        {
            label: 'Nom du véhicule',
            fieldName: 'Name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Type de véhicule',
            fieldName: 'Type',
            type: 'text',
            sortable: true
        },
        {
            label: 'Modèle-Année du véhicule',
            fieldName: 'Modele',
            type: 'text',
            sortable: true
        },
        {
            label: 'Couleur du véhicule',
            fieldName: 'Color',
            type: 'text',
            sortable: true
        },
        {
            label: 'prix à l\'unité',
            fieldName: 'unitPrice',
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

    @wire(getVehicles, {recordId: '$recordId', filter: '$filter'})
    wiredVehicle({ error, data }) {
        console.log(JSON.stringify(data));
        if (data) {
            console.log('Véhicules trouvée');
            let tempRecords = JSON.parse( JSON.stringify( data ) );
            tempRecords = tempRecords.map( row => {
                return { ...row, Name: row.Product2.Name, Type: row.Product2.Type__c, Modele: row.Product2.Modele__c, Color: row.Product2.Couleur__c, unitPrice: row.Product2.Prix_d_achat_Min__c, salesPrice: row.Product2.Prix_d_achat__c };
            })
            this.data = tempRecords;
            this.initialRecords = data;
        } else if (error) {
            console.log(JSON.stringify(error));
            console.log('Véhicules non trouvée');
        }
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
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