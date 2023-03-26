@RestResource(urlMapping='/SalesforceQueryDml/*')
global class Lex_To_Salesforce {
                        /*{ sample json code 
                    "tableName" : "Account",
                    "query" : "Select id from ",
                    "condition" :"where  Limit 10"
                    }*/
    @httpPost
    global static string stringparse(){
        string zeroRecords ='0 Records';
        RestRequest req = RestContext.request;
        String jsonPayload = req.requestBody.toString();
        Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonPayload);
        String tableName =  dataMap.get('tableName').toString();
        String query = dataMap.get('query').toString();
        String Condition = dataMap.get('condition').toString();
        String finalQuery = query + ' ' + tableName + ' ' + Condition ;
        system.debug('=============>'+FinalQuery);
        try{
            List<Sobject> ListOfRecords  = database.query(FinalQuery);
            system.debug('====>'+ListOfRecords);
            if(ListOfRecords.size()!=0){
                return JSON.serialize(ListOfRecords);
            }
        }
        catch(exception exc){
            system.debug('message '+exc.getMessage());
            return exc.getMessage();
        }
        return zeroRecords;
    }
                            /* sample json code 
                        {
                        "tableName":"Account",
                        "operation":"insert",
                        "sendingData":[
                        {
                        "Name":"aqeela",
                        "Phone":"888846599"
                        }
                        ]
                        }*/
    @httpPatch
    global static string JsonparseMethod(){
        // Parse the incoming JSON string into an Apex object
        //  String jsonPayload = '{ "tableName": "Account", "operation": "insert", "sendingData": [ { "Name": "aqeels", "Phone": "888846599" } ] }';
        RestRequest req = RestContext.request;
        String jsonPayload = req.requestBody.toString();
        
        List<string> jsonSuccess = new List<String>{'successfully inserted','successfully updated','success fully deleted' ,'No Operation done'};
            Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonPayload);
        system.debug(''+dataMap);
        String tableName =  dataMap.get('tableName').toString();
        String operation = dataMap.get('operation').toString();
        // Extract sending data and convert to list of maps
        List<Object> sendingData = (List<Object>) dataMap.get('sendingData');
        List<Map<String, Object>> dataList = new List<Map<String, Object>>();
        for (Object obj : sendingData) {
            dataList.add((Map<String, Object>) obj);
        }
        // Create list of SObjects to insert/update
        List<sObject> objectList = new List<sObject>();
        for (Map<String, Object> record : dataList) {
            sObject newObject = (sObject) Type.forName('Schema.' + tableName).newInstance();
            for (String fieldName : record.keySet()) {
                newObject.put(fieldName, record.get(fieldName));
            }
            objectList.add(newObject);
        }
        try{
            // Insert or update SObjects
            if (operation == 'insert') {
                insert objectList;
                return jsonSuccess[0];
            } else if (operation == 'update') {
                update objectList;
                return jsonSuccess[1];
            }else if (operation == 'delete'){
                delete objectList;
                return jsonSuccess[2];
            }
        }
        catch(exception exc){
            return exc.getMessage();
        }
        return jsonSuccess[3];
    } 
}