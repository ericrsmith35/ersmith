import { LightningElement, api, track } from 'lwc';

    // datatable columns Label, LogoUrl, NavType | UiType, DeveloperName, NamespacePrefix
    const COLUMNS = [
        {
            label: 'App Name',
            fieldName: 'Label',
            type: 'text',
            sortable: 'true',
            initialWidth: 280
        },
        {
            label: 'Nav Type',
            fieldName: 'NavType',
            type: 'text',
            sortable: 'true',
            initialWidth: 100
        },
        {
            label: 'Image Link',
            fieldName: 'LogoUrl',
            type: 'url',
            typeAttributes: { target: '_blank'},
            sortable: 'true',
            initialWidth: 550
        },
        {
            label: 'Select Apps',
            type: 'button',
            typeAttributes: { 
                label: 'Select',
                name: 'select',
                title: 'Click to Add this App to your Quick Switcher list',
                disabled: { fieldName: 'buttonDisabled' }
            },
            initialWidth: 90
        },
    ];

    const MYDATA = [
        {
            DeveloperName: '',
            Label: '',
            NavType: '',
            LogoUrl: '',
            buttonLabel: '',
            buttonDisabled: ''
        }
    ];

export default class QuickAppSwitcherDt extends LightningElement {

    @api tableData;
    @api selectedData;
    @api columns = COLUMNS;
    @api keyfield = 'DeveloperName';
    @api sortedBy;
    @api sortedDirection;
    @api maxRowSelection;
    @api hideCheckboxColumn;
    @track preSelectedIds = [];
    @track mydata = MYDATA;

    connectedCallback() {
        // Add fields to datatable records
        this.mydata = this.tableData.map(tableRecord => ({
            DeveloperName: tableRecord.DeveloperName,
            Label: tableRecord.Label,
            NavType: tableRecord.NavType,
            LogoUrl: tableRecord.LogoUrl,
            buttonDisabled: false        
            })
        );
        this.hideCheckboxColumn = true;
    }
   
    handleRowAction(event) {
        const action = event.detail.action;
        const row = JSON.parse(JSON.stringify(event.detail.row));
        const keyValue = row[this.keyfield];
        // Disable the button and process the record here
        this.mydata = this.mydata.map(rowData => {
            if (rowData[this.keyfield] === keyValue) {
                switch (action.name) {
                    case 'select':
                        // Disable the button from being selected again
                        rowData.buttonDisabled = true;

                        // If not already selected, highlight the row as selected
                        if(this.preSelectedIds.indexOf(rowData[this.keyfield]) === -1) {
                            this.preSelectedIds.push(rowData[this.keyfield]);
                            this.preSelectedIds = [...this.preSelectedIds];
                        }
                        // Call function to process the selected row
                        this.processRowSelection(rowData);
                        break;
                        
                    default:
                }
            }
            return rowData;
        });
    }

    processRowSelection(rowData) {
        // Add to the QuickSwitchApp metadata parameters
    }

    handleSave(event) {
        // Only used with inline editing
    }

    cancelChanges(event) {
        // Only used with inline editing
    }

    getSelectedName(event) {
        // Only used with row selection
    }
   
    updateColumnSorting(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.sortData(this.sortedBy, this.sortedDirection);
    }

    sortData(fieldname, direction) {
        // serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.mydata));

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        // checking reverse direction 
        let isReverse = direction === 'asc' ? 1: -1;

        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.mydata = parseData;

    }

}
