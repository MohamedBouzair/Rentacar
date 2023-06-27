public with sharing class RentAppController {

    // Récupération des champs nécessaires de l'objet service contract
    private static ServiceContract getServiceContract(Id recordId){
        return [SELECT Account.Name, PriceBook2Id, Name, StartDate, EndDate FROM ServiceContract WHERE Id= :recordId];
    } 

    // Génération d'une requête SOQL pour sélectionner les véhicules qui n'ont pas été ajoutés à un contrat à partir de PriceBookEntry
    private static String getQueryPriceBookId(Id priceBookId, Id recordId){
        return 'SELECT Id, Pricebook2Id, Product2.Id, Product2.RecordTypeId, Product2.Name, Product2.Modele__c, Product2.Couleur__c, Product2.Type__c, UnitPrice FROM PriceBookEntry WHERE PriceBook2Id = \''+priceBookId+'\''+'AND Id NOT IN (SELECT PriceBookEntryId FROM ContractLineItem WHERE ServiceContractId = \''+recordId+'\')';
    }
    
    @AuraEnabled(cacheable=true)
    public static Wrapper getVehicles(Id recordId, List<String> filter){
        Wrapper wrapper = new Wrapper();
        ServiceContract serviceContract = getServiceContract(recordId);
        wrapper.sc = serviceContract;

        String query = getQueryPriceBookId(serviceContract.PriceBook2Id,  recordId);
        if(filter[0] != ''){
            query += ' AND Product2.RecordTypeId = \''+filter[0]+'\'';
        }
        if(filter[1] != ''){
            query += ' AND Product2.Type__c = \''+filter[1]+'\'';
        }
        if(filter[2] != ''){
            query += ' AND Product2.Modele__c = \''+filter[2]+'\'';
        }
        if(filter[3] != ''){
            query += ' AND Product2.Couleur__c = \''+filter[3]+'\'';
        }

        List<PriceBookEntry> pbeList = Database.query(query);
        List<WrapperVehicle> vehicleWrapperList = new List<WrapperVehicle>();
        if(!pbeList.isEmpty()){
            for(PriceBookEntry pbe : pbeList){
                WrapperVehicle scProdWrapper = new WrapperVehicle();
              
                scProdWrapper.type = pbe.Product2.Type__c;
                scProdWrapper.pricebookId = pbe.Pricebook2Id;
                scProdWrapper.Id = pbe.Id;
                scProdWrapper.vehicleName = pbe.Product2.Name;
                scProdWrapper.priceunit = pbe.UnitPrice;
                scProdWrapper.salesPrice = pbe.UnitPrice;
                scProdWrapper.color = pbe.Product2.Couleur__c;
                scProdWrapper.modele = pbe.Product2.Modele__c;
                vehicleWrapperList.add(scProdWrapper);
            }
        }
        wrapper.vehicles = vehicleWrapperList;

        return wrapper;
    }

    @AuraEnabled
    public static String addVehicleToCurrentServiceContract(List<WrapperVehicle> vehicles, Id serviceContractId){
        try {
            List<ContractLineItem> contractLineItemsList = new List<ContractLineItem>();
            for(WrapperVehicle pb : vehicles){
                if(pb.salesPrice < pb.salesPrice){
                    return 'Vente échouée';
                } else {
                    contractLineItemsList.add(new ContractLineItem(ServiceContractId = serviceContractId, PriceBookEntryId = pb.Id, UnitPrice = pb.salesPrice, Quantity = 1));
                }
            }
            insert contractLineItemsList;
            return 'Vendu';
        } catch (Exception e) {
            return 'Echec';
        }
    }

   /* @AuraEnabled
    public static Boolean deleteVehicleFromCurrentContract(List<Id> vhIds){
        Boolean result = false;

        try {
            delete [SELECT Id FROM Product2 WEHRE Id IN :vhIds];
            result = true;
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }

        return result;
    }*/
    
    public class Wrapper {
        @AuraEnabled
        public ServiceContract sc { get; set; }
        @AuraEnabled
        public List<WrapperVehicle> vehicles { get; set; }
    }
    
    public class WrapperVehicle {
        @AuraEnabled
        public String pricebookId { get; set; }
        
        @AuraEnabled
        public String Id { get; set; }

        @AuraEnabled
        public String vehicleName { get; set; }

        @AuraEnabled
        public Decimal priceunit { get; set; }

        @AuraEnabled
        public Decimal salesPrice { get; set; }
        
        @AuraEnabled
        public String type { get; set; }
            
        @AuraEnabled
        public String color { get; set; }
            
        @AuraEnabled
        public String modele { get; set; }
    }
    
    
    
    
    /* @AuraEnabled(cacheable=true)
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
        }*/

}