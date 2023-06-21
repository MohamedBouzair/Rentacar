public with sharing class DataSetupTest {

    // Création d'un compte de type consommateur
    public static Account createConsumerAccount() {
        Id consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
        Account account = new Account(Name='Account Test', RecordTypeId = consumerRecordTypeId);
        insert account;
        return account;
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
}