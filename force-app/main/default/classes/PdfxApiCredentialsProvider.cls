public without sharing class PdfxApiCredentialsProvider {
    
    private static PdfxApiCredentialsProvider instance;
    private Pdfx_Api_Settings__c apiCreds; 

    public static PdfxApiCredentialsProvider getInstance(){
        if(instance == null) { instance = new PdfxApiCredentialsProvider();}
        return instance;
    }

    private PdfxApiCredentialsProvider(){
        apiCreds = Pdfx_Api_Settings__c.getOrgDefaults();
    }

    public string getBaseUrl(){
        validate('Base_Url__c');
        return apiCreds.Base_Url__c;
    }

    public string getPublicApiKey(){
        validate('Api_Key__c');
        return apiCreds.Api_Key__c;
    }


    private void validate(string fieldName){
        if(apiCreds == null  || apiCreds?.get(fieldName) == null ){
            throw new PdfxCredentialsException('Pdfx Credentials are not set in Custom Settings.');
        }
    }


    public class PdfxCredentialsException extends Exception{}
}