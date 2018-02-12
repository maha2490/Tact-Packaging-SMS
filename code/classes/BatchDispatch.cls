public with sharing class BatchDispatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{ 


    /////////////////////////////////////////////////////////////////////////
    //Interface: IBatchHandlerClass
    /////////////////////////////////////////////////////////////////////////
    public interface IBatchHandlerClass {
        BatchDispatchContext getContext();
        void setContext(BatchDispatchContext batchDispatchCtx);
        String getDefaultQuery();
        void execute(BatchDispatch ths, List<sObject> scope);
        void start(BatchDispatch ths);
        void finish(BatchDispatch ths);
        String serialize();
        BatchDispatchContext deserialize(String serializedBatchDispatchContext);    

    }

    public class BatchDispatchContext{
        public BatchDispatchContext(){
            batchHandler = 'BatchDispatch.MockBatchDispatch';
        }
        public String batchHandler {get;set;}
        public String query {get; set;}
        public Integer batchNumber {get;set;} 
    }

    private BatchDispatchContext batchCtx;

    public BatchDispatch(BatchDispatchContext ctx){
      this.batchCtx = ctx;
    }

    public BatchDispatch(){

    }
    //Properties

    //Private variables
    private IBatchHandlerClass activeBatchHandler;
    
   
    public Database.QueryLocator start(Database.BatchableContext BC) {
system.debug('BatchDispatch.start()');

        this.batchCtx.batchNumber = 0;

        //Create the activeBatchHandler if it doesn't exist
        activeBatchHandler = BatchDispatch.getBatchHandler(batchCtx);

        activeBatchHandler.start(this);

        //Get the default query for the data operations
system.debug('this.batchCtx.query:'+this.batchCtx.query);
        if(String.isEmpty(this.batchCtx.query)){
            //use the default query is none exists in the the property
            this.batchCtx.query = activeBatchHandler.getDefaultQuery();
        }

        return Database.getQueryLocator(this.batchCtx.query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
system.debug('BatchDispatch.execute()');
        this.batchCtx.batchNumber++;
        activeBatchHandler.execute(this, scope);
    }
    
    public void finish(Database.BatchableContext BC) {
system.debug('BatchDispatch.finish()');      
        activeBatchHandler.finish(this);



    }

    public static IBatchHandlerClass getBatchHandler(BatchDispatchContext batchDispatchCtx){
system.debug('BatchDispatch.getBatchHandler()');
        if(!String.isEmpty(batchDispatchCtx.batchHandler)){
            Type handlerClass = Type.forName(batchDispatchCtx.batchHandler);
            IBatchHandlerClass newBatchHandler = (IBatchHandlerClass)handlerClass.newInstance();
            newBatchHandler.setContext(batchDispatchCtx);
system.debug('newBatchHandler:'+newBatchHandler);
            return newBatchHandler;  
        }
        return null;          
    }




    public with sharing class MockBatchDispatch implements IBatchHandlerClass{
        public String getDefaultQuery(){
            if(Schema.sObjectType.User.isAccessible()){
                return 'Select id from User';                
            } else {
                return null;
            }


        }
        public void execute(BatchDispatch ths, List<sObject> scope){

        }
        public void start(BatchDispatch ths){

        }
        public void finish(BatchDispatch ths){

        }
        public String serialize(){
            return null;
        }
        public BatchDispatchContext deserialize(String serializedBatchDispatchContext){
            return null;
        }   
        public BatchDispatchContext getContext(){
            return null;
        }
        public void setContext(BatchDispatchContext batchDispatchCtx){

        }
    }
}