public without sharing class PdfxUploadActionTask extends PdfxActionTask {
    
    private List<Blob> fileData;
    
    public PdfxUploadActionTask() {

    }
    public override boolean passed(){
        return true;
    }
    public override string endPoint(){
        return '/upload';
    }

    public override PdfxActionTaskResult execute(){
        // make callout to server.


        return null;

    }
}