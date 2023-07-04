import BaseChatMessage from 'lightningsnapin/baseChatMessage';
import { track } from 'lwc';

const CHAT_CONTENT_CLASS = 'chat-content';
const AGENT_USER_TYPE = 'agent';
const CHASITOR_USER_TYPE = 'chasitor';
const SUPPORTED_USER_TYPES = [AGENT_USER_TYPE, CHASITOR_USER_TYPE];

/**
 * Displays a chat message using the inherited api messageContent and is styled based on the inherited api userType and messageContent api objects passed in from BaseChatMessage.
 */
export default class Lwc_Data_BotMain extends BaseChatMessage {
    @track messageStyle = '';
    datepicker = false;

    isSupportedUserType(userType) {
        return SUPPORTED_USER_TYPES.some((supportedUserType) => supportedUserType === userType);
    }

    connectedCallback() {
        if (this.isSupportedUserType(this.userType)) {
            this.messageStyle = `${CHAT_CONTENT_CLASS} ${this.userType}`;
        } else if (this.userType == 'agent' && this.messageContent.value.startsWith('lwc:datepicker'))
        {
            this.datepicker = true;
        }
        else {
            throw new Error(`Unsupported user type passed in: ${this.userType}`);
        }
        
    }
    handlePostMessage(event) 
    {
        const dateValue = event.detail;
        console.log('Handling Event with value: ' + dateValue);
        window.postMessage(
            {
                message: dateValue,
                type: "chasitor.sendMessage"
            },
            window.parent.location.href
        );
    }
}