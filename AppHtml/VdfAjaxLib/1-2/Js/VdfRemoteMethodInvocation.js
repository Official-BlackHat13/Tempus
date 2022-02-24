//
//  Class:
//      VdfRemoteMethodInvocation
//
//  Wrapper for the XmlRequest object for easilly calling published methods in 
//  web objects on the server.
//
//  Since:
//      09-01-2007
//  Changed:
//      --
//  Version:
//      0.1
//  Creator:
//      Data Access Europe (Harm Wibier)
//

//
//  Constructor of the VdfRemoteMethodInvocation object. Sets the properties.
//
//  Params:
//      bASynchronous   True if request should be send ASynchronous
//      sWebObject      VDF WebObject that contains the called method
//      sMethodName     Name of the called method
//      asParams        Array of parameters (optional)
//      oReturnFunction Function that is called when response is received 
//                      (optional) 
//      oSource         Object that makes the call (becomes context when the 
//                      return function is called) (optional)
//      sRequestURL     Request URL (optional, default: "WebService.wso")
//      sXmlNS          The namespace for the webservice (optional, default: 
//                      "http://tempuri.org/")
//      
function VdfRemoteMethodInvocation(bASynchronous, sWebObject, sMethodName, asParams, oReturnFunction, oSource, sRequestURL, sXmlNS, bSuppressError){
    //  XmlRequest props
    this.bASynchronous      = bASynchronous;
    this.sRequestURL        = (sRequestURL) ? sRequestURL : "WebService.wso" 
    this.sXmlNS             = (sXmlNS) ? sXmlNS : "http://tempuri.org/" 
       
    //  Own properties
    this.oReturnFunction    = (oReturnFunction) ? oReturnFunction : null;
    this.oSource            = (oSource) ? oSource : null;
    this.sWebObject         = (sWebObject) ? sWebObject : null;
    this.sMethodName        = (sMethodName) ? sMethodName : null;
    this.asParams           = (asParams) ? asParams : new Array();
    
    //  Error info
    this.bSuppressError     = (bSuppressError) ? true : false;
    this.sErrorTable        = null;
    this.sErrorField        = null;
    this.iErrorLine         = null;
    this.iErrorNumber       = 0;
    this.sErrorText         = null;
    
    //  Return value
    this.sReturnValue       = null;
}

//
//  Adds a parameter
//
//  Params:
//      sValue  The parameter value
//
VdfRemoteMethodInvocation.prototype.addParameter = function(sValue){
    this.asParams.push(sValue);
}

//
//  Sends the request (generates request and sens the request using the 
//  comm.XmlRequest object)
//
VdfRemoteMethodInvocation.prototype.sendCall = function(){
    var iParam, oXmlRequest;
    var sXml = new JStringBuilder();
    
    sXml.append("<sWebObject>" + this.sWebObject + "</sWebObject>\n");
    sXml.append("<sSessionKey>" + browser.cookie.get("vdfSessionKey") + "</sSessionKey>\n");
    sXml.append("<sMethodName>" + this.sMethodName + "</sMethodName>\n");
    sXml.append("<asParams>\n");
    
    for(iParam = 0; iParam < this.asParams.length; iParam++){
        sXml.append("<string>" + browser.xml.encode(this.asParams[iParam]) + "</string>\n");
    }
    
    sXml.append("</asParams>\n");
    
    oXmlRequest = new comm.XmlRequest(this.bASynchronous, "RemoteMethodInvocation", "", this.handleCall, this, this.sRequestURL, this.sXmlNS);
    oXmlRequest.sXML = sXml.toString();
    
    oXmlRequest.request();
}

//
//  Handles the response. Checks for errors, fetch responsevalue call return 
//  function.
//
//  Params:
//      oXmlRequest     The comm.xmlRequest object
//
//  PRIVATE
VdfRemoteMethodInvocation.prototype.handleCall = function(oXmlRequest){
    var sErrorMessage = "";
    
    if(oXmlRequest.iError == 0){
        oResponseXml = oXmlRequest.getResponseXml();
        
        //  Check for VDF errors
        aErrors = browser.xml.find(oResponseXml, "TAjaxError");
        if(aErrors.length > 0){
            this.sErrorTable = browser.xml.findNodeContent(aErrors[0], "sTableName").toLowerCase();
            this.sErrorField = browser.xml.findNodeContent(aErrors[0], "sColumnName").toLowerCase();
            this.iErrorLine = browser.xml.findNodeContent(aErrors[0], "iLine");
            this.iErrorNumber = parseInt(browser.xml.findNodeContent(aErrors[0], "iNumber"));
            this.sErrorText = browser.xml.findNodeContent(aErrors[0], "sErrorText");
        }
        
        //  Fetch responsevalue
        this.sReturnValue = browser.xml.findNodeContent(oResponseXml, "sReturnValue");
    }else{
        //  Handle request error
        this.iErrorNumber = parseInt(oXmlRequest.iError);
        this.sErrorText = oXmlRequest.sErrorMessage;
    }
    
    //  Generate and display error if needed
    if(this.iErrorNumber > 0 && !this.bSuppressError){    
        if (this.sErrorTable != "") sErrorMessage += "Table: " + this.sErrorTable;
        if (this.sErrorField != ""){
           if (sErrorMessage != "") sErrorMessage + ", "; 
           sErrorMessage += "Field: " + this.sErrorField;            
        }
        
        if (sErrorMessage != "") sErrorMessage = " (" + sErrorMessage + ")";
        sErrorMessage = this.sErrorText + sErrorMessage;
        
        alert(sErrorMessage);
    }    
    
    //  Call return function
    if(this.oReturnFunction != null){
        this.oReturnFunction.call(this.oSource, this);
    }
}

