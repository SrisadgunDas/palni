import { LightningElement ,track,api} from 'lwc';

export default class Lwcchatpack_datapicker extends LightningElement {
    @track PostingDate;
    @api PostingDateChange(event){
        this.PostingDate = event.target.value;
       console.log(' this.PostingDate  '+ this.PostingDate)
    }
}