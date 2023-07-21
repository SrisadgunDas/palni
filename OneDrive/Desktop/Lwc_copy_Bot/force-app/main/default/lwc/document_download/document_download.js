import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecentFiles from '@salesforce/apex/FileQueryController.getRecentFiles';

export default class DocumentDownload extends LightningElement {
    files;
    wiredFilesResult;

    handleRefresh() {
        this.handleRefreshData();
    }

    @wire(getRecentFiles)
    wiredFiles(result) {
        this.wiredFilesResult = result;
        if (result.data) {
            this.files = result.data;
        } else if (result.error) {
            console.error('Error retrieving recent files:', result.error);
            this.showToast('Error', 'An error occurred while fetching recent files.', 'error');
        }
    }

    handleDownload(event) {
        const contentDocumentId = event.currentTarget.dataset.contentDocumentId;
        const contentVersionId = event.currentTarget.dataset.contentVersionId;
        if (contentDocumentId && contentVersionId) {
            const downloadUrl = `/sfc/servlet.shepherd/document/download/${contentDocumentId}?operationContext=S1&contentVersionId=${contentVersionId}`;
            window.open(downloadUrl, '_blank');
        }
    }

    handleRefreshData() {
        refreshApex(this.wiredFilesResult)
            .then(() => {
                this.showToast('Success', 'Recent files refreshed successfully.', 'success');
            })
            .catch((error) => {
                console.error('Error refreshing recent files:', error);
                this.showToast('Error', 'An error occurred while refreshing recent files.', 'error');
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}
