({
    hlpDoInit: function (component)
    {
        try
        {
            var $this = this;
            var action = component.get('c.ctrlGetLists');
            var onsuccess = function(cmp, res){
                cmp.set("v.lstRelatedTo", res.lstRelatedTo);
                cmp.set("v.lstFrom", res.lstFrom);
                cmp.set("v.fromId", res.lstFrom[0].value);
                // cmp.set("v.lstContact", res.lstContact);
                // cmp.set("v.mapEmailByContact", res.mapEmailByContact);
                cmp.set("v.lstFolder", res.lstFolder);
                cmp.set("v.mapTemplatesByFolder", res.mapTemplatesByFolder);
                $this.hlpProcessParameters(cmp);
                

            }

            component.call(action, undefined, onsuccess);
        }
        catch (e)
        {
            component.error('hlpMethod - ' + e.message);
        }
    },

    hlpProcessParameters: function (component)
    {
        try
        {
            
            if(component.get('v.templateId')){
                this.hlpGetTemplate(component, component.get('v.templateId'));
            }
            if(component.get('v.relatedToRecord')){
                component.find('relatedTo_lu').doInit();
            }
            if(component.get('v.to')){
                component.find('to_lu').doInit();
            }
                
        }
        catch (e)
        {
            component.error('hlpSelectAdditionalTo - ' + e.message);
        }
    },

    hlpSelectAdditionalTo: function (component)
    {
        try
        {
            var lstSelectedAdditionalTo = component.get("v.lstSelectedAdditionalTo");
            component.set("v.lstSelectedToShow", lstSelectedAdditionalTo);
            component.set("v.whichList", 'AdditionalTo');
            component.find("contactModal").openModal();
        }
        catch (e)
        {
            component.error('hlpSelectAdditionalTo - ' + e.message);
        }
    },

    hlpSelectCC: function (component)
    {
        try
        {
            var lstSelectedCC = component.get("v.lstSelectedCC");
            component.set("v.lstSelectedToShow", lstSelectedCC);
            component.set("v.whichList", 'CC');
            component.find("contactModal").openModal();
        }
        catch (e)
        {
            component.error('hlpSelectAdditionalTo - ' + e.message);
        }
    },

    hlpSelectBCC: function (component)
    {
        try
        {
            var lstSelectedBCC = component.get("v.lstSelectedBCC");
            component.set("v.lstSelectedToShow", lstSelectedBCC);
            component.set("v.whichList", 'BCC');
            component.find("contactModal").openModal();
        }
        catch (e)
        {
            component.error('hlpSelectAdditionalTo - ' + e.message);
        }
    },

    hlpSaveContact: function (component)
    {
        try
        {
            component.showSpinner();
            var whichList = component.get("v.whichList");
            switch(whichList)
            {
                case 'AdditionalTo':
                    // update the text field
                    var lstSelectedAdditionalTo = component.get("v.lstSelectedAdditionalTo");
                    var additionalTo = component.get("v.additionalTo");
                    additionalTo = this.hlpUpdateSelection(component, lstSelectedAdditionalTo, additionalTo);
                    component.set("v.additionalTo", additionalTo);

                    // now, update the selected list
                    var lstSelectedToShow = component.get("v.lstSelectedToShow");
                    component.set("v.lstSelectedAdditionalTo", lstSelectedToShow);
                    component.set("v.lstSelectedToShow", []);

                    break;

                case 'CC':
                    // update the text field
                    var lstSelectedCC = component.get("v.lstSelectedCC");
                    var cc = component.get("v.cc");
                    cc = this.hlpUpdateSelection(component, lstSelectedCC, cc);
                    component.set("v.cc", cc);

                    // now, update the selected list
                    var lstSelectedToShow = component.get("v.lstSelectedToShow");
                    component.set("v.lstSelectedCC", lstSelectedToShow);
                    component.set("v.lstSelectedToShow", []);
                    break;

                case 'BCC':
                    // update the text field
                    var lstSelectedBCC = component.get("v.lstSelectedBCC");
                    var bcc = component.get("v.bcc");
                    bcc = this.hlpUpdateSelection(component, lstSelectedBCC, bcc);
                    component.set("v.bcc", bcc);

                    // now, update the selected list
                    var lstSelectedToShow = component.get("v.lstSelectedToShow");
                    component.set("v.lstSelectedBCC", lstSelectedToShow);
                    component.set("v.lstSelectedToShow", []);
                    break;

            }
            component.find('contactSearch').set('v.value', null);
            component.find("contactModal").closeModal();
            component.hideSpinner();
        }
        catch (e)
        {
            component.error('hlpSave - ' + e.message);
        }
    },

    hlpUpdateSelection: function (component, lstSelectedId, textValue)
    {
        try
        {
            var mapEmailByContact = component.get("v.mapEmailByContact");

            if($A.util.isEmpty(textValue))
            {
                textValue = '';
            }
            if(!$A.util.isEmpty(lstSelectedId))
            {
                var lstOldSelect = [];
                for(var i = 0; i < lstSelectedId.length; i++)
                {
                    if(!$A.util.isEmpty(mapEmailByContact[lstSelectedId[i]].Email))
                    {
                        lstOldSelect.push(mapEmailByContact[lstSelectedId[i]].Email);
                    }
                }

                var splits = textValue.split(';');
                console.log('splits = ' + JSON.stringify(splits));
                textValue = '';
                for(var i=0; i < splits.length; i++)
                {
                    if(lstOldSelect.indexOf(splits[i]) === -1)
                    {
                        textValue += textValue == '' ? splits[i] : ';' + splits[i];
                    }
                    console.log('textValue = ' + textValue);
                }
                console.log('textValue = ' + textValue);
            }

            // now, get the new selection
            var lstSelectedToShow = component.get("v.lstSelectedToShow");

            // add newly selected items to the text field
            if(!$A.util.isEmpty(lstSelectedToShow))
            {
                for (var i = 0; i < lstSelectedToShow.length; i++)
                {
                    var email = mapEmailByContact[lstSelectedToShow[i]].Email;
                    if(!$A.util.isEmpty(email))
                    {
                        textValue += textValue == '' ? email : ';' + email;
                    }
                }
            }

            return textValue;
        }
        catch (e)
        {
            component.error('hlpUpdateSelection - ' + e.message);
        }
    },

    hlpFolderChanged: function (component)
    {
        try
        {
            var folder = component.find("folder").get("v.value");
            var mapTemplatesByFolder = component.get("v.mapTemplatesByFolder");
            var lstTemplate = mapTemplatesByFolder[folder];
            component.set("v.lstTemplate", lstTemplate);
        }
        catch (e)
        {
            component.error('hlpFolderChanged - ' + e.message);
        }
    },

    hlpSaveTemplate: function (component)
    {
        try
        {
            var folder = component.find("folder").get("v.value");
            if(folder == '--Select--')
            {
                component.set("v.templateFolder", null);
                component.set("v.template", null);
                component.set("v.body", null);
                component.set("v.subject", null);
                return;
            }
            component.set("v.templateFolder", folder);
            var templateId = component.find("template").get("v.value");
            if(templateId == '--Select--')
            {
                component.set("v.template", null);
                component.set("v.body", null);
                component.set("v.subject", null);
                return;
            }

            this.hlpGetTemplate(component, templateId);
        }
        catch (e)
        {
            component.error('hlpFolderChanged - ' + e.message);
        }
    },

    hlpGetTemplate: function (component, templateId)
    {
        try
        {
            
            var onsuccess = function(component, resp){
                console.log(resp);
                component.set("v.subject", resp.et.Subject);
                component.set("v.template", resp.et);
                component.set("v.templateFolder", resp.folder);
                component.set('v.lstTemplate', component.get('v.mapTemplatesByFolder')[resp.folder])
                component.find("folder").set("v.value", resp.folder);
                component.find("template").set("v.value",resp.et.Id);
                component.set("v.format", null);
                if(resp.et.TemplateType == 'text')
                {
                    component.set("v.body", resp.et.Body);
                }
                else if(resp.et.TemplateType == 'visualforce')
                {
                    component.set("v.body", resp.et.Markup);
                }
                else
                {
                    component.set("v.body", resp.et.HtmlValue);
                }
            }

            // now, get the body and subject for the template
            var action = component.get('c.ctrlGetEmailTemplate');
            var params = {
                'templateId' : templateId
            };

            component.call(action, params, onsuccess);
        }
        catch (e)
        {
            component.error('hlpGetTemplate - ' + e.message);
        }
    },

    hlpUploadFinished: function (component, lstUploadFiles)
    {
        try
        {
            // add new uploaded files to list of all files (the ones uploaded and the ones passed in as url parameters)
            var currentAttachFiles = component.get("v.lstAttachFiles");
            if($A.util.isEmpty(currentAttachFiles))
            {
                currentAttachFiles = [];
            }
            for(var i = 0; i < lstUploadFiles.length; i++)
            {
                currentAttachFiles.push(lstUploadFiles[i]);
            }
            component.set("v.lstAttachFiles", currentAttachFiles);

            // add new uploaded files to list of files uploaded (these are attached to the Contact and need to be deleted at Save/Cancel)
            var currentContactTempFiles = component.get("v.lstContactTempFiles");
            if($A.util.isEmpty(currentContactTempFiles))
            {
                currentContactTempFiles = [];
            }
            for(var i = 0; i < lstUploadFiles.length; i++)
            {
                currentContactTempFiles.push(lstUploadFiles[i]);
            }
            component.set("v.lstContactTempFiles", currentContactTempFiles);

        }
        catch (e)
        {
            component.error('hlpUploadFinished - ' + e.message);
        }
    },

    hlpDeleteFile: function (component, documentId)
    {
        try
        {
            // remove from lists
            var currentAttachFiles = component.get("v.lstAttachFiles");
            var newAttachFiles = [];
            for(var i = 0; i < currentAttachFiles.length; i++)
            {
                if(currentAttachFiles[i].documentId != documentId)
                {
                    newAttachFiles.push(currentAttachFiles[i]);
                }
            }
            component.set("v.lstAttachFiles", newAttachFiles);

            var currentContactTempFiles = component.get("v.lstContactTempFiles");
            var newContactTempFiles = [];
            for(var i = 0; i < currentContactTempFiles.length; i++)
            {
                if(currentContactTempFiles[i].documentId != documentId)
                {
                    newContactTempFiles.push(currentContactTempFiles[i]);
                }
            }
            component.set("v.lstContactTempFiles", newContactTempFiles);

            component.showSpinner();
            // now, delete the Document record
            var lstDocumentId = [];
            lstDocumentId.push(documentId);

            this.hlpDeleteFiles(component, lstDocumentId);
        }
        catch (e)
        {
            component.error('hlpDeleteFile - ' + e.message);
        }
    },

    hlpDeleteFiles: function (component, lstDocumentId)
    {
        try
        {
            var action = component.get('c.ctrlDeleteDocument');
            var params = {
                'lstDocumentId' : lstDocumentId
            };

            component.call(action, params, undefined);
        }
        catch (e)
        {
            component.error('hlpDeleteFile - ' + e.message);
        }
    },


    hlpCancel: function (component, documentId)
    {
        try
        {

            var lstContactTempFiles = component.get("v.lstContactTempFiles");
            var ev = $A.get('e.force:navigateToSObject');
            ev.setParams({'recordId' : component.get('v.relatedToRecord')});
            if($A.util.isEmpty(lstContactTempFiles))
            {
                //window.history.back();
                console.log('cancel');
                ev.fire();
            }
            else // delete attachments if they exist
            {
                component.showSpinner();
                // now, delete the Document record
                var lstDocumentId = [];
                for(var i = 0; i < lstContactTempFiles.length; i++)
                {
                    lstDocumentId.push(lstContactTempFiles[i].documentId);
                }

                this.hlpDeleteFiles(component, lstDocumentId);
                // window.history.back();
                console.log('cancel');
                ev.fire();
            }
        }
        catch (e)
        {
            component.error('hlpCancel - ' + e.message);
        }
    },

    hlpSend: function (component, documentId)
    {
        try
        {
            if(!this.validate(component))
            {
                component.error('Please correct errors');
                return;
            }
            // component.showSpinner();

            var templateId;
            var template = component.get("v.template");
            if(!$A.util.isEmpty(template))
            {
                templateId = template.Id;
            }
            var format = component.find("format").get("v.value");
            var fromId = component.find("from").get("v.value");
            console.log('fromId = ' + fromId);
            console.log('fromId = ' + component.get("v.fromId"));
            var to = component.get("v.to");
            var relatedTo = component.find("relatedTo").get("v.value");
            var relatedToRecord = component.get("v.relatedToRecord");
            console.log('relatedToRecord = ' + relatedToRecord);
            var additionalTo = component.get("v.additionalTo");
            var cc = component.get("v.cc");
            var bcc = component.get("v.bcc");
            var useSignature = component.find("useSignature").get("v.checked");
            var subject = component.get("v.subject");
            var body = component.get("v.body");
            var lstAttachFiles = component.get("v.lstAttachFiles");

            var action = component.get('c.ctrlSendEmail');
            var params = {
                'templateId' : templateId,
                'format' : format,
                'fromId' : fromId,
                'to' : to,
                'relatedTo' : relatedTo,
                'relatedToRecord' : relatedToRecord,
                'additionalTo' : additionalTo,
                'cc' : cc,
                'bcc' : bcc,
                'useSignature' : useSignature,
                'subject' : subject,
                'body' : body,
                'lstUploadFileStr' : JSON.stringify(lstAttachFiles),
            };

            var $this = this;
            var onsuccess = function(component, resp){
                component.success('Email sent!');
                $this.hlpCancel(component);
            }

            component.call(action, params, onsuccess);
        }
        catch (e)
        {
            component.error('hlpSend - ' + e.message);
        }
    },

    validate : function(component) {

        var valid = true;

        component.set("v.checkToValidity", false);
        var to = component.get("v.to");
        if($A.util.isEmpty(to))
        {
            component.set("v.checkToValidity", true);
            valid = false;
        }

        // if related To is selected, but record is not, display error
        var relatedTo = component.get("v.relatedTo");
        var relatedToRecord = component.get("v.relatedToRecord");
        component.set("v.relatedToRecordError", false);
        if(!$A.util.isEmpty(relatedTo) && relatedTo != '--Select--' && $A.util.isEmpty(relatedToRecord))
        {
            component.set("v.relatedToRecordError", true);
            valid = false;
        }

        return valid;
    },

    findContacts : function(component) {
        // console.log(JSON.stringify(component.get('v.lstSelectedToShow')));
        // cmp.set("v.lstContact", res.lstContact);
        //         cmp.set("v.mapEmailByContact", res.mapEmailByContact);
        var searchName = component.find('contactSearch').get('v.value');
        console.log(searchName);

        var action = component.get('c.searchContactByName');
        var p = {contactSearchName : searchName};
        var onsuccess = function(component, result){
            var objmap = component.get("v.mapEmailByContact");

            var contacts = result.lstContact;
            var alreadySelected = component.get('v.lstSelectedToShow')
            for(var prop in objmap){
                if(alreadySelected.includes(prop)){
                    console.log(prop);
                    console.log(objmap[prop]);
                    contacts.push({label: objmap[prop].Name, value: prop});
                }
            }

            component.set("v.lstContact", result.lstContact);
            var objmap = component.get("v.mapEmailByContact");
            var newobj = Object.assign(result.mapEmailByContact, objmap);
            console.log(newobj)
            component.set("v.mapEmailByContact", newobj);
            // console.log(JSON.stringify(component.get('v.lstSelectedToShow')));
        }

        component.call(action, p, onsuccess);
    },
    
})