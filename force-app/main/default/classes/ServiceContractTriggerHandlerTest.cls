@istest
public with sharing class ServiceContractTriggerHandlerTest {

    @TestSetup
    static void setup() {
        Id consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
        Account account = new Account(
            Name='Account Test', 
            RecordTypeId = consumerRecordTypeId);
        insert account;

        ServiceContract c = new ServiceContract(
            Name = 'Test001',
            AccountId = account.Id,
            StartDate = date.parse('01/06/2023'),
            EndDate = date.parse('10/06/2023'),
            Statut__c = 'Brouillon');
        insert c;
    }

    @istest
    public static void checkOverlapContract() {
        Account a = [SELECT Id, Name FROM Account WHERE Name = 'Account Test' LIMIT 1];
        ServiceContract contractTest = new ServiceContract(
            Name = 'Test001',
            AccountId = a.Id,
            StartDate = date.parse('06/06/2023'),
            EndDate = date.parse('20/06/2023'),
            Statut__c = 'Brouillon');

        Test.StartTest();
        Database.SaveResult result = Database.insert(contractTest,false);
        Test.StopTest();
        System.assert(result.isSuccess()==false);
    }
}