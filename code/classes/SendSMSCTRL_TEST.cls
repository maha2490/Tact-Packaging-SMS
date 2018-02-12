@isTest
public class SendSMSCTRL_TEST {
    @TestSetup static void setupData(){
        TestUtil.setStandardTestConditions();
        system.assert(true);
    }
    @isTest
    static void validateSendSMSCTRL(){
        PageReference pageRef = Page.SendSMS;
        Test.setCurrentPage(pageRef);

        SendSMSCTRL cont = new SendSMSCTRL();
        system.assertNotEquals(cont, null);

        cont.getinClsContEdit();
        cont.sortContacts();
        cont.getInClsTemplateEdit();
        cont.addTemplate();
        cont.associateRecords();
        cont.addCampaignConList();
        cont.addContact();
        cont.QueueSMS();
        cont.gotoCancel();
        cont.gotoSMSObj();
        cont.FirstPage();
        cont.LastPage();
        //cont.previous();
        cont.next();
        cont.getprev();
        cont.getnxt();
        


    }
}