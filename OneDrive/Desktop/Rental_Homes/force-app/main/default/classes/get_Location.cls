public class get_Location {
@AuraEnabled(cacheable=true)
public static list<Apartment__c> avaliable_loaction(){  
        String location_avaliable = 'select id,Location__c from Apartment__c limit 10';
        return database.query(location_avaliable);
   
}  
@AuraEnabled(cacheable=true)
public static list<Apartment__c> showing_selectedList(string locationaddress,integer bed_rooms){  
        String location_avaliable = 'select id,Name,Locaton__c,pictureimg_c__c,Apartment_TotalPrice__c,Bed_Rooms__c,issued_Date__c from Apartment__c where Locaton__c=:locationaddress and Bed_Rooms__c =: bed_rooms     limit 3 ';
        return database.query(location_avaliable);
   
}  
}