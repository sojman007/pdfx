public without sharing class PdfxTaskCacheManager {
    private Cache.OrgPartition pdfxPartition = Cache.Org.getPartition('PdfxTasksQueue');
    
    public Object getValue(string queueId, string key){
        map<String,Object> queueState = (map<String,Object>)pdfxPartition.get(queueId);
        return null;
    }

}