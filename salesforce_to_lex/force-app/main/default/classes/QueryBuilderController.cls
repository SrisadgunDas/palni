@RestResource(urlMapping='/Querybuildservices/*')

Global class QueryBuilderController {
    
    public string TARGETC;
    public string OWNERID;
    public string USEREMAIL;
    
    @HttpPost
    Global static String getSOQLQuery() {     
        System.debug('REACH THE POST METHOD');
        RestRequest request = RestContext.request;        
        String jsonString = RestContext.request.requestBody.toString(); // json string from python
        String jsonresult=  getSOQLQueryFromJson(jsonString); // metheod 2     ||
        return jsonresult;
        
        //String Email='bilal.butt@abbott.com';
        //String userDetails=  getUserIdandTargetC(Email);
        //return userDetails;
    }
     
    public static String  getSOQLQueryFromJson(String jsonString){ // method 2
        Map<String,Object> jsonParsed =(Map<String,Object>)JSON.deserializeUntyped(jsonString);         // parameter json string
        String ObjectName =  jsonParsed.get('Table').toString(); // get table ===> object
        Object RelatedMethod =  jsonParsed.get('Method'); // get method
        System.debug('RelatedMethod---'+RelatedMethod);
        List<Object> selectCOlumnsArr = (List<Object>)jsonParsed.get('Requestdata'); // request data
        Map<Object, String> ListOfConditions = new Map<Object, String>{'gte'=>'>=','gt'=>'>','lte'=>'<=','lt'=>'<','eq'=>'=', 'neq'=>'!=', 'like'=>'LIKE'};
            
            String selectCOlumns = ''; String finalselectCOlumns = '';
        for(Integer i=0;i<selectCOlumnsArr.size();i++) {
            String selectInCOlumns = '';
            if(selectCOlumnsArr[i] instanceof String){
                System.debug('String  '+selectCOlumnsArr[i]);
                if(selectCOlumns == '' ){ selectCOlumns +=  selectCOlumnsArr[i]; finalselectCOlumns +=  selectCOlumnsArr[i]; }
                else { selectCOlumns += ', '+selectCOlumnsArr[i]; finalselectCOlumns +=   ', '+selectCOlumnsArr[i]; }
                
            }else if(selectCOlumnsArr[i] instanceof List<object>){
                
                System.debug('-31-selectCOlumnsArr[i]--:'+selectCOlumnsArr[i]);
                List<Object> inselectQuery = (List<Object>)selectCOlumnsArr[i];
                
                for (Object dataNodeqs : inselectQuery) {
                    Map<String,Object> dataNodeq = (Map<string,Object>)dataNodeqs;
                    
                    String SelectInQTable = (String)dataNodeq.get('Table');
                    List<Object> SelectInQFieldsArr = (List<Object>)dataNodeq.get('Requestdata');
                    selectInCOlumns = string.join(SelectInQFieldsArr,', ');
                    
                    System.debug('GGGGGGGGGGGGGGG '+selectInCOlumns);
                    finalselectCOlumns += ', '+selectInCOlumns.toLowerCase();
                    
                    List<Object> selinqueryconditionArr = (List<Object>)dataNodeq.get('condition');
                    
                    string selingroupbyclause = ''; string selinorderbyclause = '';
                    List<Object> selingroupbyclauseArr = (List<Object>)dataNodeq.get('GROUPBY');
                    if(selingroupbyclauseArr !=null){ selingroupbyclause = string.join(selingroupbyclauseArr,','); }
                    
                    List<Object> selinorderbyclauseArr = (List<Object>)dataNodeq.get('ORDERBY');
                    if(selinorderbyclauseArr !=null){ selinorderbyclause = string.join(selinorderbyclauseArr,','); }
                    
                    Object selinlimitofquery = dataNodeq.get('LIMIT');
                    String selInQueryCondition = ''; String selInOrQueryCondition = ''; String selInQueryStr = '';
                    
                    if(selinqueryconditionArr != null && selinqueryconditionArr.size()>0){
                        for (Object selinqueryCon : selinqueryconditionArr) {
                            Map<String,Object> selinq_StrObj = (Map<string,Object>)selinqueryCon;
                            Object selInConColumn = selinq_StrObj.get('key');
                            Object selInConType = selinq_StrObj.get('condition');
                            Object selInConValue = selinq_StrObj.get('value');
                            String selInConditionVal = ListOfConditions.get(selInConType);
                            
                            if(selinq_StrObj.size() > 0 &&  selInConColumn != null){
                                selInQueryCondition += selInConColumn+' '+selInConditionVal+' '+selInConValue;
                            }else if(selinq_StrObj.size() > 0 &&  selInConColumn != null && selInQueryCondition !=''){
                                selInQueryCondition += ' and '+selInConColumn+' '+selInConditionVal+' '+selInConValue;
                            }
                            
                        }
                        
                        System.debug('selInQueryCondition '+selInQueryCondition);
                        
                        Map<String, Object> selindataNodeIn = (Map<String, Object>)selinqueryconditionArr[0];
                        System.debug('selindataNodeIn'+selindataNodeIn);
                        
                        //Build the and condition logic start
                        List<Object> selInAndInConditionObject = (List<Object>)selindataNodeIn.get('AND');
                        System.debug('selInAndInConditionObject '+selInAndInConditionObject);
                        
                        if(selInAndInConditionObject != null && selInAndInConditionObject.size()>0){
                            for (Object selsingleInandCondition : selInAndInConditionObject) {
                                Map<String,Object> selmpin_StrObj = (Map<string,Object>)selsingleInandCondition;
                                System.debug(selmpin_StrObj);
                                Object selInandConColumn = selmpin_StrObj.get('key');
                                Object selInandConType = selmpin_StrObj.get('condition');
                                Object selInandConValue = selmpin_StrObj.get('value');
                                
                                System.debug(ListOfConditions.get(selInandConType));
                                String selInandConditionVal = ListOfConditions.get(selInandConType);
                                if(selmpin_StrObj.size() > 0 &&  selInQueryCondition ==''){
                                    selInQueryCondition += selInandConColumn+' '+selInandConditionVal+' '+selInandConValue;
                                }else if(selmpin_StrObj.size() > 0 && selInQueryCondition !=''){
                                    selInQueryCondition += ' and '+selInandConColumn+' '+selInandConditionVal+' '+selInandConValue;
                                }
                            }
                        } 
                    }
                    
                    
                    String selectInQeury = 'Select '+selectInCOlumns+' From '+SelectInQTable;
                    if(selInQueryCondition !=''){ selectInQeury += ' where '+selInQueryCondition; }
                    if(selingroupbyclause != ''){ selectInQeury += '  group by  '+selingroupbyclause; }
                    if(selinorderbyclause != ''){ selectInQeury += ' order by '+selinorderbyclause; }
                    if(selinlimitofquery !=null){ selectInQeury += ' limit '+selinlimitofquery; }
                    
                    if(selectInQeury !=''){ selectInQeury = '('+selectInQeury+')';}
                    
                    if(selectCOlumns == '' ){ selectCOlumns += selectInQeury; }
                    else { selectCOlumns += ', '+selectInQeury; }
                }
            }
        }
        System.debug('SelectInQFieldsArr'+selectCOlumns);
        
        string groupbyclause = ''; string orderbyclause = '';
        //Group by for main query
        List<Object> groupbyclauseArr = (List<Object>)jsonParsed.get('GROUPBY');
        if(groupbyclauseArr !=null){ groupbyclause = string.join(groupbyclauseArr,','); }
        
        //Order by for main query
        List<Object> orderbyclauseArr = (List<Object>)jsonParsed.get('ORDERBY');
        if(orderbyclauseArr !=null){ orderbyclause = string.join(orderbyclauseArr,','); }
        //Main query limit
        Object limitofquery = jsonParsed.get('LIMIT');
        
        String QueryCondition = '';  String InQueryCondition = ''; String InQuery = ''; String NotInQuery = '';   String NotInQueryCondition = '';
        String OrQueryCondition = ''; String InOrQueryCondition = ''; String InOrsQueryCondition = '';  String InQueryStr = '';  String NotInQueryStr = '';
        
        //Main query where conditions
        List<Object> allconditionsArr = (List<Object>)jsonParsed.get('conditions'); 
        List<Object> InConditionObject = new List<Object>{};
        List<Object> NotInConditionObject = new List<Object>{};
            
            System.debug(' allconditionsArr     '+allconditionsArr);
        if(allconditionsArr!=null){
            Map<String, Object> dataNode = (Map<String, Object>)allconditionsArr[0];
            
            //Build the and condition logic start
            List<Object> AndConditionObject = (List<Object>)dataNode.get('AND');
            
            //OR condition in main query
            if(AndConditionObject != null){
                for(Object AndORConditionObjects : AndConditionObject){
                    Map<String, Object> AndORConditionObject = (Map<String, Object>)AndORConditionObjects;
                    System.debug('AndORConditionObject '+AndORConditionObject);
                    List<Object> AndOrConditionObj = (List<Object>)AndORConditionObject.get('OR'); 
                    System.debug('AndOrConditionObj '+AndConditionObject);
                    if(AndOrConditionObj != null && AndOrConditionObj.size()>0){
                        for (Object singleORCondition : AndOrConditionObj) {
                            Map<String,Object> mor_StrObj = (Map<string,Object>)singleORCondition;
                            Object OrConColumn = mor_StrObj.get('key');
                            Object OrConType = mor_StrObj.get('condition');
                            Object OrConValue = mor_StrObj.get('value');
                            
                            System.debug(ListOfConditions.get(OrConType));
                            String OrConditionVal = ListOfConditions.get(OrConType);
                            
                            if(mor_StrObj.size() > 0 && OrQueryCondition ==''){ OrQueryCondition += OrConColumn+' '+OrConditionVal+' '+OrConValue; }
                            else if(mor_StrObj.size() > 0 && OrQueryCondition !=''){ OrQueryCondition += ' or '+OrConColumn+' '+OrConditionVal+' '+OrConValue; }
                        }
                        
                        if(OrQueryCondition !=''){ OrQueryCondition = '('+OrQueryCondition+')'; }
                        AndORConditionObject.remove('OR');
                    }
                }
            }
            
            //AND Conditions in main query
            if(AndConditionObject != null && AndConditionObject.size()>0){
                for (Object singleCondition : AndConditionObject) {
                    Map<String,Object> mp_StrObj = (Map<string,Object>)singleCondition;
                    System.debug(mp_StrObj);
                    Object ConColumn = mp_StrObj.get('key');
                    Object ConType = mp_StrObj.get('condition');
                    Object ConValue = mp_StrObj.get('value');
                    
                    System.debug(ListOfConditions.get(ConType));
                    String ConditionVal = ListOfConditions.get(ConType);
                    if(mp_StrObj.size() > 0 && QueryCondition =='' && OrQueryCondition ==''){
                        QueryCondition += ConColumn+' '+ConditionVal+' '+ConValue;
                    }else if(mp_StrObj.size() > 0 && (QueryCondition !='' || OrQueryCondition !='')){
                        QueryCondition += ' and '+ConColumn+' '+ConditionVal+' '+ConValue;
                    }
                }
            }
            //Build the and condition logic end
            
            //Build the In condition logic start in Main query
            InConditionObject = (List<Object>)dataNode.get('IN');
            NotInConditionObject = (List<Object>)dataNode.get('NOT IN');
            System.debug('NotInConditionObject '+NotInConditionObject);
            
            
            if(NotInConditionObject !=null && NotInConditionObject.size() > 0){
                for (Object singleNotInCondition : NotInConditionObject) {
                    Map<String,Object> notin_StrObj = (Map<string,Object>)singleNotInCondition;
                    
                    Object Table = notin_StrObj.get('Table');
                    Object Requestdata = notin_StrObj.get('Requestdata');
                    Object InConDfieldInvalue = notin_StrObj.get('value');
                    String fieldIn = notin_StrObj.get('fieldIn').toString();
                    Boolean fieldInType = fieldIn.contains('Date');
                    Boolean fieldInTypes = fieldIn.contains('date');
                    
                    List<Object> notinqueryconditionsArr = (List<Object>)notin_StrObj.get('conditions');  
                    List<Object> notinqueryconditionArr = (List<Object>)notin_StrObj.get('condition'); 
                    
                    string notingroupbyclause = '';  string inorderbyclause = '';
                    List<Object> notingroupbyclauseArr = (List<Object>)notin_StrObj.get('GROUPBY');
                    if(notingroupbyclauseArr !=null){ notingroupbyclause = string.join(notingroupbyclauseArr,','); }
                    
                    List<Object> inorderbyclauseArr = (List<Object>)notin_StrObj.get('ORDERBY');
                    if(inorderbyclauseArr !=null){ inorderbyclause = string.join(inorderbyclauseArr,','); }
                    Object inlimitofquery = notin_StrObj.get('LIMIT');
                    System.debug('NOT DDDDDDDDDDDDDDDDD '+notinqueryconditionArr);
                    
                    if(notinqueryconditionsArr != null && notinqueryconditionsArr.size()>0 && Requestdata != null){
                        Map<String, Object> notindataNode = (Map<String, Object>)notinqueryconditionsArr[0];                    
                        //Build the and condition logic start
                        List<Object> NotInAndConditionObject = (List<Object>)notindataNode.get('AND');
                        
                        if(NotInAndConditionObject != null){
                            Map<String, Object> InAndORConditionObject = (Map<String, Object>)NotInAndConditionObject[0];
                            List<Object> InAndOrConditionObj = (List<Object>)InAndORConditionObject.get('OR'); 
                            
                            if(InAndOrConditionObj != null && InAndOrConditionObj.size()>0){
                                for (Object insingleORCondition : InAndOrConditionObj) {
                                    Map<String,Object> inmor_StrObj = (Map<string,Object>)insingleORCondition;
                                    Object InOrConColumn = inmor_StrObj.get('key');
                                    Object InOrConType = inmor_StrObj.get('condition');
                                    Object InOrConValue = inmor_StrObj.get('value');
                                    
                                    System.debug(ListOfConditions.get(InOrConType));
                                    String InOrConditionVal = ListOfConditions.get(InOrConType);                                  
                                    if(inmor_StrObj.size() > 0 && InOrQueryCondition ==''){
                                        InOrQueryCondition += InOrConColumn+' '+InOrConditionVal+' '+InOrConValue;
                                    }else if(inmor_StrObj.size() > 0 && InOrQueryCondition !=''){
                                        InOrQueryCondition += ' or '+InOrConColumn+' '+InOrConditionVal+' '+InOrConValue;
                                    }
                                }
                                
                                if(InOrQueryCondition !=''){ InOrQueryCondition = '('+InOrQueryCondition+')'; }
                                InAndORConditionObject.remove('OR');
                            }
                        }
                        
                        if(NotInAndConditionObject != null && NotInAndConditionObject.size()>0){
                            for (Object insingleCondition : NotInAndConditionObject) {
                                Map<String,Object> notinmp_StrObj = (Map<string,Object>)insingleCondition;
                                System.debug(notinmp_StrObj);
                                Object InConColumn = notinmp_StrObj.get('key');
                                Object InConType = notinmp_StrObj.get('condition');
                                Object InConValue = notinmp_StrObj.get('value');
                                
                                System.debug(ListOfConditions.get(InConType));
                                String InConditionVal = ListOfConditions.get(InConType);
                                if(notinmp_StrObj.size() > 0 && NotInQueryCondition =='' && InOrQueryCondition ==''){
                                    NotInQueryCondition +=InConColumn+' '+InConditionVal+' '+InConValue;
                                }else if(notinmp_StrObj.size() > 0 && (NotInQueryCondition !='' || InOrQueryCondition !='')){
                                    NotInQueryCondition += ' and '+InConColumn+' '+InConditionVal+' '+InConValue;
                                }
                            }  
                        }
                    }
                    
                    if(notinqueryconditionArr != null && notinqueryconditionArr.size()>0){
                        for (Object notinqueryCon : notinqueryconditionArr) {
                            Map<String,Object> notinq_StrObj = (Map<string,Object>)notinqueryCon;
                            Object InConColumn = notinq_StrObj.get('key');
                            Object InConType = notinq_StrObj.get('condition');
                            Object InConValue = notinq_StrObj.get('value');
                            String InConditionVal = ListOfConditions.get(InConType);
                            
                            if(notinq_StrObj.size() > 0 && NotInQuery =='' &&  InConColumn != null){
                                NotInQueryCondition += InConColumn+' '+InConditionVal+' '+InConValue;
                            }else if(notinq_StrObj.size() > 0 && NotInQuery !='' &&  InConColumn != null){
                                NotInQueryCondition += ' and '+InConColumn+' '+InConditionVal+' '+InConValue;
                            }
                            
                            List<Object> NotInQueryInConditionObject = (List<Object>)notinq_StrObj.get('IN');
                            
                            if(NotInQueryInConditionObject !=null){
                               NotInQueryCondition=  getInQueryCondition( NotInQueryInConditionObject , notinq_StrObj ,NotInQuery);
                            }
                            
                        }
                        
                        Map<String, Object> notindataNodeIn = (Map<String, Object>)notinqueryconditionArr[0];
                        System.debug('notindataNodeIn'+notindataNodeIn);
                        
                        //Build the and condition logic start
                        List<Object> NotInAndInConditionObject = (List<Object>)notindataNodeIn.get('AND');
                        System.debug('NotInAndInConditionObject '+NotInAndInConditionObject);
                        System.debug('NotInQueryCondition DDDDDDDDDDD '+NotInQueryCondition);
                        if(NotInAndInConditionObject != null && NotInAndInConditionObject.size()>0){
                                NotInQueryCondition += getInQueryCondition(NotInAndInConditionObject,ListOfConditions,QueryCondition,OrQueryCondition);                            
                       
                        } 
                        System.debug('NotInQueryCondition '+NotInQueryCondition);
                        
                        List<Object> InORInConditionObject = (List<Object>)notindataNodeIn.get('OR');
                        System.debug(InORInConditionObject);
                        if(InORInConditionObject != null && InORInConditionObject.size()>0){                            
                            InOrQueryCondition = getInOrQueryCondition(InORInConditionObject,ListOfConditions,InOrsQueryCondition);                            
                            notindataNodeIn.remove('OR');
                        }
                    }
                    
                    //Build the and condition logic end
                    
                    System.debug('NotInQueryCondition   '+NotInQueryCondition+'QueryCondition  '+QueryCondition+'  NotInQuery'+NotInQuery+'  inlimitofquery'+inlimitofquery); 
                    
                    if(QueryCondition =='' && NotInQuery =='' && OrQueryCondition =='' && NotInQueryCondition !='' && Requestdata!=null){
                        NotInQueryStr = ' select '+Requestdata+' from '+Table+' where '+InOrQueryCondition+' '+NotInQueryCondition;
                        
                        System.debug('Before inorderbyclause '+inorderbyclause+'   FFFFFFFFFF '+NotInQueryStr);
                        if(notingroupbyclause != ''){ NotInQueryStr += '  group by  '+notingroupbyclause; }
                        if(inorderbyclause != ''){ NotInQueryStr += ' order by '+inorderbyclause; }
                        if(inlimitofquery !=null){ NotInQueryStr += ' limit '+inlimitofquery; }
                        
                        List<Sobject> InqueryRes = queryExecution(NotInQueryStr);
                        List<String> allIdLst = new List<String>();
                        String idinQuery = ''; Integer i=0; 
                        System.debug('inorderbyclause '+inorderbyclause+'InqueryRes  '+InqueryRes);
                        if(InqueryRes !=null && InqueryRes.size()>0){
                            for(Sobject s:InqueryRes){
                                Map<String, Object> fieldsAndValues = s.getPopulatedFieldsAsMap();
                                if((fieldInTypes!=null || fieldInType !=null) && (fieldInType || fieldInTypes)){
                                    Date dateToStr = Date.valueOf(fieldsAndValues.values()[0]);
                                    String finalcolValDate = DateTime.newInstance(dateToStr, Time.newInstance(0, 0, 0, 0)).format('YYYY-MM-dd');
                                    if(i==0){ idinQuery += finalcolValDate; }
                                    else { idinQuery += ','+finalcolValDate; }
                                }else {
                                    if(i==0){ idinQuery += '\''+fieldsAndValues.values()[0]+'\''; }
                                    else {  idinQuery += ',\''+fieldsAndValues.values()[0]+'\''; }
                                }
                                i++;
                            }
                            
                            System.debug('SOQL RESULT '+idinQuery+' fieldInTypes '+fieldInTypes+' fieldInType '+fieldInType);
                            NotInQuery += fieldIn+' NOT IN ('+idinQuery+')';
                        }
                        else  {
                            String jsonresult = getSuccessNoDataJsonResult();
                            return jsonresult;
                        }
                    }
                    else if((NotInQueryCondition !='' || NotInQuery !='' || InQueryCondition !=''|| NotInQueryCondition !='') && Requestdata != null){
                        NotInQueryStr += ' select '+Requestdata+' from '+Table+' where '+InOrQueryCondition+' '+NotInQueryCondition;
                        if(notingroupbyclause != ''){ NotInQueryStr += ' group by '+notingroupbyclause; }
                        if(inorderbyclause != ''){ NotInQueryStr += ' order by  '+inorderbyclause; }
                        if(inlimitofquery !=null){ NotInQueryStr += ' limit '+inlimitofquery; }
                        
                        System.debug('   FFFFFFFFFF '+NotInQueryStr);
                        
                        List<Sobject> InqueryRes = queryExecution(NotInQueryStr);
                        List<String> allIdLst = new List<String>();
                       
                      	String idinQuery = getIdInQuery(InqueryRes,fieldInTypes,fieldInType);
                        
                        System.debug('SOQL RESULT '+idinQuery+' fieldInTypes '+fieldInTypes+' fieldInType '+fieldInType);
                        //InQuery += fieldIn+' IN ('+InqueryRes+' )';
                        if(idinQuery ==''){
                            String jsonresult = getSuccessNoDataJsonResult();
                            
                            return jsonresult;
                        }else {
                            NotInQuery += ' and '+fieldIn+' NOT IN ('+idinQuery+')';
                        }
                        
                    }
                    
                    if(Requestdata == null && fieldIn != null){
                        if(notin_StrObj.size() > 0 &&  NotInQuery =='' && InOrQueryCondition =='' && OrQueryCondition =='' && QueryCondition == ''){
                            NotInQuery += fieldIn+' NOT IN ('+InConDfieldInvalue+')';
                        }else if(notin_StrObj.size() > 0 && (NotInQuery !=''  || InOrQueryCondition !='' || QueryCondition != '' || OrQueryCondition !='')){
                            NotInQuery += ' and '+fieldIn+' NOT IN ('+InConDfieldInvalue+')';
                        }
                    }
                }
            }
            
            if(InConditionObject !=null && InConditionObject.size() > 0){
                for (Object singleInCondition : InConditionObject) {
                    Map<String,Object> in_StrObj = (Map<string,Object>)singleInCondition;
                    
                    Object Table = in_StrObj.get('Table');
                    Object Requestdata = in_StrObj.get('Requestdata');
                    Object InConDfieldInvalue = in_StrObj.get('value');
                    String fieldIn = in_StrObj.get('fieldIn').toString();
                    Boolean fieldInType = fieldIn.contains('Date');
                    Boolean fieldInTypes = fieldIn.contains('date');
                    
                    List<Object> inqueryconditionsArr = (List<Object>)in_StrObj.get('conditions');  
                    List<Object> inqueryconditionArr = (List<Object>)in_StrObj.get('condition'); 
                    
                    string ingroupbyclause = '';  string inorderbyclause = '';
                    List<Object> ingroupbyclauseArr = (List<Object>)in_StrObj.get('GROUPBY');
                    if(ingroupbyclauseArr !=null){ ingroupbyclause = string.join(ingroupbyclauseArr,','); }
                    
                    List<Object> inorderbyclauseArr = (List<Object>)in_StrObj.get('ORDERBY');
                    if(inorderbyclauseArr !=null){ inorderbyclause = string.join(inorderbyclauseArr,','); }
                    Object inlimitofquery = in_StrObj.get('LIMIT');
                    System.debug('DDDDDDDDDDDDDDDDD '+inqueryconditionArr);
                    
                    if(inqueryconditionsArr != null && inqueryconditionsArr.size()>0 && Requestdata != null){
                        Map<String, Object> indataNode = (Map<String, Object>)inqueryconditionsArr[0];                    
                        //Build the and condition logic start
                        List<Object> InAndConditionObject = (List<Object>)indataNode.get('AND');
                        
                        if(InAndConditionObject != null){
                            Map<String, Object> InAndORConditionObject = (Map<String, Object>)InAndConditionObject[0];
                            List<Object> InAndOrConditionObj = (List<Object>)InAndORConditionObject.get('OR'); 
                            
                            if(InAndOrConditionObj != null && InAndOrConditionObj.size()>0){
                                for (Object insingleORCondition : InAndOrConditionObj) {
                                    Map<String,Object> inmor_StrObj = (Map<string,Object>)insingleORCondition;
                                    Object InOrConColumn = inmor_StrObj.get('key');
                                    Object InOrConType = inmor_StrObj.get('condition');
                                    Object InOrConValue = inmor_StrObj.get('value');
                                    
                                    System.debug(ListOfConditions.get(InOrConType));
                                    String InOrConditionVal = ListOfConditions.get(InOrConType);                                  
                                    if(inmor_StrObj.size() > 0 && InOrQueryCondition ==''){
                                        InOrQueryCondition += InOrConColumn+' '+InOrConditionVal+' '+InOrConValue;
                                    }else if(inmor_StrObj.size() > 0 && InOrQueryCondition !=''){
                                        InOrQueryCondition += ' or '+InOrConColumn+' '+InOrConditionVal+' '+InOrConValue;
                                    }
                                }
                                
                                if(InOrQueryCondition !=''){ InOrQueryCondition = '('+InOrQueryCondition+')'; }
                                InAndORConditionObject.remove('OR');
                            }
                        }
                        
                        if(InAndConditionObject != null && InAndConditionObject.size()>0){
                            for (Object insingleCondition : InAndConditionObject) {
                                Map<String,Object> inmp_StrObj = (Map<string,Object>)insingleCondition;
                                System.debug(inmp_StrObj);
                                Object InConColumn = inmp_StrObj.get('key');
                                Object InConType = inmp_StrObj.get('condition');
                                Object InConValue = inmp_StrObj.get('value');
                                
                                System.debug(ListOfConditions.get(InConType));
                                String InConditionVal = ListOfConditions.get(InConType);
                                if(inmp_StrObj.size() > 0 && InQueryCondition =='' && InOrQueryCondition ==''){
                                    InQueryCondition +=InConColumn+' '+InConditionVal+' '+InConValue;
                                }else if(inmp_StrObj.size() > 0 && (InQueryCondition !='' || InOrQueryCondition !='')){
                                    InQueryCondition += ' and '+InConColumn+' '+InConditionVal+' '+InConValue;
                                }
                            }  
                        }
                    }
                    
                    if(inqueryconditionArr != null && inqueryconditionArr.size()>0){
                        for (Object inqueryCon : inqueryconditionArr) {
                            Map<String,Object> inq_StrObj = (Map<string,Object>)inqueryCon;
                            Object InConColumn = inq_StrObj.get('key');
                            Object InConType = inq_StrObj.get('condition');
                            Object InConValue = inq_StrObj.get('value');
                            String InConditionVal = ListOfConditions.get(InConType);
                            
                            if(inq_StrObj.size() > 0 && InQuery =='' &&  InConColumn != null){
                                InQueryCondition += InConColumn+' '+InConditionVal+' '+InConValue;
                            }else if(inq_StrObj.size() > 0 && InQuery !='' &&  InConColumn != null){
                                InQueryCondition += ' and '+InConColumn+' '+InConditionVal+' '+InConValue;
                            }
                            List<Object> InQueryInConditionObject = (List<Object>)inq_StrObj.get('IN');
                            
                            if(InQueryInConditionObject !=null){
                               InQueryCondition=  getInQueryCondition( InQueryInConditionObject , inq_StrObj ,InQuery);
                              /*  Map<String,Object> inqin_StrObj = (Map<string,Object>)InQueryInConditionObject[0];
                                Object InConfieldInColumn = inqin_StrObj.get('fieldIn');
                                Object InConfieldInvalue = inqin_StrObj.get('value');
                                System.debug(InConfieldInvalue+'XXXXXXXXXXXXXXXXXXXX'+InConfieldInColumn);
                                
                                if(inq_StrObj.size() > 0 && InQuery =='' &&  InConfieldInColumn != null){
                                    InQueryCondition += InConfieldInColumn+' IN ('+InConfieldInvalue+')';
                                }else if(inq_StrObj.size() > 0 && InQuery !='' &&  InConfieldInColumn != null){
                                    InQueryCondition += ' and '+InConfieldInColumn+' IN ('+InConfieldInvalue+')';
                                }*/
                            }
                        }
                        
                        Map<String, Object> indataNodeIn = (Map<String, Object>)inqueryconditionArr[0];
                        System.debug('indataNodeIn'+indataNodeIn);
                        
                        //Build the and condition logic start
                        List<Object> InAndInConditionObject = (List<Object>)indataNodeIn.get('AND');
                        System.debug(InAndInConditionObject);
                        
                        if(InAndInConditionObject != null && InAndInConditionObject.size()>0){
                                InQueryCondition = getInQueryCondition(InAndInConditionObject,ListOfConditions,QueryCondition,OrQueryCondition);                            
                       
                        } 
                        
                        List<Object> InORInConditionObject = (List<Object>)indataNodeIn.get('OR');
                        System.debug(InORInConditionObject);
                        if(InORInConditionObject != null && InORInConditionObject.size()>0){                            
                            InOrQueryCondition = getInOrQueryCondition(InORInConditionObject,ListOfConditions,InOrsQueryCondition);                            
                            indataNodeIn.remove('OR');
                        }
                    }
                    
                    //Build the and condition logic end
                    
                    System.debug('QueryCondition   '+QueryCondition+'ingroupbyclause'+ingroupbyclause+'  inorderbyclause'+inorderbyclause+'  inlimitofquery'+inlimitofquery); 
                    
                    if(QueryCondition =='' && InQuery =='' && OrQueryCondition =='' && InQueryCondition !='' && Requestdata!=null){
                        InQueryStr = ' select '+Requestdata+' from '+Table+' where '+InOrQueryCondition+' '+InQueryCondition;
                        
                        System.debug('Before inorderbyclause '+inorderbyclause);
                        if(ingroupbyclause != ''){ InQueryStr += '  group by  '+ingroupbyclause; }
                        if(inorderbyclause != ''){ InQueryStr += ' order by '+inorderbyclause; }
                        if(inlimitofquery !=null){ InQueryStr += ' limit '+inlimitofquery; }
                        
                        List<Sobject> InqueryRes = queryExecution(InQueryStr);
                        List<String> allIdLst = new List<String>();
                        String idinQuery = ''; Integer i=0; 
                        System.debug('inorderbyclause '+inorderbyclause+'InqueryRes  '+InqueryRes);
                        if(InqueryRes !=null && InqueryRes.size()>0){
                            for(Sobject s:InqueryRes){
                                Map<String, Object> fieldsAndValues = s.getPopulatedFieldsAsMap();
                                if((fieldInTypes!=null || fieldInType !=null) && (fieldInType || fieldInTypes)){
                                    Date dateToStr = Date.valueOf(fieldsAndValues.values()[0]);
                                    String finalcolValDate = DateTime.newInstance(dateToStr, Time.newInstance(0, 0, 0, 0)).format('YYYY-MM-dd');
                                    if(i==0){ idinQuery += finalcolValDate; }
                                    else { idinQuery += ','+finalcolValDate; }
                                }else {
                                    if(i==0){ idinQuery += '\''+fieldsAndValues.values()[0]+'\''; }
                                    else {  idinQuery += ',\''+fieldsAndValues.values()[0]+'\''; }
                                }
                                i++;
                            }
                            
                            System.debug('SOQL RESULT '+idinQuery+' fieldInTypes '+fieldInTypes+' fieldInType '+fieldInType);
                            InQuery += fieldIn+' IN ('+idinQuery+')';
                        }
                        else  {
                            String jsonresult = getSuccessNoDataJsonResult();
                            return jsonresult;
                        }
                    }
                    else if((InQueryCondition !='' || InQuery !='' || InOrQueryCondition !='') && Requestdata != null){
                        InQueryStr += ' select '+Requestdata+' from '+Table+' where '+InOrQueryCondition+' '+InQueryCondition;
                        if(ingroupbyclause != ''){ InQueryStr += ' group by '+ingroupbyclause; }
                        if(inorderbyclause != ''){ InQueryStr += ' order by  '+inorderbyclause; }
                        if(inlimitofquery !=null){ InQueryStr += ' limit '+inlimitofquery; }
                                                
                        List<Sobject> InqueryRes = queryExecution(InQueryStr);
                        
                        List<String> allIdLst = new List<String>();
                       
                      String idinQuery = getIdInQuery(InqueryRes,fieldInTypes,fieldInType);
                       
                        
                        System.debug('SOQL RESULT '+idinQuery+' fieldInTypes '+fieldInTypes+' fieldInType '+fieldInType);
                        //InQuery += fieldIn+' IN ('+InqueryRes+' )';
                        if(idinQuery ==''){
                            String jsonresult = getSuccessNoDataJsonResult();
                            
                            return jsonresult;
                        }else {
                            InQuery += ' and '+fieldIn+' IN ('+idinQuery+')';
                        }
                        
                    }
                    
                    if(Requestdata == null && fieldIn != null){
                        if(in_StrObj.size() > 0 &&  InQuery =='' && InOrQueryCondition =='' && OrQueryCondition =='' && QueryCondition == ''){
                            InQuery += fieldIn+' IN ('+InConDfieldInvalue+')';
                        }else if(in_StrObj.size() > 0 && (InQuery !=''  || InOrQueryCondition !='' || QueryCondition != '' || OrQueryCondition !='')){
                            InQuery += ' and '+fieldIn+' IN ('+InConDfieldInvalue+')';
                        }
                    }
                }
            }
        
        }
        
        groupbyclause=   (groupbyclause!='') ? ' GROUP BY '+ groupbyclause:'' ;
        orderbyclause=   (orderbyclause!='') ? ' ORDER BY '+ orderbyclause:'' ;
        limitofquery=   (limitofquery!=null) ? ' LIMIT '+ limitofquery :'' ;
        
        System.debug('InConditionObject  '+InConditionObject+'  OrQueryCondition  === '+OrQueryCondition+'  QueryCondition   '+QueryCondition+ ' InQuery  '+InQuery+' NotInQuery  '+InQuery);
        
        String finalQuery = ''; String jsonresult = '';
        if(InConditionObject ==null && OrQueryCondition==''  &&  QueryCondition=='' && InQuery=='' && NotInQuery==''){
            finalQuery = 'Select '+selectCOlumns+' From '+ObjectName;
        }else if(InConditionObject !=null && InQueryStr !='' && InQuery == '' && NotInQueryStr !='' && NotInQuery == ''){
            jsonresult = getSuccessNoDataJsonResult();
            return jsonresult;
        }
        else {
            //Build the In condition logic end
            finalQuery = 'Select '+selectCOlumns+' From '+ObjectName+' where '+OrQueryCondition+' '+QueryCondition+'  '+InQuery+' '+NotInQuery;
            
            System.debug('OrQueryCondition  === '+OrQueryCondition+'  QueryCondition  '+QueryCondition);
            
            if(OrQueryCondition != '' || QueryCondition != '' || InQuery != '' || NotInQuery !=''){
                finalQuery = 'Select '+selectCOlumns+' From '+ObjectName+' where '+OrQueryCondition+' '+QueryCondition+'  '+InQuery+' '+NotInQuery;
            }else {
                finalQuery = 'Select '+selectCOlumns+' From '+ObjectName+'  '+InQuery+' '+NotInQuery;
            }
        }
        
        finalQuery+= groupbyclause+' ' +orderbyclause+' '+limitofquery;
        
        
        System.debug('finalQuery  === '+finalQuery);
        
        if(RelatedMethod ==null && finalQuery !=''){ //if(RelatedMethod!=null && RelatedMethod.toString().length()==0)
            List<Sobject> finalQueryRes = queryExecution(finalQuery);
            List<Object> executedQueryResult = new List<Object>();
            Integer s = 0;
            
            for(Sobject r:finalQueryRes){
                Map<String, Object> singleObj = r.getPopulatedFieldsAsMap();                
                executedQueryResult.add(singleObj);             
                s++;
            }
            System.debug('finalQueryRes  === '+executedQueryResult);
            Map<String, Object> finalMap = new Map<String, Object>();
            finalMap.put('Status','Success');
            finalMap.put('Subject','Data available.');
            finalMap.put('Code',200);
            finalMap.put('Data',executedQueryResult);
            jsonresult = JSON.serialize(finalMap);
        }
        else if(RelatedMethod == 'arrangeResult'  && finalQuery !=''){
            jsonresult = arrangeResult(finalQuery, selectCOlumns, ObjectName, finalselectCOlumns);
        }else if(finalQuery ==''){
            jsonresult = getSuccessNoDataJsonResult();
            return jsonresult;
        }
        system.debug('jsonresult------------'+jsonresult);
        
        //Map<String, Object> res1 = (Map<String, Object>)JSON.deserializeUntyped(jsonresult);
        //System.debug('FINAL OBJECT MAP +++++++++++'+res1);
        
        return jsonresult;
    }

    public static String getInQueryCondition( List<Object> InQueryInConditionObject ,Map<String,Object> inq_StrObj ,String InQuery){
        String InQueryCondition ='';
          Map<String,Object> inqin_StrObj = (Map<string,Object>)InQueryInConditionObject[0];
                                Object InConfieldInColumn = inqin_StrObj.get('fieldIn');
                                Object InConfieldInvalue = inqin_StrObj.get('value');
                                System.debug(InConfieldInvalue+'XXXXXXXXXXXXXXXXXXXX'+InConfieldInColumn+' MMMMMMM '+InQuery+' inq_StrObj '+inq_StrObj);
                                
                                if(inq_StrObj.size() > 0 && InQuery =='' &&  InConfieldInColumn != null){
                                    InQueryCondition += InConfieldInColumn+' IN ('+InConfieldInvalue+')';
                                }else if(inq_StrObj.size() > 0 && InQuery !='' &&  InConfieldInColumn != null){
                                    InQueryCondition += ' and '+InConfieldInColumn+' IN ('+InConfieldInvalue+')';
                                }
        
        return InQueryCondition;
        
    }    
      public static String getIdInQuery(List<sObject> InqueryRes,Boolean fieldInTypes,Boolean fieldInType) {
           String idinQuery = ''; 
           Integer si=0; 
           for(Sobject s:InqueryRes){ 
                            Map<String, Object> fieldsAndValues = s.getPopulatedFieldsAsMap();
                            if((fieldInTypes!=null || fieldInType !=null) && (fieldInType || fieldInTypes)){
                                Date dateToStr = Date.valueOf(fieldsAndValues.values()[0]);
                                String finalcolValDate = DateTime.newInstance(dateToStr, Time.newInstance(0, 0, 0, 0)).format('YYYY-MM-dd');
                                if(si==0){ idinQuery += finalcolValDate; }
                                else { idinQuery += ','+finalcolValDate; }
                                
                            }else {
                                if(si==0){ idinQuery += '\''+fieldsAndValues.values()[0]+'\''; }
                                else { idinQuery += ',\''+fieldsAndValues.values()[0]+'\''; }
                            }
                            si++;
                        }
          
          return idinQuery;
          
      }
    public static List<Sobject> queryExecution(String executableQuery) {
        System.debug('QUERY '+executableQuery);
        List<Sobject> result = database.query(executableQuery);
        return result;
    }
    
    public static String arrangeResult(String executableQuery, String selectCOlumns, String ObjectName, String finalselectCOlumns){
        System.debug('executableQuery '+executableQuery);
        List<String> fieldsArr = new List<String>();
        if(finalselectCOlumns !='' && finalselectCOlumns.contains(',')){ fieldsArr = finalselectCOlumns.split('\\, '); }
        System.debug('fieldsArr PPPPPPPPPPPPPPP '+fieldsArr);
        
        SObjectType sobjectType = Schema.getGlobalDescribe().get(ObjectName);
        List<SObject> finalQueryRes = database.query(executableQuery);
        System.debug('finalQueryRes '+finalQueryRes);
        
        //Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        Map<String, Object> fexecutedQueryResult = new Map<String, Object>();
        Map<String, Object> childRelObjMap = new Map<String, Object>();
        Map<Integer, Object> finalObjMap = new Map<Integer, Object>();
        String jsonresult = '';
        
        if(finalQueryRes !=null && finalQueryRes.size()>0){
            Integer k=0;
            for(Sobject fr:finalQueryRes){
                fexecutedQueryResult = fr.getPopulatedFieldsAsMap();
                system.debug('-----fexecutedQueryResult----'+fexecutedQueryResult);
                Map<String, Object> finalChildObj = new Map<String, Object>();
                
                for (String fieldName : fexecutedQueryResult.keySet()) {
                    System.debug(fieldsArr+'-:fieldsArr-------------------fieldName--:'+fieldName+ ' fexecutedQueryResult '+fexecutedQueryResult);
                    //System.debug(fieldsArr.contains(fieldName.toLowerCase()) +'-:lower-------------------contains--:'+fieldsArr.contains(fieldName));
                    if(selectCOlumns.contains(fieldName.toLowerCase()) || selectCOlumns.contains(fieldName.toLowerCase())){
                        System.debug('field wise value '+fexecutedQueryResult.get(fieldName));
                        finalChildObj.put(fieldName, fexecutedQueryResult.get(fieldName));
                    }
                    
                    if(fexecutedQueryResult.get(fieldName) instanceOf SObject){
                        system.debug('fexecutedQueryResult.get(fieldName)---:'+fexecutedQueryResult.get(fieldName));
                        List< SObject > qSObjList =  new List<SObject>();
                        if(fexecutedQueryResult.get(fieldName) instanceOf List<SObject> ){
                            qSObjList = ( List< SObject >) fexecutedQueryResult.get(fieldName);
                        }else  if(fexecutedQueryResult.get(fieldName) instanceOf SObject ){
                            qSObjList.add((SObject)fexecutedQueryResult.get(fieldName));
                        }
                        //qSOj.get
                        //fr.get
                        //SObject  sobj =        fr.getSObject(fieldName) ;
                        for(SObject sObj :qSObjList){
                            childRelObjMap = sObj.getPopulatedFieldsAsMap();
                            
                            for (String childFieldName : childRelObjMap.keySet()) {
                                String dynamicReqFieldName = fieldName+'.'+childFieldName;
                                //System.debug(childFieldName+' dynamicReqFieldName.toLowerCase()   '+dynamicReqFieldName.toLowerCase());
                                if(fieldsArr.contains(dynamicReqFieldName.toLowerCase()) || fieldsArr.contains(dynamicReqFieldName)){
                                    finalChildObj.put(dynamicReqFieldName, childRelObjMap.get(childFieldName));
                                }
                            }                            
                        }
                        
                    }
                }
                
                if(finalChildObj.size()>0){
                    finalObjMap.put(k, finalChildObj);
                }else{
                    
                }
                k++;
            }
        }
        
        Map<String, Object> finalMap = new Map<String, Object>();
        
        if(finalObjMap.size()>0){
            finalMap.put('Status','Success');
            finalMap.put('Subject','Data available.');
            finalMap.put('Code',200);
            finalMap.put('Data',finalObjMap);
            jsonresult = JSON.serialize(finalMap);
        }else {
            finalMap.put('Status','Success');
            finalMap.put('Subject','No Data available.');
            finalMap.put('Code',200);
            finalMap.put('Data',finalObjMap);
            jsonresult = JSON.serialize(finalMap);
        }
        return jsonresult;
    }
    
    
    global static String  getInQueryCondition(List<Object> InAndInConditionObject,  Map<Object, String>  ListOfConditions, String QueryCondition,String OrQueryCondition){                         
                 String  InQueryCondition = '';    
                            for (Object singleInandCondition : InAndInConditionObject) {
                                Map<String,Object> mpin_StrObj = (Map<string,Object>)singleInandCondition;
                                System.debug(mpin_StrObj);
                                Object InandConColumn = mpin_StrObj.get('key');
                                Object InandConType = mpin_StrObj.get('condition');
                                Object InandConValue = mpin_StrObj.get('value');
                                
                                System.debug(ListOfConditions.get(InandConType));
                                String InandConditionVal = ListOfConditions.get(InandConType);
                                if(mpin_StrObj.size() > 0 && QueryCondition =='' && OrQueryCondition ==''){
                                    InQueryCondition += InandConColumn+' '+InandConditionVal+' '+InandConValue;
                                }else if(mpin_StrObj.size() > 0 && (QueryCondition !='' || OrQueryCondition !='')){
                                    InQueryCondition += ' and '+InandConColumn+' '+InandConditionVal+' '+InandConValue;
                                }
                            }
        
        return InQueryCondition  ;
    }
    global static String getInOrQueryCondition(List<Object> InORInConditionObject,  Map<Object, String> ListOfConditions,String InOrsQueryCondition ){
        String InOrQueryCondition='';
        for (Object inORCondition : InORInConditionObject) {
            Map<String,Object> insor_StrObj = (Map<string,Object>)inORCondition;
            Object InOrsConColumn = insor_StrObj.get('key');
            Object InOrsConType = insor_StrObj.get('condition');
            Object InOrsConValue = insor_StrObj.get('value');
            
            System.debug(ListOfConditions.get(InOrsConType));
            String InOrsConditionVal = ListOfConditions.get(InOrsConType);                                  
            if(insor_StrObj.size() > 0 && InOrsQueryCondition ==''){
                InOrsQueryCondition += InOrsConColumn+' '+InOrsConditionVal+' '+InOrsConValue;
            }else if(insor_StrObj.size() > 0 && InOrsQueryCondition !=''){
                InOrsQueryCondition += ' or '+InOrsConColumn+' '+InOrsConditionVal+' '+InOrsConValue;
            }
        }
        
        if(InOrsQueryCondition !=''){
            InOrQueryCondition = '('+InOrsQueryCondition+')';
        }
        
        return InOrQueryCondition;
    }
    
    global static String getSuccessNoDataJsonResult(){
        
        Map<String, Object> finalMap = new Map<String, Object>();
        Map<Integer, Object> finalObjMap = new Map<Integer, Object>();
        finalMap.put('Status','Success');
        finalMap.put('Subject','No Data available.');
        finalMap.put('Code',200);
        finalMap.put('Data',finalObjMap);
        String jsonresult = JSON.serialize(finalMap);      
              
        return jsonresult;
    }
    
    //Fetch the userId and target__c id using logged in user email
    /*     public static String getUserIdandTargetC(String Email){
String jsonresult = '';
User activeUser = [Select Id, Email From User where Email =: Email and IsActive=true limit 1];
Map<String, String> userDetails = new Map<String, String>();

if(activeUser!=null){
String userId = '\''+activeUser.Id+'\'';
String targetCQuery = 'select Id, Name, MedRep__c from target__c where MedRep__c ='+ userId+' and IsDeleted=false limit 1';
//List<Target__c> TargetClinetDetails = [select Id, Name, MedRep__c from target__c where MedRep__c =: userId and IsDeleted=false limit 1];
List<Sobject> TargetClinetDetails = database.query(targetCQuery);

System.debug(' TargetClinetDetails  '+TargetClinetDetails);
userDetails.put('USEREMAIL',activeUser.Email);
userDetails.put('OWNERID',activeUser.Id);
if(TargetClinetDetails != null && TargetClinetDetails.size()>0){
userDetails.put('TARGET__C','043343fafq2423');
}

jsonresult = JSON.serialize(userDetails);
}else {
userDetails.put('USEREMAIL','NA');
userDetails.put('OWNERID','NA');
userDetails.put('TARGETC','NA');
jsonresult = JSON.serialize(userDetails);     
}
//parse th userdetails JSON string to array
//Map<String, Object> res = (Map<String, Object>)JSON.deserializeUntyped(jsonresult);
//System.debug('RESULT ARRAY   '+res );
return jsonresult;
}
*/
    /*
@HttpPost
Global static   AbbottFetchMasterData.getTheDetails getMasterDataAsList() {
system.debug(' HIT getMasterDataAsList');  
return  AbbottFetchMasterData.getMasterDataAsList();     
}
*/ 
}