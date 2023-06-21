trigger ServiceContractTrigger on ServiceContract (after insert, after update) {

    if (Trigger.isAfter){
        if (Trigger.isInsert || Trigger.isUpdate){
            ServiceContractTriggerHandler.checkOverlapServiceContract(trigger.new);
        }
    }

}