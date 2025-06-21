public with sharing class AzureGPTService {
    @AuraEnabled
    public static String getGPTResponse(String userMessage) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:AzureGPTCredential/openai/deployments/gpt4o/chat/completions?api-version=2024-02-15-preview');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');

        String requestBody = JSON.serialize(new Map<String, Object>{
            'messages' => new List<Object>{
                new Map<String, String>{'role' => 'system', 'content' => 'You are a helpful mental health check-in assistant.'},
                new Map<String, String>{'role' => 'user', 'content' => userMessage}
            },
            'temperature' => 0.7,
            'max_tokens' => 300
        });

        request.setBody(requestBody);

        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> choices = (List<Object>) result.get('choices');
            Map<String, Object> firstChoice = (Map<String, Object>) choices[0];
            Map<String, Object> message = (Map<String, Object>) firstChoice.get('message');
            return (String) message.get('content');
        } else {
            return 'Error: ' + response.getStatusCode() + ' - ' + response.getBody();
        }
    }
}