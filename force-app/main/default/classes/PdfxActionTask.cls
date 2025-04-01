public without sharing abstract class PdfxActionTask {
    // base class for action tasks : start , upload , process , download , 
    protected PdfxApiCredentialsProvider credentialsProvider = PdfxApiCredentialsProvider.getInstance();
    protected PdfxActionTask resultSource;
    
    public abstract boolean passed();
    public abstract boolean failed();
    public abstract string endPoint();
    public abstract PdfActionTaskResult execute();

    
}