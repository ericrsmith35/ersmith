trigger ProjectIntervalCalculate on Project__c (before update,before insert) {

  Project__c[] Projects = Trigger.new;
  ProjectInterval.calculateDueDate(Projects);
  
}