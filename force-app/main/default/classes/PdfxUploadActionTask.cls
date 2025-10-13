public without sharing class PdfxUploadActionTask extends PdfxActionTask {
    
    private string taskId;
    private Blob fileToUpload;
    private string serverUrl; // to be obtained from the results of the start procedure.
    
    
    public PdfxUploadActionTask(Blob fileToUpload) {
        this.fileToUpload = fileToUpload;
    }
    public PdfxUploadActionTask(Blob fileToUpload, string task, string serverUrl) {
        this.fileToUpload = fileToUpload;
        taskId = task;
        this.serverUrl = serverUrl;
    }
    
    public override string endPoint(){
        return '/v1/upload';
    }

    public override void execute() {
        taskId = getTaskResultByKey('task_id').value.toString();
        serverUrl = getTaskResultByKey('server').value.toString();

        System.debug('Executing Upload Action');
        string token = PdfxAuthProvider.getToken();
        System.debug(token);
        // Create a multipart HTTP form request and upload the file to the system
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://'+serverUrl + endPoint());
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer '+token );
        req.setTimeout(30000);
        req.setHeader('Content-Type', PdfxHttpMultipartFormBuilder.GetContentType());

        
        string form64 = '';
        form64 += PdfxHttpMultipartFormBuilder.WriteBoundary();
        form64 += PdfxHttpMultipartFormBuilder.WriteBodyParameter('task', this.taskId);
        form64 += PdfxHttpMultipartFormBuilder.WriteBoundary();
        form64 += PdfxHttpMultipartFormBuilder.WriteBlobBodyParameter('file', EncodingUtil.base64Encode(this.fileToUpload), this.taskId+'.pdf');
        Blob formBlob = EncodingUtil.base64Decode(form64);
        string contentLength = string.valueOf(formBlob.size());
        req.setBodyAsBlob(formBlob);

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            System.debug('upload file response ' + res.getStatusCode());
            if (res.getStatusCode() == 200) {
                this.passed = true;
                Map<String,Object> convertedResponse = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                string uploadedFileName = (String)convertedResponse.get('server_filename');
                if(!hasResultKey('uploaded_filenames')){
                    addResult('uploaded_filenames', new List<String>(), false);
                }
                PdfxActionTaskResult fileNamesResult =  getTaskResultByKey('uploaded_filenames');
                List<String> existingUploadedFiles = (List<String>)fileNamesResult.value;
                existingUploadedFiles.add(uploadedFileName);
                addResult('uploaded_filednames', existingUploadedFiles, true);
                
            }else{
                this.passed = false;
                throw new CalloutException('Failed to upload file. Status: ' + res.getStatus() + '\n' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Error during file upload: ' + e.getMessage());
            throw e;
        }
    }
}