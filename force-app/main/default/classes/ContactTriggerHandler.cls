public with sharing class ContactTriggerHandler {
    
    public static void checkContactCount(List<Contact> newContact){

        set<Id> accountId = new set<Id>();

        for(Contact ct : newContact){
            if(ct.AccountId != null){
                accountId.add(ct.AccountId);
            }
        }

        List<Account>   account = [SELECT Id,RecordTypeId,(SELECT Id FROM Contacts) FROM Account WHERE Id IN :accountId WITH SECURITY_ENFORCED];
        Id consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();

        for(Account acct : account){
            if(acct.Contacts != null && acct.Contacts.size()>1 && acct.RecordTypeId == consumerRecordTypeId){
                for(Contact ct : newContact){
                    if(ct.AccountId == acct.Id){
                        ct.addError('Un consommateur ne peut avoir qu\'un seul contact');
                    }
                }
            }
        }
    }
}