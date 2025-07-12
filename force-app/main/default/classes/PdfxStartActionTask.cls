@suppressWarnings('pmd')
public without sharing class PdfxStartActionTask extends PdfxActionTask {
    
    private final string urlBase = PdfxApiCredentialsProvider.getInstance().getBaseUrl();



    public PdfxStartActionTask(string tool) {
        this.setToolName(tool);
    }

    public void setToolName(string toolName){
        this.toolName = toolName;
    }

   
    public override string endPoint(){
        return '/start/'+toolName;
    }

    public override void execute(){
        // make callout to server.
        HttpRequest req = new HttpRequest();
        req.setEndpoint(urlBase+endPoint());
        req.setHeader('Authorization', 'Bearer '+PdfxAuthProvider.getToken());
        req.setMethod('POST');
        req.setTimeout(10000);

        HttpResponse res = new Http().send(req);
        if(res.getStatusCode() == 200){
            PdfxStartActionTask.PdfxCalloutResponse resp = (PdfxStartActionTask.PdfxCalloutResponse)JSON.deserialize(res.getBody(), PdfxStartActionTask.PdfxCalloutResponse.class);
            addResult('server', resp.server);
            addResult('task_id', resp.task);

            // save server record with url -> trigger
        }
    }


    public class PdfxCalloutResponse{
        public string server{get;set;}
        public string task {get;set;}
        //public integer remaining_credits {get;set;}
    }
}
