public without sharing class PdfxStartActionTask extends PdfxActionTask {
    
    

    public PdfxStartActionTask() {

    }

    public void setToolName(string toolName){
        this.toolName = toolName;
    }

    public override boolean passed(){
        return true;
    }
    public override string endPoint(){
        return '/start';
    }

    public override PdfxActionTaskResult execute(){
        // make callout to server.


        return null;

    }
}
