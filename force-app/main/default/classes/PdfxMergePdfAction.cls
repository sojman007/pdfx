public without sharing class PdfxMergePdfAction extends PdfxAction {
    private List<Blob> filesToMerge;
    
    public PdfxMergePdfAction(List<Blob> filesToMerge){
        this.filesToMerge = filesToMerge;
        PdfxStartActionTask start = new PdfxStartActionTask('merge');
        start.setKillSwitchOnFail(true);
        this.addTask(start);
        // for(Blob b : this.filesToMerge){
        //     this.addTask(new PdfxUploadActionTask(b));
        // }
        // add process and download task 
    }

}

