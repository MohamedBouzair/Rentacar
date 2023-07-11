public class SendEmailController {

    public ServiceContract servContract {get; set;}
    public String emailSubject {get; set;}
   	public String emailBody {get; set;}
    public ApexPages.StandardSetController setCon {get; private set;}

    public SendEmailController(ApexPages.StandardController stdController) {
        System.debug('Id :  '+ApexPages.CurrentPage().getParameters());
        ServiceContract myservicecontract = (ServiceContract) stdController.getRecord(); 
        System.debug('id 2 :  ' + myservicecontract);
        this.servContract = [SELECT Id, Account.Name, Contact.Email, Name, StartDate, EndDate, (SELECT UnitPrice, TotalPrice, Quantity, Product2.Name FROM ContractLineItems ) FROM ServiceContract WHERE Id=: myservicecontract.Id LIMIT 1];

    }

    public PageReference sendEmail(){
        // putting the infos we need in place
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
       	Messaging.SingleEmailMessage sendemail=new Messaging.SingleEmailMessage();
		String[] sendingTo = new String[]{servContract.Contact.Email};
		sendemail.setToAddresses(sendingTo);
		sendemail.setSubject(emailSubject);
		sendemail.setPlainTextBody(emailBody);
        
       	PageReference pref = page.ContractDetailsPage;
       	pref.getParameters().put('id',servContract.id);
       	pref.setRedirect(true);
        Blob b ;
        if(!Test.isRunningTest()){
            b = pref.getContent();
        }else{
            b = blob.valueof('TEST');
        }
        // preparing our email to send 
        attach.setFileName(servContract.Name +'.pdf'); 
       	attach.setBody(b);
       	sendemail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
        //sending the email 
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sendemail});
        if(results[0].isSuccess()){
			PageReference pageRef = new PageReference('/'+servContract.id);
       		pageRef.setRedirect(true);
            System.debug('mail is sent ');
			return pageRef;
		}
        System.debug('mail is not sent ');
        return null;
    }
}