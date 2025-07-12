public without sharing class PdfxStartActionFinalizer implements PdfxFinalizer , Database.AllowsCallouts{
    
    
    private static final string TOOLING_API_ENDPOINT = Url.getOrgDomainUrl().toExternalForm() + '/services/data/v64.0/'+ 'tooling/sobjects/RemoteProxy/';

    private string serverUrl;

    public void setServerUrl(string serverUrl){
        this.serverUrl = serverUrl;
    }

    public System.Finalizer getAsSystemFinalizer(){
        return (System.Finalizer)this;
    }


    public void execute(System.FinalizerContext fct){
        System.debug('Starting Task Finalizer');
        string siteName = 'Pdfx'+UUID.randomUUID().toString().remove('-');
        map<string,Object> payload = new map<string,Object>{
            'FullName'=> siteName,
            'Metadata'=> new map<String,Object>{
                'disableProtocolSecurity'=>false,
                'isActive'=> true,
                'url'=>'https://'+this.serverUrl,
                'description'=>''
            }
            
        };

        List<Pdfx_Server_Connection__c> existingServers = new List<Pdfx_Server_Connection__c>([SELECT Id , Is_Registered_As_Remote_Site__c , Server_Url__c FROM Pdfx_Server_Connection__c WHERE Server_Url__c =: serverUrl WITH SECURITY_ENFORCED LIMIT 1 ]);
        Pdfx_Server_Connection__c existingServer = existingServers?.isEmpty() ? null : existingServers.get(0);
        if(existingServer == null  || existingServer?.Is_Registered_As_Remote_Site__c == false){
            Http httpClient = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(TOOLING_API_ENDPOINT);
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            req.setHeader('Content-Type', 'application/json');
            String payloadSeri = JSON.serialize(payload);
            //System.debug(payloadSeri);
            req.setBody(payloadSeri);

            HttpResponse res = httpClient.send(req);
            integer statusCode = res.getStatusCode();
            if(statusCode < 300 && statusCode >=200){
                System.debug('Remote Site was added for pdfx server successfully');
                Pdfx_Server_Connection__c newConnection = existingServer != null ? existingServer : new Pdfx_Server_Connection__c();
                newConnection.Server_Url__c = serverUrl;
                newConnection.Is_Registered_As_Remote_Site__c = true;
                upsert as System newConnection;
            }else{
                System.debug(' Remote Site not added : ' + res.getBody());
            }
            
            
        }


    }
}