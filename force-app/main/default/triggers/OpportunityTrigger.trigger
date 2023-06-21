trigger OpportunityTrigger on Opportunity (after update) {

    if(Trigger.isAfter && Trigger.isUpdate){
        OpportunityTriggerHandler.creatServiceContractOpportunityClosedWon(trigger.new, trigger.oldMap);
    }

}