import { LightningElement, api, track  } from 'lwc';

const COLUMNS = [
    {
        label: 'Name',
        fieldName: 'Name',
        type: 'text',
        sortable: 'true',
        initialWidth: 280
    },
    {
        label: 'Button',
        type: 'button',
        typeAttributes: { 
            label: 'Select',
            name: 'select',
            title: 'Click to do something',
            disabled: { fieldName: 'buttonDisabled' },
        },
        initialWidth: 90
    },
];

const MYDATA = [
    {
        Name: '',
        Id: '',
        buttonDisabled: ''
    }
];
export default class TestDatatable extends LightningElement {

    @api tableData;
    @api columns = COLUMNS;
    @api keyfield = 'Id';
    @api hideCheckboxColumn;
    @track sortedBy;
    @track sortedDirection;
    @track mydata = MYDATA;
    @track preSelectedIds = [];

    connectedCallback() {
        // Add fields to datatable records
        console.log('Table',JSON.parse(JSON.stringify(this.tableData)));
        console.log('My',JSON.parse(JSON.stringify(this.mydata)));
        this.mydata = this.tableData.map(tableRecord => ({
            Id: tableRecord.Id,
            Name: tableRecord.Name,
            buttonDisabled: false
            })
        );
        console.log('My-after',JSON.parse(JSON.stringify(this.mydata)));
        this.hideCheckboxColumn = true;
        this.preSelectedIds.push('0016C00000Bd2yYQAR');
        this.preSelectedIds.push('0016C00000Bd2ydQAB');
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = JSON.parse(JSON.stringify(event.detail.row));
        const keyValue = row[this.keyfield];   
        console.log('Action,Key,Row',action.name,keyValue,row);
        // Change the label and disable the button here
        this.mydata = this.mydata.map(rowData => {
            if (rowData[this.keyfield] === keyValue) {
                switch (action.name) {
                    case 'select':
                        console.log('select',rowData[this.keyfield],rowData['select']);                       
                        rowData.buttonDisabled = true;
                        // Not already selected
                        if(this.preSelectedIds.indexOf(rowData[this.keyfield]) === -1) {
                            this.preSelectedIds.push(rowData[this.keyfield]);
                            this.preSelectedIds = [...this.preSelectedIds];
                        }
                        break;
                    default:
                }                                
            }
            return rowData;
        });
    }

    updateColumnSorting(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        let fieldValue = row => row[this.sortedBy] || '';
        let reverse = this.sortedDirection === 'asc'? 1: -1;
        this.mydata = [...this.mydata.sort(
            (a,b)=>(a=fieldValue(a),b=fieldValue(b),reverse*((a>b)-(b>a)))
        )];
    }

}