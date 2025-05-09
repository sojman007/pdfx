public without sharing abstract class PdfxAction implements System.Queueable {
    private boolean asyncMode;
    private boolean killSwitchHasNextTaskOverride;
    private string qJobId;

    private integer taskCounter = 0;
    private integer tasksSlotRemainder = 8;
    private List<PdfxActionTask> tasksList = new List<PdfxActionTask>(); 

    public map<integer,List<PdfxActionTaskResult>> tasksResultsDictionary = new map<integer,List<PdfxActionTaskResult>>();
    
    
    protected void addTask(PdfxActionTask task){
        if(tasksSlotRemainder > 0){
            integer key = tasksResultsDictionary.size();
            task.setKey(key);
            tasksList.add(task);
            tasksResultsDictionary.put(key, new List<PdfxActionTaskResult>());
            tasksSlotRemainder -= 1;
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
        currentTask.execute();
        
        if(currentTask.killOnFail()){
            killSwitch();
        }
        
        if (hasNextTask()) {
            setNextTask();
            
            if (asyncMode) {
                // Re-enqueue the job for the next task in asynchronous mode
                System.enqueueJob(this);
            } else {
                // Continue execution in synchronous mode
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