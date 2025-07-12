public without sharing abstract class PdfxAction implements System.Queueable , Database.AllowsCallouts {
    
    /**
     * Whenever an action is created,
     *  generate the action Id. 
     * set the action Id on the registered action tasks (even in the action orchestrator)
     * use the action Id as a key in cache in order to facilitate state sharing.
     */
    private boolean asyncMode;
    private boolean killSwitchHasNextTaskOverride;
    private string qJobId;

    private integer taskCounter = 0;
    private integer tasksSlotRemainder = 8;
    private List<PdfxActionTask> tasksList = new List<PdfxActionTask>(); 

    public map<string, PdfxActionTaskResult> tasksResultsDictionary = new map<String, PdfxActionTaskResult>();
    
    
    protected void addTask(PdfxActionTask task){
        if(tasksSlotRemainder > 0){
            task.setKey(key);
            tasksList.add(task);
            tasksSlotRemainder -= 1;
            task.setTaskResultsRef(tasksResultsDictionary);
        }
    }

    public boolean canAddTask(){
        return tasksSlotRemainder > 0;
    }

    public virtual PdfxActionTask getNextTask(){
        return tasksList.get(taskCounter);
    }
    private virtual boolean hasNextTask(){
        return killSwitchHasNextTaskOverride ?? (tasksList.size() > (taskCounter + 1));
    }
    public virtual void setNextTask(){
        taskCounter += 1;
    }
    

    public void run(){
        if(asyncMode){
            System.enqueueJob(this);
        }else{
            execute();
        }
    }

    
    public void execute(QueueableContext cont){
        qJobId = cont.getJobId();
        asyncMode = true;
        execute();
    }

    private void execute(){
        PdfxActionTask currentTask = getNextTask();
        currentTask?.execute();
        
        if(currentTask.killOnFail()){
            killSwitch();
        }
        
        if (hasNextTask()) {
            setNextTask();
            
            if (asyncMode) {
                // Re-enqueue the job for the next task in asynchronous mode
                System.enqueueJob(this);
            } else {
                // Recursively Continue execution in synchronous mode
                execute();
            }
        }
    }

    // remove all remaining tasks, clear variables .
    private void killSwitch(){
        tasksList = new List<PdfxActionTask>();
        tasksResultsDictionary = new Map<Integer,List<PdfxActionTaskResult>>();
        killSwitchHasNextTaskOverride = false;
       if(asyncMode) {System.abortJob(qJobId);}
    }
    
}