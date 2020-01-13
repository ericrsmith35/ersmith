// Project: Assets Phase 1
// Created By: Eric Smith
// Class: OLI_Wrapper
// Description: Wrapper class for the OpportunityLineItem Object used by OLI_Update.cls & others
// Classes Utilized: OLI_Select_ap.cls, OLI_SelectB_ap.cls OLI_Wrapper.cls
// VisualForce Pages: OLI_Select_vf.vfp, OLI_SelectB_vf.vfp
// Date: 3/14/2017

/**
 ** Class: OLI_Wrapper
**/
public with sharing class OLI_Wrapper {
    
    //Variables
    public Boolean isoProdSelected = false;
    private OpportunityLineItem OLI;
    private String oliID;
    
    /**
    ** Constructor
    **/ 
    public OLI_Wrapper(OpportunityLineItem oli, String id) {
        this.setOLI(oli);   
        this.oliID=id;
    }
    
    //Getters
    public OpportunityLineItem getOLI(){
        return this.OLI;
    }           
    
    public Boolean getIsoProdSelected(){
        return this.isoProdSelected;
    }
    
    public String getOliID() {
        return this.oliID;
    }
    
    //Setters
    public void setIsoProdSelected(Boolean value){
        this.isoProdSelected = value;
    }
    
    private void setOLI(OpportunityLineItem olip){
        this.OLI=olip;
    }
}