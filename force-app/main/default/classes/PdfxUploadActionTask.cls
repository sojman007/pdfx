public without sharing class PdfxUploadActionTask extends PdfxActionTask {
    
    private string taskId;
    private Blob fileToUpload;
    private string serverUrl; // to be obtained from the results of the start procedure.
    
    
    public PdfxUploadActionTask(Blob fileToUpload) {
        this.fileToUpload = fileToUpload;
        taskId = getTaskResultByKey('task_id').value.toString();
        serverUrl = getTaskResultByKey('server').value.toString();
    }
    public override boolean passed(){
        return true;
    }
    public override string endPoint(){
        return '/v1/upload';
    }

    public override void execute() {
        // Create a multipart HTTP form request and upload the file to the system
        HttpRequest req = new HttpRequest();
        req.setEndpoint(serverUrl + endPoint());
        req.setMethod('POST');
        
        // Set headers
        string boundary = '----------------------------' + DateTime.now().getTime();
        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);

        // Construct the body
        string body = '--' + boundary + '\r\n' + 'Content-Disposition: form-data;'+ 'task="' + taskId + ''  +'Content-Type: application/pdf\r\n\r\n';
        Blob bodyBlob = Blob.valueOf(body);
        Blob finalBody = Blob.valueOf( EncodingUtil.base64Encode(bodyBlob) + EncodingUtil.base64Encode(fileToUpload) + EncodingUtil.base64Encode(Blob.valueOf('\r\n--' + boundary + '--\r\n')));
        
        
        req.setBodyAsBlob(finalBody);

        // Make the HTTP callout
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            System.debug('upload file response ' + res.getStatusCode());
            if (res.getStatusCode() != 200) {

                throw new CalloutException('Failed to upload file. Status: ' + res.getStatus());
            }
        } catch (Exception e) {
            System.debug('Error during file upload: ' + e.getMessage());
            throw e;
        }
    }
}