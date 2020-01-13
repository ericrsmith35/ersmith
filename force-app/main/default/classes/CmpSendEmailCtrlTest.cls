/*
** Class: CmpSendEmailCtrlTest
** Created by OpFocus (Veena Sundara-Heragu) on 7/12/18
** Description: Test class for CmpSendEmailCtrl
*/
@isTest
public class CmpSendEmailCtrlTest
{

    static testMethod void myTest1()
    {
        Account a = DataFactory.buildAccount('Test Account');
        insert a;
        Contact c = DataFactory.buildContact('Test Contact', a.Id);
        c.Email = 'test@noemail.com';
        //Contact c = new Contact(FirstName = 'Test', LastName='Contact', AccountId = a.Id, Email='test@noemail.com');
        insert c;

        EmailTemplate temp = new EmailTemplate();
        temp.isActive = true;
        temp.Name = 'Test Template';
        temp.DeveloperName = 'Test_Template';
        temp.TemplateType = 'text';
        temp.FolderId = UserInfo.getUserId();
        system.runAs(new User(Id = UserInfo.getUserId()))
        {
            insert temp;
        }

        CmpSendEmailCtrl.InputData id1 = new CmpSendEmailCtrl.InputData();
        id1.deviceInfoStr = '{}';

        CmpSendEmailCtrl.CmpSendEmailReturn retVal = CmpSendEmailCtrl.ctrlGetLists(JSON.serialize(id1));
        system.assertEquals(null,retVal.lstContact);
        //system.assertEquals(c.Id, retVal.lstContact[0].value);
        system.assert(retVal.lstRelatedTo.size() > 1);

        CmpSendEmailCtrl.InputData id2 = new CmpSendEmailCtrl.InputData();
        id2.deviceInfoStr = '{}';
        id2.contactSearchName = 'Test';

        Test.setFixedSearchResults(new String[]{c.Id});
        retVal = CmpSendEmailCtrl.searchContactByName(JSON.serialize(id2));
        system.assertEquals(1,retVal.lstContact.size());

        CmpSendEmailCtrl.InputData id22 = new CmpSendEmailCtrl.InputData();
        id22.deviceInfoStr = '{}';
        id22.templateId = temp.Id;
        CmpSendEmailCtrl.CmpTemplateReturn ret = CmpSendEmailCtrl.ctrlGetEmailTemplate(JSON.serialize(id22));
        system.assertEquals('My Personl Email Templates', ret.folder);

        ContentVersion cv = new ContentVersion( Title = 'Test',
                                                PathOnClient = 'Test.jpg',
                                                VersionData = Blob.valueOf('Test Content Data'),
                                                IsMajorVersion = true);
        insert cv;
        cv = [Select Id, ContentDocumentId From ContentVersion Where Id = :cv.Id];
        CmpSendEmailCtrl.InputData id21 = new CmpSendEmailCtrl.InputData();
        id21.deviceInfoStr = '{}';
        id21.lstDocumentId = new List<String>{cv.ContentDocumentId};
        CmpSendEmailCtrl.ctrlDeleteDocument(JSON.serialize(id21));
        List<ContentVersion> lstCV = [Select Id from ContentVersion where Id = :cv.Id];
        system.assertEquals(0, lstCV.size());

        CmpSendEmailCtrl.InputData id3 = new CmpSendEmailCtrl.InputData();
        id3.deviceInfoStr = '{}';
        id3.templateId = temp.Id;
        id3.format = 'text';
        id3.fromId = UserInfo.getUserId();
        id3.to = c.Id;
        id3.relatedTo = 'Account';
        id3.relatedToRecord = a.Id;
        id3.additionalTo = 'test@yahoo.com';
        id3.cc = 'test@yahoo.com';
        id3.bcc = 'test@yahoo.com';
        id3.useSignature = false;
        id3.subject = 'subject';
        id3.body = 'body';
        id3.lstUploadFileStr = JSON.serialize(new EmailAttachment[]{new EmailAttachment('testdoc', cv.ContentDocumentId)});

        System.debug(JSON.serializePretty(id3));
        CmpSendEmailCtrl.ctrlSendEmail(JSON.serialize(id3));

        id3.templateId = null;

        CmpSendEmailCtrl.ctrlSendEmail(JSON.serialize(id3));
    }

}