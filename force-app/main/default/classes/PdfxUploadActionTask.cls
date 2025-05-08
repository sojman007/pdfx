public without sharing class PdfxUploadActionTask extends PdfxActionTask {
    
    private Blob fileToUpload;
    
    
    public PdfxUploadActionTask(Blob fileToUpload) {
        this.fileToUpload = fileToUpload;
    }
    public override boolean passed(){
        return true;
    }
    public override string endPoint(){
        return '/upload';
    }

    public override PdfxActionTaskResult execute(){
        // create a multipart http form request and upload the file to the system
        // make callout to server.


        return null;

    }
}