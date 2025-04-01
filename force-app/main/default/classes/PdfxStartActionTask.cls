public with sharing class PdfxStartActionTask extends PdfxActionTask {
    
    private string toolName;

    public PdfxStartActionTask() {

    }

    public void setToolName(string toolName){
        this.toolName = toolName;
    }


    public override PdfActionTaskResult execute(){
        // make callout to server.


        return null;

    }
}