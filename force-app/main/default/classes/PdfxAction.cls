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
    
    // replace this with org cache so that data can easily be referenced and removed by action key.
    public map<String , PdfxActionTaskResult> tasksResultsDictionary = new map<String , PdfxActionTaskResult>();
    
    
    protected void addTask(PdfxActionTask task){
        if(tasksSlotRemainder > 0){
            tasksList.add(task);
            task.setKey(tasksList.size());
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

    public void setAsyncMode(boolean asyncMode){
        this.asyncMode = asyncMode;
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
        // do credit availability check before anything . if user does not have enough credits to perform action
        // kill switch, and email user.
        // figure out a way to write user logs to a robust logging system like highlights.io 
        PdfxActionTask currentTask = getNextTask();
        currentTask?.execute();
        if(currentTask.passed() && currentTask.hasFinalizer()){
            System.attachFinalizer(currentTask.getFinalizer().getAsSystemFinalizer());
        }
        if(currentTask.killOnFail()){
            killSwitch();
        }
        
        if (hasNextTask()) {
            System.debug('YES We have a next task');
            setNextTask();
            
            if (asyncMode) {
                // Re-enqueue the job for the next task in asynchronous mode
                System.debug(' is async ' + asyncMode);
                System.enqueueJob(this);
            } else {
                // Recursively Continue execution in synchronous mode
                // TODO : account for potential limit hits and DML Before Callout Errors !!!!
                execute();
            }
        }else{
            System.debug('NO WE DO NOT HAVE A NEXT TASK !!!');
        }

        // calculate credit usage from all tasks and store in system. 
    }

    // remove all remaining tasks, clear variables .
    private void killSwitch(){
        System.debug(' calling kill switch');
        tasksList = new List<PdfxActionTask>();
        tasksResultsDictionary = new map<String , PdfxActionTaskResult>(); // replace this with cache based shared state
        killSwitchHasNextTaskOverride = false;
       if(asyncMode) {System.abortJob(qJobId);}
    }
    
}