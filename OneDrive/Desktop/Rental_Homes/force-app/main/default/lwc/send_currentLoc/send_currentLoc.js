import { LightningElement,api ,track } from 'lwc';

export default class Send_currentLoc extends LightningElement {
    @api inputParams;
   
    @track disableButton = false;
    @track storecoords = [];

    sendLocation(event)
    {
        if (navigator.geolocation) 
        {
            this.disableButton = true;
            navigator.geolocation.getCurrentPosition(this.showPosition.bind(this));
          } else {
            alert('Geolocation is not supported by this browser.');
          }
    }

    showPosition(position) {
        const latitude = position.coords.latitude;
        const longitude = position.coords.longitude;
        const location = latitude + ',' + longitude;
        
        this.storecoords.push(location);
        
        this.dispatchEvent(
            new CustomEvent('postmessage', {
                detail: 'lwc:hide:' + location
            })
        );
    }
}