public without sharing class PdfxProcessActionTask extends PdfxActionTask {
    private boolean runAsAsync;
    private string taskId;
    private string serverUrl;

    public PdfxProcessActionTask(string taskId , string serverUrl){
        this.taskId = taskId;
        this.serverUrl = serverUrl;
    }

    public override string endPoint(){
        return serverUrl + '/v1/process';
    }

    public override void execute(){

    }
}