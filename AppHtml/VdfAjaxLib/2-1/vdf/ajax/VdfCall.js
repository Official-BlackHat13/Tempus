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
The VdfCall can be used to call published methods inside Web Objects. Within the 
1.x versions of the AJAX Library this class was called RemoteMethodInvocation. 
The VdfCall is comparable to the oWebObject.call method available in ASP. The 
main difference is that it is much slower (because of the background 
communication) and it is performed Asynchronously by default. Although 
Asynchronous calls might be slightly more difficult they do help keeping 
the user interface responsive.

The main difference between the vdf.ajax.VdfCall and its super class 
vdf.ajax.SoapCall is that the vdf.ajax.VdfCall accesses the 
"RemoteMethodInvocation" method which is defined in the cAjaxWebService class. 
This method validates the session and calls the HasRights method of the session 
manager to check access before it forwards the call to the specified method of 
the specified Web Object. Opposed to the session checking and the ability to 
call published methods of regular Web Objects the VdfCall is limited to simple 
types as parameters and return value. 

The choice between vdf.ajax.VdfCall, vdf.ajax.SoapCall and vdf.ajax.JSONCall 
should depend on whether complex types need to be sent to and returned from 
the server. The vdf.ajax.VdfCall is with its session management and ability to 
call published methods of all web objects the easiest to use variant of the 
AJAX call but is limited to simple types.

Server (inside Web Object):
@code
{ Published = True  }
{ Description = ""  }
Function CarDetails String sBranch String sType Returns TCarInfo
    Function_Return "BMW X5 V8 3.0L"
End_Function
@code

Client:
@code
function loadCarDetails(sBranch, sType){
    var oCall;
    
    oCall = new vdf.ajax.VdfCall("AutoDetails");
    oCall.addParam("sBranch", sBranch);
    oCall.addParam("sType", sType);
    oCall.onFinished.addListener(handleCarDetails);
    oCall.send(true);
}

function handleCarDetails(oEvent){
    var sResult = oEvent.oSource.getReturnValue();
    
    if(sResult !== ""){
        alert(sResult);
    }else{
        alert("Car not found!");
    }
}

loadCarDetails('BMW', 'X5');
@code
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