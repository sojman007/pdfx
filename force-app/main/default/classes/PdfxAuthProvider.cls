public without sharing class PdfxAuthProvider {
    
    private static final PdfxApiCredentialsProvider CREDS_PROVIDER = PdfxApiCredentialsProvider.getInstance();

    public static string getToken(){
        PdfxAuthProvider.TokenInfo lastToken = getLastTokenInfoFromCache();
        string  token = (!lastToken.isValid() || tokenIsExpired(lastToken.expiry)) ? requestNewToken() : lastToken.token;
        return token;
    }

    private static string requestNewToken(){
        Datetime tokenRequestTime = Datetime.now();
        string endPoint = CREDS_PROVIDER.getBaseUrl() + '/auth';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        string token ='';
        request.setBody(JSON.serialize(new Map<String, Object>{
            'public_key' =>CREDS_PROVIDER.getPublicAPiKey()}));

        HttpResponse response = new Http().send(request);
        if(response.getStatusCode() == 200){
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            token = responseMap.get('token');
            saveTokenToCache(token, tokenRequestTime.addHours(2));
        }else{
            System.debug(response.getStatusCode());
            System.debug(response.getBody());
            throw new TokenRetrievalException('An error occured while trying To authorize into the resource server');
        }
        return token;
    }

    private static boolean tokenIsExpired(Datetime expiryTime){
        return Datetime.now() > expiryTime;
    }

    private static void saveTokenToCache(string token, Datetime expiryTime){
        PdfxAuthProvider.TokenInfo tokenInfo = new PdfxAuthProvider.TokenInfo();
        tokenInfo.token = token;
        tokenInfo.expiry = expiryTime;
        Cache.OrgPartition partition = Cache.Org.getPartition('local.PdfxAuth');
        partition.put('pdfxtoken', JSON.serialize(partition,true));
    }

    private static PdfxAuthProvider.TokenInfo getLastTokenInfoFromCache(){
        Cache.OrgPartition partition = Cache.Org.getPartition('local.PdfxAuth');
        string tokenInfoString = (String)partition.get('pdfxtoken') ?? '';
        if(String.isNotEmpty(tokenInfoString)){
            return new PdfxAuthProvider.TokenInfo (tokenInfoString);
        }
        return new PdfxAuthProvider.TokenInfo();
    }   

    


    public class TokenInfo{
        public string token;
        public Datetime expiry;
        
        private boolean isValid;

        public TokenInfo(){
            isValid = false;
        }

        public TokenInfo(string serializedTokenInfo){
            TokenInfo tempInfo = (TokenInfo) JSON.deserialize(serializedTokenInfo, TokenInfo.class);
            this.token = tempInfo.token;
            this.expiry = tempInfo.expiry;
            isValid = true;
        }

        public boolean isValid(){
            return this.isValid;
        }
    }


}