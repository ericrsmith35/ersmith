/* Class:       RecallApprovalProcess
 * Created On:  Nov 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: Flow plugin that will update a record to recall an approval. See: https://opfocus.com/mastering-the-recall-of-an-approval-process/
 */

public class RecallApprovalProcess {

    @InvocableMethod(label='Recall Approval Process')
    public static void recall(Input[] inputs){
    	Input i = inputs[0];
    	//SObject so = Schema.getGlobalDescribe().get(i.sobjectName).newSObject();
    	//so.put('Id', i.recordId);
    	//so.put('Recall_Approval__c', true);
    	//update so;
    	//so.put('Recall_Approval__c', false);
    	//update so;
        
        ProcessInstance[] instances = [Select Id from ProcessInstance where TargetObjectId =:i.recordId and Status = 'Pending'];
        ProcessInstanceWorkItem[] workItems = [Select Id,ActorId from ProcessInstanceWorkItem where ProcessInstanceId in :instances];
        List<Approval.ProcessWorkItemRequest> processes = new List<Approval.ProcessWorkItemRequest>();
        for(ProcessInstanceWorkItem wi : workItems){
            System.debug('actor: ' + wi.ActorId);
            Approval.ProcessWorkItemRequest req = new Approval.ProcessWorkItemRequest();
            req.setWorkItemId(wi.Id);
            req.setAction('Removed');
            req.setComments('Recall Approval');
            processes.add(req);
        }

        Approval.ProcessResult[] results = Approval.process(processes);
        for(Approval.ProcessResult res : results){
            if(!res.isSuccess()){
                List<String> errors = new List<String>();
                for(Database.Error de : res.getErrors()){
                    errors.add(de.getMessage());
                }
                throw new RecallApprovalProcessException(String.join(errors,'; '));
            }
        }
    }

    public class RecallApprovalProcessException extends Exception{}

    public class Input {
    	@InvocableVariable(required=true label='Record Id')
    	public String recordId;

    	@InvocableVariable(required=true label='SObject Type')
    	public String sobjectName;
    }
}