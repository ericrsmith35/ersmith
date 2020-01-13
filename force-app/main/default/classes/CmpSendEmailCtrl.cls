/* Class:       CmpSendEmailCtrl
** Created by:  OpFocus (Veena Sundara-Heragu) on 7/3/18
** Description: Controller for Lightning Component CmpSendEmail
*/
public with sharing class CmpSendEmailCtrl
{

    @AuraEnabled
    public static CmpSendEmailReturn ctrlGetLists(String datajson)
    {
        CmpSendEmailReturn retVal = new CmpSendEmailReturn();
        InputData data;
        try
        {
            data = (InputData) ltngfw.AuraInput.deserialize(datajson, InputData.class);
            
            // Add current user's name and email address followed by all the organization wide email addresses as options for the
            // "From" selection
            retVal.lstFrom = new List<ListOption>();
            retVal.lstFrom.add(new ListOption('"' + UserInfo.getName() + '" (' + UserInfo.getUserEmail() + ')', UserInfo.getUserId()));
            for(OrgWideEmailAddress owe : [select DisplayName, Address from OrgWideEmailAddress Order By DisplayName])
            {
                retVal.lstFrom.add(new ListOption('"' + owe.DisplayName + '" (' + owe.Address + ')', owe.Id));
            }

            // Add all SObjects to the related to selection list
            retVal.lstRelatedTo = new List<ListOption>();
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            List<String>lstObjectLabel = new List<String>();
            Map<String, List<ListOption>> mapListOptionByObjectLabel = new Map<String, List<ListOption>>();
            for(Schema.SObjectType objType: gd.values())
            {
                Schema.DescribeSObjectResult ds = objType.getDescribe();
                if(ds.getName() == 'Case'){
                    System.debug('PROCESSING CASE!!');
                    System.debug(ds.fields.getMap().get('Name'));
                }
                if(ds.fields.getMap().get('Name') != null || ds.getName() == 'Case')
                {
                    String label = ds.getLabel();
                    ListOption lo = new ListOption(ds.getLabel(), ds.getName());
                    if(mapListOptionByObjectLabel.containsKey(label))
                    {
                        mapListOptionByObjectLabel.get(label).add(lo);
                    }
                    else
                    {
                        mapListOptionByObjectLabel.put(ds.getLabel(), new List<ListOption>{lo});
                        lstObjectLabel.add(label);
                    }
                }
            }
            lstObjectLabel.sort();
            for(String label : lstObjectLabel)
            {
                for(ListOption lo : mapListOptionByObjectLabel.get(label))
                {
                    retVal.lstRelatedTo.add(lo);
                }
            }

            // get email templates by folder
            Set<String> setFolder = new Set<String>();
            retVal.mapTemplatesByFolder = new Map<String, List<EmailTemplate>>();
            for(EmailTemplate et : [Select
                                            Id, Name, Body, Subject, Description, Folder.Name
                                    FROM
                                            EmailTemplate
                                    WHERE
                                            IsActive = true
                                    ORDER BY Folder.Name, Name])
            {
                setFolder.add(et.Folder.Name);
                if(retVal.mapTemplatesByFolder.containsKey(et.Folder.Name))
                {
                    retVal.mapTemplatesByFolder.get(et.Folder.Name).add(et);
                }
                else
                {
                    retVal.mapTemplatesByFolder.put(et.Folder.Name, new List<EmailTemplate>{et});
                }
            }
            retVal.lstFolder = new List<String>();
            retVal.lstFolder.add('Unfiled Public Email Templates');
            retVal.lstFolder.add('My Personl Email Templates');
            retVal.lstFolder.addAll(setFolder);

            // get templates for unfiled public folder
            for(EmailTemplate et : [Select
                                            Id, Name, Body, Subject, Description
                                    FROM
                                            EmailTemplate
                                    WHERE
                                            IsActive = true AND
                                            FolderId = :UserInfo.getOrganizationId()
                                    ORDER BY Name])
            {
                if(retVal.mapTemplatesByFolder.containsKey('Unfiled Public Email Templates'))
                {
                    retVal.mapTemplatesByFolder.get('Unfiled Public Email Templates').add(et);
                }
                else
                {
                    retVal.mapTemplatesByFolder.put('Unfiled Public Email Templates', new List<EmailTemplate>{et});
                }
            }

            // get email templates for My Personal Email Templates folder
            for(EmailTemplate et : [Select
                                            Id, Name, Body, Subject, Description
                                    FROM
                                            EmailTemplate
                                    WHERE
                                            IsActive = true AND
                                            FolderId = :UserInfo.getUserId()
                                    ORDER BY Name])
            {
                if(retVal.mapTemplatesByFolder.containsKey('My Personl Email Templates'))
                {
                    retVal.mapTemplatesByFolder.get('My Personl Email Templates').add(et);
                }
                else
                {
                    retVal.mapTemplatesByFolder.put('My Personl Email Templates', new List<EmailTemplate>{et});
                }
            }

            return retVal;
        }
        catch (Exception e)
        {
            retVal.handleException(e);
            ltngfw.Log.notify(e, null, 'CmpSendEmailCtrl', ltngfw.DeviceInformation.deserialize(data.deviceInfoStr), ltngfw.Log.ErrorType.ERROR);
        }
        return retVal;
    }

    @AuraEnabled
    public static CmpSendEmailReturn searchContactByName(String datajson){
        CmpSendEmailReturn csr = new CmpSendEmailReturn();
        InputData data;
        try{
            data = (InputData) ltngfw.AuraInput.deserialize(datajson, InputData.class);
            csr.lstContact = new List<ListOption>();
            csr.mapEmailByContact = new Map<Id, Contact>();
            List<List<SObject>> lstSearchResults = [Find :data.contactSearchName in ALL FIELDS returning Contact(Id,Name,Email where Email != null)];
            //String qry = '%' + data.contactSearchName + '%';
            for(Contact c : (Contact[]) lstSearchResults[0])
            {
                csr.lstContact.add(new ListOption(c.Name, c.Id));
                csr.mapEmailByContact.put(c.Id, c);
            }
        }
        catch(Exception e){
            ltngfw.Log.notify(e, 'CmpSendEmailCtrl', ltngfw.DeviceInformation.deserialize(data.deviceInfoStr));
        }
        return csr;
    }

    public class CmpSendEmailReturn extends ltngfw.AuraReturn
    {
        @AuraEnabled public List<ListOption> lstFrom;
        @AuraEnabled public List<ListOption> lstRelatedTo;
        @AuraEnabled public List<ListOption> lstContact;
        @AuraEnabled public Map<Id, Contact> mapEmailByContact;
        @AuraEnabled public List<String> lstFolder;
        @AuraEnabled public Map<String, List<EmailTemplate>> mapTemplatesByFolder;
    }

    public Class ListOption
    {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public ListOption(String label, String value)
        {
            this.label = label;
            this.value = value;
        }
    }

    public class InputData extends ltngfw.AuraInput{
        @AuraEnabled public String templateId;
        @AuraEnabled public List<String> lstDocumentId;
        @AuraEnabled public String format;
        @AuraEnabled public String fromId;
        @AuraEnabled public String to;
        @AuraEnabled public String relatedTo;
        @AuraEnabled public String relatedToRecord;
        @AuraEnabled public String additionalTo;
        @AuraEnabled public String cc;
        @AuraEnabled public String bcc;
        @AuraEnabled public Boolean useSignature;
        @AuraEnabled public String subject;
        @AuraEnabled public String body;
        @AuraEnabled public String lstUploadFileStr;
        @AuraEnabled public String deviceInfoStr;
        @AuraEnabled public String contactSearchName;
    }


    @AuraEnabled
    public static CmpTemplateReturn ctrlGetEmailTemplate(String datajson)
    {
        CmpTemplateReturn retVal = new CmpTemplateReturn();
        InputData data;
        try
        {
            data = (InputData) ltngfw.AuraInput.deserialize(datajson, InputData.class);
            if(data.templateId instanceof Id){
                retVal.et = [Select Id, Name, FolderId, Folder.Name, Subject, Body, HtmlValue, Markup, RelatedEntityType, TemplateType
                    From EmailTemplate
                    Where Id = :data.templateId];
            }
            else{
                retVal.et = [Select Id, Name, FolderId, Folder.Name, Subject, Body, HtmlValue, Markup, RelatedEntityType, TemplateType
                    From EmailTemplate
                    Where DeveloperName = :data.templateId];
            }
            

            Map<Id, String>mapFolderNameById = new Map<Id, String>{UserInfo.getOrganizationId() => 'Unfiled Public Email Templates',
                                                                    UserInfo.getUserId() => 'My Personl Email Templates'};

            if(mapFolderNameById.containsKey(retVal.et.FolderId))
            {
                retVal.folder = mapFolderNameById.get(retVal.et.FolderId);
            }
            else
            {
                retVal.folder = retVal.et.Folder.Name;
            }

            return retVal;
        }
        catch (Exception e)
        {
            retVal.handleException(e);
            ltngfw.Log.notify(e, null, 'CmpSendEmailCtrl', ltngfw.DeviceInformation.deserialize(data.deviceInfoStr), ltngfw.Log.ErrorType.ERROR);
        }
        return retVal;
    }

    public class CmpTemplateReturn extends ltngfw.AuraReturn
    {
        @AuraEnabled public EmailTemplate et;
        @AuraEnabled public String folder;
    }

    @AuraEnabled
    public static CmpDeleteReturn ctrlDeleteDocument(String datajson)
    {
        CmpDeleteReturn retVal = new CmpDeleteReturn();
        InputData data;
        try
        {
            data = (InputData) ltngfw.AuraInput.deserialize(datajson, InputData.class);
            List<ContentDocument>lstDoc = new List<ContentDocument>();
            for(String docId: data.lstDocumentId)
            {
                lstDoc.add(new ContentDocument(Id = docId));
            }
            delete lstDoc;
            return retVal;
        }
        catch (Exception e)
        {
            retVal.handleException(e);
            ltngfw.Log.notify(e, null, 'CmpSendEmailCtrl', ltngfw.DeviceInformation.deserialize(data.deviceInfoStr), ltngfw.Log.ErrorType.ERROR);
        }
        return retVal;
    }

    @AuraEnabled
    public static CmpDeleteReturn ctrlSendEmail(String datajson)
    {
        CmpDeleteReturn retVal = new CmpDeleteReturn();
        InputData data;
        try
        {
            data = (InputData) ltngfw.AuraInput.deserialize(datajson, InputData.class);
            system.debug('=======> templateId = ' + data.templateId);
            system.debug('=======> format = ' + data.format);
            system.debug('=======> fromId = ' + data.fromId);
            system.debug('=======> to = ' + data.to);
            system.debug('=======> relatedTo = ' + data.relatedTo);
            system.debug('=======> relatedToRecord = ' + data.relatedToRecord);
            system.debug('=======> additionalTo = ' + data.additionalTo);
            system.debug('=======> cc = ' + data.cc);
            system.debug('=======> bcc = ' + data.bcc);
            system.debug('=======> useSignature = ' + data.useSignature);
            system.debug('=======> subject = ' + data.subject);
            system.debug('=======> body = ' + data.body);
            system.debug('=======> lstUploadFileStr = ' + JSON.serializePretty(data.lstUploadFileStr));
            system.debug('=======> deviceInfoStr = ' + data.deviceInfoStr);

            List<EmailAttachment> lstUploadFile = (List<EmailAttachment>)JSON.deserializeStrict(data.lstUploadFileStr, List<EmailAttachment>.Class);

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(data.to);

            if(!String.isBlank(data.additionalTo))
            {
                List<String> lstTo = data.additionalTo.split(';');
                mail.setToAddresses(lstTo);
            }

            if(!String.isBlank(data.cc))
            {
                List<String> lstCC = data.cc.split(';');
                mail.setCcAddresses(lstCC);
            }

            if(!String.isBlank(data.bcc))
            {
                List<String> lstBCC = data.bcc.split(';');
                mail.setBCCAddresses(lstBCC);
            }

            mail.setUseSignature(data.useSignature);

            if(data.templateId != null)
            {
                mail.setTemplateId(data.templateId);
            }
            else
            {
                mail.setSubject(data.subject);
                if(data.format == 'Text')
                {
                    mail.setPlainTextBody(data.body);
                }
                else
                {
                    mail.setHtmlBody(data.body);
                }
            }

            if(lstUploadFile != null && !lstUploadFile.isEmpty())
            {
                List<Id> lstDocId = new List<Id>();
                for(EmailAttachment f: lstUploadFile)
                {
                    lstDocId.add(f.documentId);
                }
                // get the ContentVersion records for these ContentDocuments.  We need ContentVersion to attach to email
                List<Id>lstCV = new List<Id>();
                for(ContentVersion cv : [Select Id from ContentVersion Where ContentDocumentId in :lstDocId])
                {
                    lstCV.add(cv.Id);
                }
                mail.setEntityAttachments(lstCV);
            }

            if(data.fromId != UserInfo.getUserId())
            {
                mail.setOrgWideEmailAddressId(data.fromId);
            }

            if(data.relatedToRecord != null)
            {
                mail.setWhatId(data.relatedToRecord);
            }
            System.debug(JSON.serializePretty(mail));

            //system.debug('=======> mail = ' + JSON.serializePretty(mail));
            Messaging.sendEmail(new Messaging.Email[] { mail } , true);

            return retVal;
        }
        catch (Exception e)
        {
            retVal.handleException(e);
            ltngfw.Log.notify(e, null, 'CmpSendEmailCtrl', ltngfw.DeviceInformation.deserialize(data.deviceInfoStr), ltngfw.Log.ErrorType.ERROR);
        }
        return retVal;
    }

    public Class CmpDeleteReturn extends ltngfw.AuraReturn
    {

    }

}