    @istest
    public with sharing class RentAppController_Test {
        
        @TestSetup
        static void makeData(){
            Account a = DataSetupTest.createConsumerAccount();
            ServiceContract serviceContract = DataSetupTest.createServiceContract(a.Id);
    
            Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
    
            Product2 vehicle0 = DataSetupTest.createVehicles( 'megane' , 'Renault' , '2012', 'jaune' );
            Product2 vehicle1 = DataSetupTest.createVehicles( '308' , 'Peugeot' , '2015', 'rouge' );
            Product2 vehicle2 = DataSetupTest.createVehicles( 'yaris' , 'Toyota' , '2016', 'grise' );
            Product2 vehicle3 = DataSetupTest.createVehicles( 'C4' , 'Citroën' , '2018', 'noir' );
    
            PricebookEntry pbe0 = DataSetupTest.createPricebookEntry(vehicle0.Id);
            PricebookEntry pbe1 = DataSetupTest.createPricebookEntry(vehicle1.Id);
            PricebookEntry pbe2 = DataSetupTest.createPricebookEntry(vehicle2.Id);
            PricebookEntry pbe3 = DataSetupTest.createPricebookEntry(vehicle3.Id);
    
    
        }
    
        @istest
        static void getVehicles_Test(){
    
            ServiceContract sc = [SELECT Id, Name, StartDate, EndDate, Account.Name, PriceBook2Id FROM ServiceContract LIMIT 1];
    
            String voitureRecordTypeId= Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Voiture').getRecordTypeId();   
            List<String> filter = new List<String>();
            filter.add(voitureRecordTypeId);
            filter.add('Renault');
            filter.add('2012');
            filter.add('jaune');
            
            List<PriceBookEntry> products = RentAppController.getVehicles(sc.Id ,filter);
             
            System.assertEquals(1,products.size());
        }
        
    
    @istest
    static void addVehicleToCurrentServiceContract_Test(){
    
        ServiceContract sc= [SELECT Id FROM ServiceContract LIMIT 1];
    
        String voitureRecordTypeId= Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Voiture').getRecordTypeId();   
        List<String> filter = new List<String>();
        filter.add(voitureRecordTypeId);
        filter.add('Renault');
        filter.add('2012');
        filter.add('jaune');
        
        List<PriceBookEntry> products = RentAppController.getVehicles(sc.Id, filter);
        
        // scénario N°1 :
        String result = RentAppController.addVehicleToCurrentServiceContract(products, sc.Id);
        System.assert(result == 'Vendu');
        
        // scénario N°2 :
        products[0].Product2.Prix_d_achat__c = 0;
        result = RentAppController.addVehicleToCurrentServiceContract(products, sc.Id);
        System.assert(result == 'Vente échouée');
    
        // scénario N°3 :
        List<String> filter2 = new List<String>(); 
        filter2.add(voitureRecordTypeId);
        filter2.add('Toyota');
        filter2.add('2016');
        filter2.add('red');
        system.debug('filter2: ' + filter2);
        products = RentAppController.getVehicles(sc.Id, filter2);
        result = RentAppController.addVehicleToCurrentServiceContract(products, sc.Id);
        system.debug('prodcuts: ' + products);
        System.assert(result == 'Echec');
    
    }
    
}
    