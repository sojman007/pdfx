public without sharing abstract class PdfxActionTask {
    // base class for action tasks : start , upload , process , download , query
    protected PdfxApiCredentialsProvider credentialsProvider = PdfxApiCredentialsProvider.getInstance();
    protected string toolName;
    protected integer key;
    protected boolean passed;
    protected boolean killQueueIfFailed; // reserved for future builds.
    protected map<string, PdfxActionTaskResult> tasksResultsDict = new Map<String,PdfxActionTaskResult>();
    
    public virtual boolean passed(){
        return this.passed;
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
    public void setTaskResultsRef(map<integer , List<PdfxActionTaskResult>> res){
        this.tasksResultsDict = res;
    }

    /**
     * @description : public facing api method to allow client code extract results from this particular task based on the name of the result
     * the assumption is that the calling code knows the name of the result it needs.
     */
    public PdfxActionTaskResult getTaskResultByKey(string name){
        PdfxActionTaskResult result;
        for(PdfxActionTaskResult tresult : taskResultList){
            if(tresult.name.equalsIgnoreCase(name)){
                result = tresult;
            }
        }

        return result;
    }
    
    protected void addResult(string name , Object value){
        if(!tasksResultsDict.containsKey(name)){

            PdfxActionTaskResult tresult = new PdfxActionTaskResult();
            tresult.name = name;
            tresult.value = value;
            resultList.add(tresult);
            tasksResultsDict.put(name, tResult);
        }else{
            throw new PdfxActionTask.TaskException('Result with name '+name+' already exists in the task result dictionary');
        }
    }
    public boolean hasResults(){
        return this.taskResultList.size() > 0;
    }

    public class TaskException extends Exception {}
}