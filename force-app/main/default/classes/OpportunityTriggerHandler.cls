public with sharing class OpportunityTriggerHandler {

    public static void creatServiceContractOpportunityClosedWon(List<Opportunity> newOppList, Map<Id, Opportunity> oppMap) {

        Map<Id, ServiceContract> contractMap = new Map<Id, ServiceContract>();

        for(Opportunity oppList : newOppList){
            
            // Création d'un contrat en mettant à jour l'opportunité ==> StageName = 'Clôturé gagné'
            /* Cas de mise à jour : l'ancien StageName de l'opportunité soit différent de 'Clôturé gagné' && 
                Le stageName après mise à jour soit égale à 'Clôturé gagné' */
            if(oppMap.get(oppList.Id).StageName != 'Clôturé gagné' && oppList.StageName == 'Clôturé gagné'){
                contractMap.put(oppList.Id, new ServiceContract(Name = oppList.Name, 
                                                                AccountId = oppList.AccountId, 
                                                                StartDate = oppList.FromDate__c, 
                                                                EndDate = oppList.ToDate__c,
                                                                Pricebook2Id = oppList.Pricebook2Id,
                                                                Statut__c = 'Brouillon'));
                System.debug('Le contrat a été créer avec succès !');
            } else {
                System.debug('La création du contrat a échoué !');
            }
        }

        // Insertion des contrats
        if(contractMap.size() >= 1){
            insert contractMap.values();
        }

    }
}