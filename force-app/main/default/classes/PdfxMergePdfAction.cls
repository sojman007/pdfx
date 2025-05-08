public without sharing class PdfxMergePdfAction extends PdfxAction {
    private List<Blob> filesToMerge;
    
    public PdfxMergePdfAction(List<Blob> filesToMerge){
        this.filesToMerge = filesToMerge;
        this.addTask(new PdfxStartActionTask());
        for(Blob b : this.filesToMerge){
            this.addTask(new PdfxUploadActionTask(b));
        }
    }

}

