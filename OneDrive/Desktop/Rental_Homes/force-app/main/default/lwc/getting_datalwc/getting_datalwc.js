import { LightningElement } from 'lwc';

export default class Getting_datalwc extends LightningElement {
    firstName ='';
    lastName ='';
    is_flowavaliale = false;
    flowvariables = [];

    handleClick() {
        this.firstName = this.template.querySelector('lightning-input[data-name="firstName"]').value;
        this.lastName = this.template.querySelector('lightning-input[data-name="lastName"]').value;
        console.log('' + this.firstName + '' + this.lastName);

        this.flowvariables = [
            {
                name: 'firstName',
                type: 'String',
                value: this.firstName
            },
            {
                name: 'lastName',
                type: 'String',
                value: this.lastName
            }
        ];

        this.is_flowavaliale = true;
    }
}
