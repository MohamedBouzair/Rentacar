public with sharing class DataSetupTest {

    // Création d'un compte de type consommateur
    public static Account createConsumerAccount() {
        Id consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
        Account account = new Account(Name='Consumer Account Test', RecordTypeId = consumerRecordTypeId);
        insert account;
        return account;
    }

    // Création d'un compte de type entreprise
    public static Account createEntrepriseAccount() {
        Id entrepriseRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entreprise').getRecordTypeId();
        Account a = new Account(Name = 'Entreprise Account Test', RecordTypeId = entrepriseRecordTypeId) ;
        insert a;
        Return a ;
    }

    // Création d'un contact pour un compte déjà créé
    public static Contact createContact(Id accountId) {
        Contact b = new Contact(LastName = 'consumerContact', AccountId = accountId);
        insert b;
        Return b ;
    }

    // Création d'une oppotunité pour un compte déjà créé
    public static Opportunity creatOpportunity(Id accountId) {
        Opportunity opp = new Opportunity(Name = 'Oppurtunity Test',
                                            AccountId = accountId,
                                            CloseDate = date.parse('29/06/2023'),
                                            FromDate__c = date.parse('09/06/2023'),
                                            ToDate__c = date.parse('29/06/2023'),
                                            StageName = 'Négotiation');
        insert opp;
        return opp;
    }

    // Création d'un véhicule
    public static Product2 createVehicles( String name, String type, String modele, String color){
        Id voitureRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Voiture').getRecordTypeId();
        Product2 p = new Product2(Name = name, RecordTypeId = voitureRecordTypeId, Type__c=type, Modele__c = modele, Couleur__c = color);
        insert p;
        return p;
    }

    public static PricebookEntry createPricebookEntry(Id productId){
        Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebook.Id, Product2Id = productId, IsActive = true, UnitPrice=800 );
        insert pbe;
        return pbe;
    }

    public static ServiceContract createServiceContract(Id accountId){
        Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        ServiceContract sc = new ServiceContract(AccountId =accountId, PriceBook2Id = pricebook.Id, Name = 'test', Statut__c = 'Brouillon', StartDate = date.parse('30/06/2023'), EndDate = date.parse('07/07/2023'));
        insert sc;
        return sc;
    }
}