public with sharing class SendMassEmailCtrl{

    public List<SelectOption> emailTemplateOptions {get;set;}
    public String emailTemplate {get;set;}
    public Set<Id> contIdSet;
    
    public SendMassEmailCtrl() { 
        String conId = ApexPages.currentPage().getParameters().get('id');  
        System.debug('-----------conId ---------'+conId );
        contIdSet = new Set<Id>();
        
        if(conId != null && conId != ''){
            for(String str : conId.split(',')) {  
              contIdSet.add(str);  
            }
        }
        System.debug('----contIdSet---------'+contIdSet.size()+'-----ContIdSet-----'+contIdSet); 
    }
    
    
    public void actionOnLoad(){
        emailTemplate = '';
        emailTemplateOptions = new List<SelectOption>();
        for(EmailTemplate et : [Select Id, Name from EmailTemplate]) {
            emailTemplateOptions.add(new SelectOption(et.id,et.name));    
        }
    }
    
    public void sendEmailToContacts(){
        System.debug('-------------emailTemplate-------'+emailTemplate);
        
        if(!contIdSet.isEmpty()){
            
            List<Contact> contList = [Select Id, Email, Name from Contact WHERE Id IN: contIdSet];
        
            Messaging.SingleEmailMessage[] theEmails  = new Messaging.SingleEmailMessage[]{};
            String[] toAddresses = new String[] {};
            
            for(Contact contObj : contList){
                toAddresses = new String[] {};
                if(contObj.Email != null || contObj.Email != ''){
                    toAddresses.add(contObj.Email);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(toAddresses);
                    mail.setTargetObjectId(contObj.Id);
                    mail.setSaveAsActivity(true);
                    mail.setTemplateId(emailTemplate);
                    
                    theEmails.add(mail);
                }
            }
            
            Messaging.Email[] allMails = new Messaging.Email[]{};
            
            if(!theEmails.isEmpty()){
                for(Integer i = 0; i < theEmails.size(); i++){
                    allMails.add(theEmails.get(i));
                }
            }
            
            try{
                Messaging.SendEmailResult[] results = Messaging.sendEmail( allMails );
                System.debug('---------results--------------'+results);
            }catch(Exception ex){
                System.debug('---------Exception--------------'+ex);
            }
            
        }
          
        
    }
}