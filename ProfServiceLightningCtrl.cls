public class ProfServiceLightningCtrl {

// logic for data fetch and display Start
/* This method retrive records from "Professional Service" object and call on Visual Force Page to display */   
    @AuraEnabled
    public static list<Prof_Services__c> fetchRecOld(String selectedSeviceType){ // older version which we were using earlier

        	list<Prof_Services__c> profServiceRecord=[select id, name,Service_Type__c,Buy_Units__c,Margin__c,Implemenation_Type__c from Prof_Services__c where Service_Type__c=:selectedSeviceType  ]; 
	        return profServiceRecord;
    }

    @AuraEnabled
    public static list<WrapperProfservice> fetchRec(String selectedSeviceType){ // older version which we were using earlier
	        list<WrapperProfservice> wrappedProfSerRecord = new list<WrapperProfservice>();   
        	list<Prof_Services__c> profServiceRecord=[select id, name,Service_Type__c,Buy_Units__c,Margin__c,Implemenation_Type__c from Prof_Services__c where Service_Type__c=:selectedSeviceType  ]; 

            for (Prof_Services__c profService: profServiceRecord){ 
                   wrappedProfSerRecord.add(new WrapperProfservice(profService, profService.Buy_Units__c,profService.Margin__c));                  
            }

        
        return wrappedProfSerRecord;
    }

    
    @AuraEnabled
    public  static string saveProfessionalServices(string selectedSeviceType, string idopp, Integer projectManagement, string profSerStandardList, string profSerCustomList){

        List<WrapperProfservice> profStandardList = new List<WrapperProfservice>();
        List<WrapperProfservice> profCustomList = new List<WrapperProfservice>();

        if(idopp.substring(2,3) == '1')
        {    
            Opportunity opportunityRecord = new Opportunity();
            opportunityRecord.Name = selectedSeviceType;
            opportunityRecord.Field_for_Opportunity_Name__c = selectedSeviceType +' Service';
            opportunityRecord.AccountId = idopp;
            opportunityRecord.CloseDate = date.today() + 40;
            opportunityRecord.StageName = 'prospecting';
            if(opportunityRecord != null)
            {
                insert opportunityRecord;
                idopp = opportunityRecord.Id;
            }
        }
 
        if(!string.isBlank(profSerStandardList)){
            
            profStandardList = (List<WrapperProfservice>)System.JSON.deserialize(profSerStandardList,List<WrapperProfservice>.class);
            system.debug('Debug for Dsiplaying all the records: lstPositionRecords'+profStandardList); 
        }

        if(!string.isBlank(profSerCustomList)){
            
			profCustomList = (List<WrapperProfservice>)System.JSON.deserialize(profSerCustomList,List<WrapperProfservice>.class);
            system.debug('Debug for Dsiplaying all the records: lstPositionRecords'+profCustomList); 
        }
        
        
        
        // Selected Professional Service object variable 
            Selected_Professional_Service__c SelectProRecord;   
      // Selected Implementation  object variable
            Selected_Implementation__c SelectImpRecord;                                        
            List<Selected_Implementation__c> insertSelectedImpelementation = new List<Selected_Implementation__c>();
            List<Selected_Implementation__c> insertSelectedCusImpelementations = new List<Selected_Implementation__c>();            
         
      //fetching Opportunity id from URL
         SelectProRecord =new Selected_Professional_Service__c(Name=selectedSeviceType,Opportunity_Selected__c=idopp,Project_Management__c = Integer.valueOf(projectManagement)); 
       
            try{  
                insert SelectProRecord;
            }
            catch(Exception ex){
                system.debug('Error'+ex.getMessage());
            }
              
//        ProfServiceLightningCtrl profServiceObject = new ProfServiceLightningCtrl();
//        profServiceObject.insertInSF(SelectProRecord.id,profSerStandardList,profSerCustomList);
            
        system.debug('Selected pro id'+SelectProRecord.id);
        
      // Creating selected professional service Record
       // SelectProRecord =new Selected_Professional_Service__c(  Name=selectedSeviceType,Opportunity_Selected__c=idopp );  
        
               
        system.debug('Satndard List'+profSerStandardList);
        system.debug('Custom List'+profSerCustomList);
           
        if(!string.isBlank(profSerCustomList)) {
            for(WrapperProfservice customList:profCustomList ) {
                //creating new record for Selected Implementation object
                if(customList.units > 0){
                    Selected_Implementation__c newSelectedImplementationRecordStand =  new Selected_Implementation__c();
                        newSelectedImplementationRecordStand.Name =  customList.con.Name;
                        newSelectedImplementationRecordStand.Selected_Proffesional_Service__c = SelectProRecord.id;
                        newSelectedImplementationRecordStand.Unit__c = customList.units;
                        newSelectedImplementationRecordStand.Buy_Unit__c=customList.buyUnits; //con.Buy_Units__c
                        newSelectedImplementationRecordStand.Implementation_Types__c='custom';
                        newSelectedImplementationRecordStand.Margin__c=customList.productMargin;//con.Margin__c
    
                    insertSelectedImpelementation .add(newSelectedImplementationRecordStand);                    
                }
        }
        
        try{
            if(insertSelectedImpelementation.size() > 0){
	        	insert insertSelectedImpelementation ;                
            }
        }
        catch(Exception ex){
			system.debug('Error in inserting custom '+ex.getMessage());            
        }
        }
        
        if(!string.isBlank(profSerStandardList)) {
            for(WrapperProfservice standardList:profStandardList ) {
                
                 if(standardList.units > 0){
                Selected_Implementation__c newSelectedImplementationRecordCustom =  new Selected_Implementation__c();
                newSelectedImplementationRecordCustom.Name =  standardList.con.Name;
                newSelectedImplementationRecordCustom.Selected_Proffesional_Service__c = SelectProRecord.id;
                newSelectedImplementationRecordCustom.Unit__c = standardList.units;
                newSelectedImplementationRecordCustom.Buy_Unit__c= standardList.buyUnits; //con.Buy_Units__c
                newSelectedImplementationRecordCustom.Implementation_Types__c='standard'; 
                newSelectedImplementationRecordCustom.Margin__c= standardList.productMargin;//con.Margin__c
                
                insertSelectedCusImpelementations.add(newSelectedImplementationRecordCustom);
            }
          }
            try{
                insert insertSelectedCusImpelementations;
            }
            catch(Exception ex){
                system.debug('Error in inserting standard '+ex.getMessage());            
            }            
        }
        return idopp;              
}    
    
  /*  public void insertInSF(string selectedProId, list<WrapperProfservice> profSerStandardList, list<WrapperProfservice> profSerCustomList){

        // Selected Implementation  object variable
            Selected_Implementation__c SelectImpRecord;                                        
            List<Selected_Implementation__c> insertSelectedImpelementation = new List<Selected_Implementation__c>();
            List<Selected_Implementation__c> insertSelectedCusImpelementations = new List<Selected_Implementation__c>();            

        system.debug('Selected pro id'+selectedProId);
        
      // Creating selected professional service Record
       // SelectProRecord =new Selected_Professional_Service__c(  Name=selectedSeviceType,Opportunity_Selected__c=idopp );  
        
               
        system.debug('Satndard List'+profSerStandardList);
        system.debug('Custom List'+profSerCustomList);
           
        system.debug('above the loop');

        for(WrapperProfservice cusList : profSerCustomList ) {
            
            system.debug('Name'+cusList.con.Name);
            system.debug('units'+cusList.units);
        }
        
        system.debug('below loop');
        if(profSerCustomList!=null) {
            system.debug('in custom list');
            for(ProfServiceLightningCtrl.WrapperProfservice customList:profSerCustomList ) {

                system.debug('Name'+customList.con.Name);
                system.debug('units'+customList.units);

                //creating new record for Selected Implementation object
                Selected_Implementation__c newSelectedImplementationRecordStand =  new Selected_Implementation__c();
                    newSelectedImplementationRecordStand.Name =  customList.con.Name;
                    newSelectedImplementationRecordStand.Selected_Proffesional_Service__c = selectedProId;
                    newSelectedImplementationRecordStand.Unit__c = customList.units;
                    newSelectedImplementationRecordStand.Buy_Unit__c=customList.con.Buy_Units__c; 
                    newSelectedImplementationRecordStand.Implementation_Types__c='custom';
                    newSelectedImplementationRecordStand.Margin__c=customList.con.Margin__c;

                insertSelectedImpelementation .add(newSelectedImplementationRecordStand);
        }
        
        try{
        insert insertSelectedImpelementation ;
        }
        catch(Exception ex){
			system.debug('Error in inserting custom '+ex.getMessage());            
        }
        }
        
        if(profSerStandardList!=null) {
            system.debug('in standard list');
            for(ProfServiceLightningCtrl.WrapperProfservice standardList:profSerStandardList ) {
                system.debug('Name'+standardList.con.Name);
                system.debug('units'+standardList.units);

                Selected_Implementation__c newSelectedImplementationRecordCustom =  new Selected_Implementation__c();
                newSelectedImplementationRecordCustom.Name =  standardList.con.Name;
                newSelectedImplementationRecordCustom.Selected_Proffesional_Service__c = selectedProId;
                newSelectedImplementationRecordCustom.Unit__c = standardList.units;
                newSelectedImplementationRecordCustom.Buy_Unit__c= standardList.con.Buy_Units__c; 
                newSelectedImplementationRecordCustom.Implementation_Types__c='standard'; 
                newSelectedImplementationRecordCustom.Margin__c= standardList.con.Margin__c;
                
                insertSelectedCusImpelementations.add(newSelectedImplementationRecordCustom);
            }
            
            try{
                insert insertSelectedCusImpelementations;
            }
            catch(Exception ex){
                system.debug('Error in inserting standard '+ex.getMessage());            
            }            
        }
        
    }*/
    
// Professinal service wrapper class 
   public class WrapperProfservice {
       @AuraEnabled
       public Prof_Services__c con;
       @AuraEnabled
       public integer units;
       @AuraEnabled
       public Decimal buyUnits;
       @AuraEnabled
       public Decimal productMargin;

       public WrapperProfservice(Prof_Services__c c, Decimal bUnits, Decimal pMargin) {
           con = c;
           units = 1;
           buyUnits = bUnits;               
           productMargin = pMargin;
       }
    }    

}