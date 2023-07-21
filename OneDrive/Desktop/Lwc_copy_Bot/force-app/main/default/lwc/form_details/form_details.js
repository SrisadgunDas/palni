import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import NEW_BOT_CUST from '@salesforce/schema/New_Bot_customer__c';
import CUST_NAME from '@salesforce/schema/New_Bot_customer__c.Name';
import CUST_EMAIL from '@salesforce/schema/New_Bot_customer__c.Email__c';
import CUST_PHONE from '@salesforce/schema/New_Bot_customer__c.Phone__c';
import CUST_TEXT from '@salesforce/schema/New_Bot_customer__c.feedBack__c';
export default class Form_details extends LightningElement {
    obj_Name
    obj_Email
    obj_Phone
    obj_Text
    thisrecord
    handlechange(event){
        if(event.target.label === 'Enter Name'){
            this.obj_Name = event.target.value;
            
        }else if(event.target.label === 'Enter  text'){
            this.obj_Text = event.target.value;
        }else if(event.target.label === 'Email'){
            this.obj_Email = event.target.value;
        }
        else if(event.target.label === 'phone Number'){
            this.obj_Phone = event.target.value;
        }
    }
    
    createnewCustomer() {
        const fields = {};
        fields[CUST_NAME.fieldApiName] = this.obj_Name;
        fields[CUST_EMAIL.fieldApiName] = this.obj_Email;
        fields[CUST_PHONE.fieldApiName] = this.obj_Phone;
        fields[CUST_TEXT.fieldApiName] = this.obj_Text;
        const recordInput = { apiName: NEW_BOT_CUST.objectApiName, fields };
        createRecord(recordInput)
            .then((eventCame) => {
                this.thisrecord = eventCame.id;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: ' created',
                        variant: 'success'
                    })
                );
            })
        }
}