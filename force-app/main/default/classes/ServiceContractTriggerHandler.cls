public with sharing class ServiceContractTriggerHandler {

    public static void checkOverlapServiceContract (List<ServiceContract> contractList) {
        Set<Id> accountId = new Set<Id>();
        List<Account> accountList = new List<Account>();

        for(ServiceContract servContract : contractList){
            if(servContract.AccountId != null){
                accountId.add(servContract.AccountId);
            }
        }

        Id consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
        Map<Id, Account> contractMap = new Map<Id, Account>([SELECT Id, RecordTypeId, (SELECT StartDate, EndDate, AccountId FROM ServiceContracts) FROM Account 
        WHERE Id IN :accountId AND RecordTypeId =: consumerRecordTypeId]);
        

        for(ServiceContract servContract : contractList){
            if(servContract.AccountId != null){
                if(contractMap.containsKey(servContract.AccountId)){
                    for(ServiceContract con : contractMap.get(servContract.AccountId).ServiceContracts){
                        if(servContract.AccountId == con.AccountId && servContract.Id != con.Id && 
                        ((servContract.EndDate >= con.StartDate && servContract.EndDate <= con.EndDate) || 
                         (servContract.StartDate >= con.StartDate && servContract.StartDate <= con.EndDate) || 
                        (servContract.StartDate <= con.StartDate && servContract.EndDate >= con.EndDate) || 
                        (servContract.StartDate >= con.StartDate && servContract.EndDate <= con.EndDate))) {
    
                            servContract.addError('Un contract est en cours pour ce compte, vous ne pouvez pas créer un nouveau contract');
                        }
                    }
                }
            }
        }   
    }
}