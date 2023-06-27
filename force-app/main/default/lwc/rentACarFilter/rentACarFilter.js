import { LightningElement, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import TYPE__C from '@salesforce/schema/Product2.Type__c';

export default class RentACarFilter extends LightningElement {
    brandValues = '';
    selectedtypeValue = '';
    year = '';
    color = '';
    @track options = [];
    @track brandPickListValues = [];
    @wire(getObjectInfo, { objectApiName: PRODUCT_OBJECT })
    prodObjectInfo({data, error}) {
        if(data) {

            let optionsValues = [];
            const rtInfos = data.recordTypeInfos;
            let rtValues = Object.values(rtInfos);

            for(let i = 0; i < rtValues.length; i++) {
                if(rtValues[i].name !== 'Master') {
                    optionsValues.push({
                        label: rtValues[i].name,
                        value: rtValues[i].recordTypeId
                    })
                }
            }

            this.options = optionsValues;
            
        }
        else if(error) {
            window.console.log('Error ===> '+JSON.stringify(error));
            this.options = optionsValues;
        }
    }

    handleChange(event) {
        this.selectedtypeValue = event.detail.value;
        console.log('selected value',this.selectedtypeValue);
    }

    @wire(getPicklistValues,{recordTypeId: "$selectedtypeValue",fieldApiName: TYPE__C })
    getPicklistValues({data,error}){
        if(data) {
            this.brandPickListValues=data.values;
        }
        else if(error) {
            console.log('Error ===> '+JSON.stringify(error));
            this.brandPickListValues = brandValues;
        }

    }
    
    handleBrand(event) {
        this.brandValues = event.detail.value;
        console.log('value',this.brandValues);
    }
    handelYearModel(event) {
        this.year=event.detail.value;
        console.log('value',this.year);
    }

    handelColor(event) {
        this.color=event.detail.value;
        console.log('value',this.color);
    }

    handleSearch() {
        let filterchild = [this.selectedtypeValue, this.brandValues, this.year, this.color]
        this.dispatchEvent(new CustomEvent('filter', {detail: {filter: filterchild}}));
    }
 
    handleClearall() {
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if(element.type === 'text'|| element.type === 'number'){
              element.value= null;
            }    
          }); 
        this.template.querySelectorAll('lightning-combobox').forEach(each => {
            each.value = null;
        });
        this.brandValues='';
        this.selectedtypeValue='';
        this.year='';
        this.color='';
        let filterchild = [this.selectedtypeValue, this.brandValues, this.year, this.color]
        this.dispatchEvent(new CustomEvent('filter', {detail: {filter: filterchild}}));
        }

}