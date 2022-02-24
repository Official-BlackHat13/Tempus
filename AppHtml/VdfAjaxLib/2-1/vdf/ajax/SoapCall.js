/*
Name:
    vdf.ajax.SoapCall
Type:
    Prototype
Extends:
    vdf.ajax.HttpRequest

Revisions:
    2008/01/16  Created the initial prototype with functionallity from the old 
    XmlRequest object which covered the SoapCall and the HttpRequest 
    functionallity in the 1.x versions. (HW, DAE)
*/

/*
@require    vdf/ajax/HttpRequest.js
@require    vdf/ajax/xmlSerializer.js
@require    vdf/sys/StringBuilder.js
*/

/*
Constructor that initializes the settings with the given values.

@param  sFunction   The name of the webservice method that should be called.
@param  oParams     Object with the parameters { <param1> : <value>, <param2>, 
                    <value>}.
@param  sUrl        (default: WebService.wso) Url to the webservice.
@param  sXmlNS      (default: http://tempuri.org) Namespace for the soap xml.
*/
vdf.ajax.SoapCall = function SoapCall(sFunction, oParams, sUrl, sXmlNS){
    if(typeof(sUrl) == "undefined" || sUrl === null){
        sUrl = "WebService.wso";
    }
    this.HttpRequest(sUrl);
    
    /*
    The webservice function that should be called.
    */
    this.sFunction = sFunction;
    /*
    Object with the function parameters. The property names should match the 
    parameter names.
    */
    this.oParams = ((oParams) ? oParams : {});
    /*
    The XML namespace used for the webservice call.
    */
    this.sXmlNS = ((sXmlNS) ? sXmlNS : "http://tempuri.org/");
};
/*
Represents an AJAX soap request that can be send to the server. By giving the 
function and the parameters the call is constructed. Parameters are serialized 
to XML and the returnvalue is deserialized. The functionality for sending the 
request is inherited from the vdf.ajax.HttpRequest prototoype.

The choice between vdf.ajax.SoapCall, vdf.ajax.VdfCall and vdf.ajax.JSONCall 
should depend on the type and amount of data that needs to be send and received 
from the server. The vdf.ajax.VdfCall is easier to use but is limited to simple 
types and isn't usable for larger amounts of data. The vdf.ajax.JSONCall is 
faster when receiving larger amounts of data but isn't able send complex data 
types. The vdf.ajax.SoapCall can send and receive complex data types.

Server (inside Web Service Object):
@code
Struct TCarInfo
    String sFullName
    Integer iHorsePower
    String sEngine
End_Struct


{ Published = True  }
{ Description = ""  }
Function CarDetails String sBranch String sType Returns TCarInfo
    TCarInfo tResult
    
    If (sBranch = "BMW" and sType = "X5") Begin
        Move "BMW X5" to tResult.sFullName
        Move 153 to tResult.iHorsePower
        Move "V8 3.0L" to tResult.sEngine
    End
    
    Function_Return tResult
End_Function
@code

Client:
@code
function loadCarDetails(sBranch, sType){
    var oCall;
    
    oCall = new vdf.ajax.SoapCall("AutoDetails");
    oCall.addParam("sBranch", sBranch);
    oCall.addParam("sType", sType);
    oCall.onFinished.addListener(handleCarDetails);
    oCall.send(true);
}

function handleCarDetails(oEvent){
    var oResult = oEvent.oSource.getResponseValue();
    
    if(oResult.sFullName !== ""){
        alert("Car " + oResult.sFullName + " has a " + oResult.sEngine + " with " + String(oResult.iHorsePower) + "HP");
    }else{
        alert("Car not found!");
    }
}

loadCarDetails('BMW', 'X5');
@code

*/
vdf.definePrototype("vdf.ajax.SoapCall", "vdf.ajax.HttpRequest", {

/*
Adds a parameter for the function call.

@param  sName   Name of the parameter.
@param  oValue  Value of the parameter.
*/
addParam : function(sName, oValue){
    this.oParams[sName] = oValue;
},

/*
Augments the setHeaders method with the functionality that sets the 
"Content-Type" header to "text/xml".

@param  oLoader     Reference to the XmlHttpRequest object.
@private
*/
setHeaders : function(oLoader){
    this.HttpRequest.prototype.setHeaders.call(this, oLoader);

    oLoader.setRequestHeader("Content-Type", "text/xml");
},

/*
Overrides the orrigional method of HttpRequest with the functionality to 
generate the soap request.

@return String with the SOAP XML.
@private
*/
getData : function(){
    var oXml = new vdf.sys.StringBuilder('<?xml version="1.0" encoding="utf-8"?>\n');
    
    oXml.append('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">\n');
    oXml.append("<soap:Body>\n");
    oXml.append("<");
    oXml.append(this.sFunction);
    oXml.append(' xmlns="');
    oXml.append(this.sXmlNS);
    oXml.append('">\n');
    
    oXml.append(vdf.ajax.xmlSerializer.serialize(this.oParams, false));
    
    oXml.append("</");
    oXml.append(this.sFunction);
    oXml.append(">\n");
    oXml.append("</soap:Body>\n");
    oXml.append("</soap:Envelope>\n");

    return oXml.getString();
},

/*
Checks if the webservice returned any errors after calling the checkErrors 
method from the super prototype.

@return True if no errors are found.
@private
*/
checkErrors : function(){
    var oXml, aFaults;
    
    this.HttpRequest.prototype.checkErrors.call(this, true);
    
    oXml = this.getResponseXml();
    if(oXml !== null && typeof(oXml) !== "undefined"){
        aFaults = vdf.sys.xml.find(oXml, "Fault", "soap");
        
        if(aFaults.length > 0){
            throw new vdf.errors.Error(504, "Server returned soap fault", this, [vdf.sys.xml.findContent(aFaults[0], "faultcode"),  vdf.sys.xml.findContent(aFaults[0], "faultstring")]);
        }
    }else{
        throw new vdf.errors.Error(502, "Unknown parse error", this);
    }
},

/*
Searches the result node in the response and deserializes the value into 
objects.

@param  sReturnObjectName   (optional) SOAP responses do not contain the name of 
        the return type. When deserializing objects it uses this name to 
        determine if a predefined object in the vdf.data library. This can be 
        important when willing to serialize the objects again.
@return Object presentation of the response.
*/
getResponseValue : function(sReturnObjectName){
    var aResponse = vdf.sys.xml.find(this.getResponseXml(), this.sFunction + "Result");
    
    if(aResponse.length > 0){
        return vdf.ajax.xmlSerializer.deSerialize(aResponse[0], sReturnObjectName);
    }else{
        throw new vdf.errors.Error(501, "Result node not found", this);
    }
}

});