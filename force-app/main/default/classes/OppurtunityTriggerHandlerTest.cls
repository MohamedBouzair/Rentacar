@istest
public with sharing class OppurtunityTriggerHandlerTest {

    // Création du data pour le test (un compte et son opportunité)
    @TestSetup
    static void setup() {
        Account acc = DataSetupTest.createConsumerAccount();
        Opportunity opp = DataSetupTest.creatOpportunity(acc.Id);
    }

    @istest
    public static void checkServiceContractCreation() {

        Test.StartTest();
        // On récupère le compte qui a été créer auparavant pour ensuite récupérer l'opportunité qui lui été associer 
        Account acct = [SELECT Id, Name FROM Account WHERE Name = 'Account Test' LIMIT 1];
        Opportunity oppor = [SELECT Id, Name, AccountId, FromDate__c, ToDate__c FROM Opportunity WHERE AccountId =: acct.Id LIMIT 1]; 

        // Mettre à jour l'opportunité
        oppor.StageName = 'Clôturé gagné';
        Database.update(oppor,true);

        // Récupération du contrat créé
        ServiceContract scList = [SELECT Id, Name, AccountId, StartDate, EndDate FROM ServiceContract 
                                        WHERE Name =: oppor.Name AND AccountId =: oppor.AccountId LIMIT 1];
        Test.StopTest();

        // On vérifie que le StartDate du contrat soit égal à le FromDate__c de l'opportunité
        // On vérifie également que le EndDate du contrat soit égal à le ToDate__c de l'opportunité
        System.assertEquals(oppor.FromDate__c, scList.StartDate);
        System.assertEquals(oppor.ToDate__c, scList.EndDate);
    }
}