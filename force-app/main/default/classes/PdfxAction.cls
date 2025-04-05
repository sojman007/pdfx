public without sharing abstract class PdfxAction {


    private List<PdfxActionTask> tasksList = new List<PdfxActionTask>(); // potentially convert this to a task queue that can
    // run async or synchronously
    private integer taskCounter = 0;
    
    
    private PdfxActionTaskResult taskResult;
    

    protected void addTask(PdfxActionTask task){
        tasksList.add(task);
    }

    public virtual PdfxActionTask getNextTask(){
        return tasksList.get(taskCounter);
    }
    public virtual boolean hasNextTask(){
        return tasksList.size() > (taskCounter + 1);
    }
    public virtual void setNextTask(){
        if(hasNextTask()){
            taskCounter += 1;
        }
    }
    public abstract PdfxActionTask extractDataFromPreviousTaskResult(PdfxActionTask current, PdfxActionTaskResult previousResult);
    
    
    public abstract PdfxActionTaskResult getTaskResult();

    public virtual void setTaskResult(PdfxActionTaskResult result){
        taskResult = result; // find out a way to do a true copy instead of referencing from memory
    }

    public virtual void execute(){
        PdfxActionTask currentTask = getNextTask();
        currentTask = extractDataFromPreviousTaskResult(currentTask, getTaskResult());
        PdfxActionTaskResult taskResult = currentTask.execute();
        // the current task needs to somehow  be able to know if there is a result 
        // from a previous task (if any) and, should be able to 
        // extract the data from the result that it needs in different ways.
        if(hasNextTask()){
            setNextTask();
            this.execute();
        }

    }
    
}