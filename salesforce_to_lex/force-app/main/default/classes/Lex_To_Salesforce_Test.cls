@isTest
private class Lex_To_Salesforce_Test {
    @isTest
    static void testStringParse() {
        Account a = new Account(Name='Test Account');
        insert a;
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/SalesforceQueryDml/';
        req.httpMethod = 'POST';
        
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('tableName', 'Account');
        dataMap.put('query', 'SELECT Id, Name FROM');
        dataMap.put('condition', 'WHERE Name = \'Test Account\'');
        
        String jsonPayload = JSON.serialize(dataMap);
        req.requestBody = Blob.valueOf(jsonPayload);
        RestContext.request = req;
        
        String response = Lex_To_Salesforce.stringparse();
        System.assert(response.contains('Test Account'));
    }
    
    @isTest
    static void testJsonParseInsert() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/SalesforceQueryDml/';
        req.httpMethod = 'PATCH';
        
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('tableName', 'Account');
        dataMap.put('operation', 'insert');
        
        List<Map<String, Object>> sendingData = new List<Map<String, Object>>();
        Map<String, Object> record = new Map<String, Object>();
        record.put('Name', 'Test Account 1');
        sendingData.add(record);
        
        dataMap.put('sendingData', sendingData);
        
        String jsonPayload = JSON.serialize(dataMap);
        req.requestBody = Blob.valueOf(jsonPayload);
        RestContext.request = req;
        
        String response = Lex_To_Salesforce.JsonparseMethod();
        System.assert(response.contains('successfully inserted'));
    }
    
    @isTest
    static void testJsonParseUpdate() {
        Account a = new Account(Name='Test Account 2');
        insert a;
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/SalesforceQueryDml/';
        req.httpMethod = 'PATCH';
        
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('tableName', 'Account');
        dataMap.put('operation', 'update');
        
        List<Map<String, Object>> sendingData = new List<Map<String, Object>>();
        Map<String, Object> record = new Map<String, Object>();
        record.put('Id', a.Id);
        record.put('Name', 'Test Account 2 Updated');
        sendingData.add(record);
        
        dataMap.put('sendingData', sendingData);
        
        String jsonPayload = JSON.serialize(dataMap);
        req.requestBody = Blob.valueOf(jsonPayload);
        RestContext.request = req;
        
        String response = Lex_To_Salesforce.JsonparseMethod();
        System.assert(response.contains('successfully updated'));
    }
    
    @isTest
    static void testJsonParseDelete() {
        Account a = new Account(Name='Test Account 3');
        insert a;
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/SalesforceQueryDml/';
        req.httpMethod = 'PATCH';
        
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('tableName', 'Account');
        dataMap.put('operation', 'delete');
        
        List<Map<String, Object>> sendingData = new List<Map<String, Object>>();
        Map<String, Object> record = new Map<String, Object>();
        record.put('Id', a.Id);
        record.put('Name', 'Test Account 2 Updated');
        sendingData.add(record);
        
        dataMap.put('sendingData', sendingData);
        
        String jsonPayload = JSON.serialize(dataMap);
        req.requestBody = Blob.valueOf(jsonPayload);
        RestContext.request = req;
        
        String response = Lex_To_Salesforce.JsonparseMethod();
        System.assert(response.contains('successfully deleted'));
    }
    
 
}