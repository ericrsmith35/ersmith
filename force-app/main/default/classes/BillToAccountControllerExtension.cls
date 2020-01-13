public class BillToAccountControllerExtension {

    private final Opportunity oppty;

    public List<SelectOption> selOptions; 
    public List<Account> availableAccountsList;

    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard controller.
    public BillToAccountControllerExtension( ApexPages.StandardController stdController ) {
        this.oppty = (Opportunity)stdController.getRecord();
        setupAccountNames();
    }

   
    public List<SelectOption> getSelOptions() {
        return this.selOptions;
    }

    public List<Account> getAvailableAccountsList() {
        return this.availableAccountsList;
    }


    public void saveOpportunity() {
        try{
            update oppty;
        }catch(exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error Occured while updating the opportunity '+e.getMessage());
            ApexPages.addMessage(myMsg);
            Throw (e);
        }
    }



   private void setupAccountNames() {

         this.availableAccountsList = [Select Name, Id from Account];
         this.selOptions = new List<SelectOption>();
         Integer actCount = this.availableAccountsList.size();
         for(integer i=0; i < actCount; i++) {
            System.Debug('>>>> ' + i + ' >>>> Name[' + this.availableAccountsList[i].Id + '] is: ' +  this.availableAccountsList[i].Name  + '  <<<<<<<<<<<<<<<<<<<<<' );
            this.selOptions.add( new SelectOption( this.availableAccountsList[i].Id, this.availableAccountsList[i].Name));
         }
   }

}