/* https://forcepanda.wordpress.com/2020/01/15/how-to-clone-records-using-flows-one-flow-to-clone-them-all-spring20delight/ */

public class CloneRecordFlowActionClass {
    
    @InvocableMethod(label='Clone Record')
    public static FlowOutputParameters[] cloneRecord(FlowInputParameters[] input){
        FlowOutputParameters[] result = new FlowOutputParameters[]{};
        
        sObject s = input[0].recordToClone; // Copying the input record to an sObject type variable
        s.put('Id',NULL); //Setting the 'Id' field of the record as NULL
        insert s; //Inserting the sObject record
        
        FlowOutputParameters obj = new FlowOutputParameters();
        obj.clonedRecordId = (string)s.get('Id'); //Copying the inserted sObject record Id to return as an flow output
        result.add(obj);
        
        return result;
    }
    
    /* Input parameters for the Apex action */
    public class FlowInputParameters{
        @InvocableVariable(label='Record to Clone' required = true )
        public sObject recordToClone;
    }
    
    /* Output parameters of the Apex action */
    public class FlowOutputParameters{
        @InvocableVariable(label='Cloned Record ID')
        public string clonedRecordId;
    }

}