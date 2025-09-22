@suppressWarnings('pmd')
public without sharing class PdfxStartActionTask extends PdfxActionTask {
    
    private final string urlBase = PdfxApiCredentialsProvider.getInstance().getBaseUrl();
    



    public PdfxStartActionTask(string tool) {
        this.setToolName(tool);
        this.taskFinalizer = new PdfxStartActionFinalizer();
    }

    public void setToolName(string toolName){
        this.toolName = toolName;
    }

   
    public override string endPoint(){
        return '/v1/start/'+toolName;
    }

    public override void execute(){
        System.debug('Executing Start Action Task');
        System.debug(PdfxAuthProvider.getToken());
        // make callout to server.
        HttpRequest req = new HttpRequest();
        req.setEndpoint(urlBase+endPoint());
        req.setHeader('Authorization', 'Bearer '+ PdfxAuthProvider.getToken());
        req.setMethod('GET');
        req.setTimeout(10000);

        HttpResponse res = new Http().send(req);
        if(res.getStatusCode() == 200){
            System.debug('task passed ' + res.getBody());
            this.passed = true;
            PdfxStartActionTask.PdfxCalloutResponse resp = (PdfxStartActionTask.PdfxCalloutResponse)JSON.deserialize(res.getBody(), PdfxStartActionTask.PdfxCalloutResponse.class);
            addResult('server', resp.server);
            addResult('task_id', resp.task);
            this.taskFinalizer.init(new map<string,Object>{'serverUrl' => resp.server});
            
        }else{
            System.debug(' The Start task failed, ' + res.getStatusCode() + ' /n' + res.getBody());
            this.killQueueIfFailed = true;
        }
    }


    public class PdfxCalloutResponse{
        public string server{get;set;}
        public string task {get;set;}
        // public integer remaining_credits {get;set;} this is still useful
    }
}
