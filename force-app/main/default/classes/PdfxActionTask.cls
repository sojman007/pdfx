public without sharing abstract class PdfxActionTask {
    // base class for action tasks : start , upload , process , download , 
    protected PdfxApiCredentialsProvider credentialsProvider = PdfxApiCredentialsProvider.getInstance();
    protected PdfxActionTask resultSource;
    protected string toolName;
    protected List<PdfxActionTaskResult> taskResultList;
    
    public abstract boolean passed();
    public abstract string endPoint();
    public abstract void execute();


    public PdfxActionTaskResult getTaskResultByName(string name){
        PdfxActionTaskResult result;
        for(PdfxActionTaskResult tresult : taskResultList){
            if(tresult.name.equalsIgnoreCase(name)){
                result = tresult;
            }
        }

        return result;
    }
    
    private void addResult(string name , Object value){
        PdfxActionTaskResult tresult = new PdfxActionTaskResult();
        tresult.name = name;
        tresult.value = value;
        taskResultList.add(tresult);
    }
    public boolean hasResults(){
        return this.taskResultList.size() > 0;
    }

    
}