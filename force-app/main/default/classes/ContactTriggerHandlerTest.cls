@istest 
public with sharing class ContactTriggerHandlerTest {
    
    @TestSetup
    static void setup() {
        Id consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
        Account account = new Account(
            Name='Test', 
            RecordTypeId = consumerRecordTypeId);
        insert account;

        Contact b = new Contact(
            LastName='consumerContact', 
            AccountId = account.Id) ;
        insert b;
    } 
    
    @istest 
    static void checkAccountContactCount() {
        Account a = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1 ];
        Contact contact = new Contact(
            LastName='consumerContact', 
            AccountId=a.Id);
            
        Test.StartTest();
        Database.SaveResult result = Database.insert(contact,false);
        Test.StopTest();
        System.assert(result.isSuccess()==false);
    }
} 