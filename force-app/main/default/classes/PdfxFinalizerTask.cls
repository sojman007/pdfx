public abstract class PdfxFinalizerTask extends PdfxActionTask {
    public abstract void init(map<string,Object> params);
    public override string endPoint(){
        throw new UnsupportedOperationException('`endPoint()` cannot be called on a finalizer task');
    }
}