@RestResource(UrlMapping='/v2/mogli/*')
global with sharing class MogliWebService {
	private static List<Log__c> logs = new List<Log__c>();

    global interface IMogliWebServiceHandler {
    	String handlePost(MogliWebService.MogliWebServiceContext context);
    }


    global class TwilioMogliWebServiceHandler implements IMogliWebServiceHandler{
     	public String handlePost(MogliWebService.MogliWebServiceContext context){
			if(MogliSMSSettings.getAppSettings().Debug__c) logs.add(new Log__c(Text__c = 'MogliWebService.TwilioMogliWebServiceHandler.handlePost()'));
            //if logging only
            
system.debug('MogliWebService.TwilioMogliWebServiceHandler()');

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
	        String toParam = paramMap.get('To');
System.debug('toParam:'+toParam);
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
			if(MogliSMSSettings.getAppSettings().Debug__c) logs.add(new Log__c(Text__c = String.valueOf(mediaMap)));

			Boolean requiredParams = false;
			if(String.isNotBlank(fromParam) &&
				 String.isNotBlank(sidParam) && 
				 (String.isNotBlank(bodyParam) || numMedia > 0)){
				requiredParams = true;
			}

	        if (requiredParams){
	        	if(String.isEmpty(bodyParam)) bodyParam = ' ';
	            //if( !sidParam.equals(MogliSMSSettings.getAppSettings().TwilioAccountSid__c) && !Test.isRunningTest()) 
	        	if(!Test.isRunningTest() && !sidParam.equals(GatewayUtil.gatewayMap.get(context.gatewayID).TwilioAccountSid__c) ){
	        		throw new MogliWebServiceException('Bad AccountSID');
	        	}

	                
                SMS__c ins = new SMS__c();

                //ins.FromNumber__c = toParam;
                ins.Phone_Number__c = fromParam;
                ins.Message__c = bodyParam;
                ins.Direction__c = 'Incoming';
                //ins.Origination__c = OriginationUtil.originationMap.get(context.originationID).id;
                ins.Gateway__c = context.gatewayID;
                //ins.type__c = 'SMS';
                ins.Status__c = 'Received Successfully';

                if(MogliSMSSettings.getAppSettings().Debug__c){
                	String debug;
                	debug = 'paramMap:'+String.valueOf(paramMap);
                	ins.Debug__c = debug;

            	}

            	List<Attachment> attachedMedia = new List<Attachment>();
            	Integer count = 0;
            	for(String url : mediaMap.keySet()){
			
					if(MogliSMSSettings.getAppSettings().Debug__c) logs.add(new Log__c(Text__c = url));

           			count++;
					HTTPRequest req = new HTTPRequest();

					req.setEndPoint(url);
					req.setMethod('GET');

					system.debug('req:'+req);

					HTTPResponse res = new HTTPResponse();
					if(!Test.isRunningTest()){
						res = new Http().send(req);                
					}
					if(MogliSMSSettings.getAppSettings().Debug__c) logs.add(new Log__c(Text__c = String.valueOf(res.getStatusCode())));

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
							if(MogliSMSSettings.getAppSettings().Debug__c) logs.add(new Log__c(Text__c = loc));
					        req.setMethod('GET');
					        res = new Http().send(req);
					        if(res.getStatusCode() != 500) { // 500 = fail
					            if(MogliSMSSettings.getAppSettings().Debug__c) logs.add(new Log__c(Text__c = String.valueOf(res.getStatusCode())));
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
                        throw new MogliWebServiceException('MogliWebService - Insufficient Access to Insert SMS__c');
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
	        	throw new MogliWebServiceException('Missing required parameters');
	        }


		    TwilioTwiML.Response resp = new TwilioTwiML.Response();
		    context.res.addHeader('Content-Type', 'application/xml');
		    context.res.responseBody = Blob.valueof(resp.toXml());
                
        
		    return 'Incoming Twilio SMS Created Successfully in Salesforce';
		}
    }


	@HttpPost
	global static String doPost(){
		if(MogliSMSSettings.getAppSettings().Debug__c) logs.add(new Log__c(Text__c = 'MogliWebService.doPost()'));
		MogliWebServiceContext context = new MogliWebServiceContext(RestContext.request, RestContext.response);
system.debug('context.req:'+context.req);
system.debug('context.res:'+context.res); 

        if(MogliSMSSettings.getAppSettings().Debug__c){
            
            logs.add(new Log__c(Text__c = 'context.req:'+context.req));
            logs.add(new Log__c(Text__c = 'context.req.params:'+context.req.params));
            for(String param : context.req.params.keySet()){
                logs.add(new Log__c(Text__c = 'param:'+param + ' value:' + context.req.params.get(param)));
            }
        }

		Gateway__c gatewayObj;
        String webhookIdentifier = context.req.requestURI.substringAfterLast('/');
        System.debug('webhookIdentifier:'+webhookIdentifier);
        try{
        	gatewayObj = GatewayUtil.gatewayByWebhook.get(webhookIdentifier);
        	//Origination__c origin = OriginationUtil.originationByWebhook.get(webhookIdentifier);
        	if(gatewayObj == null) throw new MogliWebServiceException('No Gateway_Setting__c mapped to this identifier: '+webhookIdentifier);
        	System.debug('gatewayObj:'+gatewayObj);   	
	        //if(OriginationUtil.originationMap.containsKey(origin.id)){
	        //    //gateway = OriginationUtil.originationMap.get(origin.id).Gateway__c;
	        //    System.debug('gateway:'+gateway);
	        //} else {
	        //    System.debug('No Origination Record Found');
	        //}
        } catch (Exception e) {
        	System.debug(e);
        	return 'A webhook could not be found with this identifier:'+webhookIdentifier+':'+e;
        }

        context.gatewayID = gatewayObj.id;


		String handlerClassStr;
					
		if(MogliUtil.getRecordTypeLabelNameByID('Gateway__c', gatewayObj.RecordTypeID) == 'Twilio'){
			handlerClassStr = 'MogliWebService.TwilioMogliWebServiceHandler';
		} else if(MogliUtil.getRecordTypeLabelNameByID('Gateway__c', gatewayObj.RecordTypeID) == 'Telerivet'){
			handlerClassStr = 'Mogli_Gateways.TelerivetWebServiceHandler2';
		} else if(MogliUtil.getRecordTypeLabelNameByID('Gateway__c', gatewayObj.RecordTypeID) == 'Textwire'){
			handlerClassStr = 'Mogli_Gateways.TxtWireWebServiceHandler2';
		} else if(MogliUtil.getRecordTypeLabelNameByID('Gateway__c', gatewayObj.RecordTypeID) == 'Custom'){							
            handlerClassStr = gatewayObj.CustomWebServiceHandler__c;                         

		} 	
		system.debug('handlerClassStr:'+handlerClassStr);

		if(MogliSMSSettings.getAppSettings().Debug__c) logs.add(new Log__c(Text__c = 'handlerClassStr:'+String.valueOf(handlerClassStr)));


        IMogliWebServiceHandler activeWSHandler;
        try{
        	Type handlerClass = Type.forName(handlerClassStr);
        	activeWSHandler = (IMogliWebServiceHandler)handlerClass.newInstance();        	
        } catch (Exception e){
        	return 'Unable to instantiate WebService Handler: '+e+':'+handlerClassStr+':'+gatewayObj;
        }

        String returnStr = activeWSHandler.handlePost(context);

		if(MogliSMSSettings.getAppSettings().Debug__c) logs.add(new Log__c(Text__c = 'returnStr:'+String.valueOf(returnStr)));

        if (MogliSMSSettings.getAppSettings().Debug__c && logs.size()>0){
        	insert logs;
        	logs.clear();
        }
        return returnStr;

	}
    
    global class MogliWebServiceContext {
    	public RestRequest req {get; set;}
    	public RestResponse res {get;set;}
    	global String gatewayID {get;set;}
    	global MogliWebServiceContext(RestRequest req, RestResponse res){
    		this.req = req;
    		this.res = res;
    	}
    	global MogliWebServiceContext(RestRequest req, RestResponse res, String gatewayID){
    		this.req = req;
    		this.res = res;
    		this.gatewayID = gatewayID;
    	}
    }
    public class MogliWebServiceException extends Exception {}
}