public with sharing class RentAppController {

    private static Pricebook2 getStandardPricebook(){
        return [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
    }

    @AuraEnabled(cacheable=true)
    public static ServiceContract getServiceContract(Id contractId) {
        return [SELECT Name, StartDate, EndDate, Account.Name, PriceBook2Id FROM ServiceContract WHERE Id = :contractId WITH SECURITY_ENFORCED];
    }
 
    @AuraEnabled(cacheable=true)
    public static List<PriceBookEntry> getVehicles(Id recordId, List<String> filter){
        Pricebook2 priceB = getStandardPricebook();
        // Récupération des champs nécessaires de l'objet service contract
        ServiceContract serviceContract = getServiceContract(recordId);
        System.debug(serviceContract);
        
        List<PriceBookEntry> vehicleList = new List<PriceBookEntry>([SELECT Id, Name FROM PriceBookEntry WHERE Id NOT IN (SELECT PriceBookEntryId FROM ContractLineItem)]);
        Set<Id> vehicleIds = new Set<Id>();
        for (PriceBookEntry vehicle : vehicleList) {
            vehicleIds.add(vehicle.Id);
        }
        List<ContractLineItem> contractLineItems = [SELECT PriceBookEntryId, StartDate, EndDate, ServiceContractId FROM ContractLineItem];
        for(ContractLineItem clItems : contractLineItems){
            if(serviceContract.Id != clItems.ServiceContractId && (serviceContract.StartDate > clItems.EndDate || serviceContract.EndDate < clItems.StartDate)){
                vehicleIds.add(clItems.PriceBookEntryId);
            }
        }
        System.debug('My set: ' + vehicleIds);
        // Génération d'une requête SOQL pour sélectionner les véhicules disponible
        String query = 'SELECT Id, Pricebook2Id, Product2.Id, Product2.RecordTypeId, Product2.Name, Product2.Modele__c, Product2.Couleur__c, Product2.Type__c, Product2.Prix_d_achat__c, Product2.Prix_d_achat_Min__c, UnitPrice FROM PriceBookEntry WHERE PriceBook2Id = \''+priceB.Id+'\''+' AND Id IN :vehicleIds';

        if(filter[0]!='' && filter[0]!='0'){
            query += ' AND Product2.RecordTypeId = \''+filter[0]+'\'';
        }
        if(filter[1] != '' && filter[1]!='0'){
            query += ' AND Product2.Type__c = \''+filter[1]+'\'';
        }
        if(filter[2] != '' && filter[2]!='0'){
            query += ' AND Product2.Modele__c = \''+filter[2]+'\'';
        }
        if(filter[3] != '' && filter[3]!='0'){
            query += ' AND Product2.Couleur__c = \''+filter[3]+'\'';
        }
        System.debug('MyQuery'+query);
       

        List<PriceBookEntry> pbeList=Database.query(query);
        System.debug(pbeList);
        return pbeList;
    }

    @AuraEnabled
    public static String addVehicleToCurrentServiceContract(List<PriceBookEntry> vehicles, Id serviceContractId){
        ServiceContract sc = getServiceContract(serviceContractId);

        try {
            List<ContractLineItem> contractLineItemsList = new List<ContractLineItem>();
            for(PriceBookEntry pb : vehicles){
                if(pb.Product2.Prix_d_achat__c < pb.UnitPrice){
                    return 'Vente échouée';
                } else {
                    contractLineItemsList.add(new ContractLineItem(ServiceContractId = serviceContractId, PriceBookEntryId = pb.Id, UnitPrice = pb.UnitPrice, StartDate = sc.StartDate, EndDate = sc.EndDate, Quantity = 1));
                }
            }
            insert contractLineItemsList;
            return 'Vendu';
        } catch (Exception e) {
            return 'Echec';
        }
    }
}