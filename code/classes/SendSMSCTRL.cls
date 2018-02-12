public with sharing class SendSMSCTRL {
    public String origination {get;set;}
    public List<SelectOption> getOriginationList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('-Default-', '-Default-'));
        for(Gateway__c gtw : [SELECT id, Name from Gateway__c where Inactive__c = false Order by DisplaySequence__c]){
            options.add(new SelectOption(gtw.id, gtw.Name));
        }
        return options;
    }

    public DateTime scheduledTime {get;set;}

    public Boolean showHeader {get;set;}
    public Boolean modalMode {get;set;}
    public Boolean leadMode {get;set;}
    public Boolean contactMode {get;set;}
    
    public string toStr  { get;set; }              // for TO field of SMS
    public string msgStr { get;set; }              // for MESSAGE field of SMS
    
    public SMS__c  campQueue{get;set;}        //for add campaign button
    //private List<CampaignMember> campContacts{get; set;} //list to get all member of campaign
    
    private String queryBasic { get;set; }         // the soql without the order and limit
    private String queryFinal { get;set; }         // the soql with the order and limit
    
    public String tempId   { get; set; }           // to hold Template Id
    public String sortLike { get; set; }           // to Sort according to Startswith
    
    public List<innerClassForContact>  inClsCont { get; set;} 
    public List<innerClassForLead>  inClsLead { get; set;}     

    public String  tempName {get; set;}                              // to hold Template Name
    public List<innerClassForTemplate> inClsTemplate{ get; set;}     // to show SMS TEMPLATE list
    
    

    public boolean showContact{get; set;}      // to show Contact List
    public void displayCont(){ showContact = TRUE;  showTemplate = FALSE; getinClsContEdit(); }
    public void closeCont()  { showContact = FALSE; showTemplate = FALSE; }

    public boolean showLead{get; set;}      // to show Lead List
    public void displayLead(){ showLead = TRUE;  showTemplate = FALSE; getinClsLeadEdit(); }
    public void closeLead()  { showLead = FALSE; showTemplate = FALSE; }


    
    public boolean showTemplate  { get; set; }                       // switch for pop-up of SMS TEMPLATE
    public void displayTemplate(){ showContact = FALSE; showTemplate = TRUE;  }
    public void closeTemplate()  { showContact = FALSE; showTemplate = FALSE; }
    // for pagination
    public integer OffsetSize { get; set; }
    public integer LimitSize  { get; set; }
    public integer totalRecs  { get; set; }
    public SendSMSCTRL(){

        //Get any passed in parameters
        String contactIDsParam = ApexPages.currentPage().getParameters().get('contactIDs');
        String leadIDsParam = ApexPages.currentPage().getParameters().get('leadIDs');
        List<ID> contactIDs = new List<ID>();
        List<ID> leadIDs = new List<ID>();
        if(!String.isBlank(contactIDsParam)){
            contactIDs = contactIDsParam.split(',');
        }
        if(!String.isBlank(leadIDsParam)){
            leadIDs = leadIDsParam.split(',');
        }
        showHeader=true;
        modalMode = false;
        String modalModeParam = ApexPages.currentPage().getParameters().get('modal');
        if( modalModeParam == '1'){
            modalMode = true;
            showHeader=false;
        }
        leadMode=false;
        contactMode = false;
        String leadModeParam = ApexPages.currentPage().getParameters().get('lead');
        if( leadModeParam == '1'){
            leadMode = true;
        }
        String contactModeParam = ApexPages.currentPage().getParameters().get('contact');
        if( contactModeParam == '1'){
            contactMode = true;
        }
        
        toStr = '';
System.debug(contactIDs);
System.debug(leadIDs);
        prefillContactList(contactIDs, leadIDs);

//        toStr = 'Test'; //embed the contact or lead info here
        inClsCont = new List<InnerClassForContact>();
        inClsLead = new List<innerClassForLead>();
        inClsTemplate = new List<InnerClassForTemplate>();
        campQueue = new SMS__c ();
        //campContacts =new List<CampaignMember>();
        getInClsTemplateEdit();
        OffsetSize = 0;
        LimitSize  = 20;
        totalRecs = 0;
        if((Schema.sObjectType.Contact.isAccessible())){

            totalRecs = database.countQuery(' Select count() FROM Contact limit 2001');
        } else {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The User does not have the correct access on Contact'));           
        }            
        if( totalRecs > 2000 ) totalRecs = 2000;        
    }
    
    public SendSMSCTRL(ApexPages.StandardController controller) {
        inClsCont = new List<InnerClassForContact>();
        inClsLead = new List<InnerClassForLead>();
        inClsTemplate = new List<InnerClassForTemplate>();
        campQueue = new SMS__c ();
        //campContacts =new List<CampaignMember>();
        getInClsTemplateEdit();
        OffsetSize = 0;
        LimitSize  = 20;
        totalRecs = 0;
        if((Schema.sObjectType.Contact.isAccessible())){

            totalRecs = database.countQuery(' Select count() FROM Contact limit 2001');
        } else {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The User does not have the correct access on Contact'));           
        } 
        if( totalRecs > 2000 ) totalRecs = 2000;
    }
    
    /* ***** Inner Class For Contacts with Mobile Number ***** */
    public class innerClassForContact {
        public boolean conCheck { get;set; }
        public Contact cont { get;set; }
        public innerClassForContact () { cont = new Contact(); conCheck = false; }      // Inner Class Constructor default 
        public innerClassForContact(Contact c){ cont = c; conCheck = false; }           // Inner Class Constructor parameterized
    }
    /* ***** ************************** ***** */
    
    public List<innerClassForContact> getinClsContEdit(){
        inClsCont.clear();


        if((Schema.sObjectType.Contact.isAccessible()) &&
           (Schema.sObjectType.Contact.fields.FirstName.isAccessible())&&
           (Schema.sObjectType.Contact.fields.LastName.isAccessible())&&
           (Schema.sObjectType.Contact.fields.MobilePhone.isAccessible())){

//            queryBasic = 'SELECT Id, firstname, lastname, Name, MobilePhone FROM Contact WHERE MobilePhone != null';
            queryBasic = 'SELECT Id, firstname, lastname, Name, MobilePhone, Mogli_Number__c FROM Contact WHERE Mogli_Number__c != null';
            if ( sortLike != null ){ queryBasic += ' and NAME LIKE \''+String.escapeSingleQuotes(sortLike)+'%\''; }
            
            queryFinal = queryBasic + ' ORDER BY Name DESC LIMIT '+LimitSize+' OFFSET '+OffsetSize;

            List<Contact> insertedConList = Database.query(queryFinal);
            if(insertedConList != null){ 
                for(Contact c : insertedConList){ 
                    innerClassForContact inCon = new innerClassForContact(c);
                    inClsCont.add(inCon); 
                } 
            }
        } else {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The User does not have the correct access on Contact'));           
        }

        return inClsCont;
    }
    
    public pagereference sortContacts(){
        getinClsContEdit();
        return null;
    }

    /* ***** Inner Class For Contacts with Mobile Number ***** */
    public class innerClassForLead {
        public Boolean ldCheck { get;set; }
        public Lead ld { get;set; }
        public innerClassForLead () { ld = new Lead(); ldCheck = false; }      // Inner Class Constructor default 
        public innerClassForLead(Lead l){ ld = l; ldCheck = false; }           // Inner Class Constructor parameterized
    }
    /* ***** ************************** ***** */
    
    public List<innerClassForLead> getinClsLeadEdit(){
        inClsLead.clear();


        if((Schema.sObjectType.Lead.isAccessible()) &&
           (Schema.sObjectType.Lead.fields.FirstName.isAccessible())&&
           (Schema.sObjectType.Lead.fields.LastName.isAccessible())&&
           (Schema.sObjectType.Lead.fields.MobilePhone.isAccessible())){

//            queryBasic = 'SELECT Id, firstname, lastname, Name, MobilePhone FROM Contact WHERE MobilePhone != null';
            queryBasic = 'SELECT Id, firstname, lastname, Name, MobilePhone, Mogli_Number__c FROM Lead WHERE Mogli_Number__c != null';
            if ( sortLike != null ){ queryBasic += ' and NAME LIKE \''+String.escapeSingleQuotes(sortLike)+'%\''; }
            
            queryFinal = queryBasic + ' ORDER BY Name DESC LIMIT '+LimitSize+' OFFSET '+OffsetSize;

            List<Lead> insertedLdList = Database.query(queryFinal);
            if(insertedLdList != null){ 
                for(Lead l : insertedLdList){ 
                    innerClassForLead inLd = new InnerClassForLead(l);
                    inClsLead.add(inLd); 
                } 
            }
        } else {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The User does not have the correct access on Lead'));           
        }

        return inClsLead;
    }
    
    public pagereference sortLeads(){
        getinClsLeadEdit();
        return null;
    }


    
    /* ***** Inner Class For SMS Template ***** */
    public class innerClassForTemplate {
        public boolean tempCheck { get;set; }
        public SMS_Template__c template { get; set; }
        
        public innerClassForTemplate() { template = new SMS_Template__c(); tempCheck = FALSE; }
        public innerClassForTemplate(SMS_Template__c t) { template = t; tempCheck = FALSE;    }
    }
    /* ***** ************************** ***** */
    
    public List<innerClassForTemplate> getInClsTemplateEdit(){
        inClsTemplate.clear();
        if((Schema.sObjectType.SMS_Template__c.isAccessible()) &&
           (Schema.sObjectType.SMS_Template__c.fields.Name__c.isAccessible())&&
           (Schema.sObjectType.SMS_Template__c.fields.Text__c.isAccessible())){
        
            List<SMS_Template__c> insertedTempList = [ SELECT Id, Name, Name__c, Text__c FROM SMS_Template__c ORDER BY Name DESC LIMIT 50000];
            if( insertedTempList != null ){ 
                for( SMS_Template__c s : insertedTempList ){ 
                    innerClassForTemplate inTemp = new innerClassForTemplate(s);
                    inClsTemplate.add(inTemp); 
                } 
            }
        } else {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The User does not have the correct access on SMS_Template__c'));           
        }            
        return inClsTemplate;
    }
    
    public void addTemplate(){
        showTemplate = FALSE;
        List<SMS_Template__c> tempList = [ SELECT Id, Name, Name__c, Text__c FROM SMS_Template__c where Name__c = :tempName ORDER BY Name DESC LIMIT 50000];       
//        if ( tempText != null ) { MsgStr = ''; MsgStr = tempText; }
        if(tempList.size()==1) msgStr = tempList[0].Text__c;
    }
    
    public PageReference associateRecords(){
        MogliService.AssociateSMS job = new MogliService.AssociateSMS();
        System.enqueueJob(job);
        MogliService.AssociateForms job2 = new MogliService.AssociateForms();
        System.enqueueJob(job2);
        return null;
    }

    private void prefillContactList(List<ID> contactIDs, List<ID> leadIDS){
System.debug('prefill');
        List<Contact> contList;
        List<Lead> leadList;
System.debug(contactIDs);
System.debug(leadIDs);
        String c = '';

        if((Schema.sObjectType.Contact.isAccessible()) &&
           (Schema.sObjectType.Contact.fields.FirstName.isAccessible())&&
           (Schema.sObjectType.Contact.fields.LastName.isAccessible())&&
           (Schema.sObjectType.Contact.fields.MobilePhone.isAccessible())){

            if(contactIDs.size()>0){
                contList = [SELECT id, FirstName, LastName, Name, MobilePhone, Mogli_Number__c
                                            FROM Contact where id = :contactIDs LIMIT 50000];            
                for (integer i=0; i<contList.size(); i++){
                    if(!String.isBlank(contList[i].Name)){
//                        c += contList[i].Name +'<'+contList[i].MobilePhone+'>,';                 
                        c += contList[i].Name +'<'+contList[i].Mogli_Number__c+'>;';                 
                    } 
                }
                toStr += c;
            }
        } else {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The User does not have the correct access on Contact'));           
        }


        if((Schema.sObjectType.Lead.isAccessible()) &&
           (Schema.sObjectType.Lead.fields.MobilePhone.isAccessible())){

System.debug('2');
            if(leadIDs.size()>0){
                leadList = [SELECT id, Name, MobilePhone, Mogli_Number__c
                                            FROM Lead where id = :leadIDs LIMIT 50000];            
                for (integer i=0; i<leadList.size(); i++){       
                    if (!String.isBlank(leadList[i].Name)){
//                        c += leadList[i].Name +'<'+leadList[i].MobilePhone+'>,';                 
                        c += leadList[i].Name +'<'+leadList[i].Mogli_Number__c+'>;';                 
                    } 

                }
                toStr += c;
            }
        } else {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The User does not have the correct access on Contact'));           
        }










    }

    public void addCampaignConList(){

        List<CampaignMember> campMems = new List<CampaignMember>();
        if((Schema.sObjectType.CampaignMember.isAccessible()) &&
           (Schema.sObjectType.Contact.isAccessible())&&
           (Schema.sObjectType.Contact.fields.FirstName.isAccessible())&&
           (Schema.sObjectType.Contact.fields.LastName.isAccessible())&&
           (Schema.sObjectType.Contact.fields.Name.isAccessible())&&
           (Schema.sObjectType.Contact.fields.MobilePhone.isAccessible())&&
           (Schema.sObjectType.Lead.isAccessible())&&
           (Schema.sObjectType.Lead.fields.FirstName.isAccessible())&&
           (Schema.sObjectType.Lead.fields.LastName.isAccessible())&&
           (Schema.sObjectType.Lead.fields.LastName.isAccessible())&&
           (Schema.sObjectType.Lead.fields.Name.isAccessible())&&
           (Schema.sObjectType.Lead.fields.MobilePhone.isAccessible())){

            campMems = [select Contact.id, Contact.FirstName, Contact.LastName, Contact.Name, Contact.MobilePhone, Contact.Mogli_Number__c,
                                    Lead.id, Lead.FirstName, Lead.LastName, Lead.Name, Lead.MobilePhone, Lead.Mogli_Number__c
                                    FROM CampaignMember WHERE CampaignId =: campQueue.Campaign__c LIMIT 50000];
            String c = '';
            //if ( toStr != null) c += toStr;
            for (integer i=0; i<campMems.size(); i++){
                if(!String.isBlank(campMems[i].Contact.Name)){
//                    c += campMems[i].Contact.Name +'<'+campMems[i].Contact.MobilePhone+'>,';                 
                    c += campMems[i].Contact.Name +'<'+campMems[i].Contact.Mogli_Number__c+'>;';                 
                } else if (!String.isBlank(campMems[i].Lead.Name)){
//                    c += campMems[i].Lead.Name +'<'+campMems[i].Lead.MobilePhone+'>,';                 
                    c += campMems[i].Lead.Name +'<'+campMems[i].Lead.Mogli_Number__c+'>;';                 
                } 

            }
            toStr = c;
System.debug(campMems);
System.debug(toStr);

        } else {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The User does not have the correct access on CampaignMember, Lead, or Contact'));           
        }




        

        
    }
    
    public void addContact(){
        String c = '';
        if ( toStr != null) c += toStr;
        for (integer i=0; i<inClsCont.size(); i++){
//            if ( inClsCont[i].conCheck ) { c += inClsCont[i].cont.Name +'<'+inClsCont[i].cont.MobilePhone+'>,'; }
            if ( inClsCont[i].conCheck ) { c += inClsCont[i].cont.Name +'<'+inClsCont[i].cont.Mogli_Number__c+'>;'; }
        }
        toStr = c;
        inClsCont.clear();
        getinClsContEdit();
    }
    public void addLead(){
        String l = '';
        if ( toStr != null) l += toStr;
        for (integer i=0; i<inClsLead.size(); i++){
//            if ( inClsCont[i].conCheck ) { c += inClsCont[i].cont.Name +'<'+inClsCont[i].cont.MobilePhone+'>,'; }
            if ( inClsLead[i].ldCheck ) { l += inClsLead[i].ld.Name +'<'+inClsLead[i].ld.Mogli_Number__c+'>;'; }
        }
        toStr = l;
        inClsLead.clear();
        getinClsLeadEdit();
    }
    
    public pagereference QueueSMS(){
        integer i,j,k,indexStart, indexEnd;
        k=0;
        List<String> toStrPlusNum  = new List<String>();
        List<String> toStrPlusNum2 = new List<String>();
        List<String> toNumbers = new List<String>();
        List<SMS__c> smsToAdd = new List<SMS__c>();
        
        if ( String.isEmpty(toStr) ) {
System.debug(String.isEmpty(toStr));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Please enter Valid Phone Numbers or Contacts.'));
            return null;
        } else if ( msgStr == '' ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Please enter Message.'));
            return null;
        }
        else {
            String ss = toStr.trim();
            toStrPlusNum = ss.split(';');
System.debug('toStrPlusNum:: '+toStrPlusNum);
            
            for ( i=0; i<toStrPlusNum.size(); i++){
                toStrPlusNum[i] = toStrPlusNum[i].trim();
                indexStart = toStrPlusNum[i].indexOf('<');
                indexEnd = toStrPlusNum[i].indexOf('>');
System.debug('toStrPlusNum:: '+i+'::'+toStrPlusNum[i]);
System.debug('indexStart:: '+i+'::'+indexStart);
System.debug('indexEnd :: '+i+'::'+indexEnd);
                
                toNumbers.add(toStrPlusNum[i].substring(indexStart+1,indexEnd));
System.debug('toNumbers:: '+toNumbers[i]);
            }
        }

        List<Contact> conList = new List<Contact>();
        if((Schema.sObjectType.Contact.isAccessible()) &&
           (Schema.sObjectType.Contact.fields.MobilePhone.isAccessible())){

//            conList = [select id, MobilePhone from Contact where MobilePHone in : toNumbers and mobilephone!= null LIMIT 50000];
            conList = [select id, MobilePhone, Mogli_Number__c from Contact where Mogli_Number__c in : toNumbers and Mogli_Number__c != null LIMIT 50000];
        } else {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The User does not have the correct access on Contact'));           
        }


        List<Lead> leadList = new List<Lead>();
        if((Schema.sObjectType.Lead.isAccessible()) &&
           (Schema.sObjectType.Lead.fields.MobilePhone.isAccessible())){

//            leadList = [Select id, MobilePhone from Lead where MobilePhone in: toNumbers and MobilePhone != null LIMIT 50000];
            leadList = [Select id, MobilePhone, Mogli_Number__c from Lead where Mogli_Number__c in: toNumbers and Mogli_Number__c != null LIMIT 50000];
        } else {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The User does not have the correct access on Lead'));           
        }





/*
        Map<String, Contact> contByPhoneNumber = new Map<String, Contact>();
        Map<String, Lead> leadByPhoneNumber = new Map<String, Lead>();

        for(Contact cont: conList){
            if(!contByPhoneNumber.containsKey(cont.MobilePhone)){
                contByPhoneNumber.put(cont.MobilePhone, cont);
            }
        }
        for(Lead ld: leadList){
            if(!leadByPhoneNumber.containsKey(ld.MobilePhone)){
                leadByPhoneNumber.put(ld.MobilePhone, ld);
            }
        }
*/        

        Map<String, Contact> contByNumber = new Map<String, Contact>();
        Map<String, Lead> leadByNumber = new Map<String, Lead>();

        for(Contact cont: conList){
            if(!contByNumber.containsKey(cont.Mogli_Number__c)){
                contByNumber.put(cont.Mogli_Number__c, cont);
            }
        }
        for(Lead ld: leadList){
            if(!leadByNumber.containsKey(ld.Mogli_Number__c)){
                leadByNumber.put(ld.Mogli_Number__c, ld);
            }
        }

        //Map<String, String> phoneIdMap = new Map <String, String>();
       // for (contact c: conlist)
            //phoneIdMap.put(c.mobilephone, c.id);
            //conList.clear(); //?
        
        if ( toNumbers.size()>0 ){
            for ( j=0;j<toNumbers.size();j++){
                SMS__c sq = new SMS__c();
                sq.Phone_Number__c = toNumbers[j];
                sq.Message__c = msgStr;
                sq.Direction__c = 'Outgoing';
                sq.Status__c = 'Queued';
                
//                if(contByPhoneNumber.containsKey(toNumbers[j])){
                if(contByNumber.containsKey(toNumbers[j])){
//                    sq.Contact__c = contByPhoneNumber.get(toNumbers[j]).id;
                    sq.Contact__c = contByNumber.get(toNumbers[j]).id;
//                } else if(leadByPhoneNumber.containsKey(toNumbers[j])){
                } else if(leadByNumber.containsKey(toNumbers[j])){
//                    sq.Lead__c = leadByPhoneNumber.get(toNumbers[j]).id;
                    sq.Lead__c = leadByNumber.get(toNumbers[j]).id;
                }

//                if(phoneIdMap.containsKey(toNumbers[j])){
                    //sq.contact__c = phoneIdMap.get(toNumbers[j]);                        
                //}

System.debug ('sq --' + sq);
                
                if(campQueue.Campaign__c<>null){
                    sq.Campaign__c = campQueue.Campaign__c;
                }
                if(campQueue.Scheduled_Delivery__c<>null){
                    sq.Scheduled_Delivery__c = campQueue.Scheduled_Delivery__c;
                    sq.Status__c = 'Scheduled';
                }
                if(origination != '-Default-'){
                    sq.Gateway__c = origination;                    
                }

                smsToAdd.add(sq);
            }

            //phoneIdMap.clear();           

            if(MogliUtil.respectUserSecurityDML()){
                if((SMS__c.sObjectType.getDescribe().isCreateable()) &&
                   (Schema.sObjectType.SMS__c.fields.Phone_Number__c.isCreateable()) &&
                   (Schema.sObjectType.SMS__c.fields.Message__c.isCreateable()) &&
                   (Schema.sObjectType.SMS__c.fields.Direction__c.isCreateable()) &&
                   (Schema.sObjectType.SMS__c.fields.Scheduled_Delivery__c.isCreateable()) &&
                   (Schema.sObjectType.SMS__c.fields.Status__c.isCreateable())){
                    Database.insert(smsToAdd,true);            
                } else {
                    throw new SendSMSCTRLException('SendSMSCTRL - Insufficient Access to Insert SMS__c');
                }
            } else {
//                Database.insert(smsToAdd,true);            
            }
            
            inClsCont.clear();
            inClsTemplate.clear();
            toStr = '';
            msgStr = '';
        

            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'Message Sending in progress.'));  
            return null; 

        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Server Failed.'));
            return null;
        }     
        return null;
    }
    
    public PageReference gotoCancel(){
        if(modalMode){
            return new PageReference('javascript:window.close()');
        }
        if(leadMode){
            PageReference p = new pageReference('/00Q/o');
            p.setredirect(true);        
            return p;             
        }
        if(contactMode){
            PageReference p = new pageReference('/003/o');
            p.setredirect(true);        
            return p;            
        }
		return null;
    }
    
    public PageReference gotoSMSObj(){
        Schema.DescribeSObjectResult R = SMS__c.SObjectType.getDescribe();
        PageReference p = new PageReference('/' + R.getKeyPrefix());
        p.setredirect(true);        
        return p;
    }
    
    
    
    
    /* ** To FirstPage ** */
    public void FirstPage(){ 
        OffsetSize = 0;
        getinClsContEdit();
    }
    
    /* ** To LastPage ** */
    public void LastPage() { 
        OffsetSize = totalrecs - math.mod(totalRecs,LimitSize);
        if( OffsetSize >2000 ) OffsetSize = 2000;
        getinClsContEdit();
    }
    
    /* ** To Previous Page ** */
    public void previous() { 
        OffsetSize = OffsetSize - LimitSize;
        getinClsContEdit();
    }
    
    /* ** To Next Page ** */
    public void next()     { 
        if( (OffsetSize-LimitSize) < 2000 ) OffsetSize = OffsetSize + LimitSize;
        getinClsContEdit();
    }
    
    /* ** Check Previous Page ** */
    public boolean getprev(){
        if( OffsetSize == 0 ) return true;
        else return false;
    }
    
    /* ** Check Next Page ** */
    public boolean getnxt(){
        if((OffsetSize + LimitSize) > totalRecs) return true;
        else return false;
    }

    public class SendSMSCTRLException extends Exception {}
}