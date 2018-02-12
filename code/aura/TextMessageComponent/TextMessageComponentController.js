({ 
	doInit : function(component, event, helper) {
        //alert('JS Controller doInit');
		helper.getTextMessageThread(component);
		helper.getGatewayOptions(component);
        helper.getSMSTemplates(component);

	},

	sendText : function(component, event, helper) {
        //alert('JS Controller sendText');
		helper.sendMessage(component);
		helper.getTextMessageThread(component);
        component.find("smsTemplatePicklist").set("v.value","-None-");
	},
	setupJS : function(component, event, helper) {
        //alert('JS Controller setupJS');
		helper.setupJS(component, helper); 
		component.set("v.doneRendering", true);      
	}, 

	scrollDown : function(component, event, helper) { 
        //alert('JS Controller scrollDown');
		j$ = jQuery.noConflict();
		var txtDiv = j$("#textMessageComponent");
		var n = txtDiv.height();
		txtDiv.animate({ scrollTop: 10000000 }, 50);
	},
	handleIdUpdate : function(component, event, helper) {
        //alert('JS Controller handleIdUpdate');
		var hasRerendered = component.get("v.doneRerendering");
		if(hasRerendered == false){
			helper.getTextMessageThread(component);
			helper.getGatewayOptions(component);
			component.set("v.doneRerendering", true);
		}

	},
    setTemplate : function(component, event, helper) {
        var selected = component.find("smsTemplatePicklist").get("v.value");
        if(selected != "-None-"){
            component.set("v.txtMessage", selected);
        }
    }
})