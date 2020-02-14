import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getQuickAppSwitcher from '@salesforce/apex/CustomMetadataController.getQuickAppSwitcher';    // Apex Class to return the QuickAppSwitcher Custom Metadata record
import APP_IMAGES from '@salesforce/resourceUrl/App_Images';    // Must have a Static Resource Zip file called 'App_Images' 
                                                                // with a subdirectory /images/ where the image files are stored

export default class ErsQuickSwitchApp extends NavigationMixin(LightningElement) {

    // Values passed into the component
    @api recordId;                          // Current Record ID
    @api objectApiName;                     // Current Object Name
    @api quickAppSwitcherId;                // Record Id of the QuickAppSwitcher metadata record storing the component attributes
    @api quickAppSwitcherLabel = "Test ersmith";             // Label of the QuickAppSwitcher metadata record storing the component attributes
    @api backgroundColor = "transparent";   // Background color for the component

    // Values extracted from the Custom Metadata Record
    @api inputApps = "";
    @api inputImages = "";
    @api inputAltTexts = "";

    // Internal variables
    @api choiceApps;        // List of App API Names
    @api choiceImages;      // List of image names from /images/ sub-directory in the APP_Images Static Resource
    @api choiceAltTexts;    // List of Alternate Text values for the images
    @api altText = "";      // Store the ALternate Text value
    @track apps = [];       // Store the List of App Paramters
    @track mdtRecord;       // Store the Custom Metadata returned by the Apex Class
    @track mdtValues = {};  // Store the values from the Custom Metadata Record
    @track avatar = "slds-avatar slds-avatar--large slds-m-right_small";  // Default display class

    // Get the Custom Metadata Record and build the list of selections
    @wire(getQuickAppSwitcher, { label: '$quickAppSwitcherLabel' }) 
    QuickAppSwitcher({ error, data }) {

        if(data) {
            this.mdtRecord = data;
            this.mdtValues = {
                inputApps : this.mdtRecord.AppAPINames__c,
                inputImages : this.mdtRecord.AppImageNames__c,
                inputAltTexts : this.mdtRecord.AppAlternateTexts__c,
            }
            // Default value for the first Alt Text selection in case the CMD attribute is null
            this.mdtValues.inputAltTexts = (!this.mdtValues.inputAltTexts) ? 'Selection #1' : this.mdtValues.inputAltTexts;

            let index = 0;
            let apps = [];
    
            // lightning__RecordPage does not allow parameters to be passed 
            // into a list variable so we need to parse the entries here
            this.choiceApps = this.mdtValues.inputApps.split(',');
            this.choiceImages = this.mdtValues.inputImages.split(',');
            this.choiceAltTexts = this.mdtValues.inputAltTexts.split(',');

            // Create the attributes for each list item
            this.choiceApps.forEach(app => {
                let selection = index + 1;  // Set the counter for the default Alternative Text value
                this.altText = (this.choiceAltTexts[index]) ? this.choiceAltTexts[index] : 'Selection #' + selection;
                apps.push({
                    index: index,
                    name: this.choiceApps[index],
                    image: APP_IMAGES + '/images/' + this.choiceImages[index],
                    altText: this.altText,
                    variant: 'square'
                });
                index += 1;
            });
            this.apps = apps;   // Make the list of attributes available to the rendering template

        }
        else if(error) {
            console.log('error ====> '+JSON.stringify(error))
        }
    }

    connectedCallback() {
        // make the recordId of the Custom Metadata Record available to the @wire Service
        // this.mdtId = this.quickAppSwitcherId;
        this.quickAppSwitcherLabel = this.quickAppSwitcherLabel;
    }

    handleHover(event) {
        // Modify the Style to display the image as the avatar Circle variant
        var app = this.apps.find(app => app.index == event.target.dataset.key);
        app.variant = 'circle';
        this.apps = [...this.apps];
    }

    handleMouseOut(event) {
        // Modify the Style to display the image as the default Square avatar
        var app = this.apps.find(app => app.index == event.target.dataset.key);
        app.variant = 'square';
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
                        objectApiName: this.objectApiName,  // It actually doesn't matter if this Object name doesn't match the Record Id
                        actionName: "view"
                    }
                }
            }
        })
    }
    
    // Make the background color attribute available to the rendering template
    get backgroundStyle() {
        return "background-color: " + this.backgroundColor;
    }
}