public with sharing class RentAppController {

        @AuraEnabled(cacheable=true)
        public static ServiceContract getServiceContract(Id contractId) {
            return [SELECT Name, StartDate, EndDate, Account.Name FROM ServiceContract WHERE Id = :contractId WITH SECURITY_ENFORCED];
        }

        @AuraEnabled(cacheable=true)
        public static List<Product2> getVehicle() {
            return [SELECT Name, Modele__c, Type__c, Couleur__c, Nombre_de_personne__c, Prix_d_achat_Min__c, Prix_d_achat__c FROM Product2 WITH SECURITY_ENFORCED];
        }
        
        @AuraEnabled(cacheable=true)
        public static String insertContractLineItems(List<Product2> products, Id serviceContractId){

            try{
                List<ContractLineItem> contractLineItemsList = new List<ContractLineItem>();
                for(Product2 prd : products) {
                    if(prd.Prix_d_achat__c < prd.Prix_d_achat_Min__c){
                        return 'faild sales';
                    } else {
                        contractLineItemsList.add(new ContractLineItem(ServiceContractId = serviceContractId, 
                                                                        pricebookEntryId = prd.Id, 
                                                                        UnitPrice = prd.Prix_d_achat__c, 
                                                                        Quantity = 1));
                    }
                }
                insert contractLineItemsList;
                    return 'success';
            } catch (Exception error){
                return 'failed';
            }
        }

}