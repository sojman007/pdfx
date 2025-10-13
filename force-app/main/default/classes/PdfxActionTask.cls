public without sharing abstract class PdfxActionTask {
    // base class for action tasks : start , upload , process , download , query
    protected PdfxApiCredentialsProvider credentialsProvider = PdfxApiCredentialsProvider.getInstance();
    protected string toolName;
    protected integer key;
    protected boolean passed;
    protected boolean killQueueIfFailed; // reserved for future builds.
    protected map<String , PdfxActionTaskResult> tasksResultsDict;

    protected PdfxFinalizerTask taskFinalizer; // perform any finalizing tasks for this current action 

    public PdfxFinalizerTask getFinalizer(){
        return this.taskFinalizer;
    }
    
    public virtual boolean passed(){
        return this.passed;
    }

    public void setKey(integer k){
        key = k;
    }

    public integer getKey(){
        return this.key;
    }

    public virtual boolean hasFinalizer(){
        return this.taskFinalizer != null;
    }
    public virtual void setKillSwitchOnFail(boolean killSwitch){
        this.killQueueIfFailed = killSwitch;
    }

    public boolean killOnFail(){
        return this.killQueueIfFailed;
    }

    public abstract string endPoint();
    public abstract void execute();
    

    
    /**
     * @description : sets a reference to the task action result dictionary. This is CRITICAL because we want to have access to mutations
     * made on this dictionary from other tasks (either sync or async);
     */
    public void setTaskResultsRef(map<String , PdfxActionTaskResult> res){
        this.tasksResultsDict = res;
    }

    /**
     * @description : public facing api method to allow client code extract results from this particular task based on the name of the result
     * the assumption is that the calling code knows the name of the result it needs.
     */
    public PdfxActionTaskResult getTaskResultByKey(string name){
        return tasksResultsDict.get(name);
    }

    public Boolean hasResultKey(string key){
        return tasksResultsDict.containsKey(key);
    }
    
    protected void addResult(string name , Object value, boolean overwriteIfExists){
        if(!tasksResultsDict.containsKey(name) || (tasksResultsDict.containsKey(name) && overwriteIfExists == true)){

            PdfxActionTaskResult tresult = new PdfxActionTaskResult();
            tresult.name = name;
            tresult.value = value;
            tasksResultsDict.put(name, tResult);
        }else{

            throw new PdfxActionTask.TaskException('Result with name '+ name + ' already exists in the task result dictionary');
        }
    }
    
    public class TaskException extends Exception {}
}