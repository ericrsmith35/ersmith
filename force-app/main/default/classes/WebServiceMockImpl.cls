@isTest
global class WebServiceMockImpl implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
       docSampleComDocsample.EchoStringResponse_element respElement = 
           new docSampleComDocsample.EchoStringResponse_element();
       respElement.EchoStringResult = 'Mock response';
       response.put('response_x', respElement); 
   }
}