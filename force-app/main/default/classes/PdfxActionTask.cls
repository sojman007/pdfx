public without sharing abstract class PdfxActionTask {
    // base class for action tasks : start , upload , process , download , 
    protected PdfxApiCredentialsProvider credentialsProvider = PdfxApiCredentialsProvider.getInstance();
    protected PdfxActionTask resultSource;
    protected string toolName;
    
    public abstract boolean passed();
    public abstract string endPoint();
    public abstract PdfxActionTaskResult execute();

    
}