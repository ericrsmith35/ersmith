trigger Trigger_Service_Address on Service_Address__c (before insert,before update) {
    Service_Address__c[] SAList = Trigger.new;
    if (Trigger.isBefore)
    {
        if ((Trigger.isInsert) || (Trigger.isUpdate))
        {
            if (!String.valueOf(URL.getCurrentRequestURL()).toLowerCase().contains('services/soap'))
            {
                //if request is not done via SOAP(DBAMP) Then reset Lat/Long
                LatLongReset.LLReset(SAList);       
            }
        }
    }
}