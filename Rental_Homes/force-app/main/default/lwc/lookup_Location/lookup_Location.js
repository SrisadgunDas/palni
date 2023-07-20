import { LightningElement, wire, track } from 'lwc';
import findLocation from '@salesforce/apex/get_Location.avaliable_loaction';
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';

const DELAY = 300;


export default class LookupLocation extends LightningElement {
    searchKey = '';
    @track location;
    @track location_selected = [];
    is_flowavaliale = false;
    flowvariables = {};
    @wire(findLocation, { searchKey: '$searchKey' })
    wiredLocations({ error, data }) {
        if (data) {
            this.location = data.map(loc => ({
                ...loc,
                likeState: false
            }));
        } else if (error) {
            // Handle error
        }
    }
    handleLikeButtonClick(event) {
        const clickedItemId = event.target.dataset.id;
        const clickedLocation = this.location.find(loc => loc.Id === clickedItemId);
    
        if (clickedLocation) {
            const index = this.location_selected.indexOf(clickedLocation.Location__c);
            if (index === -1) {
                this.location_selected.push(clickedLocation.Location__c);
            } else {
                this.location_selected.splice(index, 1);
            }
        }
    
        this.location = this.location.map(loc => {
            if (loc.Id === clickedItemId) {
                return {
                    ...loc,
                    likeState: !loc.likeState
                };
            }
            return loc;
        });

        const locationSelectedValue = this.location_selected.join(',');
        console.log('selected location  '+locationSelectedValue)
        this.flowvariables = [
            {
                name: "location_Data",
                type: "String", // Ensure the data type matches the flow variable type
                value: locationSelectedValue // Corrected from this.firstName to locationSelectedValue
            }
        ];
            this.is_flowavaliale = true;
        
            // Show the flow when a location is selected
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }

    handleKeyChange(event) {
        clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
        }, DELAY);
    }
}
