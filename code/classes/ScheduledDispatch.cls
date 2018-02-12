public with sharing class ScheduledDispatch implements Schedulable {

    
    /////////////////////////////////////////////////////////////////////////
    //Interface: IBatchHandlerClass
    /////////////////////////////////////////////////////////////////////////
    public interface IScheduledHandlerClass {
        ScheduledDispatchContext getContext();
        void setContext(ScheduledDispatchContext scheduledDispatchCtx);
        void execute(ScheduledDispatch ths);
        String serialize();
        ScheduledDispatchContext deserialize(String serializedScheduledDispatchContext);  

    }
    public class ScheduledDispatchContext{
        public ScheduledDispatchContext(){
            scheduledHandler = 'ScheduledDispatch.MockScheduledDispatch';
        }
        public String scheduledHandler {get;set;}

    }



    //Private variables
    private IScheduledHandlerClass activeScheduledHandler;
    private ScheduledDispatchContext scheduledDispatchCtx;

	public ScheduledDispatch() {
		
	}
    public ScheduledDispatch(ScheduledDispatchContext ctx){
      this.scheduledDispatchCtx = ctx;
    }
	

	public void execute(SchedulableContext SC){
system.debug('ScheduledDispatch.execute()');

        //Create the activeBatchHandler if it doesn't exist
        activeScheduledHandler = ScheduledDispatch.getScheduledHandler(scheduledDispatchCtx);
        activeScheduledHandler.execute(this);

	}


    public static IScheduledHandlerClass getScheduledHandler(ScheduledDispatchContext scheduledDispatchCtx){
system.debug('ScheduledDispatch.getScheduledHandler()');
        if(!String.isEmpty(scheduledDispatchCtx.scheduledHandler)){
            Type handlerClass = Type.forName(scheduledDispatchCtx.scheduledHandler);
system.debug('scheduledDispatchCtx.scheduledHandler:'+scheduledDispatchCtx.scheduledHandler);
system.debug('handlerClass:'+handlerClass);
            IScheduledHandlerClass newScheduledHandler = (IScheduledHandlerClass)handlerClass.newInstance();
            newScheduledHandler.setContext(scheduledDispatchCtx);

system.debug('newScheduledHandler:'+newScheduledHandler);
            return newScheduledHandler;  
        }
        return null;          
    }



	public with sharing class MockScheduledDispatch implements IScheduledHandlerClass{
        public ScheduledDispatchContext getContext(){
            return null;
        }
        public void setContext(ScheduledDispatchContext scheduledDispatchCtx){

        }
        public void execute(ScheduledDispatch ths){

        }
        public String serialize(){
            return null;
        }
        public ScheduledDispatchContext deserialize(String serializedScheduledDispatchCtx){
            return null;
        }   


	}
}