public without sharing class PdfxUploadActionTask extends PdfxActionTask {
    
    private Blob fileToUpload;
    private string serverUrl; // to be obtained from the results of the start procedure.
    
    
    public PdfxUploadActionTask(Blob fileToUpload) {
        this.fileToUpload = fileToUpload;
    }
    public override boolean passed(){
        return true;
    }
    public override string endPoint(){
        return '/v1/upload';
    }

    public override void execute(){
        // create a multipart http form request and upload the file to the system
        // make callout to server.


        return null;

    }
}