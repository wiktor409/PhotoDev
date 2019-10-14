global class ImageService {
  
    public Map<String, Image> convertResponse(List<ImageWrapper> response) {
        Map<String, Image> itemToInsert = new Map<String, Image>();
        
        for(ImageWrapper item: response) {
            Image img = new Image();
            
            img.Name = item.title;
            img.ExternalId__c = item.id;
        	img.Url = item.url;
            img.Album_Id__c = item.albumId;
            itemToInsert.put(img.ExternalId__c, img);
        } 
        
        return itemToInsert;
    }
    
    public void syncData(List<ImageWrapper> imagesInApi) {
        List<Image> imagesToDelete = new List<Image>();
        List<Image> imagesToUpsert = new List<Image>();
        
        List<Image> imagesInSf = [SELECT Id, ExternalId__c FROM Image];
        
        Map<String, Image> convertedResult = convertResponse(imagesInApi);
        
        for(Image item: imagesInSf) {
            if(convertedResult.get(item.ExternalId__c) == null) {
                imagesToDelete.add(item);
            }
        }
        
        
        if(imagesToDelete.size() > 0) {
            try { delete imagesToDelete; } 
            catch(Exception exp) { System.debug(exp); }
        }
        
        try{
            upsert convertedResult.values() ExternalId__c;
        } catch(Exception exp) {
            System.debug(exp);
        }
    }
    
    public List<ImageWrapper> getImagesFromResources() {
        StaticResource file = [SELECT id, body FROM StaticResource WHERE Name = 'jsonPhotos'];
        String jsonBody = file.body.toString();
        
        List<ImageWrapper> result = (List<ImageWrapper>)JSON.deserialize(jsonBody, List<ImageWrapper>.class);
                
        return result;
    }
    
    public HttpResponse apiCallout(String url, String method) {
        HttpResponse response = null;
		/*Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(jsonUrl);
        request.setMethod(method);
        HttpResponse response = http.send(request);
        try {
            List<ImageWrapper> results = (List<ImageWrapper>) JSON.deserializeUntyped(response.getBody());
        } catch(Exception exp) {
            System.debug(response.getBody());
        }*/
        
        return response;
    }
    
    //irl I would use rest here but for this app I will just get json from static resource
    public void updateDatabase() {
        //example for GET in REST
        String jsonUrl = 'https://jsonplaceholder.typicode.com/photos';
		HttpResponse response = apiCallout(jsonUrl, 'GET');
        
        //for now we will use static resource
        List<ImageWrapper> result = getImagesFromResources();
        
        //sync
        syncData(result);
    }
}