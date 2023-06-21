trigger ContactTrigger on Contact (after insert, after update) {

    ContactTriggerHandler.checkContactCount(trigger.new);

}