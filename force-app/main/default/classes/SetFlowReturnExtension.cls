/* 
SetFlowReturnExtension

Developed for GWI - Eric Smith - August 2017

Thanks to:
    Andrew Boettcher    https://techman97.wordpress.com/2013/10/18/flow-and-finishlocation/
    Jenny Bennett       http://www.inthenimbus.com/index.php/2015/07/26/flow-finish-location-you-cant-get-there-from-here/ 

Generic Apex controller extension to allow for a Visual Workflow 
to define the URL to redirect to upon completion

The Visual Workflow must have:
    a Screen Element after the url is defined and before the flow exits
    an Output Variable {!ov_WhereNext} that defines the URL
    sample TextTemplate with URL: apex/Opportunity_Lost?id={!vOppID}

Sample Visualforce Page used to call the Visual Workflow:
    <apex:page standardController="Opportunity" extensions="SetFlowReturnExtension">
        <flow:interview interview="{!aFlow}" name="Opportunity_Button_Won" finishlocation="{!finishPageRef}">
            <apex:param name="vOppID" value="{!Opportunity.Id}"/>
        </flow:interview>
    </apex:page>

*/
public with sharing class SetFlowReturnExtension{
    public final Flow.Interview.Opportunity_Button_Won aFlow {get; set;}
    public SetFlowReturnExtension(ApexPages.StandardController stdController) {}
    public String getFinishLoc() { 
         return aFlow==null? 'home/home.jsp': aFlow.ov_WhereNext; 
    }
     Public PageReference getFinishPageRef(){
        PageReference pageRef = new PageReference('/' + getfinishLoc());
        pageRef.setRedirect(true);
        return pageRef;
    }
}