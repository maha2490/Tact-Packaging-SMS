({ 
	getTextMessageThread : function(component) {
        //alert('JS Helper getTextMessageThread');
		var action = component.get("c.getSMSMessageThread");
		action.setParams({
			"recordId": component.get("v.recordId")
		});
		
		action.setCallback(this, function(response){
			component.set("v.Messages", response.getReturnValue());
		});
		$A.enqueueAction(action);
	},

	sendMessage : function(component){
        //alert('JS Helper sendMessage');
		var action = component.get("c.sendSMSMessage");
		action.setParams({
			"recordId": component.get("v.recordId"),
			"message": component.get("v.txtMessage"),
			"gatewayName": component.find("gatewayId").get("v.value")
		});
		action.setCallback(this,function(response){
			component.set("v.txtMessage", '');
		});
		$A.enqueueAction(action);
	},

	setupJS : function(component, helper){
        //alert('JS Helper setupJS');
		var action = component.get("c.getSessionId");
		action.setCallback(this,function(response){
			j$ = jQuery.noConflict();
			
			j$("#hiddenButton").click($A.getCallback(function onHiddenClick(){
				//alert('Hidden Button Clicked');
				var number = j$(this).val();
                //alert('Number = ' + number);
				helper.verifyMessage(component, number, helper);
			}));
			
			
		    configuration = {url:'https://'+window.location.hostname+'/cometd/26.0/',
		                 requestHeaders: {"Authorization": "OAuth " + response.getReturnValue()},
		                             appendMessageTypeToURL : false};

	        j$.cometd.configure(configuration); 

	        j$.cometd.handshake();


	        
	        j$.cometd.subscribe('/topic/SMSCreated', function(message) {
                //alert('Subscribed to SMSCreated Topic');
	        	var button = j$("#hiddenButton");
	        	button.val(message.data.sobject.Mogli_SMS__Phone_Number__c);
	        	button.click();        	
	        	
	        }); 
            
            var messageBox = j$(".message_input_box");
            messageBox.keyup(function(event){
                if(event.keyCode == 13){
                    j$(".message_send").find("button").click();
                }
            });
            
            var messageNumber = j$(".message_number_select");
            messageNumber.keydown(function(event){
                if(event.keyCode == 13){
                    j$(".message_send").find("button").click();
                }
            });
            
            
            var messageNumber = j$(".dynamic");
            messageNumber.keydown(function(event){
                if(event.keyCode == 13){
                    j$(".message_send").find("button").click();
                }
            });
            
            
	        
		});
		$A.enqueueAction(action);
	}, 

	verifyMessage : function(component, msgNumber, helper){
        //alert('JS Helper verifyMessage');		
		var action = component.get("c.verifyMessage");
		action.setParams({
			"recordId": component.get("v.recordId"),
			"msgNumber": msgNumber
		});
		action.setCallback(this,function(response){
            //alert('Number verified = ' + response.getReturnValue());
			if(response.getReturnValue() == true){
				helper.getTextMessageThread(component);
			}
		});
		$A.enqueueAction(action);
		
	}, 

	getGatewayOptions : function(component){
        //alert('JS Helper getGatewayOptions');
		var action = component.get("c.getOriginationList");
		action.setCallback(this,function(response){
			component.set("v.gateways", response.getReturnValue());
			
		});
		$A.enqueueAction(action);		
	},
    
    getSMSTemplates : function(component){
		var action = component.get("c.getSMSTemplates");
		action.setCallback(this,function(response){
            var options = [];
			var results = response.getReturnValue();
            var numResults = results.length;
            options.push({class: "templationOptions", label: "-None-", value: "-None-"});
            for(var i=0; i< numResults; i++){
                options.push({class: "templationOptions", label: results[i].Mogli_SMS__Name__c, value: results[i].Mogli_SMS__Text__c });
            }
            component.find("smsTemplatePicklist").set("v.options", options);
			
		});
		$A.enqueueAction(action);		
	}


})