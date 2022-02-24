/*
Name:
    vdf.ajax.VdfCall
Type:
    Prototype
Extends:
    vdf.ajax.SoapCall

Revisions:
    2008/01/17  Complete rewrite into the new 2.0 model. It now extends the 
    SoapCall and is named vdf.ajax.VdfCall. (HW, DAE)
    2001/01/09  Created the VdfRemoteMethodInvocation prototype. (HW, DAE)
*/

/*
@require    vdf/ajax/SoapCall.js
*/

/*
Constructor, initializes the properties with the given parameter.

@param  sWebObject      Name of the webobject that contains the function to call.
@param  sMethod         Name of the method that should be called.
@param  aParams         (optional) Array of parameters.
@param  sUrl            (default: WebService.wso) Url to the webservice.
@param  sXmlNS          (default: http://tempuri.org) Namespace for the soap xml.
*/
vdf.ajax.VdfCall = function VdfCall(sWebObject, sMethod, aParams, sUrl, sXmlNS){
    this.SoapCall("RemoteMethodInvocation", null, sUrl, sXmlNS);
    
    //  PUBLIC
    this.sWebObject = sWebObject;
    this.sMethod = sMethod;
    this.aParams = ((aParams) ? aParams : []);
    
    this.bSuppressError = false;
    this.aErrors = null;
    
    
    //  PRIVATE
    this.tResponse = null;
};
/*
The VdfCall replaces the RemoteMethodInvocation of the AJAX Library 1.X. It can 
be used to call any published method in the VDF WebApp that is inside an AJAX 
Web Business Process.

This can be a procedure or a function. A maximum of 16 parameters can be passed. 
Both parameters and return value must be simple values (string, integer, 
boolean).
*/
vdf.definePrototype("vdf.ajax.VdfCall", "vdf.ajax.SoapCall", {
    
/*
Adds a parameter. Note that they should be added in the correct order.

@param  sValue  The parameter value.
*/
addParameter : function(sValue){
    this.aParams.push(sValue);
},

/*
Augments the orrigional method of SoapCall with the functionality that adds the 
request parameters.

@return String with the SOAP XML.
@private
*/
getData : function(){
    this.addParam("sWebObject", this.sWebObject);
    this.addParam("sSessionKey", vdf.sys.cookie.get("vdfSessionKey"));
    this.addParam("sMethodName", this.sMethod);
    this.addParam("asParams", this.aParams);
    
    return this.SoapCall.prototype.getData.call(this);
},

/*
Augments the orrigional method of SoapCall with the checks for VDF errors.

@return True if no errors occurred.
@private
*/
checkErrors : function(){
    var iError;
    
    this.SoapCall.prototype.checkErrors.call(this);

    this.tResult = this.getResponseValue("TAjaxRMIResponse");
    
    if(this.bSuppressError){
        this.aErrors = this.tResult.aErrors;
    }else{
        for(iError = 0; iError < this.tResult.aErrors.length; iError++){
            vdf.errors.handle(new vdf.errors.createServerError(this.tResult.aErrors[iError], this));
        }
    }
},

/*
@return The return value of the called method.
*/
getReturnValue : function(){
    return this.tResult.sReturnValue;
}

});