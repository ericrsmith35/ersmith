public class LatLongReset {
    public static void LLReset(Service_Address__c[] SAList)
    {
        for (Service_Address__c SA: SAList) 
        {
            SA.Geolocation__Latitude__s = 0;
            SA.Geolocation__Longitude__s = 0;
        }
    }
}