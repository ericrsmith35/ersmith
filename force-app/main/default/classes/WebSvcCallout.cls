public class WebSvcCallout {
    public static String callEchoString(String input) {
        docSampleComDocsample.DocSamplePort sample = new docSampleComDocsample.DocSamplePort();
        sample.endpoint_x = 'http://api.salesforce.com/foo/bar';
        
        // This invokes the EchoString method in the generated class
        String echo = sample.EchoString(input);
        
        return echo;
    }   
}