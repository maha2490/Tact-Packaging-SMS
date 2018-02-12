//endpoint: https://mogli-sms-dev-developer-edition.na22.force.com/mogli/services/apexrest/v1*
//tactdemo end: https://tactdemo-developer-edition.na3.force.com/SMS/services/apexrest/MogliSMS/SMSService
//tactdemo secret: 3AM3FG6QQWLRLMK4TWCNCMUTR2R946T9

// twilio endpoint on demo: https://tactdemossms.secure.force.com/SMS/services/apexrest/MogliSMS/twilio


@RestResource(UrlMapping='/v1/sms')
global with sharing class MogliSMSWebService {
	private static List<Log__c> logs = new List<Log__c>();

    global interface IMogliSMSWebServiceHandler {
    	String handlePost(MogliSMSWebService.MogliSMSWebServiceContext context);
    }


    global class TwilioMogliSMSWebServiceHandler implements IMogliSMSWebServiceHandler{
     	public String handlePost(MogliSMSWebService.MogliSMSWebServiceContext context){
			if(MogliSMSSettings.settings.Debug__c) logs.add(new Log__c(Text__c = 'MogliSMSWebService.TwilioMogliSMSWebServiceHandler.handlePost()'));
            //if logging only
            
system.debug('MogliSMSWebService.TwilioMogliSMSWebServiceHandler()');

	        Map<String,string> paramMap = context.req.params;
System.debug('paramMap:'+paramMap); 

//insert (new Log__c(Text__c = String.valueOf(context.req)));


	        String fromParam = paramMap.get('From');
System.debug('fromParam:'+fromParam);
	        String bodyParam = paramMap.get('Body'); 
System.debug('bodyParam:'+bodyParam);
	        String sidParam = paramMap.get('AccountSid');
System.debug('sidParam:'+sidParam);
	        String mediaURL = paramMap.get('MediaURL0');
System.debug('mediaURL:'+mediaURL);
	        String mediaType = paramMap.get('MediaContentType0');
System.debug('mediaType:'+mediaType);
	        Integer numMedia = 0;
	        try {
	        	numMedia = (Integer)Integer.valueOf(paramMap.get('NumMedia'));
	        } catch (Exception e){

	        }
System.debug('numMedia:'+numMedia);
//insert (new Log__c(Text__c = String.valueOf(sidParam)));

			Map<String,String> mediaMap = new Map<String,String>();
			for(Integer i = 0; i<numMedia; i++){
				String mediaURLparam = 'MediaUrl'+ String.valueOf(i);
				String mediaTypeparam = 'MediaContentType' + String.valueOf(i);
				mediaMap.put(paramMap.get(mediaURLparam), paramMap.get(mediaTypeparam));
			}
			if(MogliSMSSettings.settings.Debug__c) logs.add(new Log__c(Text__c = String.valueOf(mediaMap)));

			Boolean requiredParams = false;
			if(String.isNotBlank(fromParam) &&
				 String.isNotBlank(sidParam) && 
				 (String.isNotBlank(bodyParam) || numMedia > 0)){
				requiredParams = true;
			}

	        if (requiredParams){
	        	if(String.isEmpty(bodyParam)) bodyParam = ' ';
	            if( !sidParam.equals(MogliSMSSettings.settings.TwilioAccountSid__c) && !Test.isRunningTest()) throw new MogliSMSWebServiceException('Bad AccountSID');

	                
                SMS__c ins = new SMS__c();

                ins.Phone_Number__c = fromParam;
                ins.Message__c = bodyParam;
                ins.Direction__c = 'Incoming';       
                //ins.type__c = 'SMS';
                ins.Status__c = 'Received Successfully';

                if(MogliSMSSettings.settings.Debug__c){
                	String debug;
                	debug = 'paramMap:'+String.valueOf(paramMap);
                	ins.Debug__c = debug;

            	}

            	List<Attachment> attachedMedia = new List<Attachment>();
            	Integer count = 0;
            	for(String url : mediaMap.keySet()){
			
					if(MogliSMSSettings.settings.Debug__c) logs.add(new Log__c(Text__c = url));

           			count++;
					HTTPRequest req = new HTTPRequest();

					req.setEndPoint(url);
					req.setMethod('GET');

					system.debug('req:'+req);

					HTTPResponse res = new HTTPResponse();
					if(!Test.isRunningTest()){
						res = new Http().send(req);                
					}
					if(MogliSMSSettings.settings.Debug__c) logs.add(new Log__c(Text__c = String.valueOf(res.getStatusCode())));

					System.debug(res);
					System.debug(res.getBody());
					System.debug(res.getHeader('Location'));

					boolean redirect = false;
					if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) {
					    do {
					        redirect = false; // reset the value each time
					        String loc = res.getHeader('Location'); // get location of the redirect
					        if(loc == null) {
					            redirect = false;
					            continue;
					        }
					        req = new HttpRequest();
					        req.setEndpoint(loc);
							if(MogliSMSSettings.settings.Debug__c) logs.add(new Log__c(Text__c = loc));
					        req.setMethod('GET');
					        res = new Http().send(req);
					        if(res.getStatusCode() != 500) { // 500 = fail
					            if(MogliSMSSettings.settings.Debug__c) logs.add(new Log__c(Text__c = String.valueOf(res.getStatusCode())));
					            if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) {
					                redirect= true;
					            }
					            // I do special handling here with cookies
					            // if you need to bring a session cookie over to the
					            // redirected page, this is the place to grab that info
					        }
					    } while (redirect );
					}
					//congratulations you're outside of the redirects now
					//read what you need from the res object
					system.debug(res.getBody());
					attachedMedia.add(new Attachment(Body = res.getBodyAsBlob(),
													  ContentType = mediaMap.get(url),
													  Name = 'Media:'+count));


            	}

                if(MogliUtil.respectUserSecurityDML()){
                    if(SMS__c.sObjectType.getDescribe().isCreateable()){
                        Database.insert(ins,true);            
                    } else {
                        throw new MogliSMSWebServiceException('MogliSMSWebService - Insufficient Access to Insert SMS__c');
                    }
                } else {
                    Database.insert(ins,true); 
                }
                System.debug('Incomming SMS Id: '+ins.id);

                for(Attachment attach : attachedMedia){
                	attach.ParentID = ins.id;
                }
                if(attachedMedia.size()>0){
                	insert attachedMedia;
                }

	        } else {
	        	throw new MogliSMSWebServiceException('Missing required parameters');
	        }


		    TwilioTwiML.Response resp = new TwilioTwiML.Response();
		    context.res.addHeader('Content-Type', 'application/xml');
		    context.res.responseBody = Blob.valueof(resp.toXml());
                
        
		    return 'Incoming Twilio SMS Created Successfully in Salesforce';
		}
    }

    global class TelerivetMogliSMSWebServiceHandler implements IMogliSMSWebServiceHandler{
     	public String handlePost(MogliSMSWebService.MogliSMSWebServiceContext context){
/*
system.debug('MogliSMSWebService.TelerivetMogliSMSWebServiceHandler()');

	        Map<String,string> paramMap = context.req.params;
System.debug('paramMap:'+paramMap); 
	        // Mapping of variables
	        String secretParam = paramMap.get('secret');            
System.debug('secretParam:'+secretParam);

	        String eventParam  = paramMap.get('event');             
System.debug('eventParam:'+eventParam);

	        String toParam     = paramMap.get('to_number');         
System.debug('toParam:'+toParam);

	        String fromParam    = paramMap.get('from_number');       
System.debug('fromParam:'+fromParam);

	        String contentParam    = paramMap.get('content');           
System.debug('contentParam:'+contentParam);

	        String projectParam    = paramMap.get('project_id');
System.debug('projectParam: '+projectParam);
	        
	        if ( String.isNotBlank(secretParam) && String.isNotBlank(eventParam) &&
	        	String.isNotBlank(toParam) && String.isNotBlank(fromParam) &&
	        	String.isNotBlank(contentParam) && String.isNotBlank(projectParam)){
	            if( !secretParam.equals(MogliSMSSettings.settings.TelerivetSecret__c)){
System.debug('wrong secret');
	            	return 'Error: Wrong Secret';
	            } else if( !projectParam.equals(MogliSMSSettings.settings.TelerivetProjectID__c)){
System.debug('wrong project');
	            	return 'Error: Wrong Project ID';
	            } else if( !eventParam.equals('incoming_message')){
System.debug('wrong event');	            	
	            	return 'Error: Wrong Event';
	            } else {

/*
disabled for security reasons given they will be hooked up in the clean up process
	                SystemContext sc = new SystemContext();
	                ID contID = sc.queryContacts(fromParam);
	                ID leadID;
	                if(String.isBlank(String.valueOf(contID))){
	                	leadID = sc.queryLeads(fromParam);
	                }*//*
	                



	                
	                SMS__c ins = new SMS__c();
	                
//Disabling the following 2 lines of code to test for b4l
//	                ins.Contact__c = contID;
//	                ins.Lead__c = leadID;

	                ins.Phone_Number__c = fromParam;
	                ins.Message__c = contentParam;
	                ins.Direction__c = 'Incoming';       
	                //ins.type__c = 'SMS';
	                ins.Status__c = 'Received Successfully';

	                if(MogliUtil.respectUserSecurityDML()){
	                    if(SMS__c.sObjectType.getDescribe().isCreateable()){
	                        Database.insert(ins,true);            
	                    } else {
	                        throw new MogliSMSWebServiceException('MogliSMSWebService - Insufficient Access to Insert SMS__c');
	                    }
	                } else {
	                    Database.insert(ins,true); 
	                }


System.debug('Incomming SMS Id: '+ins.id);
	                return 'Incoming SMS Created Successfully in Salesforce';
	            }
System.debug('Error');
	        }
	        else{
System.debug('Incomming SMS Not Created');
	        	return 'Required Parameters are missing';
	        }*/
	        return null;
	    }
	}


	@HttpPost
	global static String doPost(){
		if(MogliSMSSettings.settings.Debug__c) logs.add(new Log__c(Text__c = 'MogliSMSWebService.doPost()'));
		MogliSMSWebServiceContext context = new MogliSMSWebServiceContext(RestContext.request, RestContext.response);
system.debug('context.req:'+context.req);
system.debug('context.res:'+context.res); 

        if(MogliSMSSettings.settings.Debug__c){
            
            logs.add(new Log__c(Text__c = 'context.req:'+context.req));
            logs.add(new Log__c(Text__c = 'context.req.params:'+context.req.params));
            for(String param : context.req.params.keySet()){
                logs.add(new Log__c(Text__c = 'param:'+param + ' value:' + context.req.params.get(param)));
            }
        }

		String handlerClassStr;
		if(MogliSMSSettings.settings.Gateway__c == 'TWILIO'){
			handlerClassStr = 'MogliSMSWebService.TwilioMogliSMSWebServiceHandler';
		} else if(MogliSMSSettings.settings.Gateway__c == 'TELERIVET'){
			handlerClassStr = 'Mogli_Gateways.TelerivetWebServiceHandler';
		} else if(MogliSMSSettings.settings.Gateway__c == 'TXTWIRE'){
			handlerClassStr = 'Mogli_Gateways.TxtWireWebServiceHandler';
		} else if(MogliSMSSettings.settings.Gateway__c == 'CUSTOM'){
			handlerClassStr = MogliSMSSettings.settings.CustomWebServiceHandler__c;							
		} 					

		if(MogliSMSSettings.settings.Debug__c) logs.add(new Log__c(Text__c = 'handlerClassStr:'+String.valueOf(handlerClassStr)));

        Type handlerClass = Type.forName(handlerClassStr);
        IMogliSMSWebServiceHandler activeWSHandler = (IMogliSMSWebServiceHandler)handlerClass.newInstance();
        String returnStr = activeWSHandler.handlePost(context);

		if(MogliSMSSettings.settings.Debug__c) logs.add(new Log__c(Text__c = 'returnStr:'+String.valueOf(returnStr)));

        if (MogliSMSSettings.settings.Debug__c && logs.size()>0){
        	insert logs;
        	logs.clear();
        }
        return returnStr;

	}
/*
disabled for security reasons given they will be hooked up in the clean up process
	public without sharing class SystemContext{
		public ID queryContacts(String phoneNumber){
			String temp = '%' + phoneNumber + '%';
System.debug('phoneNumber:'+temp);

	         List<contact> conList = [ SELECT Id, MobilePhone FROM Contact WHERE MobilePhone Like: temp LIMIT 50000];
	         if(conList.size()>0){
	         	return conList[0].id;
	         } else {
System.debug('No Contact Found');
	         	return null;
	         }
		}
		public ID queryLeads(String phoneNumber){
			String temp = '%' + phoneNumber + '%';
System.debug('phoneNumber:'+temp);

	         List<Lead> leadList = [ SELECT Id, MobilePhone FROM Lead WHERE MobilePhone Like: temp LIMIT 50000];
	         if(leadList.size()>0){
	         	return leadList[0].id;
	         } else {
System.debug('No Lead Found');
	         	return null;
	         }
		}
	}*/
    
    global class MogliSMSWebServiceContext {
    	public RestRequest req {get; set;}
    	public RestResponse res {get;set;}
    	global MogliSMSWebServiceContext(RestRequest req, RestResponse res){
    		this.req = req;
    		this.res = res;
    	}
    }
    public class MogliSMSWebServiceException extends Exception {}
}