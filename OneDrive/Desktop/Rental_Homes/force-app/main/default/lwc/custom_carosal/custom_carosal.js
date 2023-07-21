import { LightningElement, wire } from 'lwc';
import aprartmentDetails from '@salesforce/apex/get_Location.showing_selectedList';

export default class Custom_carosal extends LightningElement {
    @api bed_rooms; // Public property to receive the accountName from the flow
    @api location;
    // Wire the Apex method to fetch apartment details
    @wire(aprartmentDetails,{ locationaddress: '$location' ,bed_rooms : '$bedrooms'})
    wiredApartmentDetails
    handleStatusChange(event) {
        if (event.detail.status === 'FINISHED') { // Make sure the status is in uppercase
            const outputVariables = event.detail.outputVariables;
            for (let i = 0; i < outputVariables.length; i++) {
                const outputVar = outputVariables[i];
                if (outputVar.name === 'Apartment_BedRooms' && outputVar.name === 'location_Data' ) {
                    this.bed_rooms = outputVar.value.Bed_Rooms__c; 
                   this.location = outputVar.value; 
                // } else if (outputVar.name === 'NumberOfEmployees') {
                //     this.numberOfEmployees = outputVar.value; // Access the value directly for simple variables
                }
            }
        }
    }
}
