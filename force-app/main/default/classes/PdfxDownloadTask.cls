public with sharing class PdfxDownloadTask extends PdfxActionTask {
    
    private string serverUrl;
    private string taskId;
    
    public override string endPoint(){
        return 'https://'+serverUrl + '/v1/download/'+ this.taskId;
    }

    public override void execute(){
        // extract server url and task id from results cache.
        System.debug('Executing Process Action');

        this.serverUrl = (String)getTaskResultByKey('server').value;
        this.taskId = (String)getTaskResultByKey('task_id').value;
        

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint());
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + PdfxAuthProvider.getToken());
        request.setTimeout(120000);
        HttpResponse httpRes = new Http().send(request);

        if(httpRes.getStatusCode() == 200){
            this.passed = true;
            Blob response = httpRes.getBodyAsBlob();
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Pdfx_File_Processed ' + Datetime.now().toString();
            cv.VersionData = response;

            insert cv;
        }else{
            this.passed = false;
        }
    }
}