// Project: Assets Phase 1
// Created By: Eric Smith
// Class: Asset_Wrapper
// Description: Wrapper class for the Asset Object used by OLI_UpdateA.cls & others
// Classes Utilized: OLI_SelectA_ap.cls, Asset_Wrapper.cls
// VisualForce Pages: OLI_SelectA_vf.vfp
// Date: 4/7/2017

/**
 ** Class: Asset_Wrapper
**/
public with sharing class Asset_Wrapper {
    
    //Variables
    private Boolean isoAssetSelected = false;
    private Asset ASS;
    private String assID;
    
    /**
    ** Constructor
    **/ 
    public Asset_Wrapper(Asset ass, String id) {
        this.setASS(ass);   
        this.assID=id;
    }
    
    //Getters
    public Asset getASS(){
        return this.ASS;
    }           
    
    public Boolean getIsoAssetSelected(){
        return this.isoAssetSelected;
    }
    
    public String getAssID() {
        return this.assID;
    }
    
    //Setters
    public void setIsoAssetSelected(Boolean value){
        this.isoAssetSelected = value;
    }
    
    private void setASS(Asset assp){
        this.ASS=assp;
    }
}