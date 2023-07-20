public class get_Location {
@AuraEnabled(cacheable=true)
public static list<Apartment__c> avaliable_loaction(){  
        String location_avaliable = 'select id,Location__c from Apartment__c limit 10';
        return database.query(location_avaliable);
   
}  
}