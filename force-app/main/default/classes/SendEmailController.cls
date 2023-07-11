public class SendEmailController {

    public ServiceContract myContract { get; set; }
    public ApexPages.StandardSetController setCon {get; private set;}
    public ApexPages.StandardSetController stdSetController { get; set; }

    public SendEmailController() {
        System.debug('Id :  '+ApexPages.CurrentPage().getParameters());
        ServiceContract servicecontract = (ServiceContract) stdSetController.getRecord();
        // Récupération des données du contrat
        this.myContract = [SELECT Id,Name, Account.Name, Contact.Email, StartDate, EndDate, (SELECT UnitPrice, TotalPrice, Quantity,Product2.Name FROM ContractLineItems ) FROM ServiceContract WHERE Id=: servicecontract.Id LIMIT 1];

    }

    public PageReference sendEmail(){
        // Générer le PDF de la VFP
        PageReference pdfPage = Page.ContractDetailsPage;
        pdfPage.getParameters().put('id', myContract.Id);
        Blob pdfBlob;
        if(!Test.isRunningTest()){
            pdfBlob = pdfPage.getContent();
        }else{
            pdfBlob = blob.valueof('TEST');
        }

        // Envoyer l'e-mail avec le PDF en pièce jointe
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(myContract.Name + '.pdf');
        attachment.setBody(pdfBlob);
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] sendEmailTo = new String[]{myContract.Contact.Email};
        email.setToAddresses(sendEmailTo);
        email.setSubject('Détails du contrat');
        email.setPlainTextBody('Veuillez trouver ci-joint les détails du contrat.');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        
        return null;
    }

    public pageReference okCancel() {
        return setCon.cancel();
    } 
}