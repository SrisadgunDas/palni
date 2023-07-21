import { LightningElement } from 'lwc';
import generatepdf from '@salesforce/apex/Attachment.generatepdf';
export default class Pdf_generation extends LightningElement {
    outter_html(){
        let content = this.template.querySelector('.hover_container');
        console.log( 'html outerr  '+content.outerHTML)
        generatepdf({htmldata:content.outerHTML}).then(result=>{
          console.log('attchement id  ',result)  
        }).catch(error=>{
            console.error(error)
        })
              }
}