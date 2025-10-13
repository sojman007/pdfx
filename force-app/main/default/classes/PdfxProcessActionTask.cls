public without sharing class PdfxProcessActionTask extends PdfxActionTask {
    private boolean runAsAsync;
    private string taskId;
    private string serverUrl;
    private string taskName;
    private  List<String> uploadedFiles;

    public PdfxProcessActionTask(string taskName){
        this.taskName = taskName;
    }

    public override string endPoint(){
        return 'https://'+serverUrl + '/v1/process';
    }

    public override void execute(){
        // extract server url and task id from results cache.
        System.debug('Executing Process Action');

        this.serverUrl = (String)getTaskResultByKey('server').value;
        this.taskId = (String)getTaskResultByKey('task_id').value;
        uploadedFiles = (List<String>)getTaskResultByKey('uploaded_filenames').value;


        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint());
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setBody(getBody());
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + PdfxAuthProvider.getToken());

        HttpResponse httpRes = new Http().send(request);

        if(httpRes.getStatusCode() == 200){
            this.passed = true;
            System.debug(httpRes.getBody());
            
        }else{
            this.passed = false;
        }
    }

    private string getBody(){
        map<string,Object> body = new map<string,Object>{
            'tool' => this.taskName,
            'task' => this.taskId,
            'files' => getFiles()
        };
        System.debug(JSON.serializePretty(body));
        return JSON.serialize(body);
    }

    private List<UploadedFileWrapper> getFiles(){
        List<UploadedFileWrapper> fileMap = new List<UploadedFileWrapper>();
        for(String uploadedFile : this.uploadedFiles){
            fileMap.add(new UploadedFileWrapper(uploadedFile, uploadedFile.abbreviate(10) + '.pdf'));
        }
        return fileMap;
    }

    public class UploadedFileWrapper{
        public string server_filename;
        public string filename;

        public UploadedFileWrapper(string ser, string file){
            server_filename = ser;
            filename = file;
        }
    }
}