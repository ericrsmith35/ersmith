import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import APP_IMAGES from '@salesforce/resourceUrl/App_Images';

export default class ErsSwitchAppPage extends NavigationMixin(LightningElement) {

    @api recordId;          // Current Record ID
    @api choiceApps;        // List of App API Names
    @api choiceImages;      // List of image names from /images/ sub-directory in the APP_Images Static Resource
    @api choiceAltTexts;    // List of Alternate Text values for the images
    @api backgroundColor = "transparent";   // Background color for the component

    @api inputApps = "";
    @api inputImages = "";
    @api inputAltTexts = "Alternate Text";
    @api altText = "";
    @track apps = [];
    @track avatar = "slds-avatar slds-avatar--large slds-m-right_small";  // Default display class

    connectedCallback() {
        let index = 0;
        let apps = [];

        // lightning__RecordPage does not allow parameters to be passed into a list variable
        // so we need to parse the entries here
        this.choiceApps = this.inputApps.split(',');
        this.choiceImages = this.inputImages.split(',');
        this.choiceAltTexts = this.inputAltTexts.split(',');

        // Create the attributes for each list item
        this.choiceApps.forEach(app => {
            let selection = index + 1;
            this.altText = (this.choiceAltTexts[index]) ? this.choiceAltTexts[index] : 'Selection #' + selection;
            apps.push({
                index: index,
                name: this.choiceApps[index],
                image: APP_IMAGES + '/images/' + this.choiceImages[index],
                altText: this.altText
            });
            index += 1;
        });
        this.apps = apps;
    }

    handleHover(event) {
        // Display image as the avatar Circle variant
        var app = this.apps.find(app => app.index == event.target.dataset.key);
        app.avatar = "slds-avatar slds-avatar--circle slds-avatar--large slds-m-right_small";
        this.apps = [...this.apps];
    }

    handleMouseOut(event) {
        // Display image as the default Square avatar
        var app = this.apps.find(app => app.index == event.target.dataset.key);
        app.avatar = "slds-avatar slds-avatar--large slds-m-right_small";
        this.apps = [...this.apps];
    }

    navigateToAppPage(event) {

        // Get the attributes for the selected App
        var app = this.apps.find(app => app.index == event.target.dataset.key);

        // Navigate to the specified App and App Page for the same Record
        this[NavigationMixin.Navigate]({
            type: "standard__app",
            attributes: {
                appTarget: app.name,
                pageRef: {
                    type: "standard__recordPage",
                    attributes: {
                        recordId: this.recordId,
                        objectApiName: 'Case',  // Doesn't matter if this Object name doesn't match the Record Id
                        actionName: "view"
                    }
                }
            }
        })
    }
    
    get backgroundStyle() {
        return "background-color: " + this.backgroundColor;
    }
}